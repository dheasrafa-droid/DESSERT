import 'dart:html' as html;
import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';

class DessertModel3D {
  final String id;
  final String type;
  final Float32List vertices;
  final Uint16List indices;
  final int vertexBuffer;
  final int indexBuffer;
  final int vertexCount;
  final int triangleCount;
  
  Vector3 position;
  Vector3 rotation;
  Vector3 scale;
  Vector4 color;
  Matrix4 transformMatrix;
  bool visible;
  bool selected;

  DessertModel3D({
    required this.id,
    required this.type,
    required html.WebGl2RenderingContext gl,
    required this.vertices,
    required this.indices,
    this.position = Vector3.zero(),
    this.rotation = Vector3.zero(),
    this.scale = Vector3.all(1.0),
    this.color = Vector4.all(1.0),
    this.visible = true,
    this.selected = false,
  }) : vertexBuffer = gl.createBuffer()!,
       indexBuffer = gl.createBuffer()!,
       vertexCount = vertices.length ~/ 10, // Each vertex has 10 floats
       triangleCount = indices.length ~/ 3,
       transformMatrix = Matrix4.identity() {
    _initializeBuffers(gl);
    updateTransform();
  }

  void _initializeBuffers(html.WebGl2RenderingContext gl) {
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, vertices.buffer, gl.STATIC_DRAW);
    
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices.buffer, gl.STATIC_DRAW);
  }

  void updateTransform() {
    transformMatrix = Matrix4.identity();
    transformMatrix.translate(position.x, position.y, position.z);
    transformMatrix.rotateX(rotation.x);
    transformMatrix.rotateY(rotation.y);
    transformMatrix.rotateZ(rotation.z);
    transformMatrix.scale(scale.x, scale.y, scale.z);
  }

  void setPosition(double x, double y, double z) {
    position.setValues(x, y, z);
    updateTransform();
  }

  void setRotation(double x, double y, double z) {
    rotation.setValues(x, y, z);
    updateTransform();
  }

  void setScale(double x, double y, double z) {
    scale.setValues(x, y, z);
    updateTransform();
  }

  void dispose(html.WebGl2RenderingContext gl) {
    gl.deleteBuffer(vertexBuffer);
    gl.deleteBuffer(indexBuffer);
  }

  // Static factory methods for creating different model types
  static DessertModel3D createCube({
    required html.WebGl2RenderingContext gl,
    required String id,
    double size = 1.0,
    Vector4? color,
  }) {
    final half = size / 2;
    final vertices = Float32List.fromList([
      // Front face
      -half, -half,  half,  0, 0, 1,  color?.x ?? 1, color?.y ?? 0, color?.z ?? 0, color?.w ?? 1,
       half, -half,  half,  0, 0, 1,  color?.x ?? 1, color?.y ?? 0, color?.z ?? 0, color?.w ?? 1,
       half,  half,  half,  0, 0, 1,  color?.x ?? 1, color?.y ?? 0, color?.z ?? 0, color?.w ?? 1,
      -half,  half,  half,  0, 0, 1,  color?.x ?? 1, color?.y ?? 0, color?.z ?? 0, color?.w ?? 1,
      
      // Back face
      -half, -half, -half,  0, 0, -1, color?.x ?? 0, color?.y ?? 1, color?.z ?? 0, color?.w ?? 1,
      -half,  half, -half,  0, 0, -1, color?.x ?? 0, color?.y ?? 1, color?.z ?? 0, color?.w ?? 1,
       half,  half, -half,  0, 0, -1, color?.x ?? 0, color?.y ?? 1, color?.z ?? 0, color?.w ?? 1,
       half, -half, -half,  0, 0, -1, color?.x ?? 0, color?.y ?? 1, color?.z ?? 0, color?.w ?? 1,
      
      // Top face
      -half,  half, -half,  0, 1, 0,  color?.x ?? 0, color?.y ?? 0, color?.z ?? 1, color?.w ?? 1,
      -half,  half,  half,  0, 1, 0,  color?.x ?? 0, color?.y ?? 0, color?.z ?? 1, color?.w ?? 1,
       half,  half,  half,  0, 1, 0,  color?.x ?? 0, color?.y ?? 0, color?.z ?? 1, color?.w ?? 1,
       half,  half, -half,  0, 1, 0,  color?.x ?? 0, color?.y ?? 0, color?.z ?? 1, color?.w ?? 1,
      
      // Bottom face
      -half, -half, -half,  0, -1, 0, color?.x ?? 1, color?.y ?? 1, color?.z ?? 0, color?.w ?? 1,
       half, -half, -half,  0, -1, 0, color?.x ?? 1, color?.y ?? 1, color?.z ?? 0, color?.w ?? 1,
       half, -half,  half,  0, -1, 0, color?.x ?? 1, color?.y ?? 1, color?.z ?? 0, color?.w ?? 1,
      -half, -half,  half,  0, -1, 0, color?.x ?? 1, color?.y ?? 1, color?.z ?? 0, color?.w ?? 1,
      
      // Right face
       half, -half, -half,  1, 0, 0,  color?.x ?? 1, color?.y ?? 0, color?.z ?? 1, color?.w ?? 1,
       half,  half, -half,  1, 0, 0,  color?.x ?? 1, color?.y ?? 0, color?.z ?? 1, color?.w ?? 1,
       half,  half,  half,  1, 0, 0,  color?.x ?? 1, color?.y ?? 0, color?.z ?? 1, color?.w ?? 1,
       half, -half,  half,  1, 0, 0,  color?.x ?? 1, color?.y ?? 0, color?.z ?? 1, color?.w ?? 1,
      
      // Left face
      -half, -half, -half, -1, 0, 0,  color?.x ?? 0, color?.y ?? 1, color?.z ?? 1, color?.w ?? 1,
      -half, -half,  half, -1, 0, 0,  color?.x ?? 0, color?.y ?? 1, color?.z ?? 1, color?.w ?? 1,
      -half,  half,  half, -1, 0, 0,  color?.x ?? 0, color?.y ?? 1, color?.z ?? 1, color?.w ?? 1,
      -half,  half, -half, -1, 0, 0,  color?.x ?? 0, color?.y ?? 1, color?.z ?? 1, color?.w ?? 1,
    ]);

    final indices = Uint16List.fromList([
      0, 1, 2, 0, 2, 3,       // Front
      4, 5, 6, 4, 6, 7,       // Back
      8, 9, 10, 8, 10, 11,    // Top
      12, 13, 14, 12, 14, 15, // Bottom
      16, 17, 18, 16, 18, 19, // Right
      20, 21, 22, 20, 22, 23, // Left
    ]);

    return DessertModel3D(
      id: id,
      type: 'cube',
      gl: gl,
      vertices: vertices,
      indices: indices,
      color: color ?? Vector4(0.8, 0.2, 0.8, 1.0),
    );
  }

  static DessertModel3D createPyramid({
    required html.WebGl2RenderingContext gl,
    required String id,
    double baseSize = 1.0,
    double height = 2.0,
    Vector4? color,
  }) {
    final halfBase = baseSize / 2;
    final vertices = Float32List.fromList([
      // Base
      -halfBase, 0, -halfBase,  0, -1, 0,  color?.x ?? 1, color?.y ?? 0.5, color?.z ?? 0.2, color?.w ?? 1,
       halfBase, 0, -halfBase,  0, -1, 0,  color?.x ?? 1, color?.y ?? 0.5, color?.z ?? 0.2, color?.w ?? 1,
       halfBase, 0,  halfBase,  0, -1, 0,  color?.x ?? 1, color?.y ?? 0.5, color?.z ?? 0.2, color?.w ?? 1,
      -halfBase, 0,  halfBase,  0, -1, 0,  color?.x ?? 1, color?.y ?? 0.5, color?.z ?? 0.2, color?.w ?? 1,
      
      // Apex
      0, height, 0,  0, 0.6, 0.8,  color?.x ?? 0.9, color?.y ?? 0.1, color?.z ?? 0.8, color?.w ?? 1,
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

    return DessertModel3D(
      id: id,
      type: 'pyramid',
      gl: gl,
      vertices: vertices,
      indices: indices,
      color: color ?? Vector4(1.0, 0.5, 0.2, 1.0),
    );
  }

  static DessertModel3D createSphere({
    required html.WebGl2RenderingContext gl,
    required String id,
    double radius = 1.0,
    int segments = 16,
    Vector4? color,
  }) {
    final vertices = <double>[];
    final indices = <int>[];
    
    for (int lat = 0; lat <= segments; lat++) {
      final theta = lat * Math.pi / segments;
      final sinTheta = Math.sin(theta);
      final cosTheta = Math.cos(theta);
      
      for (int lon = 0; lon <= segments; lon++) {
        final phi = lon * 2 * Math.pi / segments;
        final sinPhi = Math.sin(phi);
        final cosPhi = Math.cos(phi);
        
        final x = cosPhi * sinTheta;
        final y = cosTheta;
        final z = sinPhi * sinTheta;
        
        final u = 1 - (lon / segments);
        final v = 1 - (lat / segments);
        
        vertices.addAll([
          radius * x, radius * y, radius * z,
          x, y, z,
          color?.x ?? 0.2, color?.y ?? 0.8, color?.z ?? 0.8, 1.0,
          u, v,
        ]);
      }
    }
    
    for (int lat = 0; lat < segments; lat++) {
      for (int lon = 0; lon < segments; lon++) {
        final first = (lat * (segments + 1)) + lon;
        final second = first + segments + 1;
        
        indices.addAll([first, second, first + 1]);
        indices.addAll([second, second + 1, first + 1]);
      }
    }

    return DessertModel3D(
      id: id,
      type: 'sphere',
      gl: gl,
      vertices: Float32List.fromList(vertices),
      indices: Uint16List.fromList(indices),
      color: color ?? Vector4(0.2, 0.8, 0.8, 1.0),
    );
  }
}

class Math {
  static double pi = 3.141592653589793;
  static double sin(double x) => (x as num).sin();
  static double cos(double x) => (x as num).cos();
}
