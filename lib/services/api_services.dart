import 'dart:convert';
import 'dart:html' as html;
import 'package:vector_math/vector_math_64.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = 'https://api.dessert-engine.com/v1';
  final Duration _timeout = Duration(seconds: 10);
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Authentication token
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    _headers['Authorization'] = 'Bearer $token';
  }

  // Scene Management API
  Future<List<Map<String, dynamic>>> getScenes() async {
    return await _get('/scenes');
  }

  Future<Map<String, dynamic>> getScene(String id) async {
    return await _get('/scenes/$id');
  }

  Future<Map<String, dynamic>> saveScene(Map<String, dynamic> sceneData) async {
    return await _post('/scenes', sceneData);
  }

  Future<void> deleteScene(String id) async {
    await _delete('/scenes/$id');
  }

  // Model Library API
  Future<List<Map<String, dynamic>>> getModels() async {
    return await _get('/models');
  }

  Future<Map<String, dynamic>> uploadModel(
    String name,
    List<double> vertices,
    List<int> indices,
    Vector4? color,
  ) async {
    final data = {
      'name': name,
      'vertices': vertices,
      'indices': indices,
      'color': color != null ? [color.x, color.y, color.z, color.w] : null,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return await _post('/models', data);
  }

  // Shader Library API
  Future<List<Map<String, dynamic>>> getShaders() async {
    return await _get('/shaders');
  }

  Future<Map<String, dynamic>> saveShader(
    String name,
    String vertexSource,
    String fragmentSource,
  ) async {
    final data = {
      'name': name,
      'vertexSource': vertexSource,
      'fragmentSource': fragmentSource,
      'type': 'custom',
    };
    
    return await _post('/shaders', data);
  }

  // Asset Management API
  Future<String> uploadTexture(
    String name,
    html.File file,
  ) async {
    final formData = html.FormData();
    formData.appendBlob('file', file, name);
    formData.append('name', name);
    
    final response = await _upload('/textures/upload', formData);
    return response['url'];
  }

  Future<List<Map<String, dynamic>>> getTextures() async {
    return await _get('/textures');
  }

  // User Preferences API
  Future<Map<String, dynamic>> savePreferences(
    Map<String, dynamic> preferences,
  ) async {
    return await _post('/user/preferences', preferences);
  }

  Future<Map<String, dynamic>> getPreferences() async {
    return await _get('/user/preferences');
  }

  // Analytics API
  Future<void> sendAnalytics(
    String event,
    Map<String, dynamic> data,
  ) async {
    final payload = {
      'event': event,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'userAgent': html.window.navigator.userAgent,
      'platform': _getPlatform(),
    };
    
    await _post('/analytics', payload);
  }

  // Backup/Restore API
  Future<Map<String, dynamic>> createBackup(
    Map<String, dynamic> backupData,
  ) async {
    return await _post('/backup', backupData);
  }

  Future<Map<String, dynamic>> restoreBackup(String backupId) async {
    return await _get('/backup/$backupId');
  }

  // Community API
  Future<List<Map<String, dynamic>>> getCommunityScenes() async {
    return await _get('/community/scenes');
  }

  Future<Map<String, dynamic>> shareScene(String sceneId) async {
    return await _post('/community/scenes/$sceneId/share', {});
  }

  // Private HTTP methods
  Future<dynamic> _get(String endpoint) async {
    final url = '$_baseUrl$endpoint';
    final response = await html.HttpRequest.request(
      url,
      method: 'GET',
      requestHeaders: _headers,
    ).timeout(_timeout);

    return json.decode(response.responseText!);
  }

  Future<dynamic> _post(String endpoint, Map<String, dynamic> data) async {
    final url = '$_baseUrl$endpoint';
    final response = await html.HttpRequest.request(
      url,
      method: 'POST',
      requestHeaders: _headers,
      sendData: json.encode(data),
    ).timeout(_timeout);

    return json.decode(response.responseText!);
  }

  Future<dynamic> _put(String endpoint, Map<String, dynamic> data) async {
    final url = '$_baseUrl$endpoint';
    final response = await html.HttpRequest.request(
      url,
      method: 'PUT',
      requestHeaders: _headers,
      sendData: json.encode(data),
    ).timeout(_timeout);

    return json.decode(response.responseText!);
  }

  Future<void> _delete(String endpoint) async {
    final url = '$_baseUrl$endpoint';
    await html.HttpRequest.request(
      url,
      method: 'DELETE',
      requestHeaders: _headers,
    ).timeout(_timeout);
  }

  Future<dynamic> _upload(String endpoint, html.FormData formData) async {
    final url = '$_baseUrl$endpoint';
    final response = await html.HttpRequest.request(
      url,
      method: 'POST',
      sendData: formData,
    ).timeout(_timeout);

    return json.decode(response.responseText!);
  }

  String _getPlatform() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    
    if (userAgent.contains('mobile')) return 'mobile';
    if (userAgent.contains('tablet')) return 'tablet';
    if (userAgent.contains('windows')) return 'windows';
    if (userAgent.contains('mac')) return 'mac';
    if (userAgent.contains('linux')) return 'linux';
    
    return 'web';
  }

  // Error handling
  void handleError(dynamic error) {
    print('API Error: $error');
    
    // Could show user-friendly error message
    _showErrorNotification(error.toString());
    
    // Send error to analytics
    _sendErrorToAnalytics(error);
  }

  void _showErrorNotification(String message) {
    // Implementation depends on UI framework
    print('Error Notification: $message');
  }

  void _sendErrorToAnalytics(dynamic error) {
    // Send error to backend for monitoring
    final data = {
      'error': error.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'url': html.window.location.href,
    };
    
    // Fire and forget - don't await
    _post('/analytics/errors', data).catchError((_) {});
  }

  // Local storage fallback
  Future<void> saveToLocalStorage(
    String key,
    Map<String, dynamic> data,
  ) async {
    try {
      final jsonString = json.encode(data);
      html.window.localStorage[key] = jsonString;
    } catch (e) {
      print('Failed to save to local storage: $e');
    }
  }

  Future<Map<String, dynamic>?> loadFromLocalStorage(String key) async {
    try {
      final jsonString = html.window.localStorage[key];
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Failed to load from local storage: $e');
    }
    return null;
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await html.HttpRequest.request(
        '$_baseUrl/health',
        method: 'GET',
      ).timeout(Duration(seconds: 5));
      
      return response.status == 200;
    } catch (e) {
      return false;
    }
  }

  // Connection status
  bool get isOnline => html.window.navigator.onLine;

  // Event listeners for connection changes
  void setupConnectionListeners({
    required VoidCallback onOnline,
    required VoidCallback onOffline,
  }) {
    html.window.addEventListener('online', (event) => onOnline());
    html.window.addEventListener('offline', (event) => onOffline());
  }

  // Queue for offline operations
  final List<Map<String, dynamic>> _offlineQueue = [];

  void queueOfflineOperation(
    String endpoint,
    String method,
    Map<String, dynamic> data,
  ) {
    _offlineQueue.add({
      'endpoint': endpoint,
      'method': method,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Save queue to local storage
    saveToLocalStorage('offline_queue', {'queue': _offlineQueue});
  }

  Future<void> processOfflineQueue() async {
    if (!isOnline || _offlineQueue.isEmpty) return;
    
    for (final operation in List.from(_offlineQueue)) {
      try {
        switch (operation['method']) {
          case 'POST':
            await _post(operation['endpoint'], operation['data']);
            break;
          case 'PUT':
            await _put(operation['endpoint'], operation['data']);
            break;
          case 'DELETE':
            await _delete(operation['endpoint']);
            break;
        }
        
        _offlineQueue.remove(operation);
      } catch (e) {
        print('Failed to process offline operation: $e');
        break; // Stop processing if we encounter an error
      }
    }
    
    // Update local storage
    saveToLocalStorage('offline_queue', {'queue': _offlineQueue});
  }
}
