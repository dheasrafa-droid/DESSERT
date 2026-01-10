import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Local Storage Keys
  static const String _keySettings = 'dessert_engine_settings';
  static const String _keyScenes = 'dessert_engine_scenes';
  static const String _keyModels = 'dessert_engine_models';
  static const String _keyShaders = 'dessert_engine_shaders';
  static const String _keyPreferences = 'dessert_engine_preferences';
  static const String _keyRecent = 'dessert_engine_recent';
  static const String _keyCache = 'dessert_engine_cache';

  // IndexedDB database
  late html.Database _db;
  bool _dbInitialized = false;
  final String _dbName = 'DessertEngineDB';
  final int _dbVersion = 1;

  Future<void> initialize() async {
    try {
      // Initialize IndexedDB
      await _initIndexedDB();
      _dbInitialized = true;
    } catch (e) {
      print('Failed to initialize IndexedDB: $e');
      _dbInitialized = false;
    }
  }

  Future<void> _initIndexedDB() async {
    // Request database
    _db = await html.window.indexedDB!.open(
      _dbName,
      version: _dbVersion,
      onUpgradeNeeded: (html.VersionChangeEvent e) {
        final db = (e.target as html.IdbOpenDbRequest).result as html.Database;
        
        // Create object stores
        if (!db.objectStoreNames.contains('scenes')) {
          final sceneStore = db.createObjectStore('scenes', keyPath: 'id');
          sceneStore.createIndex('name', 'name', unique: false);
          sceneStore.createIndex('created', 'created', unique: false);
        }
        
        if (!db.objectStoreNames.contains('models')) {
          final modelStore = db.createObjectStore('models', keyPath: 'id');
          modelStore.createIndex('type', 'type', unique: false);
          modelStore.createIndex('vertices', 'vertexCount', unique: false);
        }
        
        if (!db.objectStoreNames.contains('shaders')) {
          final shaderStore = db.createObjectStore('shaders', keyPath: 'id');
          shaderStore.createIndex('name', 'name', unique: true);
        }
        
        if (!db.objectStoreNames.contains('textures')) {
          final textureStore = db.createObjectStore('textures', keyPath: 'id');
          textureStore.createIndex('name', 'name', unique: true);
        }
        
        if (!db.objectStoreNames.contains('projects')) {
          db.createObjectStore('projects', keyPath: 'id');
        }
      },
    );
  }

  // Scene Management
  Future<void> saveScene(Map<String, dynamic> scene) async {
    try {
      if (_dbInitialized) {
        // Save to IndexedDB
        final transaction = _db.transaction(['scenes'], 'readwrite');
        final store = transaction.objectStore('scenes');
        await store.put(scene);
      } else {
        // Fallback to localStorage
        final scenes = await getScenes();
        final index = scenes.indexWhere((s) => s['id'] == scene['id']);
        
        if (index >= 0) {
          scenes[index] = scene;
        } else {
          scenes.add(scene);
        }
        
        html.window.localStorage[_keyScenes] = json.encode(scenes);
      }
      
      // Update recent scenes
      await _addToRecent('scene', scene['id'], scene['name']);
    } catch (e) {
      print('Failed to save scene: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getScenes() async {
    try {
      if (_dbInitialized) {
        final transaction = _db.transaction(['scenes'], 'readonly');
        final store = transaction.objectStore('scenes');
        final request = store.getAll();
        
        await request.onSuccess.first;
        return request.result as List<Map<String, dynamic>>;
      } else {
        final jsonString = html.window.localStorage[_keyScenes];
        if (jsonString != null) {
          final list = json.decode(jsonString) as List;
          return list.map((item) => item as Map<String, dynamic>).toList();
        }
      }
    } catch (e) {
      print('Failed to get scenes: $e');
    }
    
    return [];
  }

  Future<Map<String, dynamic>?> getScene(String id) async {
    try {
      if (_dbInitialized) {
        final transaction = _db.transaction(['scenes'], 'readonly');
        final store = transaction.objectStore('scenes');
        final request = store.getObject(id);
        
        await request.onSuccess.first;
        return request.result as Map<String, dynamic>?;
      } else {
        final scenes = await getScenes();
        return scenes.firstWhere((scene) => scene['id'] == id);
      }
    } catch (e) {
      print('Failed to get scene: $e');
      return null;
    }
  }

  Future<void> deleteScene(String id) async {
    try {
      if (_dbInitialized) {
        final transaction = _db.transaction(['scenes'], 'readwrite');
        final store = transaction.objectStore('scenes');
        await store.delete(id);
      } else {
        final scenes = await getScenes();
        scenes.removeWhere((scene) => scene['id'] == id);
        html.window.localStorage[_keyScenes] = json.encode(scenes);
      }
    } catch (e) {
      print('Failed to delete scene: $e');
      throw e;
    }
  }

  // Model Management
  Future<void> saveModel(Map<String, dynamic> model) async {
    try {
      if (_dbInitialized) {
        final transaction = _db.transaction(['models'], 'readwrite');
        final store = transaction.objectStore('models');
        await store.put(model);
      } else {
        final models = await getModels();
        final index = models.indexWhere((m) => m['id'] == model['id']);
        
        if (index >= 0) {
          models[index] = model;
        } else {
          models.add(model);
        }
        
        html.window.localStorage[_keyModels] = json.encode(models);
      }
    } catch (e) {
      print('Failed to save model: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getModels() async {
    try {
      if (_dbInitialized) {
        final transaction = _db.transaction(['models'], 'readonly');
        final store = transaction.objectStore('models');
        final request = store.getAll();
        
        await request.onSuccess.first;
        return request.result as List<Map<String, dynamic>>;
      } else {
        final jsonString = html.window.localStorage[_keyModels];
        if (jsonString != null) {
          final list = json.decode(jsonString) as List;
          return list.map((item) => item as Map<String, dynamic>).toList();
        }
      }
    } catch (e) {
      print('Failed to get models: $e');
    }
    
    return [];
  }

  // Binary Data Storage (for large assets)
  Future<void> saveBinaryData(
    String key,
    Uint8List data, {
    String type = 'binary',
  }) async {
    try {
      if (_dbInitialized) {
        final transaction = _db.transaction(['binary_data'], 'readwrite');
        final store = transaction.objectStore('binary_data');
        await store.put({
          'id': key,
          'data': data,
          'type': type,
          'size': data.length,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        // Convert to base64 for localStorage
        final base64Data = base64.encode(data);
        final entry = {
          'data': base64Data,
          'type': type,
          'size': data.length,
          'timestamp': DateTime.now().toIso8601String(),
        };
        
        html.window.localStorage[key] = json.encode(entry);
      }
    } catch (e) {
      print('Failed to save binary data: $e');
      throw e;
    }
  }

  Future<Uint8List?> getBinaryData(String key) async {
    try {
      if (_dbInitialized) {
        final transaction = _db.transaction(['binary_data'], 'readonly');
        final store = transaction.objectStore('binary_data');
        final request = store.getObject(key);
        
        await request.onSuccess.first;
        final result = request.result as Map<String, dynamic>?;
        
        if (result != null) {
          return result['data'] as Uint8List;
        }
      } else {
        final jsonString = html.window.localStorage[key];
        if (jsonString != null) {
          final entry = json.decode(jsonString) as Map<String, dynamic>;
          final base64Data = entry['data'] as String;
          return base64.decode(base64Data);
        }
      }
    } catch (e) {
      print('Failed to get binary data: $e');
    }
    
    return null;
  }

  // Settings Management
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      html.window.localStorage[_keySettings] = json.encode(settings);
    } catch (e) {
      print('Failed to save settings: $e');
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final jsonString = html.window.localStorage[_keySettings];
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Failed to get settings: $e');
    }
    
    return {
      'theme': 'dark',
      'language': 'en',
      'autoSave': true,
      'autoSaveInterval': 30,
      'renderQuality': 'high',
      'shadows': true,
      'antiAliasing': true,
    };
  }

  // Recent Items Management
  Future<void> _addToRecent(String type, String id, String name) async {
    try {
      final recent = await getRecentItems();
      
      // Remove if already exists
      recent.removeWhere((item) => item['id'] == id && item['type'] == type);
      
      // Add to beginning
      recent.insert(0, {
        'type': type,
        'id': id,
        'name': name,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Keep only last 10 items
      if (recent.length > 10) {
        recent.removeRange(10, recent.length);
      }
      
      html.window.localStorage[_keyRecent] = json.encode(recent);
    } catch (e) {
      print('Failed to add to recent: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentItems() async {
    try {
      final jsonString = html.window.localStorage[_keyRecent];
      if (jsonString != null) {
        final list = json.decode(jsonString) as List;
        return list.map((item) => item as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print('Failed to get recent items: $e');
    }
    
    return [];
  }

  // Cache Management
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    try {
      final cache = await getCache();
      cache[key] = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      html.window.localStorage[_keyCache] = json.encode(cache);
    } catch (e) {
      print('Failed to cache data: $e');
    }
  }

  Future<Map<String, dynamic>> getCache() async {
    try {
      final jsonString = html.window.localStorage[_keyCache];
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Failed to get cache: $e');
    }
    
    return {};
  }

  Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      final cache = await getCache();
      final cached = cache[key] as Map<String, dynamic>?;
      
      if (cached != null) {
        final timestamp = DateTime.parse(cached['timestamp']);
        final age = DateTime.now().difference(timestamp);
        
        // Return if cache is less than 1 hour old
        if (age.inHours < 1) {
          return cached['data'] as Map<String, dynamic>;
        } else {
          // Remove expired cache
          cache.remove(key);
          html.window.localStorage[_keyCache] = json.encode(cache);
        }
      }
    } catch (e) {
      print('Failed to get cached data: $e');
    }
    
    return null;
  }

  // Export/Import
  Future<String> exportData() async {
    try {
      final data = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'scenes': await getScenes(),
        'models': await getModels(),
        'settings': await getSettings(),
        'recent': await getRecentItems(),
      };
      
      return json.encode(data);
    } catch (e) {
      print('Failed to export data: $e');
      throw e;
    }
  }

  Future<void> importData(String jsonString) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      // Validate version
      final version = data['version'] as String;
      if (!version.startsWith('1.')) {
        throw Exception('Unsupported version: $version');
      }
      
      // Import scenes
      if (data.containsKey('scenes')) {
        final scenes = data['scenes'] as List;
        for (final scene in scenes) {
          await saveScene(scene as Map<String, dynamic>);
        }
      }
      
      // Import models
      if (data.containsKey('models')) {
        final models = data['models'] as List;
        for (final model in models) {
          await saveModel(model as Map<String, dynamic>);
        }
      }
      
      // Import settings
      if (data.containsKey('settings')) {
        await saveSettings(data['settings'] as Map<String, dynamic>);
      }
      
      print('Data imported successfully');
    } catch (e) {
      print('Failed to import data: $e');
      throw e;
    }
  }

  // Storage Statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      int totalSize = 0;
      int itemCount = 0;
      
      // Calculate localStorage size
      for (int i = 0; i < html.window.localStorage.length; i++) {
        final key = html.window.localStorage.key(i)!;
        final value = html.window.localStorage[key]!;
        totalSize += key.length + value.length;
        itemCount++;
      }
      
      return {
        'totalSize': totalSize,
        'itemCount': itemCount,
        'quota': 5 * 1024 * 1024, // 5MB typical localStorage limit
        'usagePercentage': (totalSize / (5 * 1024 * 1024)) * 100,
        'lastBackup': await _getLastBackupDate(),
      };
    } catch (e) {
      print('Failed to get storage stats: $e');
      return {
        'totalSize': 0,
        'itemCount': 0,
        'quota': 0,
        'usagePercentage': 0,
        'lastBackup': null,
      };
    }
  }

  Future<DateTime?> _getLastBackupDate() async {
    try {
      final cache = await getCache();
      final backupInfo = cache['lastBackup'] as Map<String, dynamic>?;
      
      if (backupInfo != null) {
        return DateTime.parse(backupInfo['timestamp']);
      }
    } catch (e) {
      print('Failed to get last backup date: $e');
    }
    
    return null;
  }

  // Cleanup
  Future<void> cleanup() async {
    try {
      // Clear expired cache
      final cache = await getCache();
      final now = DateTime.now();
      final keysToRemove = <String>[];
      
      for (final key in cache.keys) {
        final entry = cache[key] as Map<String, dynamic>;
        final timestamp = DateTime.parse(entry['timestamp']);
        
        if (now.difference(timestamp).inDays > 7) {
          keysToRemove.add(key);
        }
      }
      
      for (final key in keysToRemove) {
        cache.remove(key);
      }
      
      html.window.localStorage[_keyCache] = json.encode(cache);
      
      print('Cleanup completed, removed ${keysToRemove.length} expired items');
    } catch (e) {
      print('Failed to cleanup storage: $e');
    }
  }

  // Backup
  Future<void> createBackup() async {
    try {
      final backupData = await exportData();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupKey = 'backup_$timestamp';
      
      await saveBinaryData(backupKey, utf8.encode(backupData) as Uint8List);
      
      // Update last backup info
      final cache = await getCache();
      cache['lastBackup'] = {
        'timestamp': DateTime.now().toIso8601String(),
        'key': backupKey,
        'size': backupData.length,
      };
      
      html.window.localStorage[_keyCache] = json.encode(cache);
      
      print('Backup created: $backupKey');
    } catch (e) {
      print('Failed to create backup: $e');
      throw e;
    }
  }
}
