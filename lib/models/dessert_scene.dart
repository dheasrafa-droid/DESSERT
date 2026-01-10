import 'package:vector_math/vector_math_64.dart';

class DessertScene {
  final String id;
  final String name;
  final String description;
  final List<DessertModel> models;
  final Vector3 ambientLight;
  final List<SceneLight> lights;
  final Map<String, dynamic> settings;

  DessertScene({
    required this.id,
    required this.name,
    required this.description,
    required this.models,
    this.ambientLight = const Vector3(0.1, 0.1, 0.1),
    this.lights = const [],
    this.settings = const {},
  });

  // Predefined scenes for DESSERT brand
  static final List<DessertScene> sceneList = [
    DessertScene(
      id: 'dessert_showcase',
      name: 'DESSERT Showcase',
      description: 'Main showcase scene with dessert-themed models',
      models: [
        DessertModel.pyramid(),
        DessertModel.cube(position: Vector3(2, 0.5, 0)),
        DessertModel.cube(position: Vector3(-2, 0.5, 0)),
        DessertModel.sphere(position: Vector3(0, 2, 2)),
      ],
      lights: [
        SceneLight(
          position: Vector3(5, 5, 5),
          color: Vector3(1, 0.8, 0.6),
          intensity: 1.0,
        ),
        SceneLight(
          position: Vector3(-5, 3, -5),
          color: Vector3(0.6, 0.8, 1),
          intensity: 0.5,
        ),
      ],
      settings: {
        'fog': true,
        'fogDensity': 0.01,
        'skybox': 'purple_gradient',
      },
    ),
    
    DessertScene(
      id: 'tech_demo',
      name: 'Tech Demo',
      description: 'Technical demonstration scene',
      models: List.generate(20, (index) {
        final angle = (index / 20) * 3.14159 * 2;
        return DessertModel.cube(
          position: Vector3(
            Math.cos(angle) * 5,
            0.5,
            Math.sin(angle) * 5,
          ),
          rotation: Vector3(0, angle, 0),
          color: Vector4(
            (Math.sin(angle) + 1) / 2,
            (Math.cos(angle) + 1) / 2,
            0.8,
            1.0,
          ),
        );
      }),
      lights: [
        SceneLight(
          position: Vector3(0, 10, 0),
          color: Vector3(1, 1, 1),
          intensity: 1.0,
          type: LightType.directional,
        ),
      ],
      settings: {
        'shadows': true,
        'reflections': false,
        'postProcessing': true,
      },
    ),
    
    DessertScene(
      id: 'minimal',
      name: 'Minimal',
      description: 'Clean minimal scene',
      models: [
        DessertModel.pyramid(
          position: Vector3.zero(),
          scale: Vector3(2, 3, 2),
          color: Vector4(0.8, 0.2, 0.8, 1),
        ),
      ],
      lights: [
        SceneLight(
          position: Vector3(3, 4, 3),
          color: Vector3(1, 1, 1),
          intensity: 0.8,
        ),
      ],
      settings: {
        'backgroundColor': Vector4(0.05, 0.05, 0.08, 1),
        'showGrid': true,
        'showAxis': true,
      },
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'models': models.map((model) => model.toJson()).toList(),
      'ambientLight': [ambientLight.x, ambientLight.y, ambientLight.z],
      'lights': lights.map((light) => light.toJson()).toList(),
      'settings': settings,
    };
  }

  static DessertScene fromJson(Map<String, dynamic> json) {
    return DessertScene(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      models: (json['models'] as List)
          .map((model) => DessertModel.fromJson(model))
          .toList(),
      ambientLight: Vector3(
        json['ambientLight'][0],
        json['ambientLight'][1],
        json['ambientLight'][2],
      ),
      lights: (json['lights'] as List)
          .map((light) => SceneLight.fromJson(light))
          .toList(),
      settings: Map<String, dynamic>.from(json['settings']),
    );
  }
}

class DessertModel {
  final String id;
  final String type;
  final Vector3 position;
  final Vector3 rotation;
  final Vector3 scale;
  final Vector4 color;
  final Map<String, dynamic> properties;

