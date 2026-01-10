import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'renderer.dart';
import 'scene_manager.dart';
import 'shader_library.dart';

class DessertEngine {
  late html.CanvasElement _canvas;
  late html.WebGl2RenderingContext _gl;
  late Renderer _renderer;
  late SceneManager _sceneManager;
  bool _initialized = false;
  bool _isRunning = false;
  DateTime _lastFrameTime = DateTime.now();
  double _fps = 0;

  bool get isInitialized => _initialized;
  bool get isRunning => _isRunning;
  double get fps => _fps;

  Future<void> initialize() async {
    try {
      // Setup WebGL2 canvas
      _canvas = html.CanvasElement()
        ..id = 'dessert-canvas'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.left = '0';

      html.document.body?.children.add(_canvas);

      // Get WebGL2 context
      _gl = _canvas.getContext('webgl2') as html.WebGl2RenderingContext;
      if (_gl == null) {
        throw Exception('WebGL2 not supported');
      }

      // Initialize subsystems
      await ShaderLibrary.initialize(_gl);
      _renderer = Renderer(_gl);
      _sceneManager = SceneManager(_gl);

      // Configure WebGL
      _gl.enable(_gl.DEPTH_TEST);
      _gl.enable(_gl.CULL_FACE);
      _gl.cullFace(_gl.BACK);
      _gl.frontFace(_gl.CCW);
      _gl.clearColor(0.0, 0.0, 0.0, 1.0);

      _initialized = true;
      _startRenderLoop();
    } catch (e) {
      print('Engine initialization failed: $e');
      rethrow;
    }
  }

  void _startRenderLoop() {
    _isRunning = true;
    _requestAnimationFrame();
  }

  void _requestAnimationFrame() {
    html.window.requestAnimationFrame((_) {
      if (_isRunning && _initialized) {
        _renderFrame();
        _requestAnimationFrame();
      }
    });
  }

  void _renderFrame() {
    final now = DateTime.now();
    final deltaTime = now.difference(_lastFrameTime).inMilliseconds / 1000.0;
    _lastFrameTime = now;

    // Calculate FPS
    _fps = deltaTime > 0 ? 1.0 / deltaTime : 0;

    // Update scene
    _sceneManager.update(deltaTime);

    // Render
    _gl.viewport(0, 0, _canvas.width!, _canvas.height!);
    _gl.clear(_gl.COLOR_BUFFER_BIT | _gl.DEPTH_BUFFER_BIT);

    _renderer.render(_sceneManager.currentScene);

    // Update canvas size if needed
    _updateCanvasSize();
  }

  void _updateCanvasSize() {
    final width = html.window.innerWidth!;
    final height = html.window.innerHeight!;

    if (_canvas.width != width || _canvas.height != height) {
      _canvas.width = width;
      _canvas.height = height;
      _sceneManager.camera.aspect = width / height;
      _sceneManager.camera.updateProjectionMatrix();
    }
  }

  void dispose() {
    _isRunning = false;
    _sceneManager.dispose();
    _renderer.dispose();
    _canvas.remove();
  }

  // Public API for interaction
  void setScene(String sceneId) {
    _sceneManager.loadScene(sceneId);
  }

  void addModel(Vector3 position, Vector3 rotation, Vector3 scale) {
    _sceneManager.addModel(position, rotation, scale);
  }

  Map<String, dynamic> getStats() {
    return {
      'fps': _fps.round(),
      'triangles': _sceneManager.triangleCount,
      'models': _sceneManager.modelCount,
      'memory': _renderer.gpuMemoryUsage,
    };
  }
}
