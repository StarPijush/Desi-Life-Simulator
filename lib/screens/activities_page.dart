import 'package:flutter/material.dart';

import '../core/design_system.dart';
import '../core/engine.dart';
import '../core/game_emoji.dart';
import '../models/character.dart';
import '../widgets/core/app_scaffold.dart';
import '../widgets/game/game_card.dart';
import '../widgets/game/section_header.dart';

class ActivitiesPage extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const ActivitiesPage({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = character.jobTitle.isNotEmpty
        ? character.jobTitle
        : (character.age < 22 ? 'Student' : 'Unemployed');

    return AppScaffold(
      title: 'Activities',
      subtitle: 'Things to Do',
      padding: const EdgeInsets.only(left: 16, right: 16),
      children: [
        const SizedBox(height: 24),
        _buildStatusCard(statusLabel),
        const SizedBox(height: 16),
        _buildActivePursuitCard(),
        const SizedBox(height: 24),
        _buildCategorySection(
          'Health & Fitness',
          children: [
            _activityRow(
              emoji: GameEmoji.gym,
              title: 'Gym',
              subtitle: '30m Session · -₹500',
              onTap: () => onGameAction(
                const GameAction('activity.perform', {
                  'activityId': 'Gym Workout',
                }),
              ),
            ),
            _activityRow(
              emoji: GameEmoji.meditation,
              title: 'Meditation',
              subtitle: 'Daily Practice · Free',
              onTap: () => onGameAction(
                const GameAction('activity.perform', {
                  'activityId': 'Temple Visit',
                }),
              ),
            ),
            _activityRow(
              emoji: GameEmoji.running,
              title: 'Running',
              subtitle: 'Park Trail · Free',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          'Social',
          children: [
            _activityRow(
              emoji: GameEmoji.relationship,
              title: 'Relationships',
              subtitle: 'Spend time with loved ones',
              onTap: () => onGameAction(
                const GameAction('activity.find_love'),
              ),
            ),
            _activityRow(
              emoji: GameEmoji.nightlife,
              title: 'Nightlife',
              subtitle: 'Go clubbing · -₹2,500',
              onTap: () => onGameAction(
                const GameAction('activity.perform', {
                  'activityId': 'Go to Party',
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          'Learning',
          children: [
            _activityRow(
              emoji: GameEmoji.library,
              title: 'Library',
              subtitle: 'Study and Research · Free',
              onTap: () => onGameAction(
                const GameAction('activity.perform', {
                  'activityId': 'Study Hard',
                }),
              ),
            ),
            _activityRow(
              emoji: GameEmoji.courses,
              title: 'Courses',
              subtitle: 'Upskill your career · -₹15,000',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          'Entertainment',
          children: [
            _activityRow(
              emoji: GameEmoji.movies,
              title: 'Movies',
              subtitle: 'Latest Cinema · -₹450',
              onTap: () => onGameAction(
                const GameAction('activity.perform', {
                  'activityId': 'Watch Movie',
                }),
              ),
            ),
            _activityRow(
              emoji: GameEmoji.shopping,
              title: 'Shopping',
              subtitle: 'Retail Therapy · Varies',
              onTap: () => onGameAction(
                const GameAction('activity.perform', {
                  'activityId': 'Shopping',
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(String statusLabel) {
    return GameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: AppTextStyles.headlineSm.copyWith(
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _statusBadge('AGE ${character.age}'),
                        const SizedBox(width: 8),
                        _statusBadge(statusLabel),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'BANK BALANCE',
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.08,
                    ),
                  ),
                  Text(
                    shortMoney(character.bankBalance),
                    style: AppTextStyles.displayMd.copyWith(
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _statColumn(
                    'Happiness',
                    '${character.happiness}%',
                    AppColors.happiness,
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.divider),
                Expanded(
                  child: _statColumn(
                    'Health',
                    '${character.health}%',
                    AppColors.health,
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.divider),
                Expanded(
                  child: _statColumn(
                    'Energy',
                    '${(100 - character.stressLevel).clamp(0, 100)}%',
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.slate200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelBold.copyWith(
          color: AppColors.journalText,
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelBold.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActivePursuitCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(GameEmoji.meditation, style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE PURSUIT',
                  style: AppTextStyles.labelBold.copyWith(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mind & Body',
                  style: AppTextStyles.headlineSm.copyWith(
                    height: 1.2,
                  ),
                ),
                Text(
                  'Improves health and happiness',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title, {
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.85),
              ),
            ),
            child: Column(children: _buildDividedRows(children)),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDividedRows(List<Widget> rows) {
    if (rows.isEmpty) return [];
    final result = <Widget>[rows[0]];
    for (int i = 1; i < rows.length; i++) {
      result.add(const Divider(height: 1, color: AppColors.divider));
      result.add(rows[i]);
    }
    return result;
  }

  Widget _activityRow({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
