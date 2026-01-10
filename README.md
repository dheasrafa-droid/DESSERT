# DESSERT 3D Engine 🎨

A custom WebGL2-based 3D engine built with Flutter Web for the DESSERT brand.

![DESSERT Engine](https://img.shields.io/badge/DESSERT-Engine-purple)
![Flutter Web](https://img.shields.io/badge/Flutter-Web-blue)
![WebGL2](https://img.shields.io/badge/WebGL2-Enabled-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ Features

### 🎯 Core Engine
- **Custom WebGL2 Renderer** - Built from scratch, no external dependencies
- **Real-time 3D Rendering** - 60+ FPS performance
- **Scene Management** - Multiple scene support with transitions
- **Shader Pipeline** - Custom GLSL shader system

### 🛠️ Editor Features
- **Interactive 3D Editor** - Real-time scene manipulation
- **Model Library** - Prebuilt 3D models (Cube, Pyramid, Sphere)
- **Shader Editor** - Live GLSL shader editing
- **Texture Management** - Import and apply textures

### 📊 Performance
- **GPU Statistics** - Real-time performance monitoring
- **Memory Management** - Efficient GPU memory usage
- **Optimization** - Frustum culling, LOD system

### 🌐 Web Integration
- **Flutter Web** - Beautiful UI with Material 3
- **Responsive Design** - Works on all screen sizes
- **Offline Support** - IndexedDB + LocalStorage
- **PWA Ready** - Install as desktop/mobile app

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Chrome/Firefox (WebGL2 support)

### Installation
```bash
# Clone repository
git clone https://github.com/DESSERT-3D/dessert-engine.git
cd dessert-engine

# Install dependencies
flutter pub get

# Run development server
flutter run -d chrome
```

Build for Production

```bash
# Build with CanvasKit renderer
flutter build web --web-renderer canvaskit --release

# Deploy to Vercel
vercel --prod
```

📁 Project Structure

```
dessert-engine/
├── lib/
│   ├── core/          # Engine core (WebGL2, rendering, scene management)
│   ├── dashboard/     # Main dashboard UI
│   ├── models/        # 3D models and scenes
│   ├── ui/           # Custom UI components
│   ├── utils/        # Math utilities and performance monitoring
│   └── services/     # API and storage services
├── web/
│   ├── assets/       # Shaders and textures
│   └── index.html    # Web entry point
└── pubspec.yaml      # Dependencies
```

🎮 Usage

Basic Example

```dart
import 'package:dessert_engine/core/dessert_engine.dart';

// Initialize engine
final engine = DessertEngine();
await engine.initialize();

// Add a model
engine.addModel(
  Vector3(0, 0, 0),
  Vector3(0, 0, 0),
  Vector3(1, 1, 1),
);

// Get performance stats
final stats = engine.getStats();
print('FPS: ${stats['fps']}');
```

Creating Custom Models

```dart
// Create a custom cube model
final cube = DessertModel3D.createCube(
  gl: gl,
  id: 'my_cube',
  size: 2.0,
  color: Vector4(1.0, 0.5, 0.2, 1.0),
);

// Add to scene
scene.addModel(cube);
```

Custom Shaders

```glsl
// Create a custom fragment shader
#version 300 es
precision highp float;

in vec3 vPosition;
out vec4 fragColor;

void main() {
    // Gradient based on position
    vec3 color = sin(vPosition * 2.0) * 0.5 + 0.5;
    fragColor = vec4(color, 1.0);
}
```

🔧 Configuration

Engine Settings

```dart
// In lib/main.dart
MaterialApp(
  title: 'DESSERT Engine',
  theme: ThemeData(
    primarySwatch: Colors.deepPurple,
    fontFamily: 'Inter',
    useMaterial3: true,
  ),
  home: DessertHomePage(),
)
```

WebGL Configuration

· WebGL2 Context with anti-aliasing
· Depth testing enabled
· Face culling for performance
· Alpha blending support

📊 Performance Optimization

GPU Memory Management

· Vertex buffer pooling
· Texture compression
· Shader program caching

Rendering Optimization

· Frustum culling
· Level of Detail (LOD)
· Instanced rendering
· Occlusion culling

🌐 Deployment

Vercel Configuration

```json
{
  "builds": [{"src": "build/web/**", "use": "@vercel/static"}],
  "routes": [{"src": "/(.*)", "dest": "/build/web/index.html"}],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {"key": "Cross-Origin-Opener-Policy", "value": "same-origin"},
        {"key": "Cross-Origin-Embedder-Policy", "value": "require-corp"}
      ]
    }
  ]
}
```

Netlify Configuration

```toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    Cross-Origin-Opener-Policy = "same-origin"
    Cross-Origin-Embedder-Policy = "require-corp"
```

📈 Monitoring

Performance Metrics

· FPS counter
· Frame time analysis
· GPU memory usage
· Draw call count
· Triangle count

Error Reporting

· WebGL context loss recovery
· Shader compilation errors
· Memory overflow detection

🔗 API Reference

Core Classes

· DessertEngine - Main engine class
· Renderer - WebGL2 renderer
· SceneManager - Scene management
· ShaderLibrary - Shader management

UI Components

· DessertAppBar - Custom app bar
· DessertButton - Styled buttons
· DessertCard - Card components
· ControlPanel - 3D controls

🤝 Contributing

1. Fork the repository
2. Create a feature branch (git checkout -b feature/AmazingFeature)
3. Commit changes (git commit -m 'Add AmazingFeature')
4. Push to branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

🏆 Credits

· DESSERT Brand - Project concept and design
· Flutter Team - Web framework
· WebGL2 - Graphics API
· Contributors - All who help improve the engine

📞 Support

· Issues: GitHub Issues
· Discussions: GitHub Discussions
· Email: support@dessert-engine.com

---

Built with ❤️ for the DESSERT brand
