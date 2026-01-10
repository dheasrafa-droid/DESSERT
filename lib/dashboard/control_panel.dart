import 'package:flutter/material.dart';
import 'package:dessert_engine/core/dessert_engine.dart';
import 'package:vector_math/vector_math_64.dart';

class ControlPanel extends StatefulWidget {
  final DessertEngine engine;
  final VoidCallback onToggleStats;
  final VoidCallback onToggleEditor;

  const ControlPanel({
    super.key,
    required this.engine,
    required this.onToggleStats,
    required this.onToggleEditor,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  bool _wireframeMode = false;
  bool _shadowsEnabled = true;
  bool _postProcessing = true;
  double _cameraSpeed = 1.0;
  double _rotationSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.settings, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Control Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.deepPurpleAccent, height: 1),
          const SizedBox(height: 16),

          // Scene Controls
          _buildSectionHeader('Scene Controls'),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  'Reset Scene',
                  Icons.refresh,
                  Colors.orange,
                  () => widget.engine.setScene('default'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  'Add Model',
                  Icons.add_box,
                  Colors.green,
                  () => widget.engine.addModel(
                    Vector3(
                      2 * (DateTime.now().millisecondsSinceEpoch % 100) / 100 - 1,
                      1.0,
                      2 * (DateTime.now().millisecondsSinceEpoch % 100) / 100 - 1,
                    ),
                    Vector3.zero(),
                    Vector3.all(0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rendering Options
          _buildSectionHeader('Rendering Options'),
          const SizedBox(height: 12),
          
          _buildToggle(
            'Wireframe Mode',
            _wireframeMode,
            Icons.grid_on,
            (value) => setState(() => _wireframeMode = value),
          ),
          _buildToggle(
            'Enable Shadows',
            _shadowsEnabled,
            Icons.shadow,
            (value) => setState(() => _shadowsEnabled = value),
          ),
          _buildToggle(
            'Post Processing',
            _postProcessing,
            Icons.filter,
            (value) => setState(() => _postProcessing = value),
          ),
          const SizedBox(height: 12),

          // Speed Controls
          _buildSectionHeader('Camera & Rotation'),
          const SizedBox(height: 12),
          
          _buildSlider(
            'Camera Speed',
            _cameraSpeed,
            0.1,
            5.0,
            Icons.speed,
            (value) => setState(() => _cameraSpeed = value),
          ),
          _buildSlider(
            'Rotation Speed',
            _rotationSpeed,
            0.1,
            5.0,
            Icons.rotate_right,
            (value) => setState(() => _rotationSpeed = value),
          ),
          const SizedBox(height: 12),

          // View Controls
          _buildSectionHeader('View Controls'),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  _shadowsEnabled ? 'Hide Stats' : 'Show Stats',
                  Icons.bar_chart,
                  Colors.blue,
                  widget.onToggleStats,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  'Scene Editor',
                  Icons.edit,
                  Colors.purple,
                  widget.onToggleEditor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.deepPurpleAccent,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color, width: 1),
        ),
      ),
    );
  }

  Widget _buildToggle(
    String label,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.deepPurple,
          inactiveTrackColor: Colors.grey[800],
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    IconData icon,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(1)}x',
              style: TextStyle(color: Colors.deepPurpleAccent, fontSize: 12),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 10,
          onChanged: onChanged,
          activeColor: Colors.deepPurple,
          inactiveColor: Colors.grey[800],
        ),
      ],
    );
  }
}
