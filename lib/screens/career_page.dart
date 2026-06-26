import 'package:flutter/material.dart';

import '../models/character.dart';
import '../core/engine.dart';
import '../core/app_animations.dart';
import '../core/design_system.dart';
import '../core/career_data.dart';
import '../core/institute_data.dart';
import '../widgets/core/app_scaffold.dart';
import '../widgets/core/app_status_banner.dart';
import '../widgets/game/game_card.dart';
import '../widgets/game/section_header.dart';
import '../widgets/game/career_path_card.dart';
import '../widgets/game/action_tile.dart';
import '../widgets/game/job_card.dart';
import '../widgets/game/progress_bar.dart';
import '../widgets/events/event_card.dart';
import '../widgets/events/event_types.dart';
import 'career/freelance_page.dart';
import 'career/jobs_page.dart';
import 'career/military_page.dart';
import 'career/part_time_jobs/part_time_jobs_screen.dart';
import 'career/special_careers/actor/actor_page.dart';
import 'career/special_careers/singer_page.dart';
import 'career/special_careers/cricketer_page.dart';
import 'career/special_careers/footballer_page.dart';
import 'career/special_careers/influencer/influencer_screen.dart';
import 'career/special_careers/politician/politician_screen.dart';
import 'education/exam_quiz_page.dart';
import 'education/school_activities_screen.dart';
import 'education/scholarships_screen.dart';
import 'education/tutors_screen.dart';

typedef LifeAction = ActionResult Function(Character character);

