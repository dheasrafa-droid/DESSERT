import 'package:vector_math/vector_math_64.dart';

class MathUtils {
  static const double epsilon = 0.000001;
  static const double pi = 3.141592653589793;
  static const double twoPi = pi * 2;
  static const double halfPi = pi / 2;
  static const double degToRad = pi / 180.0;
  static const double radToDeg = 180.0 / pi;

  /// Converts degrees to radians
  static double toRadians(double degrees) => degrees * degToRad;

  /// Converts radians to degrees
  static double toDegrees(double radians) => radians * radToDeg;

  /// Linearly interpolates between two values
  static double lerp(double a, double b, double t) => a + (b - a) * t;

  /// Clamps a value between min and max
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Returns the smoothstep interpolation
  static double smoothstep(double edge0, double edge1, double x) {
    final t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
  }

  /// Creates a look-at matrix
  static Matrix4 lookAt(
    Vector3 eye,
    Vector3 target,
    Vector3 up,
  ) {
    final zAxis = (eye - target).normalized();
    final xAxis = up.cross(zAxis).normalized();
    final yAxis = zAxis.cross(xAxis);

    return Matrix4(
      xAxis.x, xAxis.y, xAxis.z, -xAxis.dot(eye),
      yAxis.x, yAxis.y, yAxis.z, -yAxis.dot(eye),
      zAxis.x, zAxis.y, zAxis.z, -zAxis.dot(eye),
      0, 0, 0, 1,
    );
  }

  /// Creates a perspective projection matrix
  static Matrix4 perspective(
    double fovY,
    double aspect,
    double zNear,
    double zFar,
  ) {
    final f = 1.0 / math.tan(fovY * degToRad / 2.0);
    final rangeInv = 1.0 / (zNear - zFar);

    return Matrix4(
      f / aspect, 0, 0, 0,
      0, f, 0, 0,
      0, 0, (zNear + zFar) * rangeInv, 2 * zNear * zFar * rangeInv,
      0, 0, -1, 0,
    );
  }

  /// Creates an orthographic projection matrix
  static Matrix4 orthographic(
    double left,
    double right,
    double bottom,
    double top,
    double near,
    double far,
  ) {
    final lr = 1.0 / (left - right);
    final bt = 1.0 / (bottom - top);
    final nf = 1.0 / (near - far);

    return Matrix4(
      -2.0 * lr, 0, 0, (left + right) * lr,
      0, -2.0 * bt, 0, (top + bottom) * bt,
      0, 0, 2.0 * nf, (near + far) * nf,
      0, 0, 0, 1,
    );
  }

  /// Spherical interpolation between two quaternions
  static Quaternion slerp(Quaternion a, Quaternion b, double t) {
    final dot = a.dot(b);
    
    if (dot.abs() >= 1.0) {
      return a.clone();
    }
    
    final theta = math.acos(dot.abs());
    final sinTheta = math.sin(theta);
    
    if (sinTheta < epsilon) {
      return Quaternion.identity();
    }
    
    final ratioA = math.sin((1.0 - t) * theta) / sinTheta;
    final ratioB = math.sin(t * theta) / sinTheta;
    
    final result = Quaternion.identity();
    result.x = ratioA * a.x + ratioB * b.x;
    result.y = ratioA * a.y + ratioB * b.y;
    result.z = ratioA * a.z + ratioB * b.z;
    result.w = ratioA * a.w + ratioB * b.w;
    
    return result.normalized();
  }

  /// Generates a random float between min and max
  static double randomRange(double min, double max) {
    return min + (max - min) * math.Random().nextDouble();
  }

  /// Generates a random vector within a sphere
  static Vector3 randomInSphere(double radius) {
    final random = math.Random();
    final theta = random.nextDouble() * twoPi;
    final phi = math.acos(2.0 * random.nextDouble() - 1.0);
    final r = radius * math.pow(random.nextDouble(), 1.0 / 3.0);
    
    return Vector3(
      r * math.sin(phi) * math.cos(theta),
      r * math.sin(phi) * math.sin(theta),
      r * math.cos(phi),
    );
  }

  /// Generates a random color
  static Vector4 randomColor({double alpha = 1.0}) {
    final random = math.Random();
    return Vector4(
      random.nextDouble(),
      random.nextDouble(),
      random.nextDouble(),
      alpha,
    );
  }

  /// Calculates the bounding box for a list of vertices
  static (Vector3, Vector3) calculateBoundingBox(Float32List vertices) {
    if (vertices.isEmpty) {
      return (Vector3.zero(), Vector3.zero());
    }
    
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    double minZ = double.infinity, maxZ = double.negativeInfinity;
    
    for (int i = 0; i < vertices.length; i += 3) {
      final x = vertices[i];
      final y = vertices[i + 1];
      final z = vertices[i + 2];
      
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
      if (z < minZ) minZ = z;
      if (z > maxZ) maxZ = z;
    }
    
    return (
      Vector3(minX, minY, minZ),
      Vector3(maxX, maxY, maxZ),
    );
  }

