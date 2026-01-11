/// DSRT Engine Version Information
class Version {
  /// Engine version (MAJOR.MINOR.PATCH)
  static const String version = '0.1.0-alpha';
  
  /// Build timestamp
  static const String build = '2024.01.01';
  
  /// Build number
  static const int buildNumber = 1;
  
  /// API version
  static const String apiVersion = 'v1';
  
  /// Engine name
  static const String name = 'DSRT Engine';
  
  /// Engine codename
  static const String codename = 'Dartium';
  
  /// Copyright year
  static const String copyright = '2024 DSRT Team';
  
  /// License
  static const String license = 'MIT License';
  
  /// Repository URL
  static const String repository = 'https://github.com/yourname/dsrt_engine';
  
  /// Documentation URL
  static const String documentation = 'https://dsrt-engine.dev/docs';
  
  /// Support email
  static const String support = 'support@dsrt-engine.dev';
  
  /// Get version info as map
  static Map<String, dynamic> get info {
    return {
      'name': name,
      'version': version,
      'build': build,
      'buildNumber': buildNumber,
      'apiVersion': apiVersion,
      'codename': codename,
      'copyright': copyright,
      'license': license,
      'repository': repository,
      'documentation': documentation,
      'support': support,
    };
  }
  
  /// Check if version is compatible with another version
  static bool isCompatible(String otherVersion) {
    final currentParts = version.split('.');
    final otherParts = otherVersion.split('.');
    
    if (currentParts.length < 2 || otherParts.length < 2) return false;
    
    // Major version must match
    return currentParts[0] == otherParts[0];
  }
  
  /// Compare versions
  /// Returns:
  ///   -1 if this < other
  ///    0 if this == other
  ///    1 if this > other
  static int compare(String otherVersion) {
    final currentParts = _parseVersion(version);
    final otherParts = _parseVersion(otherVersion);
    
    for (int i = 0; i < 3; i++) {
      if (currentParts[i] < otherParts[i]) return -1;
      if (currentParts[i] > otherParts[i]) return 1;
    }
    
    return 0;
  }
  
  /// Parse version string into [major, minor, patch]
  static List<int> _parseVersion(String versionStr) {
    // Remove suffix like "-alpha", "-beta", etc.
    final cleanVersion = versionStr.split('-').first;
    final parts = cleanVersion.split('.');
    
    return [
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0,
    ];
  }
  
  /// Get version as integer (for sorting/comparison)
  static int get versionCode {
    final parts = _parseVersion(version);
    return parts[0] * 1000000 + parts[1] * 1000 + parts[2];
  }
  
  @override
  String toString() {
    return '$name $version (Build $build)';
  }
}
