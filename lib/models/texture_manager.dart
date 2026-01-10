import 'dart:html' as html;
import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';

class TextureManager {
  final html.WebGl2RenderingContext _gl;
  final Map<String, int> _textures = {};
  final Map<String, Map<String, dynamic>> _textureInfo = {};

  TextureManager(this._gl);

  Future<int> loadTexture(String name, String url) async {
    if (_textures.containsKey(name)) {
      return _textures[name]!;
    }

    final texture = _gl.createTexture()!;
    _gl.bindTexture(_gl.TEXTURE_2D, texture);
    
    // Set default texture parameters
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_S, _gl.REPEAT);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_T, _gl.REPEAT);
    
    // Create a temporary 1x1 pixel texture
    _gl.texImage2D(
      _gl.TEXTURE_2D,
      0,
      _gl.RGBA,
      1,
      1,
      0,
      _gl.RGBA,
      _gl.UNSIGNED_BYTE,
      Uint8List.fromList([255, 255, 255, 255]),
    );

    // Load actual texture asynchronously
    final image = html.ImageElement();
    image.src = url;
    
    await image.onLoad.first;
    
    _gl.bindTexture(_gl.TEXTURE_2D, texture);
    _gl.texImage2D(_gl.TEXTURE_2D, 0, _gl.RGBA, _gl.RGBA, _gl.UNSIGNED_BYTE, image);
    _gl.generateMipmap(_gl.TEXTURE_2D);
    
    _textures[name] = texture;
    _textureInfo[name] = {
      'width': image.width,
      'height': image.height,
      'url': url,
      'format': 'RGBA',
      'type': '2D',
    };
    
    return texture;
  }

  int createSolidColorTexture(Vector4 color, {String name = 'solid_color'}) {
    if (_textures.containsKey(name)) {
      return _textures[name]!;
    }

    final texture = _gl.createTexture()!;
    _gl.bindTexture(_gl.TEXTURE_2D, texture);
    
    final pixels = Uint8List.fromList([
      (color.x * 255).toInt(),
      (color.y * 255).toInt(),
      (color.z * 255).toInt(),
      (color.w * 255).toInt(),
    ]);
    
    _gl.texImage2D(
      _gl.TEXTURE_2D,
      0,
      _gl.RGBA,
      1,
      1,
      0,
      _gl.RGBA,
      _gl.UNSIGNED_BYTE,
      pixels,
    );
    
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.NEAREST);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.NEAREST);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_S, _gl.CLAMP_TO_EDGE);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_T, _gl.CLAMP_TO_EDGE);
    
    _textures[name] = texture;
    _textureInfo[name] = {
      'width': 1,
      'height': 1,
      'type': 'solid_color',
      'color': [color.x, color.y, color.z, color.w],
    };
    
    return texture;
  }

  int createNoiseTexture(int size, {String name = 'noise'}) {
    if (_textures.containsKey(name)) {
      return _textures[name]!;
    }

    final texture = _gl.createTexture()!;
    _gl.bindTexture(_gl.TEXTURE_2D, texture);
    
    final pixels = Uint8List(size * size * 4);
    final random = Random();
    
    for (int i = 0; i < pixels.length; i += 4) {
      final value = random.nextInt(256);
      pixels[i] = value;
      pixels[i + 1] = value;
      pixels[i + 2] = value;
      pixels[i + 3] = 255;
    }
    
    _gl.texImage2D(
      _gl.TEXTURE_2D,
      0,
      _gl.RGBA,
      size,
      size,
      0,
      _gl.RGBA,
      _gl.UNSIGNED_BYTE,
      pixels,
    );
    
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_S, _gl.REPEAT);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_T, _gl.REPEAT);
    
    _textures[name] = texture;
    _textureInfo[name] = {
      'width': size,
      'height': size,
      'type': 'noise',
      'size': size,
    };
    
    return texture;
  }

  int createGradientTexture({
    required Vector4 color1,
    required Vector4 color2,
    int width = 256,
    int height = 256,
    String name = 'gradient',
  }) {
    if (_textures.containsKey(name)) {
      return _textures[name]!;
    }

    final texture = _gl.createTexture()!;
    _gl.bindTexture(_gl.TEXTURE_2D, texture);
    
    final pixels = Uint8List(width * height * 4);
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final t = x / width;
        final r = ((color1.x * (1 - t) + color2.x * t) * 255).toInt();
        final g = ((color1.y * (1 - t) + color2.y * t) * 255).toInt();
        final b = ((color1.z * (1 - t) + color2.z * t) * 255).toInt();
        final a = ((color1.w * (1 - t) + color2.w * t) * 255).toInt();
        
        final index = (y * width + x) * 4;
        pixels[index] = r;
        pixels[index + 1] = g;
        pixels[index + 2] = b;
        pixels[index + 3] = a;
      }
    }
    
    _gl.texImage2D(
      _gl.TEXTURE_2D,
      0,
      _gl.RGBA,
      width,
      height,
      0,
      _gl.RGBA,
      _gl.UNSIGNED_BYTE,
      pixels,
    );
    
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_S, _gl.CLAMP_TO_EDGE);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_T, _gl.CLAMP_TO_EDGE);
    
    _textures[name] = texture;
    _textureInfo[name] = {
      'width': width,
      'height': height,
      'type': 'gradient',
      'color1': [color1.x, color1.y, color1.z, color1.w],
      'color2': [color2.x, color2.y, color2.z, color2.w],
    };
    
    return texture;
  }

  void bindTexture(String name, int unit) {
    if (_textures.containsKey(name)) {
      _gl.activeTexture(_gl.TEXTURE0 + unit);
      _gl.bindTexture(_gl.TEXTURE_2D, _textures[name]!);
    }
  }

  Map<String, dynamic>? getTextureInfo(String name) {
    return _textureInfo[name];
  }

  List<String> getTextureList() {
    return _textures.keys.toList();
  }

  void dispose() {
    for (final texture in _textures.values) {
      _gl.deleteTexture(texture);
    }
    _textures.clear();
    _textureInfo.clear();
  }

  Future<int> loadTextureFromBytes(
    String name,
    Uint8List bytes,
    int width,
    int height,
  ) async {
    if (_textures.containsKey(name)) {
      return _textures[name]!;
    }

    final texture = _gl.createTexture()!;
    _gl.bindTexture(_gl.TEXTURE_2D, texture);
    
    _gl.texImage2D(
      _gl.TEXTURE_2D,
      0,
      _gl.RGBA,
      width,
      height,
      0,
      _gl.RGBA,
      _gl.UNSIGNED_BYTE,
      bytes,
    );
    
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MIN_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_MAG_FILTER, _gl.LINEAR);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_S, _gl.REPEAT);
    _gl.texParameteri(_gl.TEXTURE_2D, _gl.TEXTURE_WRAP_T, _gl.REPEAT);
    
    _textures[name] = texture;
    _textureInfo[name] = {
      'width': width,
      'height': height,
      'type': 'bytes',
      'size': bytes.length,
    };
    
    return texture;
  }
}

class Random {
  final _random = math.Random();
  
  int nextInt(int max) => _random.nextInt(max);
  double nextDouble() => _random.nextDouble();
}

class math {
  static final Random = _Random();
}

class _Random {
  final _random = Random();
  
  int nextInt(int max) => _random.nextInt(max);
  double nextDouble() => _random.nextDouble();
}
