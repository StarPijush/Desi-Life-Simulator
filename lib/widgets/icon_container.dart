// lib/widgets/icon_container.dart
import 'package:flutter/material.dart';
import '../core/design_system.dart';

/// Consistent icon container with soft tinted background.
class IconContainer extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final double size;
  final double iconSize;

  const IconContainer({
    super.key,
    required this.icon,
    required this.gradient,
    this.size = 40,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient.first.withValues(alpha: 0.15),
            gradient.last.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Center(
        child: Icon(icon, color: gradient.first, size: iconSize),
      ),
    );
  }
}
