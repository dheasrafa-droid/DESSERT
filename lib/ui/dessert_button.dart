import 'package:flutter/material.dart';

class DessertButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final DessertButtonType type;
  final bool isLoading;
  final double width;
  final double height;
  final Color? customColor;
  final bool disabled;

  const DessertButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.type = DessertButtonType.primary,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 48,
    this.customColor,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);
    final borderRadius = BorderRadius.circular(12);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: colors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: disabled || isLoading ? null : onPressed,
          borderRadius: borderRadius,
          splashColor: colors.splashColor,
          highlightColor: colors.highlightColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Content
                Opacity(
                  opacity: isLoading ? 0 : 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 20,
                          color: colors.textColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: colors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Loading indicator
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.textColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _getColors(BuildContext context) {
    if (disabled) {
      return _ButtonColors(
        backgroundGradient: [
          Colors.grey[800]!,
          Colors.grey[900]!,
        ],
        textColor: Colors.grey,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        shadowColor: Colors.transparent,
      );
    }

    switch (type) {
      case DessertButtonType.primary:
        return _ButtonColors(
          backgroundGradient: customColor != null
              ? [customColor!, customColor!.withOpacity(0.8)]
              : [
                  Colors.deepPurple,
                  Colors.purple,
                ],
          textColor: Colors.white,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          shadowColor: Colors.deepPurple.withOpacity(0.3),
        );

      case DessertButtonType.secondary:
        return _ButtonColors(
          backgroundGradient: [
            Colors.transparent,
            Colors.transparent,
          ],
          textColor: Colors.deepPurple,
          splashColor: Colors.deepPurple.withOpacity(0.1),
          highlightColor: Colors.deepPurple.withOpacity(0.05),
          shadowColor: Colors.transparent,
        );

      case DessertButtonType.success:
        return _ButtonColors(
          backgroundGradient: [
            Colors.green,
            Colors.greenAccent,
          ],
          textColor: Colors.white,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          shadowColor: Colors.green.withOpacity(0.3),
        );

      case DessertButtonType.warning:
        return _ButtonColors(
          backgroundGradient: [
            Colors.orange,
            Colors.deepOrange,
          ],
          textColor: Colors.white,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          shadowColor: Colors.orange.withOpacity(0.3),
        );

      case DessertButtonType.danger:
        return _ButtonColors(
          backgroundGradient: [
            Colors.red,
            Colors.redAccent,
          ],
          textColor: Colors.white,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          shadowColor: Colors.red.withOpacity(0.3),
        );

      case DessertButtonType.glass:
        return _ButtonColors(
          backgroundGradient: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          textColor: Colors.white,
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.2),
          shadowColor: Colors.white.withOpacity(0.1),
        );
    }
  }
}

class _ButtonColors {
  final List<Color> backgroundGradient;
  final Color textColor;
  final Color splashColor;
  final Color highlightColor;
  final Color shadowColor;

  _ButtonColors({
    required this.backgroundGradient,
    required this.textColor,
    required this.splashColor,
    required this.highlightColor,
    required this.shadowColor,
  });
}

enum DessertButtonType {
  primary,
  secondary,
  success,
  warning,
  danger,
  glass,
}

// Icon Button variant
class DessertIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? color;
  final bool isLoading;
  final bool disabled;
  final String? tooltip;

  const DessertIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.color,
    this.isLoading = false,
    this.disabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Colors.deepPurple;
    final borderRadius = BorderRadius.circular(size / 2);

    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: disabled
                ? [Colors.grey[800]!, Colors.grey[900]!]
                : [
                    buttonColor,
                    buttonColor.withOpacity(0.8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: disabled
                  ? Colors.transparent
                  : buttonColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: disabled || isLoading ? null : onPressed,
            borderRadius: borderRadius,
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: size * 0.5,
                      height: size * 0.5,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      icon,
                      size: size * 0.5,
                      color: disabled ? Colors.grey : Colors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Floating Action Button variant
class DessertFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool extended;

  const DessertFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.deepPurple;
    final fgColor = foregroundColor ?? Colors.white;

    if (extended && label != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          icon: Icon(icon, color: fgColor),
          label: Text(
            label!,
            style: TextStyle(color: fgColor, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        child: Icon(icon, color: fgColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
