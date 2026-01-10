import 'dart:html' as html;
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

class SceneManager {
  final html.WebGl2RenderingContext _gl;
  final Map<String, Scene> _scenes = {};
  Scene _currentScene = Scene();
  Camera _camera = Camera();
  int _triangleCount = 0;
  int _modelCount = 0;

  SceneManager(this._gl) {
    _initializeDefaultScene();
  }

  Scene get currentScene => _currentScene;
  Camera get camera => _camera;
  int get triangleCount => _triangleCount;
  int get modelCount => _modelCount;

  void _initializeDefaultScene() {
    final defaultScene = Scene();
    
    // Create a dessert-themed 3D scene
    _addDessertModels(defaultScene);
    
    _scenes['default'] = defaultScene;
    _currentScene = defaultScene;
    
    // Setup camera
    _camera.position = Vector3(0, 2, 5);
    _camera.target = Vector3(0, 0, 0);
    _camera.updateViewMatrix();
  }

  void _addDessertModels(Scene scene) {
    // Create a pyramid (representing dessert)
    final pyramid = _createPyramidModel();
    pyramid.position = Vector3(0, 0, 0);
    scene.addModel(pyramid);

    // Create decorative elements
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2;
      final radius = 3.0;
      
      final decorative = _createCubeModel();
      decorative.position = Vector3(
        math.cos(angle) * radius,
        0.5,
        math.sin(angle) * radius,
      );
      decorative.scale = Vector3(0.5, 1.0, 0.5);
      scene.addModel(decorative);
    }

    _updateCounts(scene);
  }

  Model3D _createPyramidModel() {
    // Vertices for a pyramid (position, normal, color)
    final vertices = Float32List.fromList([
      // Base
      -1.0, 0.0, -1.0,  0.0, -1.0, 0.0,  1.0, 0.5, 0.2, 1.0,
      1.0, 0.0, -1.0,   0.0, -1.0, 0.0,  1.0, 0.5, 0.2, 1.0,
      1.0, 0.0, 1.0,    0.0, -1.0, 0.0,  1.0, 0.5, 0.2, 1.0,
      -1.0, 0.0, 1.0,   0.0, -1.0, 0.0,  1.0, 0.5, 0.2, 1.0,
      
      // Apex
      0.0, 2.0, 0.0,    0.0, 0.6, 0.8,   0.9, 0.1, 0.8, 1.0,
    ]);

    final indices = Uint16List.fromList([
      // Base
      0, 1, 2,
      0, 2, 3,
      
      // Sides
      0, 1, 4,
      1, 2, 4,
      2, 3, 4,
      3, 0, 4,
    ]);

    return Model3D(_gl, vertices, indices);
  }

  Model3D _createCubeModel() {
    // Simple cube vertices
    final vertices = Float32List.fromList([
      -0.5, -0.5, -0.5,  0.0, 0.0, -1.0,  0.8, 0.2, 0.8, 1.0,
      0.5, -0.5, -0.5,   0.0, 0.0, -1.0,  0.8, 0.2, 0.8, 1.0,
      0.5, 0.5, -0.5,    0.0, 0.0, -1.0,  0.8, 0.2, 0.8, 1.0,
      -0.5, 0.5, -0.5,   0.0, 0.0, -1.0,  0.8, 0.2, 0.8, 1.0,
      // ... more vertices for cube
    ]);

    final indices = Uint16List.fromList([
      0, 1, 2, 0, 2, 3,
      4, 5, 6, 4, 6, 7,
      8, 9, 10, 8, 10, 11,
      12, 13, 14, 12, 14, 15,
      16, 17, 18, 16, 18, 19,
      20, 21, 22, 20, 22, 23,
    ]);

    return Model3D(_gl, vertices, indices);
  }

  void loadScene(String sceneId) {
    if (_scenes.containsKey(sceneId)) {
      _currentScene = _scenes[sceneId]!;
      _updateCounts(_currentScene);
    }
  }

  void addModel(Vector3 position, Vector3 rotation, Vector3 scale) {
    final model = _createCubeModel();
    model.position = position;
    model.rotation = rotation;
    model.scale = scale;
    
    _currentScene.addModel(model);
    _updateCounts(_currentScene);
  }

  void _updateCounts(Scene scene) {
    _triangleCount = 0;
    _modelCount = scene.models.length;
    
    for (final model in scene.models) {
      _triangleCount += model.indexCount ~/ 3;
    }
  }

  void update(double deltaTime) {
    // Animate models
    for (int i = 0; i < _currentScene.models.length; i++) {
      final model = _currentScene.models[i];
      model.rotation.y += deltaTime * 0.5;
      model.updateTransform();
    }
    
    _camera.updateViewMatrix();
  }

  void dispose() {
    for (final scene in _scenes.values) {
      scene.dispose();
    }
    _scenes.clear();
  }
}

