import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MovieRequirementTile extends StatelessWidget {
  final String label;
  final String value;

  const MovieRequirementTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        border: Border.all(color: const Color(0xFFBBCBBB), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF006D37),
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5C5E62),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF161C28),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
