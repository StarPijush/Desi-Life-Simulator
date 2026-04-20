// lib/widgets/timeline_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/enums.dart';
import '../models/life_event.dart';
import '../core/design_system.dart';
import 'vertical_timeline.dart';
import 'section_header.dart';

// Maximum events rendered in the timeline to prevent long-session memory bloat
const int _kMaxTimelineEvents = 100;

class TimelineSection extends StatelessWidget {
  final List<LifeEvent> events;
  final Function(LifeEvent) onEventTap;

  const TimelineSection({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Center(
            child: Text(
              'Your story begins now...',
              style: AppTextStyles.subtitle,
            ),
          ),
        ),
      );
    }

    // Only render up to the cap — newest events are at index 0
    final displayEvents = events.length > _kMaxTimelineEvents
        ? events.sublist(0, _kMaxTimelineEvents)
        : events;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        240,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final event = displayEvents[index];
            final eventAge = (event.metadata['age'] as int?) ?? 0;

            // Show age separator only when age group changes
            String? ageSeparatorLabel;
            if (index == 0 ||
                eventAge !=
                    ((displayEvents[index - 1].metadata['age'] as int?) ?? 0)) {
              ageSeparatorLabel = 'AGE $eventAge';
            }

            // Key by index so Flutter reuses element slots efficiently
            return VerticalTimelineItem(
              key: ValueKey(event.hashCode),
              ageSeparatorLabel: ageSeparatorLabel,
              isFirst: index == 0,
              isLast: index == displayEvents.length - 1,
              eventType: event.type,
              priority: event.priority,
              applyTint: index % 2 == 0,
              onTap: () {
                HapticFeedback.lightImpact();
                onEventTap(event);
              },
              child: _EventCard(event: event),
            );
          },
          childCount: displayEvents.length,
          // Provide estimated item extent for faster layout
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true, // Flutter adds RepaintBoundary per item
          addSemanticIndexes: false,  // Not needed — saves overhead
        ),
      ),
    );
  }

  // Timeline header is a static section widget embedded here
  static Widget buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s24,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      child: SectionHeader(
        title: 'Life Timeline',
        subtitle: 'Your journey so far',
      ),
    );
  }
}

// Extracted to a StatelessWidget so Flutter can identity-check it efficiently
class _EventCard extends StatelessWidget {
  final LifeEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final (cardBg, borderColor, textColor) = _eventColors(event.type);
    final isRare = event.priority == EventPriority.rare;
    final isCritical = event.priority == EventPriority.critical;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.large)),
        border: Border.all(
          color: isRare
              ? const Color(0x99F59E0B)
              : borderColor,
          width: (isCritical || isRare) ? 1.5 : 1,
        ),
        boxShadow: (isRare || isCritical)
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : AppShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.title,
              style: AppTextStyles.bodyBold.copyWith(
                color: textColor,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                event.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor.withAlpha(180),
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static (Color, Color, Color) _eventColors(LifeEventType type) {
    switch (type) {
      case LifeEventType.positive:
        return (
          AppColors.eventPositiveBg,
          const Color(0x40059669),
          const Color(0xFF065F46),
        );
      case LifeEventType.negative:
        return (
          AppColors.eventNegativeBg,
          const Color(0x40F43F5E),
          const Color(0xFF9F1239),
        );
      case LifeEventType.milestone:
        return (
          AppColors.eventMilestoneBg,
          const Color(0x403B82F6),
          const Color(0xFF1E3A8A),
        );
      case LifeEventType.rare:
        return (
          const Color(0xFFFEF9C3),
          const Color(0xFFF59E0B),
          const Color(0xFF92400E),
        );
      case LifeEventType.critical:
        return (
          const Color(0xFFFEE2E2),
          const Color(0xFFEF4444),
          const Color(0xFF991B1B),
        );
      default:
        return (
          AppColors.eventNeutralBg,
          const Color(0x30D97706),
          const Color(0xFF78350F),
        );
    }
  }
}
