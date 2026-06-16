import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TVAuditionTile extends StatelessWidget {
  final String showTitle;
  final String genre;
  final String roleType;
  final String iconEmoji;
  final VoidCallback onTap;

  const TVAuditionTile({
    super.key,
    required this.showTitle,
    required this.genre,
    required this.roleType,
    required this.iconEmoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: const Color(0xFFDEDFE3).withValues(alpha: 0.3),
        splashColor: const Color(0xFFDEDFE3).withValues(alpha: 0.3),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFDDE2F3), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Text(
                iconEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showTitle,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF161C28),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          genre,
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3D4A3E),
                          ),
                        ),
                        Text(
                          ' • $roleType',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF006D37),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFC5C6CA),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
