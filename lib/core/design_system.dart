// lib/core/design_system.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  // Strict 8px grid
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
}

/// Standardized animation durations for a consistent motion feel.
class AppMotion {
  /// 120ms — for tap/press scale feedback
  static const Duration tap = Duration(milliseconds: 120);

  /// 180ms — for card appearance / stagger reveals
  static const Duration appearance = Duration(milliseconds: 180);

  /// 200ms — for tab transitions and navigation
  static const Duration navigation = Duration(milliseconds: 200);

  /// 300ms — for longer transitions (modal entry)
  static const Duration modal = Duration(milliseconds: 300);

  static const Curve tapCurve = Curves.easeOut;
  static const Curve appearCurve = Curves.easeOutCubic;
  static const Curve navCurve = Curves.easeInOutCubic;

  /// Tiered snapping curves for 'Elite' feel
  static const Curve standardSnap = Cubic(0.1, 0.9, 0.2, 1.05);
  static const Curve eliteSnap = Cubic(0.1, 0.9, 0.2, 1.15);
}

class AppRadius {
  static const double small = 12;
  static const double medium = 16;
  static const double large = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;
}

class AppColors {
  // Backgrounds
  static const Color scaffoldBg = Color(0xFFF5F7FB);
  static const List<Color> mainBgGradient = [
    Color(0xFFF5F7FB),
    Color(0xFFEEF2FF),
  ];
  static const Color cardBg = Colors.white;
  static const Color darkBg = Color(0xFF0F172A);

  // Primary: Deep Royal Blue
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primarySurface = Color(0xFFEFF6FF);

  // CTA: Orange Gradient (ONLY for action buttons)
  static const List<Color> ctaGradient = [
    Color(0xFFFB923C),
    Color(0xFFEA580C),
  ];
  static const Color ctaColor = Color(0xFFF97316);

  // Brand Gradients (legacy / profile)
  static const List<Color> primaryGradient = [
    Color(0xFFFB923C),
    Color(0xFFEA580C),
  ];
  static const List<Color> avatarRingGradient = [
    Color(0xFF3B82F6),
    Color(0xFF1D4ED8),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF3B82F6),
  ];
  static const List<Color> netWorthGradient = [
    Color(0xFF1E293B),
    Color(0xFF0F172A),
  ];
  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  static const List<Color> dangerGradient = [
    Color(0xFFF43F5E),
    Color(0xFFEF4444),
  ];

  // Stat Gradients
  static const List<Color> happyGradient = [Color(0xFF34D399), Color(0xFF10B981)];
  static const List<Color> healthGradient = [Color(0xFFFB7185), Color(0xFFF43F5E)];
  static const List<Color> smartsGradient = [Color(0xFF60A5FA), Color(0xFF3B82F6)];
  static const List<Color> socialGradient = [Color(0xFFFBBF24), Color(0xFFF59E0B)];
  static const List<Color> karmaGradient = [Color(0xFFA78BFA), Color(0xFF8B5CF6)];

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color highlightGreen = Color(0xFF10B981);
  static const Color alertRed = Color(0xFFF43F5E);

  // Timeline Event Colors
  static const Color eventPositive = Color(0xFF10B981);
  static const Color eventNegative = Color(0xFFF43F5E);
  static const Color eventNeutral = Color(0xFFF59E0B);
  static const Color eventMilestone = Color(0xFF3B82F6);

  // Timeline Event Card Backgrounds (very soft tint)
  static const Color eventPositiveBg = Color(0xFFECFDF5);
  static const Color eventNegativeBg = Color(0xFFFFF1F2);
  static const Color eventNeutralBg = Color(0xFFFFFBEB);
  static const Color eventMilestoneBg = Color(0xFFEFF6FF);
}

class AppShadows {
  // Tiny-footprint soft shadow for standard cards
  static List<BoxShadow> card = [
    BoxShadow(
      color: const Color(0xFF94A3B8).withValues(alpha: 0.07),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> soft = [
    BoxShadow(
      color: const Color(0xFF94A3B8).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> premium = [
    BoxShadow(
      color: const Color(0xFF1E40AF).withValues(alpha: 0.06),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // Orange glow for the Age FAB
  static List<BoxShadow> fab = [
    BoxShadow(
      color: const Color(0xFFF97316).withValues(alpha: 0.45),
      blurRadius: 28,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFFF97316).withValues(alpha: 0.18),
      blurRadius: 8,
      offset: const Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> glass = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // Navigation bar shadow
  static List<BoxShadow> nav = [
    BoxShadow(
      color: const Color(0xFF1E40AF).withValues(alpha: 0.08),
      blurRadius: 32,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Elite Adaptive Blur Sigmas
  static const double blurHigh = 28.0;
  static const double blurMid = 18.0;
  static const double blurLow = 12.0;
}

class AppTextStyles {
  // Inter — product-grade typography

  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700, // SemiBold
        color: AppColors.textPrimary,
        letterSpacing: -0.6,
        height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
        height: 1.2,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get bodyBold => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500, // Medium
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.6,
        height: 1.4,
      );

  static TextStyle get financial => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get ageSeparator => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.5,
        height: 1.4,
      );
}

class AppDecoration {
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    boxShadow: AppShadows.card,
  );

  static BoxDecoration get premiumCard => BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(AppRadius.xl),
    boxShadow: AppShadows.premium,
    border: Border.all(
      color: const Color(0xFFE2E8F0),
      width: 1,
    ),
  );

  static BoxDecoration statCard = BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.xl),
    gradient: const LinearGradient(
      colors: [Colors.white, Color(0xFFF8FAFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    boxShadow: AppShadows.premium,
    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
  );

  static BoxDecoration glass = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(AppRadius.xl),
    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
  );
}
