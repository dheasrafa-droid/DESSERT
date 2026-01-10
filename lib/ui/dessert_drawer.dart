import 'package:flutter/material.dart';
import 'package:dessert_engine/models/dessert_scene.dart';

class DessertDrawer extends StatelessWidget {
  const DessertDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.95),
      width: 280,
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/patterns/dessert_pattern.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'DESSERT',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '3D Engine v1.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.landscape,
                  label: 'Scenes',
                  onTap: () => _navigateToScenes(context),
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  label: 'Engine Settings',
                  onTap: () => _navigateToSettings(context),
                ),
                _buildDrawerItem(
                  icon: Icons.code,
                  label: 'Shader Editor',
                  onTap: () => _navigateToShaderEditor(context),
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  label: 'Documentation',
                  onTap: () => _openDocumentation(context),
                ),
                
                const Divider(color: Colors.deepPurpleAccent, height: 20),
                
                _buildDrawerItem(
                  icon: Icons.palette,
                  label: 'Theme',
                  onTap: () => _changeTheme(context),
                ),
                _buildDrawerItem(
                  icon: Icons.import_export,
                  label: 'Import/Export',
                  onTap: () => _showImportExport(context),
                ),
                _buildDrawerItem(
                  icon: Icons.backup,
                  label: 'Backup',
                  onTap: () => _createBackup(context),
                ),
                
                const Divider(color: Colors.deepPurpleAccent, height: 20),
                
                _buildDrawerItem(
                  icon: Icons.info,
                  label: 'About',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildDrawerItem(
                  icon: Icons.exit_to_app,
                  label: 'Exit',
                  onTap: () => _exitApplication(context),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.deepPurple.withOpacity(0.3), width: 1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'GPU: WebGL2 Ready',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0 • © 2024 DESSERT',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.deepPurpleAccent,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.deepPurpleAccent,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _navigateToScenes(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Select Scene',
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: DessertScene.sceneList.map((scene) {
              return ListTile(
                leading: Icon(Icons.landscape, color: Colors.deepPurple),
                title: Text(
                  scene.name,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  scene.description,
                  style: TextStyle(color: Colors.grey),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.deepPurple),
                onTap: () {
                  Navigator.pop(context);
                  // Load scene logic here
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    // Implement settings navigation
  }

  void _navigateToShaderEditor(BuildContext context) {
    // Implement shader editor navigation
  }

  void _openDocumentation(BuildContext context) {
    // Open documentation
  }

  void _changeTheme(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Select Theme',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Dark', Colors.deepPurple, true),
            _buildThemeOption('Light', Colors.amber, false),
            _buildThemeOption('Cyberpunk', Colors.pink, false),
            _buildThemeOption('Matrix', Colors.green, false),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String name, Color color, bool selected) {
    return ListTile(
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        name,
        style: TextStyle(color: Colors.white),
      ),
      trailing: selected ? Icon(Icons.check, color: color) : null,
      onTap: () {
        // Change theme logic
      },
    );
  }

  void _showImportExport(BuildContext context) {
    // Implement import/export dialog
  }

  void _createBackup(BuildContext context) {
    // Implement backup logic
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.95),
        title: Text(
          'About DESSERT Engine',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A custom 3D engine built with Flutter Web and WebGL2.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('Custom WebGL2 Renderer'),
            _buildFeatureItem('Real-time Scene Editor'),
            _buildFeatureItem('Shader Pipeline'),
            _buildFeatureItem('GPU Statistics'),
            _buildFeatureItem('Cross-platform Support'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 14),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _exitApplication(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Exit Application',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to exit?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Additional exit logic if needed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
