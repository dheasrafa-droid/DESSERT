import 'dart:html' as html;
import 'dart:math';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<double> _fpsSamples = [];
  final List<double> _frameTimeSamples = [];
  final List<double> _memorySamples = [];
  final int _maxSamples = 120; // Store last 2 seconds at 60 FPS

  DateTime _lastFrameTime = DateTime.now();
  int _frameCount = 0;
  double _averageFPS = 0;
  double _averageFrameTime = 0;
  double _peakFPS = 0;
  double _lowestFPS = double.infinity;
  int _totalFrames = 0;
  DateTime _startTime = DateTime.now();

  // WebGL specific
  html.WebGl2RenderingContext? _gl;
  int _gpuMemoryUsage = 0;
  int _drawCalls = 0;
  int _triangleCount = 0;

  void initialize(html.WebGl2RenderingContext gl) {
    _gl = gl;
    _startTime = DateTime.now();
  }

  void beginFrame() {
    _drawCalls = 0;
    _triangleCount = 0;
  }

  void endFrame() {
    final now = DateTime.now();
    final frameTime = now.difference(_lastFrameTime).inMilliseconds;
    _lastFrameTime = now;

    // Calculate FPS
    final fps = frameTime > 0 ? 1000.0 / frameTime : 0;
    
    // Update statistics
    _updateSamples(fps, frameTime);
    _frameCount++;
    _totalFrames++;

    // Update peak values
    if (fps > _peakFPS) _peakFPS = fps;
    if (fps < _lowestFPS && fps > 0) _lowestFPS = fps;

    // Calculate averages
    _averageFPS = _calculateAverage(_fpsSamples);
    _averageFrameTime = _calculateAverage(_frameTimeSamples);
  }

  void _updateSamples(double fps, double frameTime) {
    _fpsSamples.add(fps);
    _frameTimeSamples.add(frameTime);

    if (_fpsSamples.length > _maxSamples) {
      _fpsSamples.removeAt(0);
      _frameTimeSamples.removeAt(0);
    }

    // Try to get memory information if available
    _updateMemorySample();
  }

  void _updateMemorySample() {
    // Web doesn't have direct memory access, but we can estimate
    if (_gl != null) {
      // This is an estimation - real memory usage would need
      // WebGL extensions that aren't always available
      final estimatedMemory = (_drawCalls * 100) + (_triangleCount * 0.1);
      _memorySamples.add(estimatedMemory);
      
      if (_memorySamples.length > _maxSamples) {
        _memorySamples.removeAt(0);
      }
    }
  }

  double _calculateAverage(List<double> samples) {
    if (samples.isEmpty) return 0;
    return samples.reduce((a, b) => a + b) / samples.length;
  }

  void recordDrawCall(int triangles) {
    _drawCalls++;
    _triangleCount += triangles;
  }

  void updateGPUMemory(int bytes) {
    _gpuMemoryUsage = bytes;
  }

  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final uptime = now.difference(_startTime);

    return {
      'fps': {
        'current': _fpsSamples.isNotEmpty ? _fpsSamples.last.round() : 0,
        'average': _averageFPS.round(),
        'peak': _peakFPS.round(),
        'lowest': _lowestFPS.round(),
      },
      'frameTime': {
        'current': _frameTimeSamples.isNotEmpty ? _frameTimeSamples.last : 0,
        'average': _averageFrameTime,
        'min': _frameTimeSamples.isNotEmpty ? _frameTimeSamples.reduce(min) : 0,
        'max': _frameTimeSamples.isNotEmpty ? _frameTimeSamples.reduce(max) : 0,
      },
      'counters': {
        'totalFrames': _totalFrames,
        'drawCalls': _drawCalls,
        'triangles': _triangleCount,
        'gpuMemoryKB': _gpuMemoryUsage,
      },
      'uptime': {
        'seconds': uptime.inSeconds,
        'formatted': _formatDuration(uptime),
      },
      'performance': _getPerformanceRating(),
    };
  }

  String _getPerformanceRating() {
    if (_averageFPS >= 58) return 'Excellent';
    if (_averageFPS >= 45) return 'Good';
    if (_averageFPS >= 30) return 'Fair';
    if (_averageFPS >= 15) return 'Poor';
    return 'Critical';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    parts.add('${seconds}s');

    return parts.join(' ');
  }

  List<double> getFpsHistory() => List.from(_fpsSamples);
  List<double> getFrameTimeHistory() => List.from(_frameTimeSamples);
  List<double> getMemoryHistory() => List.from(_memorySamples);

  void reset() {
    _fpsSamples.clear();
    _frameTimeSamples.clear();
    _memorySamples.clear();
    _frameCount = 0;
    _averageFPS = 0;
    _averageFrameTime = 0;
    _peakFPS = 0;
    _lowestFPS = double.infinity;
    _startTime = DateTime.now();
  }

  // Benchmarking utilities
  Future<Map<String, dynamic>> runBenchmark({
    required Function() benchmarkFunction,
    int iterations = 1000,
    String name = 'Benchmark',
  }) async {
    final times = <int>[];
    final memoryBefore = _gpuMemoryUsage;

    for (int i = 0; i < iterations; i++) {
      final start = DateTime.now();
      benchmarkFunction();
      final end = DateTime.now();
      times.add(end.difference(start).inMicroseconds);
    }

    times.sort();
    
    final avgTime = times.reduce((a, b) => a + b) / times.length;
    final minTime = times.first;
    final maxTime = times.last;
    final medianTime = times[times.length ~/ 2];
    final p95Time = times[(times.length * 0.95).toInt()];

    final memoryAfter = _gpuMemoryUsage;
    final memoryDelta = memoryAfter - memoryBefore;

    return {
      'name': name,
      'iterations': iterations,
      'time': {
        'average': avgTime / 1000, // Convert to ms
        'min': minTime / 1000,
        'max': maxTime / 1000,
        'median': medianTime / 1000,
        'p95': p95Time / 1000,
        'total': times.reduce((a, b) => a + b) / 1000,
      },
      'memory': {
        'before': memoryBefore,
        'after': memoryAfter,
        'delta': memoryDelta,
      },
      'opsPerSecond': 1000000 / avgTime, // Convert microseconds to seconds
    };
  }

  void logPerformanceWarning(String message, {Object? data}) {
    print('PERFORMANCE WARNING: $message');
    if (data != null) print('Data: $data');
    
    // Could send to analytics service
    _sendToAnalytics('warning', {
      'message': message,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'stats': getStats(),
    });
  }

  void _sendToAnalytics(String type, Map<String, dynamic> data) {
    // Implementation depends on analytics service
    // For now, just log to console
    print('Analytics [$type]: $data');
  }

  static bool isWebGL2Supported() {
    try {
      final canvas = html.CanvasElement();
      final gl = canvas.getContext('webgl2') as html.WebGl2RenderingContext?;
      return gl != null;
    } catch (e) {
      return false;
    }
  }

  static String getGPUInfo() {
    try {
      final canvas = html.CanvasElement();
      final gl = canvas.getContext('webgl2') as html.WebGl2RenderingContext?;
      
      if (gl == null) return 'WebGL2 not supported';
      
      final debugInfo = gl.getExtension('WEBGL_debug_renderer_info');
      if (debugInfo != null) {
        final vendor = gl.getParameter(debugInfo.UNMASKED_VENDOR_WEBGL);
        final renderer = gl.getParameter(debugInfo.UNMASKED_RENDERER_WEBGL);
        return '$vendor - $renderer';
      }
      
      return 'GPU info not available';
    } catch (e) {
      return 'Error getting GPU info: $e';
    }
  }
}

// Performance overlay widget data
class PerformanceData {
  final double currentFPS;
  final double averageFPS;
  final double frameTime;
  final int drawCalls;
  final int triangleCount;
  final int gpuMemory;
  final String performanceRating;

  PerformanceData({
    required this.currentFPS,
    required this.averageFPS,
    required this.frameTime,
    required this.drawCalls,
    required this.triangleCount,
    required this.gpuMemory,
    required this.performanceRating,
  });

  factory PerformanceData.fromMonitor(PerformanceMonitor monitor) {
    final stats = monitor.getStats();
    return PerformanceData(
      currentFPS: stats['fps']['current'].toDouble(),
      averageFPS: stats['fps']['average'].toDouble(),
      frameTime: stats['frameTime']['current'].toDouble(),
      drawCalls: stats['counters']['drawCalls'],
      triangleCount: stats['counters']['triangles'],
      gpuMemory: stats['counters']['gpuMemoryKB'],
      performanceRating: stats['performance'],
    );
  }
}
