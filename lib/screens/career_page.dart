// lib/screens/career_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';
import '../core/engine.dart';
import '../core/design_system.dart';
import '../core/storage.dart';
import '../widgets/career_switch_dialog.dart';

class CareerPage extends StatefulWidget {
  final Character character;
  final bool isTab;
  final VoidCallback? onBack;
  const CareerPage({super.key, required this.character, this.isTab = false, this.onBack});

  @override
  State<CareerPage> createState() => _CareerPageState();
}

class _CareerPageState extends State<CareerPage> {
  late Character _char;

  @override
  void initState() {
    super.initState();
    _char = widget.character;
  }

  void _perform(String activityId) {
    HapticFeedback.mediumImpact();
    final result = GameEngine.performActivity(_char, activityId);
    final isError = result.startsWith('❌');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: isError ? AppColors.alertRed : AppColors.highlightGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
      margin: const EdgeInsets.all(AppSpacing.s16),
      duration: const Duration(seconds: 2),
    ));

    if (!isError) {
      StorageService.saveCharacter(_char);
      setState(() {});
    }
  }

  void _resign() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text('Resign from ${_char.jobTitle}?', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to quit your job?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.label.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _char.jobTitle = 'Unemployed';
                _char.annualIncome = 0;
              });
              StorageService.saveCharacter(_char);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('You resigned from your job.'),
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: Text('Resign', style: AppTextStyles.label.copyWith(color: AppColors.alertRed)),
          ),
        ],
      ),
    );
  }

  void _showCareerSwitch({CareerTier? tier}) {
    final alts = CareerSystem.alternativeGroups(_char, tier: tier);
    if (alts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No job openings in this category. Improve your stats!'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    
    // If only one option, we might skip the pair-choice dialog or just show it with one
    // But pair-switch dialog needs 2. Let's adapt it to show what's available.
    final offer = CareerSwitchOffer(
      optionA: alts[0], 
      optionB: alts.length > 1 ? alts[1] : alts[0]
    );
    CareerSwitchDialog.show(
      context,
      offer: offer,
      onChoice: (CareerGroup? chosen) {
        if (chosen == null) return; // stayed
        final result = CareerSystem.switchCareer(_char, chosen);
        StorageService.saveCharacter(_char);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.highlightGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
          margin: const EdgeInsets.all(AppSpacing.s16),
        ));
      },
    );
  }

  String _getSchoolName() => _char.universityType != 'None' 
    ? '${_char.city} ${_char.universityType} University' 
    : '${_char.educationLevel} School';

  bool get _isStudent => _char.age < 19 || (_char.universityType != 'None' && _char.age < 25);
  bool get _isEmployed => _char.annualIncome > 0 && _char.careerGroup != 'None';
  bool get _canWorkPartTime => _char.age >= 16 && _char.age < 22;

  void _takeExam(String type) {
    HapticFeedback.heavyImpact();
    final result = GameEngine.takeEntranceExam(_char, type);
    StorageService.saveCharacter(_char);
    _showFeedback(result);
    setState(() {});
  }

  void _chooseCollege(String type) {
    HapticFeedback.mediumImpact();
    final result = GameEngine.chooseCollege(_char, type);
    StorageService.saveCharacter(_char);
    _showFeedback(result);
    setState(() {});
  }

  void _showFeedback(String message) {
    final isError = message.startsWith('❌');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: isError ? AppColors.alertRed : AppColors.highlightGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
      margin: const EdgeInsets.all(AppSpacing.s16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.black,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Scaffold(
              backgroundColor: AppColors.scaffoldBg,
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.mainBgGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ── App Bar (visible if not tab or if onBack provided) ──
                      if (!widget.isTab || widget.onBack != null)
                        SliverToBoxAdapter(
                          child: _CareerAppBar(onBack: widget.onBack),
                        ),

                      // ── Page Title ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.s20, AppSpacing.s8, AppSpacing.s20, AppSpacing.s4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Career',
                                style: AppTextStyles.h1.copyWith(fontSize: 32, letterSpacing: -0.5),
                              ),
                              Text(
                                'Education & Professional Life',
                                style: AppTextStyles.subtitle,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, 160),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                             // ── Education Section ──
                            if (_char.age >= 5) ...[
                              const _SectionLabel(
                                title: 'EDUCATION',
                                icon: Icons.school_rounded,
                                gradient: AppColors.smartsGradient,
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              _EducationStatusCard(
                                schoolName: _getSchoolName(),
                                level: _char.universityType != 'None' ? 'University (${_char.universityType})' : _char.educationLevel,
                                smarts: _char.smarts,
                                age: _char.age,
                              ),
                              const SizedBox(height: AppSpacing.s12),

                              // Study actions
                              if (_isStudent) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ActionCardSmall(
                                        icon: Icons.menu_book_rounded,
                                        title: 'Study Hard',
                                        gradient: AppColors.smartsGradient,
                                        onTap: () => _perform('Study Hard'),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s12),
                                    Expanded(
                                      child: _ActionCardSmall(
                                        icon: Icons.sports_esports_rounded,
                                        title: 'Skip School',
                                        gradient: const [AppColors.alertRed, Color(0xFFFF6B6B)],
                                        onTap: () => _perform('Skip School'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.s12),
                                _ActionCard(
                                  icon: Icons.people_rounded,
                                  title: 'Socialize',
                                  subtitle: 'Build connections and relax',
                                  gradient: AppColors.happyGradient,
                                  onTap: () => _perform('Socialize'),
                                ),
                              ],

                              // Competitive Exams (Age 17-18)
                              if (_char.educationLevel == 'Higher Secondary' && _char.universityType == 'None') ...[
                                const SizedBox(height: AppSpacing.s20),
                                Text('Competitive Exams', style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: AppColors.textSecondary)),
                                const SizedBox(height: AppSpacing.s12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ActionCardSmall(
                                        icon: Icons.biotech_rounded,
                                        title: 'JEE (Tech)',
                                        gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                        onTap: () => _takeExam('JEE'),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s12),
                                    Expanded(
                                      child: _ActionCardSmall(
                                        icon: Icons.medical_services_rounded,
                                        title: 'NEET (Med)',
                                        gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                                        onTap: () => _takeExam('NEET'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              // College Admission (If school done but no college yet)
                              if (_char.age >= 18 && _char.universityType == 'None' && !_isEmployed) ...[
                                const SizedBox(height: AppSpacing.s20),
                                Text('Higher Education', style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: AppColors.textSecondary)),
                                const SizedBox(height: AppSpacing.s12),
                                _ActionCard(
                                  icon: Icons.account_balance_rounded,
                                  title: 'Government College',
                                  subtitle: 'Merit-based admission, low fees',
                                  gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                                  onTap: () => _chooseCollege('Government'),
                                ),
                                const SizedBox(height: AppSpacing.s12),
                                _ActionCard(
                                  icon: Icons.business_rounded,
                                  title: 'Private University',
                                  subtitle: 'Direct admission, higher fees',
                                  gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                                  onTap: () => _chooseCollege('Private'),
                                ),
                                const SizedBox(height: AppSpacing.s12),
                                _ActionCard(
                                  icon: Icons.timer_rounded,
                                  title: 'Take a Gap Year',
                                  subtitle: 'Focus on your own path for now',
                                  gradient: const [AppColors.textMuted, Color(0xFF64748B)],
                                  onTap: () => _chooseCollege('Drop'),
                                ),
                              ],

                              const SizedBox(height: AppSpacing.s32),
                            ],

                            // ── Career Section ──
                            const _SectionLabel(
                              title: 'CAREER',
                              icon: Icons.work_rounded,
                              gradient: AppColors.primaryGradient,
                            ),
                            const SizedBox(height: AppSpacing.s12),

                            // Lock message for youngsters
                            if (_char.age < 16) ...[
                              const _EmptyCareerCard(
                                message: 'Focus on your education for now. Professional opportunities unlock at age 16.',
                                icon: Icons.lock_clock_rounded,
                              ),
                            ]
                            // Employed
                            else if (_isEmployed) ...[
                              _JobStatusCard(
                                jobTitle: _char.jobTitle,
                                annualIncome: _char.annualIncome,
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              _ActionCard(
                                icon: Icons.bolt_rounded,
                                title: 'Work Hard',
                                subtitle: 'Put in the extra effort this year',
                                gradient: AppColors.primaryGradient,
                                onTap: () => _perform('Side Hustle'),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              _ActionCard(
                                icon: Icons.trending_up_rounded,
                                title: 'Ask for Promotion',
                                subtitle: 'Negotiate a raise or higher title',
                                gradient: AppColors.happyGradient,
                                onTap: () => _perform('Side Hustle'),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              _ActionCard(
                                icon: Icons.swap_horiz_rounded,
                                title: 'Switch Career',
                                subtitle: 'Explore a different profession',
                                gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                                onTap: _showCareerSwitch,
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              _ActionCard(
                                icon: Icons.money_off_rounded,
                                title: 'Resign',
                                subtitle: 'Leave your current job',
                                gradient: const [AppColors.alertRed, Color(0xFFFF6B6B)],
                                onTap: _resign,
                              ),
                            ]
                            // Unemployed
                            else ...[
                              const _EmptyCareerCard(
                                message: 'You are currently not working.',
                                icon: Icons.work_off_rounded,
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              
                              Text('Job Categories', style: AppTextStyles.bodyBold.copyWith(fontSize: 14, color: AppColors.textSecondary)),
                              const SizedBox(height: AppSpacing.s12),
                              
                              if (_canWorkPartTime) ...[
                                _ActionCard(
                                  icon: Icons.delivery_dining_rounded,
                                  title: 'Part-Time Jobs',
                                  subtitle: 'Gigs for students and teens',
                                  gradient: const [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
                                  onTap: () => _showCareerSwitch(tier: CareerTier.partTime),
                                ),
                                const SizedBox(height: AppSpacing.s12),
                              ],
                              
                              _ActionCard(
                                icon: Icons.business_center_rounded,
                                title: 'Full-Time Careers',
                                subtitle: 'Formal professional roles',
                                gradient: AppColors.primaryGradient,
                                onTap: () => _showCareerSwitch(tier: CareerTier.fullTime),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              _ActionCard(
                                icon: Icons.laptop_mac_rounded,
                                title: 'Freelancing',
                                subtitle: 'Skill-based independent work',
                                gradient: const [Color(0xFFF472B6), Color(0xFFDB2777)],
                                onTap: () => _showCareerSwitch(tier: CareerTier.freelance),
                              ),
                            ],
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Sub-Widgets
// ──────────────────────────────────────────────────────────────────

class _CareerAppBar extends StatelessWidget {
  final VoidCallback? onBack;
  const _CareerAppBar({this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.pop(context);
              }
            },
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadows.soft,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> gradient;

  const _SectionLabel({required this.title, required this.icon, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: AppSpacing.s12),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EducationStatusCard extends StatelessWidget {
  final String schoolName;
  final String level;
  final int smarts;
  final int age;

  const _EducationStatusCard({
    required this.schoolName,
    required this.level,
    required this.smarts,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.smartsGradient.first.withValues(alpha: 0.08),
            AppColors.smartsGradient.last.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.smartsGradient.first.withValues(alpha: 0.15)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.smartsGradient),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.smartsGradient.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schoolName, style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
                const SizedBox(height: 3),
                Text(level, style: AppTextStyles.subtitle.copyWith(fontSize: 12)),
                const SizedBox(height: AppSpacing.s12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: Stack(
                          children: [
                            Container(
                              height: 5,
                              color: AppColors.smartsGradient.first.withValues(alpha: 0.1),
                            ),
                            FractionallySizedBox(
                              widthFactor: (smarts / 100).clamp(0.0, 1.0),
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: AppColors.smartsGradient),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      'Grade: $smarts%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.smartsGradient.first,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JobStatusCard extends StatelessWidget {
  final String jobTitle;
  final double annualIncome;

  const _JobStatusCard({required this.jobTitle, required this.annualIncome});

  String _formatMoney(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(2)} Cr/yr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(2)} L/yr';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K/yr';
    return '₹${amount.toStringAsFixed(0)}/yr';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.work_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobTitle,
                  style: AppTextStyles.bodyBold.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMoney(annualIncome),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.happyGradient.first,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.highlightGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'EMPLOYED',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.highlightGreen,
                fontWeight: FontWeight.w800,
                fontSize: 9,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCareerCard extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyCareerCard({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 24),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s16,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: widget.gradient.first.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCardSmall extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionCardSmall({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12, horizontal: AppSpacing.s12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: gradient.first.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyBold.copyWith(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
