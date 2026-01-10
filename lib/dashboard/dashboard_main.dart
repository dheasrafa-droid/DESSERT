import 'package:flutter/material.dart';
import 'package:dessert_engine/core/dessert_engine.dart';
import 'control_panel.dart';
import 'stats_overlay.dart';
import 'scene_editor.dart';

class DashboardMain extends StatefulWidget {
  final DessertEngine engine;

  const DashboardMain({super.key, required this.engine});

  @override
  State<DashboardMain> createState() => _DashboardMainState();
}

class _DashboardMainState extends State<DashboardMain> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showControlPanel = true;
  bool _showStats = true;
  bool _showSceneEditor = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 3D Engine Canvas Container
        Positioned.fill(
          child: Container(
            color: Colors.transparent,
          ),
        ),

        // Control Panel
        if (_showControlPanel)
          Positioned(
            left: 20,
            top: 20,
            child: ControlPanel(
              engine: widget.engine,
              onToggleStats: () => setState(() => _showStats = !_showStats),
              onToggleEditor: () => setState(() => _showSceneEditor = !_showSceneEditor),
            ),
          ),

        // Stats Overlay
        if (_showStats)
          Positioned(
            right: 20,
            top: 20,
            child: StatsOverlay(engine: widget.engine),
          ),

        // Scene Editor
        if (_showSceneEditor)
          Positioned(
            right: 20,
            bottom: 20,
            child: SceneEditor(engine: widget.engine),
          ),

        // Floating Action Button
        Positioned(
          bottom: 20,
          left: 20,
          child: FloatingActionButton(
            onPressed: () {
              widget.engine.addModel(
                Vector3(
                  (DateTime.now().millisecondsSinceEpoch % 100) / 50 - 1,
                  0.5,
                  (DateTime.now().millisecondsSinceEpoch % 100) / 50 - 1,
                ),
                Vector3.zero(),
                Vector3.all(0.3),
              );
            },
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