class CareerPage extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;
  final void Function(LifeAction) onLifeAction;

  const CareerPage({
    super.key,
    required this.character,
    required this.onGameAction,
    required this.onLifeAction,
  });

  bool get _isStudent => character.annualIncome <= 0 && character.age < 18;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'career',
      padding: const EdgeInsets.only(left: 16, right: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Career', style: AppTextStyles.headlineSm),
              Text(
                'Work, education and future opportunities',
                style: AppTextStyles.labelSm,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CurrentStatusCard(
          name: character.name,
          age: character.age,
          isStudent: _isStudent,
          annualIncome: character.annualIncome.toDouble(),
        ),
        const SizedBox(height: AppSpacing.md),
        _StatsGrid(
          smarts: character.smarts.toDouble(),
          looks: character.looks.toDouble(),
        ),
        const SizedBox(height: AppSpacing.md),
        const SectionHeader(
          title: 'Active Pursuit',
          padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
        ),
        _ActivePursuitCard(
          emoji: _isStudent ? '🏫' : '💼',
          title: _isStudent ? 'Student' : character.jobTitle,
          subtitle: _isStudent
              ? 'Studying at Public High School'
              : character.careerGroup,
          onTap: _isStudent
              ? () => _push(
                    context,
                    _EducationListScreen(
                      character: character,
                      onGameAction: onGameAction,
                    ),
                  )
              : () => _push(
                    context,
                    JobsListScreen(
                      title: 'JOBS',
                      character: character,
                      onGameAction: onGameAction,
                      tier: CareerTier.fullTime,
                    ),
                  ),
        ),
        const SizedBox(height: AppSpacing.md),
        const SectionHeader(
          title: 'Explore Careers',
          padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
        ),
        CareerPathCard(
          emoji: '💼',
          title: 'Jobs',
          subtitle: 'Full-Time Careers',
          onTap: () => _push(
            context,
            JobsListScreen(
              title: 'JOBS',
              character: character,
              onGameAction: onGameAction,
              tier: CareerTier.fullTime,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CareerPathCard(
          emoji: '⏰',
          title: 'Part-Time',
          subtitle: 'Student Work',
          onTap: () => _push(
            context,
            PartTimeJobsScreen(
              character: character,
              onGameAction: onGameAction,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CareerPathCard(
          emoji: '💻',
          title: 'Freelance',
          subtitle: 'Gig Work',
          onTap: () => _push(
            context,
            FreelanceClientsScreen(
              character: character,
              onGameAction: onGameAction,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CareerPathCard(
          emoji: '🎖',
          title: 'Military',
          subtitle: 'Serve Your Country',
          onTap: () => _push(
            context,
            MilitaryPage(
              character: character,
              onGameAction: onGameAction,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CareerPathCard(
          emoji: '⭐',
          title: 'Special',
          subtitle: 'Fame & Glory',
          onTap: () => _push(
            context,
            _SpecialListScreen(
              character: character,
              onGameAction: onGameAction,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CareerPathCard(
          emoji: '🎓',
          title: 'Education',
          subtitle: 'University & More',
          onTap: () => _push(
            context,
            _EducationListScreen(
              character: character,
              onGameAction: onGameAction,
            ),
          ),
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

// ─── Current Status Card ──────────────────────────────────────────────────────

class _CurrentStatusCard extends StatelessWidget {
  final String name;
  final int age;
  final bool isStudent;
  final double annualIncome;

  const _CurrentStatusCard({
    required this.name,
    required this.age,
    required this.isStudent,
    required this.annualIncome,
  });

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.headlineSm),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _StatusBadge(
                          label: 'Age $age',
                          bgColor: AppColors.primary.withValues(alpha: 0.1),
                          textColor: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _StatusBadge(
                          label: isStudent ? 'Student' : 'Worker',
                          bgColor: AppColors.secondaryContainer,
                          textColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                      text: formatMoney(annualIncome),
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.primary,
                      ),
                      children: [
                        TextSpan(
                          text: '/year',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'INCOME',
                    style: AppTextStyles.labelSm.copyWith(
                      letterSpacing: -0.05,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.85)),
            ),
            child: Row(
              children: [
                Icon(Icons.school, color: AppColors.primary, size: 28),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isStudent ? 'Studying' : 'Working',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isStudent ? 'Class of ${2025 + (18 - age)}' : 'High School',
                        style: AppTextStyles.labelSm,
                      ),
                    ],
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

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _StatusBadge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelBold.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final double smarts;
  final double looks;

  const _StatsGrid({required this.smarts, required this.looks});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(
          label: 'Smarts',
          value: smarts,
          color: AppColors.primary,
        )),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatCard(
          label: 'Looks',
          value: looks,
          color: AppColors.tertiary,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.85)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${value.round()}%',
                style: AppTextStyles.labelBold.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.85)),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active Pursuit Card ──────────────────────────────────────────────────────

class _ActivePursuitCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActivePursuitCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ActivePursuitCard> createState() => _ActivePursuitCardState();
}

class _ActivePursuitCardState extends State<_ActivePursuitCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? kPressScale : 1.0,
        duration: AppMotion.tap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Text(
                widget.emoji,
                style: const TextStyle(
                  fontSize: 48,
                  leadingDistribution: TextLeadingDistribution.proportional,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.headlineSm,
                    ),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Special Careers Screen ──────────────────────────────────────────────────

class _SpecialListScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _SpecialListScreen({
    required this.character,
    required this.onGameAction,
  });

  bool _isLocked(String careerName) {
    return false;
  }

  void _showRequirements(BuildContext context, String careerName) {
    try {
      final career =
          CareerSystem.specialCareers.firstWhere((c) => c.name == careerName);

      final eduLevels = [
        'None', 'Primary', 'Secondary', 'Higher Secondary',
        'Undergraduate', 'Graduate', 'Postgraduate',
      ];
      final charEduIdx = eduLevels.indexOf(character.educationLevel);
      final reqEduIdx = eduLevels.indexOf(career.eduReq);

      showEventCard(
        context: context,
        category: EventCategory.career,
        mode: EventCardMode.requirement,
        title: '$careerName Locked',
        description:
            'You do not meet the minimum requirements for this special career.',
        illustration: const EventIllustration.emoji('🔒'),
        requirements: [
          if (career.minAge > 0)
            EventRequirement(
              emojiIcon: '🎂',
              label:
                  'Age (Current: ${character.age} | Required: ${career.minAge}+)',
              isMet: character.age >= career.minAge,
            ),
          if (reqEduIdx > 0)
            EventRequirement(
              emojiIcon: '📚',
              label:
                  'Education (Current: ${character.educationLevel} | Required: ${career.eduReq})',
              isMet: charEduIdx >= reqEduIdx,
            ),
          if (career.smartsReq > 0)
            EventRequirement(
              emojiIcon: '🧠',
              label:
                  'Smarts (Current: ${character.smarts} | Required: ${career.smartsReq})',
              isMet: character.smarts >= career.smartsReq,
            ),
          if (career.socialReq > 0)
            EventRequirement(
              emojiIcon: '🗣️',
              label:
                  'Social (Current: ${character.social} | Required: ${career.socialReq})',
              isMet: character.social >= career.socialReq,
            ),
        ],
        primaryAction: EventCardAction(
          label: 'Okay',
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Special Careers',
      children: [
        const SectionHeader(title: 'Fame'),
        _SpecialCareerTile(
          emoji: '🎬',
          title: 'Actor',
          subtitle: 'Fame: 0% · Education: None',
          locked: _isLocked('Actor'),
          onTap: () {
            const bool kSpecialCareerDebugMode = true;
            if (kSpecialCareerDebugMode) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ActorPage(character: character)));
              return;
            }
            if (_isLocked('Actor')) {
              _showRequirements(context, 'Actor');
            } else {
              onGameAction(const GameAction('career.perform',
                  {'actionId': 'career.special.apply::Actor'}));
            }
          },
        ),
        _SpecialCareerTile(
          emoji: '🎤',
          title: 'Singer',
          subtitle: 'Fame: 0% · Skill: High',
          locked: _isLocked('Musician'),
          onTap: () {
            const bool kSpecialCareerDebugMode = true;
            if (kSpecialCareerDebugMode) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SingerPage()));
              return;
            }
            if (_isLocked('Musician')) {
              _showRequirements(context, 'Musician');
            } else {
              onGameAction(const GameAction('career.perform',
                  {'actionId': 'career.special.apply::Musician'}));
            }
          },
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'Sports'),
        _SpecialCareerTile(
          emoji: '🏏',
          title: 'Cricketer',
          subtitle: 'Reputation: 0% · Skill: Max',
          locked: _isLocked('Athlete'),
          onTap: () {
            const bool kSpecialCareerDebugMode = true;
            if (kSpecialCareerDebugMode) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CricketerPage()));
              return;
            }
            if (_isLocked('Athlete')) {
              _showRequirements(context, 'Athlete');
            } else {
              onGameAction(const GameAction('career.perform',
                  {'actionId': 'career.special.apply::Athlete'}));
            }
          },
        ),
        _SpecialCareerTile(
          emoji: '⚽',
          title: 'Footballer',
          subtitle: 'Reputation: 0% · Skill: Max',
          locked: _isLocked('Athlete'),
          onTap: () {
            const bool kSpecialCareerDebugMode = true;
            if (kSpecialCareerDebugMode) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FootballerPage()));
              return;
            }
            onGameAction(const GameAction('career.perform',
                {'actionId': 'career.special.apply::Athlete'}));
          },
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'Entertainment'),
        _SpecialCareerTile(
          emoji: '📺',
          title: 'Influencer',
          subtitle: 'Fame: 0% · Followers: 0',
          locked: _isLocked('Influencer'),
          onTap: () {
            const bool kSpecialCareerDebugMode = true;
            if (kSpecialCareerDebugMode) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => InfluencerCareerScreen(
                          character: character, onGameAction: onGameAction)));
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => InfluencerCareerScreen(
                  character: character,
                  onGameAction: onGameAction,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'Government'),
        _SpecialCareerTile(
          emoji: '🏛️',
          title: 'Politician',
          subtitle: 'Reputation: 0% · Education: University',
          locked: _isLocked('Politician'),
          onTap: () {
            const bool kSpecialCareerDebugMode = true;
            if (kSpecialCareerDebugMode) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PoliticianScreen(
                          character: character, onGameAction: onGameAction)));
              return;
            }
            if (character.careerGroup == 'Politician') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PoliticianScreen(
                    character: character,
                    onGameAction: onGameAction,
                  ),
                ),
              );
              return;
            }
            if (_isLocked('Politician')) {
              _showRequirements(context, 'Politician');
            } else {
              onGameAction(const GameAction('career.perform',
                  {'actionId': 'career.special.apply::Politician'}));
            }
          },
        ),
      ],
    );
  }
}

