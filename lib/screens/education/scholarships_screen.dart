import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/character.dart';
import '../../core/engine.dart';
import '../../core/design_system.dart';
import '../../widgets/core/app_scaffold.dart';
import '../../widgets/game/game_card.dart';
import '../../widgets/game/section_header.dart';
import '../../widgets/game/status_chip.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/events/event_types.dart';

class ScholarshipsScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const ScholarshipsScreen({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  void _showScholarshipDialog(BuildContext context, String id, String title,
      bool isClaimed, double reward, String subtitle) {
    if (isClaimed) {
      showEventCard(
        context: context,
        category: EventCategory.scholarship,
        mode: EventCardMode.info,
        title: title,
        description: 'You have already claimed this scholarship. The funds were deposited into your bank account.',
        illustration: const EventIllustration.emoji('💰'),
        primaryAction: EventCardAction(
          label: 'OK',
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
      return;
    }

    final formattedReward = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    ).format(reward);

    showEventCard(
      context: context,
      category: EventCategory.scholarship,
      mode: EventCardMode.offer,
      title: 'Scholarship: $title',
      description: 'Would you like to apply for this scholarship? We will evaluate your eligibility based on your performance and stats.',
      illustration: const EventIllustration.emoji('🎓'),
      infoRows: [
        EventInfoRow(label: 'Grant', value: formattedReward),
        EventInfoRow(label: 'Criteria', value: subtitle.replaceAll('Requires ', '')),
      ],
      primaryAction: EventCardAction(
        label: 'Apply',
        onPressed: () {
          Navigator.of(context).pop();
          onGameAction(GameAction('activity.perform',
              {'activityId': 'scholarship.apply::$id'}));
        },
      ),
      secondaryAction: EventCardAction(
        label: 'Cancel',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildScholarshipRow(BuildContext context, String id, String title,
      String subtitle, String emoji, double reward) {
    final bool isClaimed = character.claimedScholarships.contains(id);
    final String formattedReward = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    ).format(reward);

    return InkWell(
      onTap: () =>
          _showScholarshipDialog(context, id, title, isClaimed, reward, subtitle),
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
                    title,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSm.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            if (isClaimed)
              const StatusChip(label: 'CLAIMED', color: AppColors.primary)
            else
              Text(
                formattedReward,
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'SCHOLARSHIPS',
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      children: [
        const SectionHeader(title: 'NEED-BASED AID'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildScholarshipRow(
                context,
                'low_income',
                'Financial Support Grant',
                'Requires Low parent wealth',
                '🪙',
                10000,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const SectionHeader(title: 'HIGH SCHOOL MERIT'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildScholarshipRow(
                context,
                '10th_merit',
                '10th Board Merit',
                'Requires 75%+ in 10th Boards',
                '📝',
                10000,
              ),
              _buildDivider,
              _buildScholarshipRow(
                context,
                '12th_excellence',
                '12th Excellence Award',
                'Requires Smarts 80%+, Prep 80%+',
                '🎓',
                25000,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const SectionHeader(title: 'TALENT & EXTRACURRICULAR'),
        GameCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildScholarshipRow(
                context,
                'sports_talent',
                'Sports Council Grant',
                'Elite in Cricket/Football/Basketball',
                '🏅',
                15000,
              ),
              _buildDivider,
              _buildScholarshipRow(
                context,
                'arts_talent',
                'Creative Arts Talent',
                'Elite in Acting/Singing/Dance',
                '🎭',
                15000,
              ),
              _buildDivider,
              _buildScholarshipRow(
                context,
                'coding_talent',
                'Hackathon Winner Grant',
                'Good in Coding Club + Smarts 75%+',
                '💻',
                15000,
              ),
              _buildDivider,
              _buildScholarshipRow(
                context,
                'debate_excellence',
                'Debate Excellence Award',
                'Good in Debate Club + Smarts 70%+',
                '🏆',
                12000,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  static const _buildDivider = Divider(height: 1, color: AppColors.divider);
}
