import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/design_system.dart';
import '../../../../../models/character.dart';

class InfluencerProfileSection extends StatelessWidget {
  final Character character;

  const InfluencerProfileSection({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final active =
        character.careerGroup == 'Influencer' && character.annualIncome > 0;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F7EF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.alternate_email,
                color: Color(0xFF059669), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        character.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF181C1F),
                        ),
                      ),
                    ),
                    if (character.isVerified)
                      const Icon(Icons.verified,
                          color: Color(0xFF2563EB), size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  active ? character.jobTitle : 'Aspiring Influencer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5C5E62),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  active
                      ? '${formatMoney(character.annualIncome)}/yr'
                      : 'Not started',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? const Color(0xFF059669)
                        : const Color(0xFF71717A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
