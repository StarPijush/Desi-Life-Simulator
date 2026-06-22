import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../core/engine.dart';
import '../../core/design_system.dart';
import '../../widgets/core/app_scaffold.dart';
import '../../widgets/game/game_card.dart';
import '../../widgets/game/section_header.dart';

class TutorsScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const TutorsScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  void _showTutorOptionsDialog(
      BuildContext context, String subject, Map? activeTutor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$subject Tutors',
                  style: AppTextStyles.displayMd.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.md),
                if (activeTutor != null) ...[
                  Text(
                    'Currently hired: ${activeTutor['name']}',
                    style: AppTextStyles.labelBold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Cost: ₹${activeTutor['monthlyFee']}/mo\nBoost: +${activeTutor['learningBoost']}%\nStress Impact: ${activeTutor['stressImpact'] > 0 ? '+' : ''}${activeTutor['stressImpact']}',
                    style: AppTextStyles.bodyMd,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.1),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onGameAction(GameAction('activity.perform',
                            {'activityId': 'tutor.fire::$subject'}));
                      },
                      child: const Text('Fire Tutor'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ] else ...[
                  const Text(
                    'Hiring a tutor will automatically deduct their monthly fee from your bank balance every year (fee x 12). Only one tutor per subject allowed.'),
                  const SizedBox(height: AppSpacing.md),
                ],
                Text(
                  'Available Tutors:',
                  style: AppTextStyles.labelBold,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildTutorOption(
                  title: 'Friendly Tutor',
                  fee: '₹7,000/mo',
                  desc: 'Moderate prep boost, stress relief',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onGameAction(GameAction('activity.perform',
                        {'activityId': 'tutor.hire::$subject::Friendly'}));
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildTutorOption(
                  title: 'Strict Tutor',
                  fee: '₹12,000/mo',
                  desc: 'Extreme prep boost, increases stress',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onGameAction(GameAction('activity.perform',
                        {'activityId': 'tutor.hire::$subject::Strict'}));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTutorOption({
    required String title,
    required String fee,
    required String desc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardGap),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelBold,
                  ),
                  Text(
                    desc,
                    style: AppTextStyles.labelSm.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              fee,
              style: AppTextStyles.labelBold.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectRow(BuildContext context, String subject, String emoji) {
    final Map? activeTutor = character.activeTutors[subject];
    final bool hasTutor = activeTutor != null;

    return InkWell(
      onTap: () => _showTutorOptionsDialog(context, subject, activeTutor),
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
                    subject,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasTutor)
                    Text(
                      'Hired: ${activeTutor['name']}',
                      style: AppTextStyles.labelSm.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    Text(
                      'No active tutor',
                      style: AppTextStyles.labelSm.copyWith(fontSize: 10),
                    ),
                ],
              ),
            ),
            if (hasTutor)
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
      title: 'TUTORS',
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      children: [
        const SectionHeader(title: 'SCIENCE & MATH'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSubjectRow(context, 'Mathematics', '📐'),
              _buildDivider,
              _buildSubjectRow(context, 'Physics', '⚛️'),
              _buildDivider,
              _buildSubjectRow(context, 'Chemistry', '🧪'),
              _buildDivider,
              _buildSubjectRow(context, 'Biology', '🧬'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const SectionHeader(title: 'COMMERCE & HUMANITIES'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildSubjectRow(context, 'Accounts', '📊'),
              _buildDivider,
              _buildSubjectRow(context, 'Economics', '📉'),
              _buildDivider,
              _buildSubjectRow(context, 'English', '📚'),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  static const _buildDivider = Divider(height: 1, color: AppColors.divider);
}
