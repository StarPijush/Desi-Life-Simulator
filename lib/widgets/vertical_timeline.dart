import 'package:flutter/material.dart';
import '../core/design_system.dart';
import '../core/enums.dart';

class VerticalTimelineItem extends StatefulWidget {
  final Widget child;
  final String? ageSeparatorLabel;
  final bool isLast;
  final bool isFirst;
  final Color? indicatorColor;
  final IconData? icon;
  final LifeEventType eventType;
  final EventPriority priority;
  final String? age;
  final VoidCallback? onTap;
  final bool applyTint;

  const VerticalTimelineItem({
    super.key,
    required this.child,
    this.ageSeparatorLabel,
    this.isLast = false,
    this.isFirst = false,
    this.indicatorColor,
    this.icon,
    this.eventType = LifeEventType.neutral,
    this.priority = EventPriority.normal,
    this.age,
    this.onTap,
    this.applyTint = false,
  });

  @override
  State<VerticalTimelineItem> createState() => _VerticalTimelineItemState();
}

class _VerticalTimelineItemState extends State<VerticalTimelineItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Pre-computed values — avoid recalculating on every build
  late Color _cachedColor;
  late IconData _cachedIcon;
  late bool _isCritical;
  late bool _isRare;

  @override
  void initState() {
    super.initState();

    _isCritical = widget.priority == EventPriority.critical;
    _isRare = widget.priority == EventPriority.rare;
    _cachedColor = _resolveIndicatorColor(widget.eventType);
    _cachedIcon = _resolveIcon(widget.eventType);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220), // Snappier than before
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Minimal delay — just enough to avoid frame-0 jank
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Color _lineColor = Color(0x2D94A3B8); // Pre-computed, no withValues on every build

  Color _resolveIndicatorColor(LifeEventType type) {
    if (widget.indicatorColor != null) return widget.indicatorColor!;
    switch (type) {
      case LifeEventType.positive:   return AppColors.eventPositive;
      case LifeEventType.negative:   return AppColors.eventNegative;
      case LifeEventType.milestone:  return AppColors.eventMilestone;
      case LifeEventType.rare:       return const Color(0xFFD97706);
      case LifeEventType.critical:   return const Color(0xFFDC2626);
      default:                       return const Color(0x4D94A3B8);
    }
  }

  IconData _resolveIcon(LifeEventType type) {
    if (widget.icon != null) return widget.icon!;
    switch (type) {
      case LifeEventType.positive:  return Icons.check_circle_rounded;
      case LifeEventType.negative:  return Icons.cancel_rounded;
      case LifeEventType.milestone: return Icons.star_rounded;
      case LifeEventType.rare:      return Icons.auto_awesome_rounded;
      case LifeEventType.decision:  return Icons.help_outline_rounded;
      case LifeEventType.critical:  return Icons.error_rounded;
      default:                      return Icons.circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.ageSeparatorLabel != null)
                _AgeSeparator(label: widget.ageSeparatorLabel!),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left column: line + indicator ──────────────────────────
                  // Fixed-width column — no IntrinsicHeight needed
                  SizedBox(
                    width: 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top connector
                        Container(
                          width: 2,
                          height: 12,
                          color: widget.isFirst ? Colors.transparent : _lineColor,
                        ),
                        // Indicator node — RepaintBoundary isolates glow repaints
                        RepaintBoundary(
                          child: Container(
                            width: _isCritical ? 42 : 36,
                            height: _isCritical ? 42 : 36,
                            decoration: BoxDecoration(
                              color: _cachedColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isRare ? Colors.amber : Colors.white,
                                width: _isCritical ? 4 : 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _cachedColor.withValues(
                                    alpha: _isRare ? 0.6 : 0.35,
                                  ),
                                  blurRadius: _isRare ? 20 : 12,
                                  spreadRadius: _isRare ? 4 : 0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                _cachedIcon,
                                color: Colors.white,
                                size: _isCritical ? 24 : 18,
                              ),
                            ),
                          ),
                        ),
                        // Bottom connector — fixed height rather than Expanded
                        Container(
                          width: 2,
                          height: widget.isLast ? 0 : 9999, // collapses naturally with Column
                          color: widget.isLast ? Colors.transparent : _lineColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.s12),

                  // ── Right column: content card ──────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.s20,
                        top: AppSpacing.s4,
                      ),
                      child: widget.applyTint
                          ? ColoredBox(
                              // ColoredBox cheaper than Container with decoration
                              color: const Color(0x07EA580C),
                              child: widget.child,
                            )
                          : widget.child,
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
}

class _AgeSeparator extends StatelessWidget {
  final String label;
  const _AgeSeparator({required this.label});

  static const _borderColor = Color(0x33EA580C);
  static const _bgColor = Color(0xFFFFF7ED);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.s8,
        bottom: AppSpacing.s16,
      ),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Container(width: 24, height: 1.5, color: _borderColor),
          const SizedBox(width: AppSpacing.s8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: const BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.all(Radius.circular(999)),
              border: Border.fromBorderSide(
                BorderSide(color: _borderColor, width: 1),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.ageSeparator.copyWith(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          const Expanded(
            child: SizedBox(height: 1.5), // Placeholder; actual line via DecoratedBox
          ),
        ],
      ),
    );
  }
}