class _SpecialCareerTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool locked;
  final VoidCallback onTap;

  const _SpecialCareerTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.locked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
        vertical: AppSpacing.xs,
      ),
      child: JobCard(
        emoji: emoji,
        title: title,
        company: subtitle,
        salary: '',
        requirement: locked ? 'Locked' : null,
        locked: locked,
        accentColor: locked ? AppColors.outline : AppColors.warning,
        onTap: onTap,
      ),
    );
  }
}

// ─── Education Screen ────────────────────────────────────────────────────────

class _EducationListScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _EducationListScreen({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Education',
      children: [
        AppStatusBanner(
          label: 'HIGH SCHOOL',
          title: 'Grade: ${_currentGrade()}',
          subtitle: 'GPA: ${_gpa()}',
          trailing: Container(
            width: 96,
            height: 8,
            decoration: const BoxDecoration(color: Color(0xFFE1E2E6)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.85,
              child: Container(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'Current Education'),
        GameCard(
          child: Column(
            children: [
              const _EduInfoRow(emoji: '🏫', title: 'Public High School', subtitle: 'Grade 10'),
              const Divider(height: 1, color: AppColors.divider),
              const _EduInfoRow(emoji: '📈', title: 'GPA / Performance', subtitle: 'Excellent'),
              const Divider(height: 1, color: AppColors.divider),
              _EduInfoRow(
                emoji: '📚',
                title: 'Study Harder',
                subtitle: 'Improve your grades',
                onTap: () => onGameAction(const GameAction(
                  'career.perform', {'actionId': 'career.study_hard'},
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'Options'),
        _buildOptionsGrid(context),
        const SizedBox(height: 8),
        const SectionHeader(title: 'Universities'),
        _buildUniversitySection(context),
        if (character.educationLevel == 'Graduate' ||
            character.educationLevel == 'Postgraduate')
          _buildCompetitiveExams(context),
      ],
    );
  }

  String _currentGrade() {
    if (character.age <= 14) return '9';
    if (character.age <= 15) return '10';
    if (character.age <= 16) return '11';
    return '12';
  }

  String _gpa() {
    final avg = ((character.smarts + character.ambition) / 200 * 4.0);
    return avg.toStringAsFixed(1);
  }

  Widget _buildOptionsGrid(BuildContext context) {
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
            emoji: '🎭',
            label: 'Activities',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SchoolActivitiesScreen(
                character: character,
                onGameAction: onGameAction,
              ),
            )),
          ),
          ActionTile(
            emoji: '📝',
            label: 'Exams',
            rewards: const [ActionReward('JEE/NEET', AppColors.primary)],
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ExamQuizPage(
                character: character,
                onGameAction: onGameAction,
              ),
            )),
          ),
          ActionTile(
            emoji: '💰',
            label: 'Scholarships',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ScholarshipsScreen(
                character: character,
                onGameAction: onGameAction,
              ),
            )),
          ),
          ActionTile(
            emoji: '🏛️',
            label: 'Libraries',
            rewards: const [ActionReward('+Prep', AppColors.primary)],
            onTap: () => onGameAction(const GameAction(
              'career.perform', {'actionId': 'career.study_hard'},
            )),
          ),
          ActionTile(
            emoji: '👨‍🏫',
            label: 'Tutors',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TutorsScreen(
                character: character,
                onGameAction: onGameAction,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversitySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      child: GameCard(
        child: Column(
          children: [
            _EduInfoRow(
              emoji: '🎓',
              title: 'Universities',
              subtitle: 'Apply for higher education',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => _UniversityScreen(
                  character: character,
                  onGameAction: onGameAction,
                ),
              )),
            ),
                    const Divider(height: 1, color: AppColors.divider),
            _EduInfoRow(
              emoji: '🏢',
              title: 'Post-Graduate',
              subtitle: 'Complete University first',
              locked: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitiveExams(BuildContext context) {
    final passedUPSC = character.memories.containsKey('passed_UPSC');
    final passedSSC = character.memories.containsKey('passed_SSC');
    final passedBankPO = character.memories.containsKey('passed_BankPO');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const SectionHeader(title: 'Competitive Exams'),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          child: GameCard(
            child: Column(
              children: [
                _EduInfoRow(
                  emoji: '\ud83c\udfdb\ufe0f',
                  title: passedUPSC ? '\u2705 UPSC Cleared' : 'Prepare UPSC',
                  subtitle: passedUPSC
                      ? 'IAS/IPS/IFS unlocked'
                      : 'Prep: ${character.prepLevel}% · Need 30%+',
                  locked: passedUPSC,
                  onTap: passedUPSC
                      ? () {}
                      : () => onGameAction(const GameAction('career.perform',
                          {'actionId': 'career.prepare_upsc'})),
                ),
                if (!passedUPSC) ...[
                  const Divider(height: 1, color: AppColors.divider),
                  _EduInfoRow(
                    emoji: '\ud83d\udcdd',
                    title: 'Attempt UPSC',
                    subtitle: 'Very low pass rate · High preparation needed',
                    onTap: () => showEventCard(
                      context: context,
                      category: EventCategory.education,
                      mode: EventCardMode.choice,
                      title: 'Attempt UPSC Exam',
                      description:
                          'This is a highly competitive exam.\nYour Current Prep Level: ${character.prepLevel}%\n\nDo you want to attempt it now?',
                      illustration: const EventIllustration.emoji('📝'),
                      primaryAction: EventCardAction(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      secondaryAction: EventCardAction(
                        label: 'Attempt',
                        onPressed: () {
                          Navigator.of(context).pop();
                          onGameAction(const GameAction('career.perform',
                              {'actionId': 'career.take_upsc'}));
                        },
                      ),
                    ),
                  ),
                ],
                const Divider(height: 1, color: AppColors.divider),
                _EduInfoRow(
                  emoji: '\ud83d\udccb',
                  title: passedSSC ? '\u2705 SSC Cleared' : 'Prepare SSC',
                  subtitle: passedSSC
                      ? 'Government clerk/officer posts unlocked'
                      : 'Stable government job · Moderate difficulty',
                  locked: passedSSC,
                  onTap: passedSSC
                      ? () {}
                      : () => onGameAction(const GameAction('career.perform',
                          {'actionId': 'career.prepare_ssc'})),
                ),
                if (!passedSSC) ...[
                  const Divider(height: 1, color: AppColors.divider),
                  _EduInfoRow(
                    emoji: '\u270f\ufe0f',
                    title: 'Attempt SSC',
                    subtitle: 'Prep: ${character.prepLevel}% · Need 20%+',
                    onTap: () => showEventCard(
                      context: context,
                      category: EventCategory.education,
                      mode: EventCardMode.choice,
                      title: 'Attempt SSC Exam',
                      description:
                          'This exam is required for many government roles.\nYour Current Prep Level: ${character.prepLevel}%\n\nDo you want to attempt it now?',
                      illustration: const EventIllustration.emoji('📝'),
                      primaryAction: EventCardAction(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      secondaryAction: EventCardAction(
                        label: 'Attempt',
                        onPressed: () {
                          Navigator.of(context).pop();
                          onGameAction(const GameAction('career.perform',
                              {'actionId': 'career.take_ssc'}));
                        },
                      ),
                    ),
                  ),
                ],
                const Divider(height: 1, color: AppColors.divider),
                _EduInfoRow(
                  emoji: '\ud83c\udfe6',
                  title: passedBankPO ? '\u2705 Bank PO Cleared' : 'Attempt Bank PO',
                  subtitle: passedBankPO
                      ? 'Bank PO/RBI posts unlocked'
                      : 'Good salary · Respectable government role',
                  locked: passedBankPO,
                  onTap: passedBankPO
                      ? () {}
                      : () => showEventCard(
                            context: context,
                            category: EventCategory.education,
                            mode: EventCardMode.choice,
                            title: 'Attempt Bank PO Exam',
                            description:
                                'This exam is required for banking roles.\nYour Current Prep Level: ${character.prepLevel}%\n\nDo you want to attempt it now?',
                            illustration: const EventIllustration.emoji('🏦'),
                            primaryAction: EventCardAction(
                              label: 'Cancel',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            secondaryAction: EventCardAction(
                              label: 'Attempt',
                              onPressed: () {
                                Navigator.of(context).pop();
                                onGameAction(const GameAction('career.perform',
                                    {'actionId': 'career.take_bank_po'}));
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EduInfoRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool locked;
  final VoidCallback? onTap;

  const _EduInfoRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSm,
                  ),
                ],
              ),
            ),
            if (locked)
              const Icon(Icons.lock, color: AppColors.outline, size: 18)
            else if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.outline, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── University Screen ───────────────────────────────────────────────────────

class _UniversityScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _UniversityScreen({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'University',
      children: [
        AppStatusBanner(
          label: 'CURRENT STATUS',
          title: 'High School Graduate',
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                GameEngine.formatMoney(character.bankBalance),
                style: AppTextStyles.displayMd.copyWith(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Savings',
                style: AppTextStyles.labelSm,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const SectionHeader(title: 'Colleges'),
        ...InstituteData.topInstitutes.map((inst) => Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.cardGap,
            left: AppSpacing.containerPadding,
            right: AppSpacing.containerPadding,
          ),
          child: JobCard(
            emoji: '🎓',
            title: inst.name,
            company: 'Fees: ₹${GameEngine.formatMoney(inst.feesPerYear)} · Prestige: ${inst.tier}',
            salary: '',
            onTap: () => showEventCard(
              context: context,
              category: EventCategory.education,
              mode: EventCardMode.choice,
              title: '${inst.name} Admission',
              description:
                  'Fees: ₹${GameEngine.formatMoney(inst.feesPerYear)}/year\nPrestige: ${inst.tier}\n\nDo you wish to enroll?',
              illustration: const EventIllustration.emoji('🎓'),
              primaryAction: EventCardAction(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
              secondaryAction: EventCardAction(
                label: 'Enroll',
                onPressed: () {
                  Navigator.of(context).pop();
                  onGameAction(GameAction('career.perform',
                      {'actionId': 'education.enroll::${inst.name}'}));
                },
              ),
            ),
          ),
        )),
        const SizedBox(height: 8),
        const SectionHeader(title: 'Application'),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          child: GameCard(
            child: Column(
              children: [
                _EduInfoRow(
                  emoji: '📝',
                  title: 'Apply for Admission',
                  subtitle: 'Choose your major',
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.divider),
                _EduInfoRow(
                  emoji: '💰',
                  title: 'Financial Aid',
                  subtitle: 'Apply for a student loan',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          child: GameCard(
            child: Column(
              children: [
                ProgressBarRow(
                  label: 'INTELLIGENCE',
                  value: character.smarts.toDouble(),
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                const ProgressBarRow(
                  label: 'AMBITION',
                  value: 95.0,
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

