import 'dart:html' as html;
import 'dart:typed_data';

class ShaderLibrary {
  static final Map<String, String> _vertexShaders = {
    'default': '''
      #version 300 es
      precision highp float;
      
      in vec3 aPosition;
      in vec3 aNormal;
      in vec4 aColor;
      
      uniform mat4 uModelMatrix;
      uniform mat4 uViewMatrix;
      uniform mat4 uProjectionMatrix;
      
      out vec3 vNormal;
      out vec4 vColor;
      out vec3 vPosition;
      
      void main() {
        vec4 worldPosition = uModelMatrix * vec4(aPosition, 1.0);
        vec4 viewPosition = uViewMatrix * worldPosition;
        gl_Position = uProjectionMatrix * viewPosition;
        
        vNormal = mat3(uModelMatrix) * aNormal;
        vColor = aColor;
        vPosition = worldPosition.xyz;
      }
    ''',
    
    'phong': '''
      #version 300 es
      precision highp float;
      
      in vec3 aPosition;
      in vec3 aNormal;
      in vec4 aColor;
      
      uniform mat4 uModelMatrix;
      uniform mat4 uViewMatrix;
      uniform mat4 uProjectionMatrix;
      uniform vec3 uLightPosition;
      
      out vec3 vNormal;
      out vec4 vColor;
      out vec3 vPosition;
      out vec3 vLightDirection;
      
      void main() {
        vec4 worldPosition = uModelMatrix * vec4(aPosition, 1.0);
        vec4 viewPosition = uViewMatrix * worldPosition;
        gl_Position = uProjectionMatrix * viewPosition;
        
        vNormal = normalize(mat3(uModelMatrix) * aNormal);
        vColor = aColor;
        vPosition = worldPosition.xyz;
        vLightDirection = normalize(uLightPosition - worldPosition.xyz);
      }
    '''
  };

  static final Map<String, String> _fragmentShaders = {
    'default': '''
      #version 300 es
      precision highp float;
      
      in vec3 vNormal;
      in vec4 vColor;
      in vec3 vPosition;
      
      uniform vec3 uCameraPosition;
      uniform vec3 uLightPosition;
      uniform vec3 uLightColor;
      uniform float uAmbientStrength;
      
      out vec4 fragColor;
      
      void main() {
        // Ambient lighting
        vec3 ambient = uAmbientStrength * uLightColor;
        
        // Diffuse lighting
        vec3 norm = normalize(vNormal);
        vec3 lightDir = normalize(uLightPosition - vPosition);
        float diff = max(dot(norm, lightDir), 0.0);
        vec3 diffuse = diff * uLightColor;
        
        // Specular lighting
        vec3 viewDir = normalize(uCameraPosition - vPosition);
        vec3 reflectDir = reflect(-lightDir, norm);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
        vec3 specular = 0.5 * spec * uLightColor;
        
        // Combine
        vec3 result = (ambient + diffuse + specular) * vColor.rgb;
        fragColor = vec4(result, vColor.a);
      }
    ''',
    
    'wireframe': '''
      #version 300 es
      precision highp float;
      
      in vec3 vNormal;
      in vec4 vColor;
      
      out vec4 fragColor;
      
      void main() {
        float edge = 1.0 - abs(vNormal.y);
        vec3 color = mix(vColor.rgb, vec3(1.0, 1.0, 1.0), edge);
        fragColor = vec4(color, 1.0);
      }
    '''
  };

  static void initialize(html.WebGl2RenderingContext gl) {
    // Pre-compile shaders
    for (final name in _vertexShaders.keys) {
      createProgram(gl, name);
    }
  }

  static int createProgram(html.WebGl2RenderingContext gl, String shaderName) {
    final vertexShader = _compileShader(
      gl,
      _vertexShaders[shaderName] ?? _vertexShaders['default']!,
      gl.VERTEX_SHADER,
    );
    
    final fragmentShader = _compileShader(
      gl,
      _fragmentShaders[shaderName] ?? _fragmentShaders['default']!,
      gl.FRAGMENT_SHADER,
    );
    
    final program = gl.createProgram()!;
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      final error = gl.getProgramInfoLog(program);
      gl.deleteProgram(program);
      throw Exception('Failed to link program: $error');
    }
    
    gl.deleteShader(vertexShader);
    gl.deleteShader(fragmentShader);
    
    return program;
  }

  static int _compileShader(
    html.WebGl2RenderingContext gl,
    String source,
    int type,
  ) {
    final shader = gl.createShader(type)!;
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      final error = gl.getShaderInfoLog(shader);
      gl.deleteShader(shader);
      throw Exception('Failed to compile shader: $error');
    }
    
    return shader;
  }

  static Map<String, dynamic> getShaderList() {
    return {
      'vertex': _vertexShaders.keys.toList(),
      'fragment': _fragmentShaders.keys.toList(),
    };
  }
}
