import 'package:flutter/material.dart';

class DessertCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double elevation;
  final double borderRadius;
  final Color? backgroundColor;
  final bool glassEffect;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DessertCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.elevation = 4,
    this.borderRadius = 16,
    this.backgroundColor,
    this.glassEffect = false,
    this.gradient,
    this.border,
    this.shadows,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);
    final cardBackground = backgroundColor ?? colors.cardColor;
    final cardShadows = shadows ?? _getDefaultShadows(elevation);

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: glassEffect ? Colors.transparent : cardBackground,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: cardShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    // Add glass effect overlay if enabled
    if (glassEffect) {
      cardContent = Stack(
        children: [
          // Glass blur background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: _getBlurFilter(),
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ),
          
          // Content
          cardContent,
        ],
      );
    }

    // Make tappable if onTap is provided
    if (onTap != null || onLongPress != null) {
      return InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }

  List<BoxShadow> _getDefaultShadows(double elevation) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1 * elevation),
        blurRadius: 8 * elevation,
        offset: Offset(0, 2 * elevation),
      ),
      BoxShadow(
        color: Colors.deepPurple.withOpacity(0.05 * elevation),
        blurRadius: 4 * elevation,
        offset: Offset(0, 1 * elevation),
      ),
    ];
  }

  ui.ImageFilter _getBlurFilter() {
    return ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10);
  }
}

// Specialized card types
class DessertSceneCard extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final int modelCount;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSelected;

  const DessertSceneCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.modelCount = 0,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return DessertCard(
      onTap: onTap,
      padding: const EdgeInsets.all(0),
      border: Border.all(
        color: isSelected ? Colors.deepPurple : Colors.transparent,
        width: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail area
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Stack(
              children: [
                // Placeholder 3D preview
                Center(
                  child: Icon(
                    Icons.landscape,
                    size: 48,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                
                // Model count badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cube,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$modelCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Open'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                        tooltip: 'Edit',
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Delete',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DessertStatsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String unit;
  final Color? color;
  final double progress;
  final bool showProgress;

  const DessertStatsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.unit,
    this.color,
    this.progress = 0.0,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Colors.deepPurple;
    
    return DessertCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: cardColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: cardColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: cardColor.withOpacity(0.2),
              color: cardColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
    );
  }
}

class DessertSettingsCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget control;
  final IconData? icon;

  const DessertSettingsCard({
    super.key,
    required this.title,
    required this.description,
    required this.control,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DessertCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.deepPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          control,
        ],
      ),
    );
  }
}
