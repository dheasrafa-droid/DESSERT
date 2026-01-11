import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import '../utils/logger.dart';
import '../events/event_dispatcher.dart';
import '../events/event_types.dart';

/// Global Engine Settings Manager
/// 
/// Manages engine-wide settings that can be modified at runtime.
/// Persists settings across sessions and dispatches change events.
class Settings extends EventDispatcher {
  static Settings? _instance;
  
  /// Singleton instance
  factory Settings() {
    _instance ??= Settings._internal();
    return _instance!;
  }
  
  final Logger _logger = Logger('Settings');
  final Map<String, dynamic> _settings = {};
  final Map<String, List<SettingValidator>> _validators = {};
  final Map<String, dynamic> _defaults = {};
  final Map<String, dynamic> _constraints = {};
  final Map<String, List<StreamSubscription>> _subscriptions = {};
  
  bool _initialized = false;
  bool _autoSave = true;
  String _storageKey = 'dsrt_engine_settings';
  
  /// Private constructor
  Settings._internal();
  
  /// Initialize settings with defaults
  Future<void> init([Map<String, dynamic>? defaultSettings]) async {
    if (_initialized) {
      _logger.warning('Settings already initialized');
      return;
    }
    
    _logger.debug('⚙️ Initializing settings...');
    
    // Set defaults
    _defaults.clear();
    _defaults.addAll(_getDefaultSettings());
    
    if (defaultSettings != null) {
      _defaults.addAll(defaultSettings);
    }
    
    // Apply defaults
    _settings.clear();
    _settings.addAll(_defaults);
    
    // Load saved settings
    await _load();
    
    // Validate all settings
    _validateAll();
    
    _initialized = true;
    
    _logger.success('✅ Settings initialized');
    dispatchEvent(SettingEvent.initialized);
  }
  
  /// Get a setting value
  dynamic get(String key, [dynamic defaultValue]) {
    if (!_initialized) {
      throw StateError('Settings not initialized. Call init() first.');
    }
    
    if (_settings.containsKey(key)) {
      return _settings[key];
    }
    
    if (defaultValue != null) {
      return defaultValue;
    }
    
    if (_defaults.containsKey(key)) {
      return _defaults[key];
    }
    
    throw ArgumentError('Setting "$key" not found');
  }
  
  /// Get setting as specific type
  T getAs<T>(String key, [T? defaultValue]) {
    final value = get(key, defaultValue);
    
    if (value is T) {
      return value;
    }
    
    // Try to convert
    try {
      if (T == int && value is num) {
        return value.toInt() as T;
      } else if (T == double && value is num) {
        return value.toDouble() as T;
      } else if (T == bool && value is String) {
        return (value.toLowerCase() == 'true') as T;
      } else if (T == String) {
        return value.toString() as T;
      } else if (T == List && value is String) {
        return json.decode(value) as T;
      } else if (T == Map && value is String) {
        return json.decode(value) as T;
      }
    } catch (e) {
      // Fall through to error
    }
    
    throw ArgumentError('Setting "$key" cannot be converted to type $T');
  }
  