class Scene {
  final List<Model3D> models = [];
  final List<Light> lights = [];

  void addModel(Model3D model) => models.add(model);
  void addLight(Light light) => lights.add(light);

  void dispose() {
    for (final model in models) {
      model.dispose();
    }
    models.clear();
  }
}

class Model3D {
  final html.WebGl2RenderingContext _gl;
  final Float32List vertices;
  final Uint16List indices;
  final int vertexBuffer;
  final int indexBuffer;
  final int indexCount;
  
  Vector3 position = Vector3.zero();
  Vector3 rotation = Vector3.zero();
  Vector3 scale = Vector3.all(1.0);
  Matrix4 transformMatrix = Matrix4.identity();

  Model3D(this._gl, this.vertices, this.indices)
      : vertexBuffer = _gl.createBuffer()!,
        indexBuffer = _gl.createBuffer()!,
        indexCount = indices.length {
    _gl.bindBuffer(html.WebGl2RenderingContext.ARRAY_BUFFER, vertexBuffer);
    _gl.bufferData(html.WebGl2RenderingContext.ARRAY_BUFFER, vertices.buffer, html.WebGl2RenderingContext.STATIC_DRAW);
    
    _gl.bindBuffer(html.WebGl2RenderingContext.ELEMENT_ARRAY_BUFFER, indexBuffer);
    _gl.bufferData(html.WebGl2RenderingContext.ELEMENT_ARRAY_BUFFER, indices.buffer, html.WebGl2RenderingContext.STATIC_DRAW);
    
    updateTransform();
  }

  void updateTransform() {
    transformMatrix = Matrix4.identity();
    transformMatrix.translate(position.x, position.y, position.z);
    transformMatrix.rotateX(rotation.x);
    transformMatrix.rotateY(rotation.y);
    transformMatrix.rotateZ(rotation.z);
    transformMatrix.scale(scale.x, scale.y, scale.z);
  }

  void dispose() {
    _gl.deleteBuffer(vertexBuffer);
    _gl.deleteBuffer(indexBuffer);
  }
}

class Camera {
  Vector3 position = Vector3(0, 0, 5);
  Vector3 target = Vector3.zero();
  Vector3 up = Vector3(0, 1, 0);
  double fov = 45.0;
  double aspect = 16.0 / 9.0;
  double near = 0.1;
  double far = 100.0;
  
  final Matrix4 viewMatrix = Matrix4.identity();
  final Matrix4 projectionMatrix = Matrix4.identity();

  Camera() {
    updateProjectionMatrix();
    updateViewMatrix();
  }

  void updateViewMatrix() {
    viewMatrix.setLookAt(position, target, up);
  }

  void updateProjectionMatrix() {
    projectionMatrix.setPerspective(fov, aspect, near, far);
  }
}

class Light {
  Vector3 position = Vector3.zero();
  Vector3 color = Vector3(1, 1, 1);
  double intensity = 1.0;
}