  /// Calculates the normal for a triangle
  static Vector3 calculateNormal(
    Vector3 v1,
    Vector3 v2,
    Vector3 v3,
  ) {
    final edge1 = v2 - v1;
    final edge2 = v3 - v1;
    return edge1.cross(edge2).normalized();
  }

  /// Converts Euler angles to a quaternion
  static Quaternion eulerToQuaternion(Vector3 euler) {
    final cy = math.cos(euler.z * 0.5);
    final sy = math.sin(euler.z * 0.5);
    final cp = math.cos(euler.y * 0.5);
    final sp = math.sin(euler.y * 0.5);
    final cr = math.cos(euler.x * 0.5);
    final sr = math.sin(euler.x * 0.5);
    
    return Quaternion(
      sr * cp * cy - cr * sp * sy,
      cr * sp * cy + sr * cp * sy,
      cr * cp * sy - sr * sp * cy,
      cr * cp * cy + sr * sp * sy,
    );
  }

  /// Converts a quaternion to Euler angles
  static Vector3 quaternionToEuler(Quaternion q) {
    // Roll (x-axis rotation)
    final sinrCosp = 2.0 * (q.w * q.x + q.y * q.z);
    final cosrCosp = 1.0 - 2.0 * (q.x * q.x + q.y * q.y);
    final roll = math.atan2(sinrCosp, cosrCosp);

    // Pitch (y-axis rotation)
    final sinp = 2.0 * (q.w * q.y - q.z * q.x);
    double pitch;
    if (sinp.abs() >= 1.0) {
      pitch = math.copySign(pi / 2, sinp);
    } else {
      pitch = math.asin(sinp);
    }

    // Yaw (z-axis rotation)
    final sinyCosp = 2.0 * (q.w * q.z + q.x * q.y);
    final cosyCosp = 1.0 - 2.0 * (q.y * q.y + q.z * q.z);
    final yaw = math.atan2(sinyCosp, cosyCosp);

    return Vector3(roll, pitch, yaw);
  }

  /// Creates a rotation matrix from axis and angle
  static Matrix4 rotationAxisAngle(Vector3 axis, double angle) {
    final normalizedAxis = axis.normalized();
    final c = math.cos(angle);
    final s = math.sin(angle);
    final t = 1.0 - c;
    
    final x = normalizedAxis.x;
    final y = normalizedAxis.y;
    final z = normalizedAxis.z;
    
    return Matrix4(
      t * x * x + c,     t * x * y - s * z, t * x * z + s * y, 0,
      t * x * y + s * z, t * y * y + c,     t * y * z - s * x, 0,
      t * x * z - s * y, t * y * z + s * x, t * z * z + c,     0,
      0, 0, 0, 1,
    );
  }

  /// Projects a 3D point to 2D screen coordinates
  static Vector2 projectPoint(
    Vector3 point,
    Matrix4 viewMatrix,
    Matrix4 projectionMatrix,
    double screenWidth,
    double screenHeight,
  ) {
    final viewProjection = projectionMatrix * viewMatrix;
    final clipSpace = viewProjection.transform3(point);
    
    if (clipSpace.z <= 0) {
      return Vector2(-1, -1); // Behind camera
    }
    
    final ndc = Vector2(
      clipSpace.x / clipSpace.z,
      clipSpace.y / clipSpace.z,
    );
    
    return Vector2(
      (ndc.x + 1.0) * 0.5 * screenWidth,
      (1.0 - ndc.y) * 0.5 * screenHeight,
    );
  }
}

// Extension for Vector operations
extension VectorExtensions on Vector3 {
  /// Rotates the vector by a quaternion
  Vector3 rotateByQuaternion(Quaternion q) {
    final uv = q.xyz.cross(this);
    final uuv = q.xyz.cross(uv);
    return this + (uv * 2.0 * q.w) + (uuv * 2.0);
  }

  /// Returns a vector with each component clamped
  Vector3 clamped(double min, double max) {
    return Vector3(
      MathUtils.clamp(x, min, max),
      MathUtils.clamp(y, min, max),
      MathUtils.clamp(z, min, max),
    );
  }

  /// Linear interpolation between two vectors
  Vector3 lerp(Vector3 other, double t) {
    return Vector3(
      MathUtils.lerp(x, other.x, t),
      MathUtils.lerp(y, other.y, t),
      MathUtils.lerp(z, other.z, t),
    );
  }

  /// Returns the distance to another vector
  double distanceTo(Vector3 other) {
    return (this - other).length;
  }

  /// Returns the squared distance to another vector (faster)
  double distanceToSquared(Vector3 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return dx * dx + dy * dy + dz * dz;
  }

  /// Returns a vector with each component rounded
  Vector3 rounded() {
    return Vector3(
      x.roundToDouble(),
      y.roundToDouble(),
      z.roundToDouble(),
    );
  }
}
