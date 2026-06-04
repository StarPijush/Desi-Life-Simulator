import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MilitaryActionsSection extends StatelessWidget {
  final int promotionScore;
  final bool isEnlisted;
  final VoidCallback onTrainPhysically;
  final VoidCallback onWeaponsPractice;
  final VoidCallback onLeadershipTraining;
  final VoidCallback onPromotionExam;
  final VoidCallback onSpecialForcesSelection;

  const MilitaryActionsSection({
    super.key,
    required this.promotionScore,
    required this.isEnlisted,
    required this.onTrainPhysically,
    required this.onWeaponsPractice,
    required this.onLeadershipTraining,
    required this.onPromotionExam,
    required this.onSpecialForcesSelection,
  });

  @override
  Widget build(BuildContext context) {
    final missingScore = (80 - promotionScore).clamp(0, 80);
    final promotionLocked = promotionScore < 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Training & Operations'),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              _ActionRow(
                emoji: '🏋️',
                title: isEnlisted ? 'Training' : 'Join Military',
                subtitle: isEnlisted
                    ? 'Build discipline and fitness'
                    : 'Enlist as a Recruit',
                onTap: onTrainPhysically,
              ),
              const _Divider(),
              _ActionRow(
                emoji: '🎯',
                title: 'Weapons Practice',
                subtitle: 'Improve your combat accuracy',
                onTap: onWeaponsPractice,
              ),
              const _Divider(),
              _ActionRow(
                emoji: '🗣️',
                title: 'Leadership Training',
                subtitle: 'Gain respect from subordinates',
                onTap: onLeadershipTraining,
              ),
              const _Divider(),
              _ActionRow(
                emoji: '📝',
                title: 'Apply For Promotion Exam',
                subtitle: promotionLocked
                    ? 'Requires 80% score (Missing $missingScore%)'
                    : 'Promotion exam available',
                locked: promotionLocked,
                onTap: onPromotionExam,
              ),
              const _Divider(),
              _ActionRow(
                emoji: '⚡',
                title: 'Special Forces Selection',
                subtitle: 'Elite training for the bravest',
                onTap: onSpecialForcesSelection,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool locked;
  final VoidCallback onTap;

  const _ActionRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.locked = false,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final background = _pressed
        ? const Color(0xFFF0F0F0)
        : widget.locked
            ? const Color(0xFFFAFAFA)
            : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Opacity(
        opacity: widget.locked ? 0.8 : 1,
        child: Container(
          color: background,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 24, height: 1.0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF18181B),
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF71717A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.locked ? Icons.lock : Icons.chevron_right,
                color: const Color(0xFFD4D4D8),
                size: 24,
              ),
            ],
          ),
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
