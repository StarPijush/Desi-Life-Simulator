import 'package:flutter/material.dart';

import '../../core/career_data.dart';
import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../models/character.dart';
import '../../widgets/core/app_scaffold.dart';
import '../../widgets/core/app_status_banner.dart';
import '../../widgets/game/action_tile.dart';
import '../../widgets/game/game_card.dart';
import '../../widgets/game/job_card.dart';
import '../../widgets/game/progress_bar.dart';
import '../../widgets/game/section_header.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/events/event_types.dart';

class JobsListScreen extends StatelessWidget {
  final String title;
  final Character character;
  final void Function(GameAction) onGameAction;
  final CareerTier tier;

  const JobsListScreen({
    super.key,
    required this.title,
    required this.character,
    required this.onGameAction,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    if (title.toUpperCase() == 'JOBS') {
      return _FullTimeJobsView(
        character: character,
        onGameAction: onGameAction,
      );
    }
    if (title.toUpperCase() == 'PART-TIME JOBS') {
      return _PartTimeJobsView(
        character: character,
        onGameAction: onGameAction,
      );
    }

    return _CareerGroupView(
      title: title,
      character: character,
      onGameAction: onGameAction,
      tier: tier,
    );
  }
}

class _FullTimeJobsView extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _FullTimeJobsView({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Full-Time Jobs',
      children: [
        const SizedBox(height: 8),
        const SectionHeader(title: 'Competitive Exams'),
        _buildExamsGrid(),
        const SizedBox(height: 8),
        ...Industry.values.map((industry) {
          final industryJobs = CareerData.allJobs
              .where((j) =>
                  j.industry == industry &&
                  j.tier != CareerTier.partTime &&
                  j.tier != CareerTier.freelance)
              .toList();
          if (industryJobs.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              SectionHeader(title: industry.name.toUpperCase()),
              const SizedBox(height: 4),
              ...industryJobs.map((job) {
                final locked = _isJobLocked(job, character);
                final lockReason = _getLockReason(job, character);

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.cardGap,
                    left: AppSpacing.containerPadding,
                    right: AppSpacing.containerPadding,
                  ),
                  child: JobCard(
                    emoji: job.emoji.isNotEmpty ? job.emoji : '💼',
                    title: job.title,
                    company: locked ? lockReason : '${_industryLabel(job.industry)} • ${_difficultyLabel(job)}',
                    salary: '₹${GameEngine.formatMoney(job.startingSalary)}/yr',
                    requirement: locked ? lockReason : null,
                    locked: locked,
                    accentColor: locked ? AppColors.outline : AppColors.primary,
                    onTap: locked
                        ? () => _showJobRequirements(context, job, character)
                        : () => _showJobOffer(context, job),
                  ),
                );
              }),
            ],
          );
        }),
        const SizedBox(height: 16),
        _buildMetricsSection(),
      ],
    );
  }

  Widget _buildExamsGrid() {
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
            emoji: '🏛️',
            label: 'UPSC',
            rewards: const [ActionReward('Govt', AppColors.primary)],
            onTap: () => onGameAction(const GameAction(
              'career.perform', {'actionId': 'career.exam::UPSC'},
            )),
          ),
          ActionTile(
            emoji: '🏦',
            label: 'Bank PO',
            rewards: const [ActionReward('Banking', AppColors.primary)],
            onTap: () => onGameAction(const GameAction(
              'career.perform', {'actionId': 'career.exam::BankPO'},
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      child: GameCard(
        child: Column(
          children: [
            ProgressBarRow(
              label: 'HAPPINESS',
              value: character.happiness.toDouble(),
              color: AppColors.primary,
              barHeight: 5,
            ),
            const SizedBox(height: AppSpacing.md),
            ProgressBarRow(
              label: 'HEALTH',
              value: character.health.toDouble(),
              color: AppColors.primary,
              barHeight: 5,
            ),
            const SizedBox(height: AppSpacing.md),
            ProgressBarRow(
              label: 'STRESS',
              value: character.stressLevel.toDouble(),
              color: AppColors.warning,
              barHeight: 5,
            ),
          ],
        ),
      ),
    );
  }

  bool _isJobLocked(JobDefinition job, Character character) {
    if (job.smartsReq > character.smarts) return true;

    final eduLevels = [
      'None', 'Primary', 'Secondary', 'Higher Secondary',
      'Undergraduate', 'Graduate', 'Postgraduate',
    ];
    final charEduIdx = eduLevels.indexOf(character.educationLevel);
    final reqEduIdx = eduLevels.indexOf(job.eduReq);
    if (reqEduIdx > charEduIdx) return true;

    if (job.examReq != null &&
        !character.memories.containsKey('passed_${job.examReq}')) {
      return true;
    }

    if (job.specializationReq != null) {
      final spec = job.specializationReq!;
      final hasSpec = character.specialization == spec ||
          character.degree.toLowerCase().contains(spec.toLowerCase()) ||
          character.memories.containsKey('track_${spec.toLowerCase()}') ||
          character.memories.containsKey('cleared_$spec');
      if (!hasSpec) return true;
    }

    return false;
  }

  String _getLockReason(JobDefinition job, Character character) {
    if (job.smartsReq > character.smarts) {
      return job.lockReason ?? 'Requires Smarts ${job.smartsReq}+';
    }

    final eduLevels = [
      'None', 'Primary', 'Secondary', 'Higher Secondary',
      'Undergraduate', 'Graduate', 'Postgraduate',
    ];
    final charEduIdx = eduLevels.indexOf(character.educationLevel);
    final reqEduIdx = eduLevels.indexOf(job.eduReq);
    if (reqEduIdx > charEduIdx) {
      return job.lockReason ?? 'Requires ${job.eduReq} education';
    }

    if (job.examReq != null &&
        !character.memories.containsKey('passed_${job.examReq}')) {
      return job.lockReason ?? 'Requires ${job.examReq} clearance';
    }

    if (job.specializationReq != null) {
      final spec = job.specializationReq!;
      return job.lockReason ?? 'Requires $spec specialization';
    }

    return job.lockReason ?? 'Requires more experience';
  }

  String _industryLabel(Industry industry) {
    switch (industry) {
      case Industry.tech:
        return 'Tech';
      case Industry.medical:
        return 'Medical';
      case Industry.govt:
        return 'Government';
      case Industry.creative:
        return 'Creative';
      case Industry.commerce:
        return 'Commerce';
      case Industry.services:
        return 'Services';
      case Industry.manual:
        return 'Manual';
    }
  }

  String _difficultyLabel(JobDefinition job) {
    if (job.stressLevel > 70) return 'High Stress';
    if (job.stressLevel > 40) return 'Moderate';
    return 'Easy';
  }

  void _showJobOffer(BuildContext context, JobDefinition job) {
    showEventCard(
      context: context,
      category: EventCategory.career,
      mode: EventCardMode.offer,
      title: 'Job Opening: ${job.title}',
      description: 'The company is hiring. Are you ready to apply?',
      illustration: EventIllustration.emoji(job.emoji),
      infoRows: [
        EventInfoRow(label: 'Salary', value: '₹${GameEngine.formatMoney(job.startingSalary)}/yr'),
        EventInfoRow(label: 'Stress', value: job.stressLevel > 70 ? 'Extreme' : job.stressLevel > 40 ? 'High' : 'Low'),
        const EventInfoRow(label: 'Hours', value: '40 hours/week'),
      ],
      primaryAction: EventCardAction(
        label: 'Apply',
        onPressed: () {
          Navigator.of(context).pop();
          onGameAction(GameAction('career.perform', {
            'actionId': 'career.apply::${job.title}'
          }));
        },
      ),
      secondaryAction: EventCardAction(
        label: 'Cancel',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showJobRequirements(
      BuildContext context, JobDefinition job, Character character) {
    final eduLevels = [
      'None', 'Primary', 'Secondary', 'Higher Secondary',
      'Undergraduate', 'Graduate', 'Postgraduate',
    ];
    final charEduIdx = eduLevels.indexOf(character.educationLevel);
    final reqEduIdx = eduLevels.indexOf(job.eduReq);

    bool hasSpec = true;
    if (job.specializationReq != null) {
      final spec = job.specializationReq!;
      hasSpec = character.specialization == spec ||
          character.degree.toLowerCase().contains(spec.toLowerCase()) ||
          character.memories.containsKey('track_${spec.toLowerCase()}') ||
          character.memories.containsKey('cleared_$spec');
    }

    showEventCard(
      context: context,
      category: EventCategory.career,
      mode: EventCardMode.requirement,
      title: '${job.title} Locked',
      description:
          'You do not meet the minimum requirements for this position.',
      illustration: const EventIllustration.emoji('🔒'),
      requirements: [
        if (reqEduIdx > 0)
          EventRequirement(
            emojiIcon: '📚',
            label:
                'Education (Current: ${character.educationLevel} | Required: ${job.eduReq})',
            isMet: charEduIdx >= reqEduIdx,
          ),
        if (job.smartsReq > 0)
          EventRequirement(
            emojiIcon: '🧠',
            label:
                'Smarts (Current: ${character.smarts} | Required: ${job.smartsReq})',
            isMet: character.smarts >= job.smartsReq,
          ),
        if (job.specializationReq != null)
          EventRequirement(
            emojiIcon: '🎓',
            label:
                'Specialization (Current: ${character.specialization.isEmpty ? "None" : character.specialization} | Required: ${job.specializationReq})',
            isMet: hasSpec,
          ),
        if (job.examReq != null)
          EventRequirement(
            emojiIcon: '📝',
            label: 'Exam (Required: ${job.examReq})',
            isMet: character.memories.containsKey('passed_${job.examReq}'),
          ),
      ],
      primaryAction: EventCardAction(
        label: 'Okay',
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _PartTimeJobsView extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _PartTimeJobsView({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Part-Time Jobs',
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
            vertical: AppSpacing.sm,
          ),
          color: AppColors.background,
          child: Text(
            'AVAILABLE POSITIONS',
            style: AppTextStyles.labelBold.copyWith(
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...CareerData.allJobs
            .where((j) => j.tier == CareerTier.partTime)
            .map((job) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerPadding,
                vertical: AppSpacing.xs,
              ),
              child: JobCard(
                emoji: job.emoji.isNotEmpty ? job.emoji : '💼',
                title: job.title,
                company: 'Part-Time',
                salary: '₹${GameEngine.formatMoney(job.startingSalary)}/yr',
                requirement: character.age < 14
                    ? 'Requires Age 14+'
                    : character.age < 16
                        ? 'Requires Age 16+'
                        : null,
                locked: character.age < 14,
                onTap: () {
                  if (character.age >= 14) {
                    onGameAction(const GameAction(
                      'career.perform',
                      {'actionId': 'career.apply_group::Part-Time'},
                    ));
                    Navigator.of(context).pop();
                  } else {
                    showEventCard(
                      context: context,
                      category: EventCategory.career,
                      mode: EventCardMode.requirement,
                      title: 'Too Young',
                      description:
                          'You are too young for a part-time job. Try again when you are 14.',
                      requirements: [
                        EventRequirement(
                          emojiIcon: '🎂',
                          label:
                              'Age (Current: ${character.age} | Required: 14+)',
                          isMet: false,
                        ),
                      ],
                    );
                  }
                },
              ),
            )),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          child: GameCard(
            child: Column(
              children: [
                ProgressBarRow(
                  label: 'HAPPINESS',
                  value: character.happiness.toDouble(),
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md + 4),
                ProgressBarRow(
                  label: 'STRESS',
                  value: character.stressLevel.toDouble(),
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CareerGroupView extends StatelessWidget {
  final String title;
  final Character character;
  final void Function(GameAction) onGameAction;
  final CareerTier tier;

  const _CareerGroupView({
    required this.title,
    required this.character,
    required this.onGameAction,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final groups =
        CareerSystem.allGroups.where((g) => g.tier == tier).toList();

    return AppScaffold(
      title: title,
      children: [
        AppStatusBanner(
          label: 'CURRENT STATUS',
          title: character.name,
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatMoney(character.bankBalance),
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
              Text(
                'Age: ${character.age}',
                style: AppTextStyles.labelSm,
              ),
            ],
          ),
        ),
        _buildStatsRow(),
        const SizedBox(height: 4),
        const SectionHeader(title: 'Openings'),
        ...groups.map((group) {
          final firstStep = group.steps.first;
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppSpacing.cardGap,
              left: AppSpacing.containerPadding,
              right: AppSpacing.containerPadding,
            ),
            child: JobCard(
              emoji: group.emoji.isNotEmpty ? group.emoji : '💼',
              title: group.name,
              company: firstStep.title,
              salary: '₹${GameEngine.formatMoney(firstStep.annualSalary)}/yr',
              onTap: () => showEventCard(
                context: context,
                category: EventCategory.career,
                mode: EventCardMode.choice,
                title: 'Apply for ${firstStep.title}?',
                description:
                    'Salary: ₹${GameEngine.formatMoney(firstStep.annualSalary.toDouble())}/year\nStress: Low\nHours: 40 hours/week',
                illustration: EventIllustration.emoji(
                    group.emoji.isNotEmpty ? group.emoji : '💼'),
                primaryAction: EventCardAction(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                secondaryAction: EventCardAction(
                  label: 'Apply',
                  onPressed: () {
                    Navigator.of(context).pop();
                    onGameAction(GameAction('career.perform', {
                      'actionId': 'career.apply_group::${group.name}'
                    }));
                  },
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              'SMARTS',
              style: AppTextStyles.labelSm.copyWith(fontSize: 10),
            ),
          ),
          Expanded(
            child: ProgressBar.xs(value: character.smarts.toDouble()),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 56,
            child: Text(
              'LOOKS',
              style: AppTextStyles.labelSm.copyWith(fontSize: 10),
            ),
          ),
          Expanded(
            child: ProgressBar.xs(value: character.looks.toDouble()),
          ),
        ],
      ),
    );
  }
}
