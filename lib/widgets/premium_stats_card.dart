// lib/widgets/premium_stats_card.dart
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../core/design_system.dart';
import 'icon_container.dart';
import 'section_header.dart';

class PremiumStatsCard extends StatelessWidget {
  final Character character;
  final Map<String, int>? statDeltas;

  const PremiumStatsCard({
    super.key,
    required this.character,
    this.statDeltas,
  });

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates this card from parent scroll repaints
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s20),
        decoration: AppDecoration.statCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Life Stats',
              action: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: Text(
                  'AGE ${character.age}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            _AnimatedStatRow(
              label: 'Happiness',
              icon: Icons.sentiment_very_satisfied_rounded,
              value: character.happiness,
              delta: statDeltas?['happiness'],
              gradient: AppColors.happyGradient,
            ),
            const SizedBox(height: AppSpacing.s16),
            _AnimatedStatRow(
              label: 'Health',
              icon: Icons.favorite_rounded,
              value: character.health,
              delta: statDeltas?['health'],
              gradient: AppColors.healthGradient,
            ),
            const SizedBox(height: AppSpacing.s16),
            _AnimatedStatRow(
              label: 'Smarts',
              icon: Icons.psychology_rounded,
              value: character.smarts,
              delta: statDeltas?['smarts'],
              gradient: AppColors.smartsGradient,
            ),
            const SizedBox(height: AppSpacing.s16),
            _AnimatedStatRow(
              label: 'Social',
              icon: Icons.people_alt_rounded,
              value: character.social,
              delta: statDeltas?['social'],
              gradient: AppColors.socialGradient,
            ),
            const SizedBox(height: AppSpacing.s16),
            _AnimatedStatRow(
              label: 'Karma',
              icon: Icons.auto_awesome_rounded,
              value: character.karma,
              delta: statDeltas?['karma'],
              gradient: AppColors.karmaGradient,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStatRow extends StatefulWidget {
  final String label;
  final IconData icon;
  final int value;
  final int? delta;
  final List<Color> gradient;

  const _AnimatedStatRow({
    required this.label,
    required this.icon,
    required this.value,
    this.delta,
    required this.gradient,
  });

  @override
  State<_AnimatedStatRow> createState() => _AnimatedStatRowState();
}

class _AnimatedStatRowState extends State<_AnimatedStatRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _deltaController;
  late Animation<double> _deltaOpacity;
  late Animation<double> _deltaSlide;

  @override
  void initState() {
    super.initState();
    _deltaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _deltaOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_deltaController);
    _deltaSlide = Tween(begin: 8.0, end: -32.0).animate(
      CurvedAnimation(parent: _deltaController, curve: AppMotion.standardSnap),
    );
    if (widget.delta != null && widget.delta != 0) {
      _deltaController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(_AnimatedStatRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delta != null &&
        widget.delta != oldWidget.delta &&
        widget.delta != 0) {
      _deltaController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _deltaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delta = widget.delta ?? 0;
    final deltaColor =
        delta > 0 ? AppColors.highlightGreen : AppColors.alertRed;
    final glow = delta != 0;

    return Column(
      children: [
        Row(
          children: [
            // Icon with soft background
            IconContainer(
              icon: widget.icon,
              gradient: widget.gradient,
              size: 36,
              iconSize: 17,
            ),
            const SizedBox(width: AppSpacing.s12),
            Text(
              widget.label,
              style: AppTextStyles.label,
            ),
            const Spacer(),
            // Floating delta animation
            if (delta != 0)
              AnimatedBuilder(
                animation: _deltaController,
                builder: (context, _) => Opacity(
                  opacity: _deltaOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _deltaSlide.value),
                    child: Text(
                      '${delta > 0 ? '+' : ''}$delta',
                      style: AppTextStyles.bodyBold.copyWith(
                        color: deltaColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Text(
              '${widget.value}%',
              style: AppTextStyles.bodyBold.copyWith(
                color: widget.gradient.first,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        // Smooth animated progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Stack(
            children: [
              Container(
                height: 7,
                width: double.infinity,
                color: widget.gradient.first.withValues(alpha: 0.1),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0,
                  end: (widget.value / 100).clamp(0.0, 1.0),
                ),
                duration: const Duration(milliseconds: 550),
                curve: const Cubic(0.1, 0.9, 0.2, 1.1),
                builder: (_, v, __) => FractionallySizedBox(
                  widthFactor: v,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: glow
                          ? [
                              BoxShadow(
                                color: deltaColor.withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 1),
                              )
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
