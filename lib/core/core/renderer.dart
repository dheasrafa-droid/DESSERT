import 'dart:html' as html;
import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';
import 'scene_manager.dart';
import 'shader_library.dart';

class Renderer {
  final html.WebGl2RenderingContext _gl;
  final Map<String, int> _programCache = {};
  final Map<String, int> _bufferCache = {};
  final Map<String, int> _textureCache = {};
  int _gpuMemoryUsage = 0;

  Renderer(this._gl);

  int get gpuMemoryUsage => _gpuMemoryUsage;

  void render(Scene scene) {
    if (scene.models.isEmpty) return;

    final program = _getProgram('default');
    _gl.useProgram(program);

    // Set view and projection matrices
    final viewMatrixLocation = _gl.getUniformLocation(program, 'uViewMatrix');
    final projectionMatrixLocation = _gl.getUniformLocation(program, 'uProjectionMatrix');

    _gl.uniformMatrix4fv(viewMatrixLocation, false, scene.camera.viewMatrix.storage);
    _gl.uniformMatrix4fv(projectionMatrixLocation, false, scene.camera.projectionMatrix.storage);

    // Render each model
    for (final model in scene.models) {
      _renderModel(model, program);
    }
  }

  void _renderModel(Model3D model, int program) {
    // Set model matrix
    final modelMatrixLocation = _gl.getUniformLocation(program, 'uModelMatrix');
    _gl.uniformMatrix4fv(modelMatrixLocation, false, model.transformMatrix.storage);

    // Set up vertex attributes
    final positionLocation = _gl.getAttribLocation(program, 'aPosition');
    final normalLocation = _gl.getAttribLocation(program, 'aNormal');
    final colorLocation = _gl.getAttribLocation(program, 'aColor');

    _gl.bindBuffer(_gl.ARRAY_BUFFER, model.vertexBuffer);
    
    _gl.enableVertexAttribArray(positionLocation);
    _gl.vertexAttribPointer(positionLocation, 3, _gl.FLOAT, false, 32, 0);
    
    _gl.enableVertexAttribArray(normalLocation);
    _gl.vertexAttribPointer(normalLocation, 3, _gl.FLOAT, false, 32, 12);
    
    _gl.enableVertexAttribArray(colorLocation);
    _gl.vertexAttribPointer(colorLocation, 4, _gl.FLOAT, false, 32, 24);

    // Draw
    _gl.bindBuffer(_gl.ELEMENT_ARRAY_BUFFER, model.indexBuffer);
    _gl.drawElements(_gl.TRIANGLES, model.indexCount, _gl.UNSIGNED_SHORT, 0);

    // Cleanup
    _gl.disableVertexAttribArray(positionLocation);
    _gl.disableVertexAttribArray(normalLocation);
    _gl.disableVertexAttribArray(colorLocation);
  }

  int _getProgram(String shaderName) {
    if (_programCache.containsKey(shaderName)) {
      return _programCache[shaderName]!;
    }

    final program = ShaderLibrary.createProgram(_gl, shaderName);
    _programCache[shaderName] = program;
    return program;
  }

  int createVertexBuffer(Float32List vertices) {
    final buffer = _gl.createBuffer()!;
    _gl.bindBuffer(_gl.ARRAY_BUFFER, buffer);
    _gl.bufferData(_gl.ARRAY_BUFFER, vertices.buffer, _gl.STATIC_DRAW);
    
    _gpuMemoryUsage += vertices.lengthInBytes;
    return buffer;
  }

  int createIndexBuffer(Uint16List indices) {
    final buffer = _gl.createBuffer()!;
    _gl.bindBuffer(_gl.ELEMENT_ARRAY_BUFFER, buffer);
    _gl.bufferData(_gl.ELEMENT_ARRAY_BUFFER, indices.buffer, _gl.STATIC_DRAW);
    
    _gpuMemoryUsage += indices.lengthInBytes;
    return buffer;
  }

  void dispose() {
    for (final program in _programCache.values) {
      _gl.deleteProgram(program);
    }
    for (final buffer in _bufferCache.values) {
      _gl.deleteBuffer(buffer);
    }
    for (final texture in _textureCache.values) {
      _gl.deleteTexture(texture);
    }
    
    _programCache.clear();
    _bufferCache.clear();
    _textureCache.clear();
    _gpuMemoryUsage = 0;
  }
}
