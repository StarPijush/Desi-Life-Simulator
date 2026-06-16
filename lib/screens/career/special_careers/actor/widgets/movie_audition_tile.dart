import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MovieAuditionTile extends StatelessWidget {
  final String title;
  final String genre;
  final String roleType;
  final String iconEmoji;
  final VoidCallback onTap;

  const MovieAuditionTile({
    super.key,
    required this.title,
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
        highlightColor: const Color(0xFFF1F3FF),
        splashColor: const Color(0xFFF1F3FF),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEFF),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    iconEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF161C28),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          genre,
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF006D37),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            '•',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: const Color(0xFF6C7B6D),
                            ),
                          ),
                        ),
                        Text(
                          roleType,
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3D4A3E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF6C7B6D),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
