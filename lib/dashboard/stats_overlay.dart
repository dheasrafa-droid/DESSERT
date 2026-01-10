import 'package:flutter/material.dart';
import 'package:dessert_engine/core/dessert_engine.dart';

class StatsOverlay extends StatefulWidget {
  final DessertEngine engine;

  const StatsOverlay({super.key, required this.engine});

  @override
  State<StatsOverlay> createState() => _StatsOverlayState();
}

class _StatsOverlayState extends State<StatsOverlay> {
  late Map<String, dynamic> _stats;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _stats = widget.engine.getStats();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _stats = widget.engine.getStats();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurple, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.monitor_heart, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                'Performance Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.deepPurpleAccent, height: 1),
          const SizedBox(height: 8),

          // Stats Grid
          _buildStatItem('FPS', '${_stats['fps']}', Icons.speed, Colors.green),
          _buildStatItem('Triangles', '${_stats['triangles']}', Icons.polyline, Colors.blue),
          _buildStatItem('Models', '${_stats['models']}', Icons.cube, Colors.orange),
          _buildStatItem('GPU Memory', '${_stats['memory']} KB', Icons.memory, Colors.purple),
          
          // Performance Indicator
          const SizedBox(height: 8),
          _buildPerformanceBar(_stats['fps']),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color, width: 0.5),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBar(int fps) {
    double performance = fps / 60.0; // Normalize to 60 FPS target
    Color color = Colors.red;
    
    if (performance > 0.8) {
      color = Colors.green;
    } else if (performance > 0.5) {
      color = Colors.orange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assessment, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              'Performance',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
            const Spacer(),
            Text(
              '${(performance * 100).toInt()}%',
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: performance.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
