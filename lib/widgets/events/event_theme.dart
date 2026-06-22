import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import 'event_types.dart';

class EventTheme {
  static const Color overlay = Color(0xB3000000);
  static const Color cardBackground = AppColors.surface;
  static const Color primaryButton = AppColors.primary;
  static const Color primaryButtonPressed = Color(0xFF1A8A48);
  static const Color secondaryButton = Color(0xFFDEDFE3);
  static const Color secondaryButtonPressed = Color(0xFFBBCBBB);
  static const Color secondaryButtonText = Color(0xFF3D4A3E);
  static const Color titleText = AppColors.textPrimary;
  static const Color bodyText = Color(0xFF4A4A4A);
  static const Color mutedText = AppColors.textSecondary;
  static const Color labelText = AppColors.textSecondary;
  static const Color infoRowLabel = AppColors.textSecondary;
  static const Color infoRowValue = Color(0xFF161C28);
  static const Color infoRowDots = Color(0xFFBBCBBB);
  static const Color requirementMet = AppColors.primary;
  static const Color requirementUnmet = AppColors.error;
  static const Color borderColor = Color(0xFFBBCBBB);

  final EventCategory category;
  final Color accentColor;
  final String label;

  const EventTheme({
    required this.category,
    required this.accentColor,
    required this.label,
  });

  factory EventTheme.fromCategoryAndMode(EventCategory category, EventCardMode mode) {
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
      EventCategory.career => AppColors.primary,
      EventCategory.freelance => const Color(0xFF7C3AED),
      EventCategory.relationships => const Color(0xFFDB2777),
      EventCategory.family => const Color(0xFF16A34A),
      EventCategory.health => AppColors.error,
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
