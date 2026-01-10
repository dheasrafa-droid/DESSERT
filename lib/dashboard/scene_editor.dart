import 'package:flutter/material.dart';
import 'package:dessert_engine/core/dessert_engine.dart';
import 'package:vector_math/vector_math_64.dart';

class SceneEditor extends StatefulWidget {
  final DessertEngine engine;

  const SceneEditor({super.key, required this.engine});

  @override
  State<SceneEditor> createState() => _SceneEditorState();
}

class _SceneEditorState extends State<SceneEditor> {
  final _selectedModels = <int>{};
  Vector3 _position = Vector3.zero();
  Vector3 _rotation = Vector3.zero();
  Vector3 _scale = Vector3.all(1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
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
              Icon(Icons.edit, color: Colors.deepPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Scene Editor',
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

          // Transform Controls
          _buildTransformSection(),
          const SizedBox(height: 16),

          // Model List
          _buildModelList(),
          const SizedBox(height: 16),

          // Actions
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTransformSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transform',
          style: TextStyle(
            color: Colors.deepPurpleAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildVectorControl(
          'Position',
          _position,
          Icons.open_with,
          (index, value) {
            setState(() {
              if (index == 0) _position.x = value;
              if (index == 1) _position.y = value;
              if (index == 2) _position.z = value;
            });
          },
        ),
        
        _buildVectorControl(
          'Rotation',
          _rotation,
          Icons.rotate_90_degrees_ccw,
          (index, value) {
            setState(() {
              if (index == 0) _rotation.x = value;
              if (index == 1) _rotation.y = value;
              if (index == 2) _rotation.z = value;
            });
          },
        ),
        
        _buildVectorControl(
          'Scale',
          _scale,
          Icons.aspect_ratio,
          (index, value) {
            setState(() {
              if (index == 0) _scale.x = value;
              if (index == 1) _scale.y = value;
              if (index == 2) _scale.z = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVectorControl(
    String label,
    Vector3 vector,
    IconData icon,
    ValueChanged2<int, double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildNumberInput('X', vector.x, (value) => onChanged(0, value)),
            const SizedBox(width: 8),
            _buildNumberInput('Y', vector.y, (value) => onChanged(1, value)),
            const SizedBox(width: 8),
            _buildNumberInput('Z', vector.z, (value) => onChanged(2, value)),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNumberInput(String label, double value, ValueChanged<double> onChanged) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.deepPurple.withOpacity(0.5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.deepPurple, fontSize: 10),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: value.toStringAsFixed(2)),
                    onChanged: (text) {
                      final parsed = double.tryParse(text);
                      if (parsed != null) onChanged(parsed);
                    },
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => onChanged(value + 0.1),
                      child: Icon(Icons.arrow_drop_up, color: Colors.deepPurple, size: 16),
                    ),
                    GestureDetector(
                      onTap: () => onChanged(value - 0.1),
                      child: Icon(Icons.arrow_drop_down, color: Colors.deepPurple, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Models in Scene',
          style: TextStyle(
            color: Colors.deepPurpleAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.deepPurple.withOpacity(0.5), width: 1),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: 10, // Replace with actual model count
            itemBuilder: (context, index) {
              final isSelected = _selectedModels.contains(index);
              return ListTile(
                leading: Icon(
                  Icons.cube,
                  color: isSelected ? Colors.deepPurple : Colors.grey,
                ),
                title: Text(
                  'Model ${index + 1}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.deepPurple, size: 16)
                    : null,
                onTap: () {
                  setState(() {
                    if (_selectedModels.contains(index)) {
                      _selectedModels.remove(index);
                    } else {
                      _selectedModels.add(index);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              widget.engine.addModel(_position, _rotation, _scale);
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Model'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _position = Vector3.zero();
                _rotation = Vector3.zero();
                _scale = Vector3.all(1.0);
              });
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

typedef ValueChanged2<T1, T2> = void Function(T1, T2);
