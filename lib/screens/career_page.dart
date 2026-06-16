// lib/screens/career_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/character.dart';
import '../core/engine.dart';
import '../core/design_system.dart';
import '../core/career_data.dart';
import '../core/institute_data.dart';
import '../widgets/common_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, 'CAREER'),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildIdentityHeader(character),
          _buildSectionHeader('OCCUPATION'),
          AppFlatRowGroup(
            rows: [
              AppFlatRow(
                icon: Text(character.annualIncome > 0 ? '💼' : '🏫',
                    style: const TextStyle(fontSize: 24)),
                title:
                    character.annualIncome > 0 ? character.jobTitle : 'Student',
                subtitle: character.annualIncome > 0
                    ? character.careerGroup
                    : 'Studying at School',
                isPrestige: character.annualIncome > 0 &&
                    (character.fame > 70 ||
                        character.bankBalance > 5000000 ||
                        character.jobTitle.contains('CEO') ||
                        character.jobTitle.contains('Director') ||
                        character.jobTitle.contains('Cricketer') ||
                        character.jobTitle.contains('Actor') ||
                        character.jobTitle.contains('Politician') ||
                        character.jobTitle.contains('Special')),
                onTap: () {},
              ),
              if (character.annualIncome > 0 || character.age >= 5)
                AppFlatRow(
                  icon: const Icon(Icons.auto_stories,
                      color: Color(0xFF059669), size: 24),
                  title: 'Study Harder',
                  onTap: () => onGameAction(const GameAction(
                      'career.perform', {'actionId': 'career.study_hard'})),
                ),
              if (character.annualIncome > 0)
                AppFlatRow(
                  icon: const Icon(Icons.exit_to_app,
                      color: AppColors.danger, size: 24),
                  title: 'Resign / Career Break',
                  titleStyle:
                      AppTextStyles.rowTitle.copyWith(color: AppColors.danger),
                  onTap: () {
                    // Using our global dialog system for a confirmation popup
                    showEventCard(
                      context: context,
                      category: EventCategory.career,
                      mode: EventCardMode.choice,
                      title: 'Resign?',
                      description:
                          'Are you sure you want to quit your current career? You will lose your salary and position, but you can explore new opportunities.',
                      illustration: const EventIllustration.emoji('🚪'),
                      primaryAction: EventCardAction(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                      ),
                      secondaryAction: EventCardAction(
                        label: 'Resign',
                        onPressed: () {
                          Navigator.pop(context);
                          onGameAction(const GameAction(
                              'career.perform', {'actionId': 'career.resign'}));
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
          _buildSectionHeader('OPTIONS'),
          AppFlatRowGroup(
            rows: [
              AppFlatRow(
                icon:
                    const Icon(Icons.work, color: Color(0xFF059669), size: 24),
                title: 'Jobs',
                onTap: () => _push(
                    context,
                    JobsListScreen(
                      title: 'JOBS',
                      character: character,
                      onGameAction: onGameAction,
                      tier: CareerTier.fullTime,
                    )),
              ),
              AppFlatRow(
                icon: const Icon(Icons.schedule,
                    color: Color(0xFF059669), size: 24),
                title: 'Part-Time Jobs',
                onTap: () => _push(
                    context,
                    PartTimeJobsScreen(
                      character: character,
                      onGameAction: onGameAction,
                    )),
              ),
              AppFlatRow(
                icon: const Icon(Icons.computer,
                    color: Color(0xFF059669), size: 24),
                title: 'Freelance',
                onTap: () => _push(
                    context,
                    FreelanceClientsScreen(
                      character: character,
                      onGameAction: onGameAction,
                    )),
              ),
              AppFlatRow(
                icon: const Icon(Icons.shield,
                    color: Color(0xFF059669), size: 24),
                title: 'Military',
                onTap: () => _push(
                    context,
                    MilitaryPage(
                      character: character,
                      onGameAction: onGameAction,
                    )),
              ),
              AppFlatRow(
                icon:
                    const Icon(Icons.star, color: Color(0xFF059669), size: 24),
                title: 'Special Careers',
                onTap: () => _push(
                    context,
                    _SpecialListScreen(
                      character: character,
                      onGameAction: onGameAction,
                    )),
              ),
              AppFlatRow(
                icon: const Icon(Icons.school,
                    color: Color(0xFF059669), size: 24),
                title: 'Education',
                onTap: () => _push(
                    context,
                    _EducationListScreen(
                      character: character,
                      onGameAction: onGameAction,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

// ─── Sub Screens (Using same flat style) ─────────────────────────────────────

class _SpecialFlatRow extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool locked;
  final bool allowLockedTap;
  final VoidCallback onTap;

  const _SpecialFlatRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.locked = false,
    this.allowLockedTap = false,
    required this.onTap,
  });

  @override
  State<_SpecialFlatRow> createState() => _SpecialFlatRowState();
}

class _SpecialFlatRowState extends State<_SpecialFlatRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.locked && !widget.allowLockedTap
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.locked && !widget.allowLockedTap
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFE8EEFF) : Colors.transparent,
          border: const Border(
              bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
        ),
        child: Opacity(
          opacity: widget.locked ? 0.6 : 1.0,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child:
                      Text(widget.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.locked
                                ? const Color(0xFF5C5E62)
                                : const Color(0xFFB58A3D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!widget.locked) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.stars,
                              color: Color(0xFFFFD700), size: 18),
                        ],
                      ],
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5C5E62).withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.locked)
                const Icon(Icons.lock, color: Color(0xFF6C7B6D), size: 24)
              else
                const Icon(Icons.chevron_right,
                    color: Color(0xFFFFD700), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialListScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _SpecialListScreen({
    required this.character,
    required this.onGameAction,
  });

  bool _isLocked(String careerName) {
    return false; // Temporarily bypassed for testing
  }

  void _showRequirements(BuildContext context, String careerName) {
    try {
      final career =
          CareerSystem.specialCareers.firstWhere((c) => c.name == careerName);

      final eduLevels = [
        'None',
        'Primary',
        'Secondary',
        'Higher Secondary',
        'Undergraduate',
        'Graduate',
        'Postgraduate'
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar:
          _buildAppBar(context, 'SPECIAL CAREERS', trailing: const SizedBox()),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader('FAME'),
          _SpecialFlatRow(
            icon: '🎬',
            title: 'Actor',
            subtitle: 'Fame: 0% • Education: None',
            locked: _isLocked('Actor'),
            allowLockedTap: true,
            onTap: () {
              // TODO: Remove Special Career Debug Mode after UI development
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
          _SpecialFlatRow(
            icon: '🎤',
            title: 'Singer',
            subtitle: 'Fame: 0% • Skill: High',
            locked: _isLocked('Musician'),
            allowLockedTap: true,
            onTap: () {
              // TODO: Remove Special Career Debug Mode after UI development
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
          _buildSectionHeader('SPORTS'),
          _SpecialFlatRow(
            icon: '🏏',
            title: 'Cricketer',
            subtitle: 'Reputation: 0% • Skill: Max',
            locked: _isLocked('Athlete'),
            allowLockedTap: true,
            onTap: () {
              // TODO: Remove Special Career Debug Mode after UI development
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
          _SpecialFlatRow(
            icon: '⚽',
            title: 'Footballer',
            subtitle: 'Reputation: 0% • Skill: Max',
            locked: _isLocked('Athlete'),
            onTap: () {
              // TODO: Remove Special Career Debug Mode after UI development
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
          _buildSectionHeader('ENTERTAINMENT'),
          _SpecialFlatRow(
            icon: '📺',
            title: 'Influencer',
            subtitle: 'Fame: 0% • Followers: 0',
            locked: _isLocked('Influencer'),
            allowLockedTap: true,
            onTap: () {
              // TODO: Remove Special Career Debug Mode after UI development
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
          _buildSectionHeader('GOVERNMENT'),
          _SpecialFlatRow(
            icon: '🏛️',
            title: 'Politician',
            subtitle: 'Reputation: 0% • Education: University',
            locked: _isLocked('Politician'),
            allowLockedTap: true,
            onTap: () {
              // TODO: Remove Special Career Debug Mode after UI development
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
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _EducationListScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _EducationListScreen({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(context, 'EDUCATION', trailing: const SizedBox()),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Status Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EEFF),
              border: Border(
                  bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'High School',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF161C28),
                      ),
                    ),
                    Text(
                      'GPA: 3.8',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF006D37),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENT GRADE: 10',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5E62),
                      ),
                    ),
                    SizedBox(
                      width: 96,
                      height: 8,
                      child: Container(
                        decoration:
                            const BoxDecoration(color: Color(0xFFE1E2E6)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.85,
                          child: Container(color: const Color(0xFF2ECC71)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildSectionHeader('CURRENT EDUCATION'),
          AppFlatRowGroup(
            rows: [
              AppFlatRow(
                icon: const Text('🏫', style: TextStyle(fontSize: 24)),
                title: 'Public High School',
                subtitle: 'Grade 10',
                onTap: () {},
              ),
              AppFlatRow(
                icon: const Text('📈', style: TextStyle(fontSize: 24)),
                title: 'GPA / Performance',
                subtitle: 'Excellent',
                subtitleStyle: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF006D37),
                ),
                onTap: () {},
              ),
              AppFlatRow(
                icon: const Text('📚', style: TextStyle(fontSize: 24)),
                title: 'Study Harder',
                subtitle: 'Improve your grades',
                onTap: () => onGameAction(const GameAction(
                    'career.perform', {'actionId': 'career.study_hard'})),
              ),
            ],
          ),

          _buildSectionHeader('OPTIONS'),
          AppFlatRowGroup(
            rows: [
              AppFlatRow(
                  icon: const Text('🎭', style: TextStyle(fontSize: 24)),
                  title: 'School Activities',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SchoolActivitiesScreen(
                          character: character,
                          onGameAction: onGameAction,
                        ),
                      ))),
              AppFlatRow(
                icon: const Text('📝', style: TextStyle(fontSize: 24)),
                title: 'Exams',
                subtitle: 'Take entrance exam (JEE / NEET)',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ExamQuizPage(
                    character: character,
                    onGameAction: onGameAction,
                  ),
                )),
              ),
              AppFlatRow(
                  icon: const Text('💰', style: TextStyle(fontSize: 24)),
                  title: 'Scholarships',
                  subtitle: 'Check eligibility',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ScholarshipsScreen(
                          character: character,
                          onGameAction: onGameAction,
                        ),
                      ))),
              AppFlatRow(
                  icon: const Text('🏛️', style: TextStyle(fontSize: 24)),
                  title: 'Libraries',
                  subtitle: 'Study session',
                  onTap: () => onGameAction(const GameAction(
                      'career.perform', {'actionId': 'career.study_hard'}))),
              AppFlatRow(
                  icon: const Text('👨‍🏫', style: TextStyle(fontSize: 24)),
                  title: 'Tutors',
                  subtitle: 'Boost prep level',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => TutorsScreen(
                          character: character,
                          onGameAction: onGameAction,
                        ),
                      ))),
            ],
          ),

          _buildSectionHeader('UNIVERSITIES'),
          AppFlatRowGroup(
            rows: [
              AppFlatRow(
                icon: const Text('🎓', style: TextStyle(fontSize: 24)),
                title: 'Universities',
                subtitle: 'Apply for higher education',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _UniversityScreen(
                        character: character, onGameAction: onGameAction))),
              ),
              AppFlatRow(
                icon: const Text('🏢', style: TextStyle(fontSize: 24)),
                title: 'Post-Graduate',
                subtitle: 'Complete University first',
                locked: true,
                titleStyle: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5C5E62)),
                subtitleStyle: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF5C5E62)),
                onTap: () {},
              ),
            ],
          ),
          // --- COMPETITIVE EXAMS (Graduate+) ---
          if (character.educationLevel == 'Graduate' ||
              character.educationLevel == 'Postgraduate') ...[
            _buildSectionHeader('COMPETITIVE EXAMS'),
            AppFlatRowGroup(
              rows: [
                AppFlatRow(
                  icon: const Text('\ud83c\udfdb\ufe0f',
                      style: TextStyle(fontSize: 24)),
                  title: character.memories.containsKey('passed_UPSC')
                      ? '\u2705 UPSC Cleared'
                      : 'Prepare UPSC',
                  subtitle: character.memories.containsKey('passed_UPSC')
                      ? 'IAS/IPS/IFS unlocked'
                      : 'Prep: ${character.prepLevel}% \u2022 Need 30%+',
                  locked: character.memories.containsKey('passed_UPSC'),
                  onTap: character.memories.containsKey('passed_UPSC')
                      ? () {}
                      : () => onGameAction(const GameAction('career.perform',
                          {'actionId': 'career.prepare_upsc'})),
                ),
                if (!character.memories.containsKey('passed_UPSC'))
                  AppFlatRow(
                    icon: const Text('\ud83d\udcdd',
                        style: TextStyle(fontSize: 24)),
                    title: 'Attempt UPSC',
                    subtitle:
                        'Very low pass rate \u2022 High preparation needed',
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
                AppFlatRow(
                  icon: const Text('\ud83d\udccb',
                      style: TextStyle(fontSize: 24)),
                  title: character.memories.containsKey('passed_SSC')
                      ? '\u2705 SSC Cleared'
                      : 'Prepare SSC',
                  subtitle: character.memories.containsKey('passed_SSC')
                      ? 'Government clerk/officer posts unlocked'
                      : 'Stable government job \u2022 Moderate difficulty',
                  locked: character.memories.containsKey('passed_SSC'),
                  onTap: character.memories.containsKey('passed_SSC')
                      ? () {}
                      : () => onGameAction(const GameAction('career.perform',
                          {'actionId': 'career.prepare_ssc'})),
                ),
                if (!character.memories.containsKey('passed_SSC'))
                  AppFlatRow(
                    icon: const Text('\u270f\ufe0f',
                        style: TextStyle(fontSize: 24)),
                    title: 'Attempt SSC',
                    subtitle: 'Prep: ${character.prepLevel}% \u2022 Need 20%+',
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
                AppFlatRow(
                  icon: const Text('\ud83c\udfe6',
                      style: TextStyle(fontSize: 24)),
                  title: character.memories.containsKey('passed_BankPO')
                      ? '\u2705 Bank PO Cleared'
                      : 'Attempt Bank PO',
                  subtitle: character.memories.containsKey('passed_BankPO')
                      ? 'Bank PO/RBI posts unlocked'
                      : 'Good salary \u2022 Respectable government role',
                  locked: character.memories.containsKey('passed_BankPO'),
                  onTap: character.memories.containsKey('passed_BankPO')
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
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _UniversityScreen extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _UniversityScreen({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _buildAppBar(
        context,
        'UNIVERSITY',
        trailing: const Icon(Icons.school, color: Color(0xFF5C5E62), size: 24),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Identity Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3FF),
              border: Border(
                  bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT STATUS',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5E62),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'High School Graduate',
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF161C28),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      GameEngine.formatMoney(character.bankBalance),
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF006D37),
                      ),
                    ),
                    Text(
                      'Savings',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5E62),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildSectionHeader('COLLEGES'),
          AppFlatRowGroup(
            rows: InstituteData.topInstitutes.map((inst) {
              return AppFlatRow(
                icon: const Text('🎓', style: TextStyle(fontSize: 24)),
                title: inst.name,
                subtitle:
                    'Fees: ₹${GameEngine.formatMoney(inst.feesPerYear)} • Prestige: ${inst.tier}',
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
              );
            }).toList(),
          ),

          _buildSectionHeader('APPLICATION'),
          AppFlatRowGroup(
            rows: [
              AppFlatRow(
                icon: const Text('📝', style: TextStyle(fontSize: 24)),
                title: 'Apply for Admission',
                subtitle: 'Choose your major',
                onTap: () {},
              ),
              AppFlatRow(
                icon: const Text('💰', style: TextStyle(fontSize: 24)),
                title: 'Financial Aid',
                subtitle: 'Apply for a student loan',
                onTap: () {},
              ),
            ],
          ),

          // Metric Bars
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
            ),
            child: Column(
              children: [
                _buildMetricBar('INTELLIGENCE', character.smarts,
                    color: const Color(0xFF006D37)),
                const SizedBox(height: 16),
                _buildMetricBar('AMBITION', 95, color: const Color(0xFF98472A)),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Reusable UI Components ──────────────────────────────────────────────────

PreferredSizeWidget _buildAppBar(BuildContext context, String title,
    {Widget? trailing}) {
  return FlatBackAppBar(title: title, trailing: trailing);
}

Widget _buildIdentityHeader(Character character) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STATUS',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF71717A),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  character.name,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF181C1F),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(character.bankBalance),
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF059669),
                  ),
                ),
                Text(
                  'Age: ${character.age}',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF71717A),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        _buildMetricBar('Smarts', character.smarts),
        const SizedBox(height: 4),
        _buildMetricBar('Looks', character.looks),
      ],
    ),
  );
}

Widget _buildMetricBar(String label, int value,
    {Color color = const Color(0xFF10B981)}) {
  return Row(
    children: [
      SizedBox(
        width: 64,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF71717A),
          ),
        ),
      ),
      Expanded(
        child: Container(
          height: 5,
          decoration: const BoxDecoration(color: Color(0xFFF4F4F5)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (value / 100).clamp(0.01, 1.0),
            child: Container(color: color),
          ),
        ),
      ),
    ],
  );
}

Widget _buildSectionHeader(String title) {
  return AppSectionHeader(
    title: title,
    style: GoogleFonts.lexend(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF71717A),
      letterSpacing: 2.0,
    ),
  );
}
