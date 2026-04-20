// lib/screens/activities_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/engine.dart';
import '../models/character.dart';
import '../core/design_system.dart';
import '../core/storage.dart';


class ActivitiesPage extends StatefulWidget {
  final Character character;
  final bool isTab;
  final VoidCallback? onBack;
  const ActivitiesPage({super.key, required this.character, this.isTab = false, this.onBack});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  @override
  void initState() {
    super.initState();
  }

  void _perform(String activityId) {
    HapticFeedback.mediumImpact();
    final result = GameEngine.performActivity(widget.character, activityId);
    bool isError = result.startsWith('❌');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor:
          isError ? AppColors.alertRed : AppColors.highlightGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(AppSpacing.s16),
      duration: const Duration(seconds: 2),
    ));

    if (!isError) {
      StorageService.saveCharacter(widget.character);
      setState(() {});
    }
  }
  void _showDatingDialog() {
    if (widget.character.age < 16) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You must be at least 16 years old to start dating!'),
        backgroundColor: AppColors.alertRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final candidate = GameEngine.generateDatingCandidate(widget.character.age);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppShadows.premium,
          ),
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: AppColors.healthGradient),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppColors.healthGradient.first.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    candidate.initial,
                    style: AppTextStyles.h1
                        .copyWith(color: Colors.white, fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              Text(candidate.name,
                  style: AppTextStyles.bodyBold.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text('${candidate.age} years old', style: AppTextStyles.subtitle),
              const SizedBox(height: AppSpacing.s16),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.eventPositiveBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.eventPositive.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'You met at a social event. They seem interested in you. Start dating?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF065F46),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: AppColors.textMuted.withValues(alpha: 0.3)),
                        ),
                      ),
                      child: Text(
                        'Not Now',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        GameEngine.addPartner(widget.character, candidate);
                        StorageService.saveCharacter(widget.character);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('You are now dating ${candidate.name}! ❤️'),
                          backgroundColor: AppColors.healthGradient.last,
                          behavior: SnackBarBehavior.floating,
                        ));
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: AppColors.healthGradient),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.healthGradient.first
                                  .withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Let's Go! ❤️",
                            style: AppTextStyles.bodyBold
                                .copyWith(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
                      // 0. Back AppBar (visible if not tab or if onBack provided)
                      if (!widget.isTab || widget.onBack != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (widget.onBack != null) {
                                      widget.onBack!();
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
                          ),
                        ),
                      // 1. Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Activities', style: AppTextStyles.h1.copyWith(fontSize: 32)),
                              Text('Shape your future & skills',
                                  style: AppTextStyles.subtitle),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s16, 0, AppSpacing.s16, 120),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                  _SectionHeading(
                    title: 'MIND & BODY',
                    icon: Icons.fitness_center_rounded,
                    color: AppColors.healthGradient.first,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _TappableActivityCard(
                    icon: Icons.fitness_center_rounded,
                    gradient: AppColors.healthGradient,
                    title: 'Gym Workout',
                    desc: 'Improve health & happiness',
                    cost: '₹500',
                    onTap: () => _perform('Gym Workout'),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _TappableActivityCard(
                    icon: Icons.self_improvement_rounded,
                    gradient: AppColors.karmaGradient,
                    title: 'Meditation',
                    desc: 'Find your inner peace',
                    cost: 'Free',
                    onTap: () => _perform('Temple Visit'),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _TappableActivityCard(
                    icon: Icons.menu_book_rounded,
                    gradient: AppColors.smartsGradient,
                    title: 'Study Hard',
                    desc: 'Expand your knowledge',
                    cost: 'Free',
                    onTap: () => _perform('Study Hard'),
                  ),

                  const SizedBox(height: AppSpacing.s32),

                  _SectionHeading(
                    title: 'SOCIAL & LIFESTYLE',
                    icon: Icons.people_rounded,
                    color: AppColors.socialGradient.first,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _TappableActivityCard(
                    icon: Icons.favorite_rounded,
                    gradient: AppColors.healthGradient,
                    title: 'Find Love',
                    desc: 'Seek a meaningful relationship',
                    cost: 'Free',
                    onTap: _showDatingDialog,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _TappableActivityCard(
                    icon: Icons.nightlife_rounded,
                    gradient: AppColors.socialGradient,
                    title: 'Go to Party',
                    desc: 'Relax and meet new people',
                    cost: '₹1,000',
                    onTap: () => _perform('Go to Party'),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _TappableActivityCard(
                    icon: Icons.volunteer_activism_rounded,
                    gradient: AppColors.happyGradient,
                    title: 'Volunteer',
                    desc: 'Make a positive impact',
                    cost: 'Free',
                    onTap: () => _perform('Side Hustle'),
                  ),
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

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeading(
      {required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _TappableActivityCard extends StatefulWidget {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String desc;
  final String cost;
  final VoidCallback onTap;

  const _TappableActivityCard({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.desc,
    required this.cost,
    required this.onTap,
  });

  @override
  State<_TappableActivityCard> createState() => _TappableActivityCardState();
}

class _TappableActivityCardState extends State<_TappableActivityCard>
    with SingleTickerProviderStateMixin {
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
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.gradient.first.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.9),
                blurRadius: 0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon in gradient rounded square
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: AppSpacing.s16),
              // Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.desc,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              // Cost badge + arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.gradient.first.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.cost,
                      style: AppTextStyles.caption.copyWith(
                        color: widget.gradient.first,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