  /// Set a setting value
  Future<void> set(String key, dynamic value) async {
    if (!_initialized) {
      throw StateError('Settings not initialized. Call init() first.');
    }
    
    final oldValue = _settings[key];
    
    // Validate the value
    final validationResult = _validate(key, value);
    if (!validationResult.isValid) {
      throw ArgumentError('Setting "$key" validation failed: ${validationResult.message}');
    }
    
    // Apply constraints
    final constrainedValue = _applyConstraints(key, value);
    
    // Check if value actually changed
    if (_isEqual(oldValue, constrainedValue)) {
      return;
    }
    
    // Update value
    _settings[key] = constrainedValue;
    
    _logger.debug('⚙️ Setting changed: $key = $constrainedValue');
    
    // Dispatch change event
    dispatchEvent(SettingEvent.changed, {
      'key': key,
      'oldValue': oldValue,
      'newValue': constrainedValue,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // Auto-save if enabled
    if (_autoSave) {
      await _save();
    }
  }
  
  /// Set multiple settings at once
  Future<void> setMany(Map<String, dynamic> settings) async {
    for (final entry in settings.entries) {
      await set(entry.key, entry.value);
    }
  }
  
  /// Reset a setting to its default value
  Future<void> reset(String key) async {
    if (_defaults.containsKey(key)) {
      await set(key, _defaults[key]);
    }
  }
  
  /// Reset all settings to defaults
  Future<void> resetAll() async {
    _settings.clear();
    _settings.addAll(_defaults);
    
    await _save();
    
    dispatchEvent(SettingEvent.reset);
    _logger.info('⚙️ All settings reset to defaults');
  }
  
  /// Check if a setting exists
  bool has(String key) {
    return _settings.containsKey(key);
  }
  
  /// Remove a setting (resets to default)
  Future<void> remove(String key) async {
    if (_defaults.containsKey(key)) {
      await set(key, _defaults[key]);
    } else {
      _settings.remove(key);
      await _save();
    }
  }
  
  /// Add a validator for a setting
  void addValidator(String key, SettingValidator validator) {
    if (!_validators.containsKey(key)) {
      _validators[key] = [];
    }
    _validators[key]!.add(validator);
  }
  
  /// Add a constraint for a setting
  void addConstraint(String key, dynamic min, dynamic max) {
    _constraints[key] = {'min': min, 'max': max};
  }
  
  /// Listen for changes to a specific setting
  StreamSubscription<SettingChangeEvent> watch(
    String key, 
    void Function(SettingChangeEvent) onChanged
  ) {
    final controller = StreamController<SettingChangeEvent>.broadcast();
    
    final subscription = on<SettingEvent.changed>((event) {
      final data = event.data as Map<String, dynamic>;
      if (data['key'] == key) {
        controller.add(SettingChangeEvent(
          key: key,
          oldValue: data['oldValue'],
          newValue: data['newValue'],
          timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
        ));
      }
    });
    
    // Store subscription for cleanup
    if (!_subscriptions.containsKey(key)) {
      _subscriptions[key] = [];
    }
    _subscriptions[key]!.add(subscription);
    
    return controller.stream.listen(onChanged);
  }
  
  /// Get all settings as map
  Map<String, dynamic> getAll() {
    return Map<String, dynamic>.unmodifiable(_settings);
  }
  
  /// Export settings to JSON
  String toJson() {
    return json.encode(_settings);
  }
  
  /// Import settings from JSON
  Future<void> fromJson(String jsonStr) async {
    try {
      final settings = json.decode(jsonStr) as Map<String, dynamic>;
      await setMany(settings);
    } catch (error) {
      throw FormatException('Invalid settings JSON: $error');
    }
  }
  
  /// Save settings to persistent storage
  Future<void> save() async {
    await _save();
  }
  
  /// Load settings from persistent storage
  Future<void> load() async {
    await _load();
  }
  
  /// Clear all settings from storage (keeps defaults)
  Future<void> clearStorage() async {
    await _clearStorage();
  }
  
  /// Enable/disable auto-save
  set autoSave(bool enabled) {
    _autoSave = enabled;
  }
  
  /// Set storage key
  set storageKey(String key) {
    _storageKey = key;
  }
  
  // --------------------------------------------------------------------------
  // PRIVATE METHODS
  // --------------------------------------------------------------------------
  
  Map<String, dynamic> _getDefaultSettings() {
    return {
      // Rendering
      'renderer.antialias': true,
      'renderer.alpha': true,
      'renderer.depth': true,
      'renderer.stencil': false,
      'renderer.powerPreference': 'high-performance',
      'renderer.maxLights': 8,
      'renderer.shadowMap.enabled': true,
      'renderer.shadowMap.type': 'pcf', // pcf, pcfsoft, basic
      'renderer.shadowMap.size': 512,
      'renderer.precision': 'highp',
      
      // Quality
      'quality.texture': 'high', // low, medium, high, ultra
      'quality.shadows': 'medium',
      'quality.antialiasing': 'msaa4x', // none, fxaa, msaa2x, msaa4x, smaa
      'quality.postProcessing': true,
      'quality.ambientOcclusion': true,
      'quality.reflections': true,
      'quality.particles': true,
      
      // Performance
      'performance.targetFPS': 60,
      'performance.vsync': true,
      'performance.culling': true,
      'performance.lod.enabled': true,
      'performance.lod.distances': [10, 25, 50, 100],
      'performance.instancing': true,
      'performance.frustumCulling': true,
      'performance.occlusionCulling': false,
      
      // Graphics
      'graphics.resolution.scale': 1.0,
      'graphics.resolution.width': 1920,
      'graphics.resolution.height': 1080,
      'graphics.resolution.fullscreen': false,
      'graphics.resolution.aspectRatio': 'auto',
      'graphics.brightness': 1.0,
      'graphics.contrast': 1.0,
      'graphics.saturation': 1.0,
      'graphics.gamma': 2.2,
      
      // Display
      'display.uiScale': 1.0,
      'display.uiOpacity': 1.0,
      'display.showFPS': false,
      'display.showStats': false,
      'display.showWireframe': false,
      'display.showNormals': false,
      'display.showBoundingBoxes': false,
      'display.showAxes': false,
      'display.showGrid': false,
      
      // Camera
      'camera.fov': 60.0,
      'camera.near': 0.1,
      'camera.far': 1000.0,
      'camera.mouseSensitivity': 1.0,
      'camera.invertY': false,
      'camera.smoothness': 0.1,
      
      // Audio
      'audio.masterVolume': 1.0,
      'audio.musicVolume': 0.8,
      'audio.sfxVolume': 1.0,
      'audio.voiceVolume': 1.0,
      'audio.spatialAudio': true,
      'audio.quality': 'high', // low, medium, high
      
      // Input
      'input.mouse.sensitivity': 1.0,
      'input.mouse.acceleration': false,
      'input.keyboard.repeatDelay': 500,
      'input.keyboard.repeatRate': 30,
      'input.gamepad.deadzone': 0.15,
      'input.gamepad.vibration': true,
      'input.touch.sensitivity': 1.0,
      
      // Physics
      'physics.gravity': 9.81,
      'physics.substeps': 1,
      'physics.solverIterations': 10,
      'physics.debug.enabled': false,
      'physics.debug.wireframe': false,
      'physics.debug.aabbs': false,
      'physics.debug.contactPoints': false,
      
      // Network
      'network.maxBandwidth': 1024, // KB/s
      'network.compression': true,
      'network.timeout': 30,
      'network.reconnectAttempts': 3,
      'network.updateRate': 20, // Hz
      
      // AI
      'ai.updateRate': 10, // Hz
      'ai.maxAgents': 100,
      'ai.debug.pathfinding': false,
      'ai.debug.states': false,
      'ai.debug.perception': false,
      
      // Environment
      'environment.timeScale': 1.0,
      'environment.dayLength': 86400, // seconds
      'environment.weather.enabled': true,
      'environment.weather.intensity': 0.5,
      'environment.fog.enabled': true,
      'environment.fog.density': 0.00025,
      'environment.wind.speed': 1.0,
      'environment.wind.direction': 0.0,
      
      // Development
      'dev.console.enabled': false,
      'dev.console.level': 'info', // debug, info, warning, error
      'dev.profiler.enabled': false,
      'dev.logging.level': 'info',
      'dev.logging.toFile': false,
      'dev.logging.maxSize': 10, // MB
      'dev.breakOnError': false,
      'dev.breakOnWarning': false,
      
      // System
      'system.language': 'en',
      'system.region': 'US',
      'system.timezone': 'UTC',
      'system.units': 'metric', // metric, imperial
      'system.dateFormat': 'yyyy-MM-dd',
      'system.timeFormat': 'HH:mm:ss',
      'system.currency': 'USD',
      
      // Storage
      'storage.cache.enabled': true,
      'storage.cache.size': 256, // MB
      'storage.cache.autoClear': true,
      'storage.cache.clearInterval': 3600, // seconds
      'storage.save.autoSave': true,
      'storage.save.interval': 300, // seconds
      'storage.save.backupCount': 5,
      
      // Accessibility
      'accessibility.colorBlindMode': 'none', // none, protanopia, deuteranopia, tritanopia
      'accessibility.highContrast': false,
      'accessibility.largeText': false,
      'accessibility.subtitles': true,
      'accessibility.subtitleSize': 1.0,
      'accessibility.captions': false,
      
      // Advanced
      'advanced.worker.enabled': true,
      'advanced.worker.count': 2,
      'advanced.memory.warningThreshold': 512, // MB
      'advanced.memory.criticalThreshold': 768, // MB
      'advanced.memory.autoCleanup': true,
      'advanced.shaderCache.enabled': true,
      'advanced.textureCompression.enabled': true,
      'advanced.geometryCompression.enabled': false,
    };
  }
  
  ValidationResult _validate(String key, dynamic value) {
    // Check validators
    if (_validators.containsKey(key)) {
      for (final validator in _validators[key]!) {
        final result = validator.validate(key, value);
        if (!result.isValid) {
          return result;
        }
      }
    }
    
    // Type-specific validation
    final defaultValue = _defaults[key];
    if (defaultValue != null) {
      final defaultType = defaultValue.runtimeType;
      final valueType = value.runtimeType;
      
      // Basic type checking
      if (defaultType != valueType) {
        // Allow numeric conversions
        if (defaultType == int && value is num) {
          // OK
        } else if (defaultType == double && value is num) {
          // OK
        } else if (defaultType == String && value is! String) {
          return ValidationResult(false, 'Setting "$key" must be a string');
        } else if (defaultType == bool && value is! bool) {
          return ValidationResult(false, 'Setting "$key" must be a boolean');
        } else if (defaultType == List && value is! List) {
          return ValidationResult(false, 'Setting "$key" must be a list');
        } else if (defaultType == Map && value is! Map) {
          return ValidationResult(false, 'Setting "$key" must be a map');
        }
      }
    }
    
    return ValidationResult.valid();
  }
  
  void _validateAll() {
    for (final entry in _settings.entries) {
      final result = _validate(entry.key, entry.value);
      if (!result.isValid) {
        _logger.warning('Setting validation failed for "${entry.key}": ${result.message}');
        // Reset to default if invalid
        if (_defaults.containsKey(entry.key)) {
          _settings[entry.key] = _defaults[entry.key];
        }
      }
    }
  }
  
  dynamic _applyConstraints(String key, dynamic value) {
    if (!_constraints.containsKey(key)) {
      return value;
    }
    
    final constraint = _constraints[key] as Map<String, dynamic>;
    final min = constraint['min'];
    final max = constraint['max'];
    
    if (value is num) {
      if (min != null && value < min) {
        _logger.debug('Constrained $key from $value to min $min');
        return min;
      }
      if (max != null && value > max) {
        _logger.debug('Constrained $key from $value to max $max');
        return max;
      }
    }
    
    return value;
  }
  
  bool _isEqual(dynamic a, dynamic b) {
    if (a == b) return true;
    
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_isEqual(a[i], b[i])) return false;
      }
      return true;
    }
    
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_isEqual(a[key], b[key])) return false;
      }
      return true;
    }
    
    return false;
  }
  
  Future<void> _save() async {
    try {
      final jsonStr = toJson();
      
      // Platform-specific storage
      if (isWeb) {
        // Web: localStorage
        window.localStorage[_storageKey] = jsonStr;
      } else {
        // Native: File storage
        // TODO: Implement file-based storage for native platforms
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(_storageKey, jsonStr);
      }
      
      _logger.debug('💾 Settings saved');
      dispatchEvent(SettingEvent.saved);
      
    } catch (error) {
      _logger.error('Failed to save settings: $error');
      dispatchEvent(SettingEvent.error, {'error': error});
    }
  }
  
  Future<void> _load() async {
    try {
      String? jsonStr;
      
      // Platform-specific loading
      if (isWeb) {
        // Web: localStorage
        jsonStr = window.localStorage[_storageKey];
      } else {
        // Native: File storage
        // TODO: Implement file-based loading for native platforms
        final prefs = await SharedPreferences.getInstance();
        jsonStr = prefs.getString(_storageKey);
      }
      
      if (jsonStr != null) {
        final loadedSettings = json.decode(jsonStr) as Map<String, dynamic>;
        
        // Merge with current settings (don't overwrite defaults for missing keys)
        for (final entry in loadedSettings.entries) {
          if (_defaults.containsKey(entry.key)) {
            _settings[entry.key] = entry.value;
          }
        }
        
        _logger.debug('📂 Settings loaded');
        dispatchEvent(SettingEvent.loaded);
      }
      
    } catch (error) {
      _logger.error('Failed to load settings: $error');
      dispatchEvent(SettingEvent.error, {'error': error});
    }
  }
  
  Future<void> _clearStorage() async {
    try {
      if (isWeb) {
        window.localStorage.remove(_storageKey);
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove(_storageKey);
      }
      
      _logger.debug('🗑️ Settings storage cleared');
      
    } catch (error) {
      _logger.error('Failed to clear settings storage: $error');
    }
  }
  
  // Platform detection
  bool get isWeb => !isMobile && !isDesktop;
  bool get isMobile => isAndroid || isIOS;
  bool get isDesktop => isWindows || isMacOS || isLinux;
  bool get isAndroid => false; // TODO: Implement platform detection
  bool get isIOS => false;
  bool get isWindows => false;
  bool get isMacOS => false;
  bool get isLinux => false;
  
  @override
  void dispose() {
    // Clean up subscriptions
    for (final subscriptions in _subscriptions.values) {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    }
    _subscriptions.clear();
    
    super.dispose();
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? message;
  
  ValidationResult(this.isValid, [this.message]);
  
  factory ValidationResult.valid() {
    return ValidationResult(true);
  }
  
  factory ValidationResult.invalid(String message) {
    return ValidationResult(false, message);
  }
}

/// Setting validator interface
abstract class SettingValidator {
  ValidationResult validate(String key, dynamic value);
}

/// Setting change event
class SettingChangeEvent {
  final String key;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime timestamp;
  
  SettingChangeEvent({
    required this.key,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'SettingChangeEvent($key: $oldValue -> $newValue)';
  }
}

/// Setting events
class SettingEvent {
  static const String initialized = 'settings:initialized';
  static const String changed = 'settings:changed';
  static const String saved = 'settings:saved';
  static const String loaded = 'settings:loaded';
  static const String reset = 'settings:reset';
  static const String error = 'settings:error';
}
