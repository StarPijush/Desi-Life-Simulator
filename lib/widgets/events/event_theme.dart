import 'package:flutter/material.dart';

import 'event_types.dart';

class EventTheme {
  // ── V4 Design Tokens (Military HTML Reference) ─────────────────────────
  static const Color overlay = Color(0xB3000000); // 70% black, no blur
  static const Color cardBackground = Colors.white;

  // Buttons
  static const Color primaryButton = Color(0xFF1D4ED8); // Blue
  static const Color primaryButtonPressed = Color(0xFF1E40AF);
  static const Color secondaryButton = Color(0xFFDEDFE3);
  static const Color secondaryButtonPressed = Color(0xFFBBCBBB);
  static const Color secondaryButtonText = Color(0xFF3D4A3E);

  // Typography
  static const Color titleText = Color(0xFF000000); // Black
  static const Color bodyText = Color(0xFF4A4A4A); // Dark gray
  static const Color mutedText = Color(0xFF5C5E62); // Secondary
  static const Color labelText = Color(0xFF5C5E62); // Category label

  // Info rows
  static const Color infoRowLabel = Color(0xFF5C5E62);
  static const Color infoRowValue = Color(0xFF161C28);
  static const Color infoRowDots = Color(0xFFBBCBBB); // outline-variant

  // Requirements
  static const Color requirementMet = Color(0xFF006D37); // primary green
  static const Color requirementUnmet = Color(0xFFBA1A1A); // error red

  // Borders
  static const Color borderColor = Color(0xFFBBCBBB); // outline-variant

  final EventCategory category;
  final Color accentColor;
  final String label;

  const EventTheme({
    required this.category,
    required this.accentColor,
    required this.label,
  });

  factory EventTheme.fromCategoryAndMode(EventCategory category, EventCardMode mode) {
    // Accent color is kept for semantic differentiation but is no longer
    // used for card borders or banners in V4.
    return EventTheme(
      category: category,
      accentColor: category.accentColor,
      label: category.label,
    );
  }
}

extension EventCategoryTheme on EventCategory {
  Color get accentColor {
    return switch (this) {
      EventCategory.military => const Color(0xFF1B5E20),
      EventCategory.politics => const Color(0xFFD97706),
      EventCategory.education => const Color(0xFF2563EB),
      EventCategory.scholarship => const Color(0xFFFFC107),
      EventCategory.career => const Color(0xFF0F766E),
      EventCategory.freelance => const Color(0xFF7C3AED),
      EventCategory.relationships => const Color(0xFFDB2777),
      EventCategory.family => const Color(0xFF16A34A),
      EventCategory.health => const Color(0xFFDC2626),
      EventCategory.crime => const Color(0xFF374151),
      EventCategory.fame => const Color(0xFFEA580C),
      EventCategory.actor => const Color(0xFF9333EA),
      EventCategory.singer => const Color(0xFF0891B2),
      EventCategory.business => const Color(0xFF334155),
      EventCategory.cricketer => const Color(0xFF15803D),
      EventCategory.footballer => const Color(0xFF65A30D),
      EventCategory.finance => const Color(0xFF047857),
    };
  }

  String get label {
    return switch (this) {
      EventCategory.military => 'MILITARY',
      EventCategory.politics => 'POLITICS',
      EventCategory.education => 'EDUCATION',
      EventCategory.scholarship => 'SCHOLARSHIP',
      EventCategory.career => 'CAREER',
      EventCategory.freelance => 'FREELANCE',
      EventCategory.relationships => 'RELATIONSHIPS',
      EventCategory.family => 'FAMILY',
      EventCategory.health => 'HEALTH',
      EventCategory.crime => 'CRIME',
      EventCategory.fame => 'FAME',
      EventCategory.actor => 'ACTOR',
      EventCategory.singer => 'SINGER',
      EventCategory.business => 'BUSINESS',
      EventCategory.cricketer => 'CRICKETER',
      EventCategory.footballer => 'FOOTBALLER',
      EventCategory.finance => 'FINANCE',
    };
  }
}
