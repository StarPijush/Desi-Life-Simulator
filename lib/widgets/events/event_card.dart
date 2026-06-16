import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'event_theme.dart';
import 'event_types.dart';

Future<T?> showEventCard<T>({
  required BuildContext context,
  required EventCategory category,
  required EventCardMode mode,
  required String title,
  required String description,
  EventIllustration? illustration, // Kept for API compat — ignored in V4
  List<EventInfoRow> infoRows = const [],
  List<EventRequirement> requirements = const [],
  EventCardAction? primaryAction,
  EventCardAction? secondaryAction,
  List<EventCardAction> actions = const [],
  bool barrierDismissible = false,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierColor: Colors.transparent,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      void close() => Navigator.of(dialogContext).pop();

      return EventCard(
        category: category,
        mode: mode,
        title: title,
        description: description,
        infoRows: infoRows,
        requirements: requirements,
        primaryAction: primaryAction ??
            (mode == EventCardMode.actions
                ? null
                : EventCardAction(
                    label: 'Continue',
                    onPressed: close,
                  )),
        secondaryAction: secondaryAction,
        actions: actions,
        onClose: close,
      );
    },
  );
}

// =============================================================================
// EventCard — Root overlay widget (V4: 70% black, no blur)
// =============================================================================

class EventCard extends StatelessWidget {
  final EventCategory category;
  final EventCardMode mode;
  final String title;
  final String description;
  final List<EventInfoRow> infoRows;
  final List<EventRequirement> requirements;
  final EventCardAction? primaryAction;
  final EventCardAction? secondaryAction;
  final List<EventCardAction> actions;
  final VoidCallback? onClose;

  const EventCard({
    super.key,
    required this.category,
    required this.mode,
    required this.title,
    required this.description,
    this.infoRows = const [],
    this.requirements = const [],
    this.primaryAction,
    this.secondaryAction,
    this.actions = const [],
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = EventTheme.fromCategoryAndMode(category, mode);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 70% black overlay — no blur
          Positioned.fill(
            child: Container(color: EventTheme.overlay),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: FractionallySizedBox(
                    widthFactor: 0.88,
                    child: _CardShell(
                      theme: theme,
                      mode: mode,
                      title: title,
                      description: description,
                      infoRows: infoRows,
                      requirements: requirements,
                      primaryAction: primaryAction,
                      secondaryAction: secondaryAction,
                      actions: actions,
                      onClose: onClose,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _CardShell — White card with 4px radius, subtle shadow, close button top-right
// =============================================================================

class _CardShell extends StatelessWidget {
  final EventTheme theme;
  final EventCardMode mode;
  final String title;
  final String description;
  final List<EventInfoRow> infoRows;
  final List<EventRequirement> requirements;
  final EventCardAction? primaryAction;
  final EventCardAction? secondaryAction;
  final List<EventCardAction> actions;
  final VoidCallback? onClose;

  const _CardShell({
    required this.theme,
    required this.mode,
    required this.title,
    required this.description,
    this.infoRows = const [],
    this.requirements = const [],
    required this.primaryAction,
    required this.secondaryAction,
    this.actions = const [],
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: EventTheme.cardBackground,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Content area ─────────────────────────────
          _buildBody(),
          // ── Button area ──────────────────────────────
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // All modes share the same shell: category label → title → description
    // followed by mode-specific content (requirements, info rows, etc.)
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category label
              _CategoryLabel(label: theme.label),
              const SizedBox(height: 8),
              // Title
              _buildTitle(title),
              const SizedBox(height: 8),
              // Description
              _buildDescription(description),
              // Mode-specific content
              _buildModeContent(),
            ],
          ),
        ),
        // Close button — top right inside card
        if (onClose != null)
          Positioned(
            top: 8,
            right: 8,
            child: _CloseButton(onPressed: onClose!),
          ),
      ],
    );
  }

  Widget _buildModeContent() {
    return switch (mode) {
      EventCardMode.offer => _buildOfferContent(),
      EventCardMode.success => _buildInfoContent(),
      EventCardMode.failure => _buildInfoContent(),
      EventCardMode.choice => _buildInfoContent(),
      EventCardMode.requirement => _buildRequirementContent(),
      EventCardMode.actions => const SizedBox.shrink(),
      EventCardMode.info => _buildInfoContent(),
    };
  }

  Widget _buildOfferContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requirements.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Requirements',
            style: GoogleFonts.lexend(
              color: EventTheme.titleText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _RequirementChecklist(requirements: requirements),
          const SizedBox(height: 8),
        ],
        if (infoRows.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoRowsBlock(rows: infoRows),
        ],
      ],
    );
  }

  Widget _buildRequirementContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requirements.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Requirements',
            style: GoogleFonts.lexend(
              color: EventTheme.titleText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _RequirementChecklist(requirements: requirements),
          const SizedBox(height: 8),
        ],
        if (infoRows.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoRowsBlock(rows: infoRows),
        ],
      ],
    );
  }

  Widget _buildInfoContent() {
    if (infoRows.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _InfoRowsBlock(rows: infoRows),
      ],
    );
  }

  Widget _buildButtons() {
    if (mode == EventCardMode.actions) {
      if (actions.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _PrimaryButton(action: actions[i]),
            ],
          ],
        ),
      );
    } else {
      if (primaryAction == null && secondaryAction == null) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (secondaryAction != null) ...[
              Expanded(child: _SecondaryButton(action: secondaryAction!)),
              if (primaryAction != null) const SizedBox(width: 8),
            ],
            if (primaryAction != null)
              Expanded(child: _PrimaryButton(action: primaryAction!)),
          ],
        ),
      );
    }
  }
}

