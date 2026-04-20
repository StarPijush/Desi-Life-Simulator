// lib/screens/relations_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';
import '../models/relationship.dart';
import '../widgets/relation_dialog.dart';
import '../core/design_system.dart';
import '../widgets/empty_state.dart';

class RelationsPage extends StatefulWidget {
  final Character character;
  final bool isTab;
  final VoidCallback? onBack;
  const RelationsPage({super.key, required this.character, this.isTab = false, this.onBack});

  @override
  State<RelationsPage> createState() => _RelationsPageState();
}

class _RelationsPageState extends State<RelationsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openInteraction(Relationship rel) {
    RelationDialog.show(
      context,
      character: widget.character,
      relationship: rel,
      onInteraction: (result) {
        if (result.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.darkBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(AppSpacing.s16),
            ),
          );
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final char = widget.character;
    final family = char.relationships
        .where((r) => ['Father', 'Mother', 'Sibling'].contains(r.type))
        .toList();
    final friends =
        char.relationships.where((r) => r.type == 'Friend').toList();
    final partners =
        char.relationships.where((r) => r.type == 'Partner').toList();

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
                  child: FadeTransition(
                    opacity: _fadeAnim,
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
                                Text('Connections',
                                    style: AppTextStyles.h1.copyWith(fontSize: 32)),
                                Text('Your life in ${char.city}',
                                    style: AppTextStyles.subtitle),
                              ],
                            ),
                          ),
                        ),

                        if (char.relationships.isEmpty)
                          SliverToBoxAdapter(
                            child: EmptyStateWidget(
                              icon: Icons.people_outline_rounded,
                              title: 'No Connections Yet',
                              subtitle:
                                  'Age up to meet family, friends, and potentially your future partner!',
                              color: AppColors.secondaryGradient.first,
                              actionLabel: 'Meet People',
                              onAction: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Focus on yourself and grow up! New connections will appear as you age.'),
                                  backgroundColor: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.s16, 0, AppSpacing.s16, 120),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                if (family.isNotEmpty) ...[
                                  const _RelationSectionHeader(
                                    title: 'FAMILY',
                                    icon: Icons.home_rounded,
                                    colors: AppColors.primaryGradient,
                                  ),
                                  const SizedBox(height: AppSpacing.s12),
                                  ...family.map((r) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: AppSpacing.s12),
                                        child: _RelationCard(
                                          rel: r,
                                          gradientColors: AppColors.primaryGradient,
                                          onTap: () => _openInteraction(r),
                                        ),
                                      )),
                                  const SizedBox(height: AppSpacing.s24),
                                ],
                                if (friends.isNotEmpty) ...[
                                  const _RelationSectionHeader(
                                    title: 'FRIENDS',
                                    icon: Icons.people_rounded,
                                    colors: AppColors.smartsGradient,
                                  ),
                                  const SizedBox(height: AppSpacing.s12),
                                  ...friends.map((r) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: AppSpacing.s12),
                                        child: _RelationCard(
                                          rel: r,
                                          gradientColors: AppColors.smartsGradient,
                                          onTap: () => _openInteraction(r),
                                        ),
                                      )),
                                  const SizedBox(height: AppSpacing.s24),
                                ],
                                if (partners.isNotEmpty) ...[
                                  const _RelationSectionHeader(
                                    title: 'ROMANCE',
                                    icon: Icons.favorite_rounded,
                                    colors: AppColors.healthGradient,
                                  ),
                                  const SizedBox(height: AppSpacing.s12),
                                  ...partners.map((r) => Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: AppSpacing.s12),
                                        child: _RelationCard(
                                          rel: r,
                                          gradientColors: AppColors.healthGradient,
                                          onTap: () => _openInteraction(r),
                                        ),
                                      )),
                                ],
                              ]),
                            ),
                          ),
                        // Bottom padding for persistent navigation bar
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 160),
                        ),
                      ],
                    ),
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

class _RelationSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> colors;

  const _RelationSectionHeader({
    required this.title,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: AppSpacing.s12),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _RelationCard extends StatefulWidget {
  final Relationship rel;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _RelationCard({
    required this.rel,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_RelationCard> createState() => _RelationCardState();
}

class _RelationCardState extends State<_RelationCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = widget.gradientColors.first;

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
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.07),
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
              // Avatar with gradient ring
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.gradientColors),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.rel.initial,
                      style: AppTextStyles.bodyBold
                          .copyWith(color: primaryColor, fontSize: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.rel.name,
                            style: AppTextStyles.bodyBold.copyWith(fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.rel.age}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.rel.type,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    // Gradient bond progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: Stack(
                              children: [
                                Container(
                                  height: 6,
                                  color: primaryColor.withValues(alpha: 0.08),
                                ),
                                FractionallySizedBox(
                                  widthFactor:
                                      (widget.rel.bond / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: widget.gradientColors),
                                      borderRadius: BorderRadius.circular(99),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(alpha: 0.35),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          '${widget.rel.bond}%',
                          style: AppTextStyles.bodyBold.copyWith(
                            fontSize: 11,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted.withValues(alpha: 0.5),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
