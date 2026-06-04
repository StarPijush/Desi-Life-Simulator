import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum MilitaryRankState {
  completed,
  active,
  locked,
}

class MilitaryRankProgress {
  final String rank;
  final MilitaryRankState state;
  final String? status;

  const MilitaryRankProgress({
    required this.rank,
    required this.state,
    this.status,
  });
}

class RankProgressionSection extends StatelessWidget {
  final List<MilitaryRankProgress> ranks;

  const RankProgressionSection({
    super.key,
    required this.ranks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Rank Progression'),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              for (int i = 0; i < ranks.length; i++) ...[
                _RankRow(progress: ranks[i]),
                if (i < ranks.length - 1) const _Divider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final MilitaryRankProgress progress;

  const _RankRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    final active = progress.state == MilitaryRankState.active;
    final completed = progress.state == MilitaryRankState.completed;
    final locked = progress.state == MilitaryRankState.locked;

    return Opacity(
      opacity: completed
          ? 0.5
          : locked
              ? 0.6
              : 1,
      child: Container(
        color: active
            ? const Color(0xFFECFDF5)
            : completed
                ? const Color(0xFFFAFAFA)
                : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Icon(
                completed
                    ? Icons.check_circle
                    : active
                        ? Icons.stars
                        : Icons.lock,
                color: completed
                    ? const Color(0xFF10B981)
                    : active
                        ? const Color(0xFF059669)
                        : const Color(0xFFD4D4D8),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                active ? progress.rank.toUpperCase() : progress.rank,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight:
                      active || completed ? FontWeight.w600 : FontWeight.w500,
                  color: active
                      ? const Color(0xFF064E3B)
                      : const Color(0xFF18181B),
                  letterSpacing: active ? 0.6 : 0,
                ),
              ),
            ),
            if (progress.status != null)
              Text(
                progress.status!.toUpperCase(),
                style: GoogleFonts.lexend(
                  fontSize: 9,
                  height: 1.0,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                  fontStyle: completed ? FontStyle.italic : FontStyle.normal,
                  color: active
                      ? const Color(0xFF059669)
                      : const Color(0xFFA1A1AA),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 12,
          height: 1.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF71717A),
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF4F4F5));
  }
}
