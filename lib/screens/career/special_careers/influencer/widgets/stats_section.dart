import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../models/character.dart';
import '../../../../../widgets/common_widgets.dart';

class InfluencerStatsSection extends StatelessWidget {
  final Character character;

  const InfluencerStatsSection({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader.band('CREATOR STATS'),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatTile(
                  label: 'Followers',
                  value: _formatFollowers(character.followers)),
              _StatTile(label: 'Fame', value: '${character.fame}%'),
              _StatTile(label: 'Engagement', value: '${character.engagement}%'),
              _StatTile(label: 'Reputation', value: '${character.reputation}%'),
            ],
          ),
        ),
      ],
    );
  }

  String _formatFollowers(int value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        border: Border.all(color: const Color(0xFFE4E4E7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF181C1F),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF71717A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
