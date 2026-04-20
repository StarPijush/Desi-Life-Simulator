// lib/widgets/pill_button.dart
import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;
  final bool outlined;

  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF1A56DB),
    this.textColor = Colors.white,
    this.fontSize = 15,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: padding,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(50),
          border: outlined ? Border.all(color: color, width: 2) : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: outlined ? color : textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
