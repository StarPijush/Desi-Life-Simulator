import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../core/engine.dart';
import '../../core/design_system.dart';
import '../../widgets/core/app_scaffold.dart';
import '../../widgets/game/game_card.dart';
import '../../widgets/game/section_header.dart';
import '../../widgets/game/status_chip.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/events/event_types.dart';

class SchoolActivitiesScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const SchoolActivitiesScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  String _getPerformanceString(int performance) {
    if (performance >= 5) return 'Elite';
    if (performance >= 4) return 'Excellent';
    if (performance >= 3) return 'Good';
    if (performance >= 2) return 'Average';
    return 'Beginner';
  }

  Color _getPerformanceColor(int performance) {
    if (performance >= 5) return AppColors.primary;
    if (performance >= 4) return const Color(0xFF059669);
    if (performance >= 3) return AppColors.warning;
    if (performance >= 2) return AppColors.textSecondary;
    return AppColors.error;
  }

  void _showActivityDialog(BuildContext context, String id, bool isJoined) {
    showEventCard(
      context: context,
      category: EventCategory.education,
      mode: EventCardMode.actions,
      title: id,
      description: isJoined
          ? 'You are currently a member of the $id. You can practice harder to improve your performance or leave the activity.'
          : 'Would you like to try out for the $id? Make sure you meet the requirements.',
      illustration: const EventIllustration.emoji('🏫'),
      actions: isJoined
          ? [
              EventCardAction(
                label: 'Practice Harder',
                onPressed: () {
                  Navigator.of(context).pop();
                  onGameAction(GameAction('activity.perform',
                      {'activityId': 'school_activity.practice::$id'}));
                },
              ),
              EventCardAction(
                label: 'Leave Activity',
                onPressed: () {
                  Navigator.of(context).pop();
                  onGameAction(GameAction('activity.perform',
                      {'activityId': 'school_activity.leave::$id'}));
                },
              ),
              EventCardAction(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]
          : [
              EventCardAction(
                label: 'Join',
                onPressed: () {
                  Navigator.of(context).pop();
                  onGameAction(GameAction('activity.perform',
                      {'activityId': 'school_activity.join::$id'}));
                },
              ),
              EventCardAction(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
    );
  }

  Widget _buildActivityRow(BuildContext context, String id, String emoji) {
    final bool isJoined = character.joinedActivities.contains(id);
    final int performance = character.activityPerformance[id] ?? 0;

    return InkWell(
      onTap: () => _showActivityDialog(context, id, isJoined),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.containerPadding,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isJoined) ...[
                    const SizedBox(height: 2),
                    StatusChip(
                      label: _getPerformanceString(performance),
                      color: _getPerformanceColor(performance),
                    ),
                  ],
                ],
              ),
            ),
            if (isJoined)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
            else
              const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'SCHOOL ACTIVITIES',
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      children: [
        const SectionHeader(title: 'SPORTS'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildActivityRow(context, 'Cricket', '🏏'),
              _buildDivider,
              _buildActivityRow(context, 'Football', '⚽'),
              _buildDivider,
              _buildActivityRow(context, 'Basketball', '🏀'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const SectionHeader(title: 'ARTS & CULTURE'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildActivityRow(context, 'Acting Club', '🎭'),
              _buildDivider,
              _buildActivityRow(context, 'Singing Club', '🎤'),
              _buildDivider,
              _buildActivityRow(context, 'Dance Club', '💃'),
              _buildDivider,
              _buildActivityRow(context, 'Art Club', '🎨'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const SectionHeader(title: 'ACADEMICS & CLUBS'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildActivityRow(context, 'Debate Club', '🗣️'),
              _buildDivider,
              _buildActivityRow(context, 'Coding Club', '💻'),
              _buildDivider,
              _buildActivityRow(context, 'Science Club', '🔬'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const SectionHeader(title: 'VOLUNTEERING'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildActivityRow(context, 'NCC Cadet', '🪖'),
              _buildDivider,
              _buildActivityRow(context, 'Teaching Volunteer', '👨‍🏫'),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  static const _buildDivider = Divider(height: 1, color: AppColors.divider);
}
