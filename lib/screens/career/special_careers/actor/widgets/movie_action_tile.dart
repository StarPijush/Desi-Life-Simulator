import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MovieActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const MovieActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFBA1A1A) : const Color(0xFF006D37);
    final textColor = isDestructive ? const Color(0xFFBA1A1A) : const Color(0xFF161C28);
    final chevronColor = isDestructive ? const Color(0xFFBA1A1A) : const Color(0xFF6C7B6D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: const Color(0xFFE8EEFF),
        splashColor: const Color(0xFFE8EEFF),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: chevronColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