  DessertModel({
    required this.id,
    required this.type,
    required this.position,
    required this.rotation,
    required this.scale,
    required this.color,
    this.properties = const {},
  });

  // Factory constructors for common model types
  factory DessertModel.pyramid({
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    Vector4? color,
  }) {
    return DessertModel(
      id: 'pyramid_${DateTime.now().millisecondsSinceEpoch}',
      type: 'pyramid',
      position: position ?? Vector3.zero(),
      rotation: rotation ?? Vector3.zero(),
      scale: scale ?? Vector3.all(1.0),
      color: color ?? Vector4(1.0, 0.5, 0.2, 1.0),
      properties: {
        'height': 2.0,
        'baseSize': 1.0,
        'segments': 1,
      },
    );
  }

  factory DessertModel.cube({
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    Vector4? color,
  }) {
    return DessertModel(
      id: 'cube_${DateTime.now().millisecondsSinceEpoch}',
      type: 'cube',
      position: position ?? Vector3.zero(),
      rotation: rotation ?? Vector3.zero(),
      scale: scale ?? Vector3.all(1.0),
      color: color ?? Vector4(0.8, 0.2, 0.8, 1.0),
      properties: {
        'size': 1.0,
        'segments': 1,
      },
    );
  }

  factory DessertModel.sphere({
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    Vector4? color,
  }) {
    return DessertModel(
      id: 'sphere_${DateTime.now().millisecondsSinceEpoch}',
      type: 'sphere',
      position: position ?? Vector3.zero(),
      rotation: rotation ?? Vector3.zero(),
      scale: scale ?? Vector3.all(1.0),
      color: color ?? Vector4(0.2, 0.8, 0.8, 1.0),
      properties: {
        'radius': 1.0,
        'segments': 16,
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'position': [position.x, position.y, position.z],
      'rotation': [rotation.x, rotation.y, rotation.z],
      'scale': [scale.x, scale.y, scale.z],
      'color': [color.x, color.y, color.z, color.w],
      'properties': properties,
    };
  }

  static DessertModel fromJson(Map<String, dynamic> json) {
    return DessertModel(
      id: json['id'],
      type: json['type'],
      position: Vector3(
        (json['position'] as List)[0],
        (json['position'] as List)[1],
        (json['position'] as List)[2],
      ),
      rotation: Vector3(
        (json['rotation'] as List)[0],
        (json['rotation'] as List)[1],
        (json['rotation'] as List)[2],
      ),
      scale: Vector3(
        (json['scale'] as List)[0],
        (json['scale'] as List)[1],
        (json['scale'] as List)[2],
      ),
      color: Vector4(
        (json['color'] as List)[0],
        (json['color'] as List)[1],
        (json['color'] as List)[2],
        (json['color'] as List)[3],
      ),
      properties: Map<String, dynamic>.from(json['properties']),
    );
  }
}

class SceneLight {
  final Vector3 position;
  final Vector3 color;
  final double intensity;
  final LightType type;

  SceneLight({
    required this.position,
    required this.color,
    required this.intensity,
    this.type = LightType.point,
  });

  Map<String, dynamic> toJson() {
    return {
      'position': [position.x, position.y, position.z],
      'color': [color.x, color.y, color.z],
      'intensity': intensity,
      'type': type.name,
    };
  }

  static SceneLight fromJson(Map<String, dynamic> json) {
    return SceneLight(
      position: Vector3(
        (json['position'] as List)[0],
        (json['position'] as List)[1],
        (json['position'] as List)[2],
      ),
      color: Vector3(
        (json['color'] as List)[0],
        (json['color'] as List)[1],
        (json['color'] as List)[2],
      ),
      intensity: json['intensity'],
      type: LightType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => LightType.point,
      ),
    );
  }
}

enum LightType {
  point,
  directional,
  spot,
  ambient;
}

class Math {
  static double cos(double angle) => (angle as num).cos();
  static double sin(double angle) => (angle as num).sin();
}