// =============================================================================
// Shared Primitives — V4 Design Language
// =============================================================================

/// 12px semibold uppercase category label with 3px letter spacing
class _CategoryLabel extends StatelessWidget {
  final String label;

  const _CategoryLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.lexend(
        color: EventTheme.labelText,
        fontSize: 12,
        height: 1.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.0,
      ),
    );
  }
}

/// Simple 24px close icon — top right, no circle, no shadow
class _CloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(
            Icons.close,
            color: EventTheme.mutedText,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// 24px bold black title, left-aligned, max 2 lines
Widget _buildTitle(String text) {
  return Text(
    text,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: GoogleFonts.lexend(
      color: EventTheme.titleText,
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.bold,
    ),
  );
}

/// 16px medium dark-gray description, left-aligned, max 4 lines
Widget _buildDescription(String text) {
  return Text(
    text,
    maxLines: 4,
    overflow: TextOverflow.ellipsis,
    style: GoogleFonts.lexend(
      color: EventTheme.bodyText,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w500,
    ),
  );
}

// =============================================================================
// Info Rows — Dotted separator style (label ........ value)
// =============================================================================

class _InfoRowWidget extends StatelessWidget {
  final EventInfoRow row;

  const _InfoRowWidget({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Label
          Text(
            row.label,
            style: GoogleFonts.lexend(
              color: EventTheme.infoRowLabel,
              fontSize: 14,
              height: 1.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Dotted separator
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: EventTheme.infoRowDots,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              height: 12,
            ),
          ),
          // Value
          Text(
            row.value,
            style: GoogleFonts.lexend(
              color: row.valueColor ?? EventTheme.infoRowValue,
              fontSize: 14,
              height: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRowsBlock extends StatelessWidget {
  final List<EventInfoRow> rows;

  const _InfoRowsBlock({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: EventTheme.borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 2),
            _InfoRowWidget(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// Requirements — Simple ✓/✗ icon rows (no emoji, no gray background)
// =============================================================================

class _RequirementChecklist extends StatelessWidget {
  final List<EventRequirement> requirements;

  const _RequirementChecklist({required this.requirements});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < requirements.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          _RequirementRow(requirement: requirements[i]),
        ],
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final EventRequirement requirement;

  const _RequirementRow({required this.requirement});

  @override
  Widget build(BuildContext context) {
    final met = requirement.isMet;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            met ? Icons.check : Icons.close,
            color:
                met ? EventTheme.requirementMet : EventTheme.requirementUnmet,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                requirement.label,
                style: GoogleFonts.lexend(
                  color: met
                      ? EventTheme.infoRowValue
                      : EventTheme.requirementUnmet,
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!met &&
                  (requirement.currentValue != null ||
                      requirement.requiredValue != null ||
                      requirement.guidance != null)) ...[
                const SizedBox(height: 4),
                if (requirement.currentValue != null)
                  _RequirementDetail(
                    label: 'Current',
                    value: requirement.currentValue!,
                  ),
                if (requirement.requiredValue != null)
                  _RequirementDetail(
                    label: 'Required',
                    value: requirement.requiredValue!,
                  ),
                if (requirement.guidance != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    requirement.guidance!,
                    style: GoogleFonts.lexend(
                      color: EventTheme.bodyText,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RequirementDetail extends StatelessWidget {
  final String label;
  final String value;

  const _RequirementDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label: $value',
      style: GoogleFonts.lexend(
        color: EventTheme.mutedText,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// =============================================================================
// Buttons — V4 Primary (Green) + Secondary (Gray)
// =============================================================================

/// Green #15803d, 48px height, full-width, uppercase, bold
class _PrimaryButton extends StatelessWidget {
  final EventCardAction action;

  const _PrimaryButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: action.onPressed,
        style: TextButton.styleFrom(
          backgroundColor: EventTheme.primaryButton,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            EventTheme.primaryButtonPressed,
          ),
        ),
        child: Text(
          action.label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: 18,
            height: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Light gray #DEDFE3, dark text #3D4A3E, 48px height, full-width, uppercase
class _SecondaryButton extends StatelessWidget {
  final EventCardAction action;

  const _SecondaryButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: action.onPressed,
        style: TextButton.styleFrom(
          backgroundColor: EventTheme.secondaryButton,
          foregroundColor: EventTheme.secondaryButtonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            EventTheme.secondaryButtonPressed,
          ),
        ),
        child: Text(
          action.label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: 18,
            height: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
