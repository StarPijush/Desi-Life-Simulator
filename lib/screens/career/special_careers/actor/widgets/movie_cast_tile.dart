import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie_project.dart';

class MovieCastTile extends StatelessWidget {
  final MovieCastMember member;
  final VoidCallback onTap;

  const MovieCastTile({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: const Color(0xFFE8EEFF),
        splashColor: const Color(0xFFE8EEFF),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF161C28),
                        height: 1.2,
                      ),
                    ),
                    Text(
                      member.role,
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5E62),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF6C7B6D), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
