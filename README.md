# DESSERT 3D Engine 🎨

A custom WebGL2-based 3D engine built with Flutter Web for the DESSERT brand.

![DESSERT Engine](https://img.shields.io/badge/DESSERT-Engine-purple)
![Flutter Web](https://img.shields.io/badge/Flutter-Web-blue)
![WebGL2](https://img.shields.io/badge/WebGL2-Enabled-green)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Version](https://img.shields.io/badge/Version-1.0.0-orange)

## ✨ Features

### 🎯 Core Engine
- **Custom WebGL2 Renderer** - Built from scratch, no external dependencies
- **Real-time 3D Rendering** - 60+ FPS performance
- **Scene Management** - Multiple scene support with transitions
- **Shader Pipeline** - Custom GLSL shader system with live editing
- **Physics Engine** - Collision detection and rigid body simulation
- **Audio System** - Spatial 3D audio integration

### 🛠️ Editor Features
- **Interactive 3D Editor** - Real-time scene manipulation with gizmos
- **Model Library** - Prebuilt 3D models (Cube, Pyramid, Sphere, Custom OBJ)
- **Shader Editor** - Live GLSL shader editing with syntax highlighting
- **Texture Management** - Import and apply textures (PNG, JPG, WebP)
- **Animation Timeline** - Keyframe animation system
- **Particle System** - Real-time particle effects editor

### 📊 Performance & Optimization
- **GPU Statistics** - Real-time performance monitoring
- **Memory Management** - Efficient GPU memory usage with pooling
- **Frustum Culling** - Automatic occlusion optimization
- **LOD System** - Level of Detail management
- **Instanced Rendering** - Batch rendering for identical objects

### 🌐 Web Integration
- **Flutter Web** - Beautiful UI with Material 3 design system
- **Responsive Design** - Works on desktop, tablet, and mobile
- **Offline Support** - IndexedDB + LocalStorage for asset caching
- **PWA Ready** - Install as desktop/mobile app
- **WebXR Support** - VR/AR compatibility

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+ (with web support enabled)
- Chrome/Firefox/Edge with WebGL2 support
- Git for version control

### Installation
```bash
# Clone repository
git clone https://github.com/dheasrafa-droid/DESSERT.git
cd DESSERT

# Install dependencies
flutter pub get

# Run development server
flutter run -d chrome
```

Build for Production

```bash
# Build with CanvasKit for better performance
flutter build web --web-renderer canvaskit --release

# Deploy to your preferred hosting
```

📁 Project Structure

```
DESSERT/
├── lib/
│   ├── core/           # Engine core components
│   │   ├── dessert_engine.dart    # Main engine class
│   │   ├── renderer.dart          # WebGL2 renderer
│   │   ├── scene_manager.dart     # Scene management
│   │   └── shader_library.dart    # Shader management
│   ├── dashboard/      # Main dashboard UI
│   ├── models/         # 3D models and mesh definitions
│   │   ├── dessert_model.dart
│   │   ├── cube_model.dart
│   │   └── pyramid_model.dart
│   ├── ui/            # Custom UI components
│   │   ├── dessert_app_bar.dart
│   │   ├── dessert_button.dart
│   │   └── control_panel.dart
│   ├── utils/         # Utilities
│   │   ├── math_utils.dart
│   │   ├── performance_monitor.dart
│   │   └── texture_loader.dart
│   ├── services/      # Services
│   │   └── storage_service.dart
│   └── main.dart      # Application entry point
├── web/
│   ├── assets/        # Static assets
│   │   ├── shaders/   # GLSL shader files
│   │   └── textures/  # Texture images
│   └── index.html     # Web entry point
├── pubspec.yaml       # Dependencies and metadata
├── README.md          # This file
└── LICENSE           # MIT License
```

🎮 Usage

Basic Example

```dart
import 'package:dessert/core/dessert_engine.dart';
import 'package:dessert/utils/math_utils.dart';

void main() async {
  // Initialize engine
  final engine = DessertEngine();
  await engine.initialize(canvasId: 'webgl-canvas');
  
  // Create a scene
  final scene = engine.createScene('main_scene');
  
  // Add a cube model
  engine.addModel(
    position: Vector3(0, 0, 0),
    rotation: Vector3(0, 0, 0),
    scale: Vector3(1, 1, 1),
    modelType: ModelType.cube,
    color: Vector4(1.0, 0.5, 0.2, 1.0)
  );
  
  // Start rendering loop
  engine.start();
}
```

Creating Custom Models

```dart
// Create a custom model with custom vertices
final vertices = Float32List.fromList([
  // Vertex positions (x, y, z)
  -1, -1,  0,
   1, -1,  0,
   0,  1,  0,
]);

final colors = Float32List.fromList([
  // Colors (r, g, b, a)
  1, 0, 0, 1,
  0, 1, 0, 1,
  0, 0, 1, 1,
]);

final model = DessertModel3D(
  id: 'custom_triangle',
  vertices: vertices,
  colors: colors,
  vertexCount: 3
);

scene.addModel(model);
```

Custom Shaders

```glsl
// Example: Custom fragment shader (fragment_shader.glsl)
#version 300 es
precision highp float;

in vec3 vPosition;
in vec3 vNormal;
in vec2 vTexCoord;

uniform sampler2D uTexture;
uniform vec3 uLightDirection;
uniform vec3 uColor;

out vec4 fragColor;

void main() {
    vec3 lightDir = normalize(uLightDirection);
    float diffuse = max(dot(vNormal, lightDir), 0.2);
    
    vec4 texColor = texture(uTexture, vTexCoord);
    vec3 finalColor = texColor.rgb * uColor * diffuse;
    
    fragColor = vec4(finalColor, texColor.a);
}
```

🔧 Configuration

Engine Initialization Options

```dart
final engine = DessertEngine(
  config: EngineConfig(
    antialiasing: true,
    alpha: true,
    depth: true,
    stencil: true,
    preserveDrawingBuffer: false,
    powerPreference: 'high-performance',
    maxLights: 8,
    shadowQuality: ShadowQuality.medium,
  )
);
```

WebGL Context Configuration

· WebGL2 context with hardware acceleration
· 4x MSAA anti-aliasing
· Depth testing enabled
· Face culling for performance
· Alpha blending for transparency
· High-performance power preference

📊 Performance Optimization

GPU Memory Management

· Vertex buffer pooling and reuse
· Texture compression (ASTC, ETC2, BC7)
· Shader program caching and compilation caching
· Buffer streaming for dynamic geometry

Rendering Optimization Techniques

· Frustum Culling: Automatically culls objects outside view
· Level of Detail (LOD): Multiple detail levels based on distance
· Instanced Rendering: Batch identical objects
· Occlusion Culling: Hardware-accelerated occlusion queries
· Texture Atlasing: Combine multiple textures

Performance Monitoring

```dart
// Monitor engine performance
final monitor = PerformanceMonitor(engine);

// Get real-time stats
final stats = monitor.getStats();
print('''
FPS: ${stats.fps}
Frame Time: ${stats.frameTime}ms
Draw Calls: ${stats.drawCalls}
Triangles: ${stats.triangleCount}
GPU Memory: ${stats.gpuMemory}MB
''');
```

🌐 Deployment

Vercel Deployment

```json
// vercel.json
{
  "builds": [{"src": "build/web/**", "use": "@vercel/static"}],
  "routes": [{"src": "/(.*)", "dest": "/build/web/index.html"}],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {"key": "Cross-Origin-Opener-Policy", "value": "same-origin"},
        {"key": "Cross-Origin-Embedder-Policy", "value": "require-corp"},
        {"key": "Cross-Origin-Resource-Policy", "value": "cross-origin"}
      ]
    }
  ]
}
```

Firebase Hosting

```json
// firebase.json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{"source": "**", "destination": "/index.html"}],
    "headers": [
      {
        "source": "**",
        "headers": [
          {"key": "Cross-Origin-Opener-Policy", "value": "same-origin"},
          {"key": "Cross-Origin-Embedder-Policy", "value": "require-corp"}
        ]
      }
    ]
  }
}
```

Netlify Configuration

```toml
# netlify.toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    Cross-Origin-Opener-Policy = "same-origin"
    Cross-Origin-Embedder-Policy = "require-corp"

[build]
  publish = "build/web"
  command = "flutter build web --web-renderer canvaskit --release"
```

📈 Monitoring & Debugging

Performance Metrics Dashboard

· Real-time FPS counter
· Frame time graph (16.67ms target)
· GPU memory usage monitor
· Draw call counter
· Triangle count per frame
· Shader compilation timing

Debug Tools

· Wireframe mode toggle
· Bounding box visualization
· Normal visualization
· Texture coordinate visualization
· Light source visualization
· Performance overlay

Error Handling

```dart
// WebGL context loss recovery
engine.onContextLost = () {
  print('WebGL context lost, attempting recovery...');
  engine.recoverContext();
};

// Shader compilation errors
engine.onShaderError = (String shaderName, String error) {
  print('Shader $shaderName compilation error: $error');
};

// Memory warnings
engine.onMemoryWarning = (int usage, int limit) {
  print('GPU memory usage: ${usage}MB/${limit}MB');
  engine.cleanupUnusedResources();
};
```

🔗 API Reference

Core Classes

DessertEngine

```dart
class DessertEngine {
  Future<void> initialize({String canvasId})
  void start()
  void pause()
  void stop()
  Scene createScene(String name)
  void setActiveScene(String name)
  Map<String, dynamic> getStats()
  void dispose()
}
```

Renderer

```dart
class Renderer {
  void render(Scene scene)
  void setClearColor(Vector4 color)
  void enableFeature(RenderFeature feature)
  void disableFeature(RenderFeature feature)
}
```

SceneManager

```dart
class SceneManager {
  void addModel(DessertModel3D model)
  void removeModel(String modelId)
  List<DessertModel3D> getModels()
  void setCamera(Camera camera)
  void addLight(Light light)
}
```

UI Components

DessertAppBar

```dart
class DessertAppBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final bool showPerformanceOverlay;
  
  DessertAppBar({
    required this.title,
    this.actions = const [],
    this.showPerformanceOverlay = false,
  });
}
```

ControlPanel

```dart
class ControlPanel extends StatefulWidget {
  final DessertEngine engine;
  final ValueChanged<Vector3> onPositionChanged;
  final ValueChanged<Vector3> onRotationChanged;
  final ValueChanged<Vector3> onScaleChanged;
  
  ControlPanel({
    required this.engine,
    required this.onPositionChanged,
    required this.onRotationChanged,
    required this.onScaleChanged,
  });
}
```

🚧 Development Guide

Setting Up Development Environment

```bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web support
flutter config --enable-web

# Check installation
flutter doctor -v

# Install dependencies
cd DESSERT
flutter pub get
```

Running Tests

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Run performance tests
flutter run --profile -d chrome
```

Code Style

· Follow Dart style guide
· Use meaningful variable names
· Add comments for complex logic
· Write documentation for public APIs
· Use // ignore: comments sparingly with explanations

🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the Repository
2. Create a Feature Branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Make Your Changes
   · Follow the code style
   · Add tests for new features
   · Update documentation
4. Commit Changes
   ```bash
   git commit -m 'Add amazing feature'
   ```
5. Push to Branch
   ```bash
   git push origin feature/amazing-feature
   ```
6. Open a Pull Request

Contribution Guidelines

· Ensure code compiles without warnings
· Add unit tests for new functionality
· Update README.md if needed
· Keep PRs focused on single features
· Be respectful in discussions

📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

```
MIT License

Copyright (c) 2024 DESSERT Brand

Permission is hereby granted...
```

🏆 Credits

· DESSERT Brand - Project concept and design direction
· Flutter Team - Web framework and tooling
· WebGL Working Group - Graphics API specification
· Khronos Group - WebGL2 and GLSL standards
· Contributors - Everyone who helps improve the engine

Special Thanks

· All beta testers and early adopters
· Open source community for inspiration
· Graphics programming community

📞 Support

· GitHub Issues: Report Bugs & Features
· Discussions: Join the Conversation
· Documentation: API Reference & Guides
· Community Discord: Join Our Server

Troubleshooting

· WebGL2 not supported: Ensure your browser is updated and hardware acceleration is enabled
· Blank screen: Check browser console for WebGL errors
· Performance issues: Enable hardware acceleration in browser settings
· Shader errors: Check GLSL syntax and WebGL2 compatibility

🔮 Roadmap

v1.1.0 (Upcoming)

· Physically Based Rendering (PBR)
· Real-time shadows
· Post-processing effects
· Import/Export GLTF format
· Video texture support

v1.2.0 (Planned)

· Terrain system
· Water rendering
· Particle system improvements
· Networking for multiplayer
· Mobile optimization

v2.0.0 (Future)

· Vulkan backend (via Dawn)
· Ray tracing support
· AI-powered content generation
· Cross-platform native builds

---

Built with ❤️ for the DESSERT brand
