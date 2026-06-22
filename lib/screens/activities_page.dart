import 'package:flutter/material.dart';
import '../core/design_system.dart';
import '../core/engine.dart';
import '../models/character.dart';
import '../widgets/core/app_scaffold.dart';
import '../widgets/core/app_status_banner.dart';
import '../widgets/game/action_tile.dart';
import '../widgets/game/progress_bar.dart';
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
    return AppScaffold(
      title: 'Activities',
      subtitle: 'Things to Do',
      children: [
        AppStatusBanner(
          label: 'CURRENT STATUS',
          title: '${character.name}, ${character.age}',
          trailing: Text(
            formatMoney(character.bankBalance),
            style: AppTextStyles.displayMd.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Favorites',
          padding: EdgeInsets.only(left: AppSpacing.containerPadding, bottom: 4),
        ),
        _buildFavoritesGrid(),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'All Activities',
          padding: EdgeInsets.only(left: AppSpacing.containerPadding, bottom: 4),
        ),
        _buildAllActivitiesGrid(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.containerPadding,
            32,
            AppSpacing.containerPadding,
            40,
          ),
          child: Column(
            children: [
              ProgressBarRow(
                label: 'HAPPINESS',
                value: character.happiness.toDouble(),
                color: AppColors.primary,
                showPercent: true,
              ),
              const SizedBox(height: 12),
              ProgressBarRow(
                label: 'HEALTH',
                value: character.health.toDouble(),
                color: AppColors.primary,
                showPercent: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.3,
        children: [
          ActionTile(
            emoji: '❤️',
            label: 'Love',
            locked: character.age < 16,
            onTap: () => onGameAction(
              const GameAction('activity.find_love'),
            ),
          ),
          ActionTile(
            emoji: '🧘',
            label: 'Mind & Body',
            onTap: () => onGameAction(
              const GameAction('activity.perform', {'activityId': 'Temple Visit'}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllActivitiesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
        children: [
          ActionTile(
            emoji: '💼',
            label: 'Doctor',
            rewards: const [ActionReward('-₹250', AppColors.error)],
            onTap: () => onGameAction(
              const GameAction('activity.perform', {'activityId': 'Doctor Visit'}),
            ),
          ),
          ActionTile(
            emoji: '🏋️',
            label: 'Gym',
            locked: character.age < 12,
            onTap: () => onGameAction(
              const GameAction('activity.perform', {'activityId': 'Gym Workout'}),
            ),
          ),
          ActionTile(
            emoji: '📚',
            label: 'Library',
            locked: character.age < 5,
            onTap: () => onGameAction(
              const GameAction('activity.perform', {'activityId': 'Study Hard'}),
            ),
          ),
          ActionTile(
            emoji: '🎬',
            label: 'Movies',
            rewards: const [ActionReward('-₹500', AppColors.error)],
            onTap: () => onGameAction(
              const GameAction('activity.perform', {'activityId': 'Watch Movie'}),
            ),
          ),
          ActionTile(
            emoji: '🍸',
            label: 'Nightlife',
            locked: character.age < 18,
            onTap: () => onGameAction(
              const GameAction('activity.perform', {'activityId': 'Go to Party'}),
            ),
          ),
          ActionTile(
            emoji: '🛍️',
            label: 'Shopping',
            onTap: () => onGameAction(
              const GameAction('activity.perform', {'activityId': 'Shopping'}),
            ),
          ),
        ],
      ),
    );
  }
}
