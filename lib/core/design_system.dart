import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ─── Utility ────────────────────────────────────────────────────────────────
String formatMoney(num amount) {
  final formatter = NumberFormat.currency(
    symbol: '₹',
    locale: 'en_IN',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

String shortMoney(num value) {
  final negative = value < 0;
  final abs = value.abs();
  String text;
  if (abs >= 10000000) {
    text = '${(abs / 10000000).toStringAsFixed(1)}Cr';
  } else if (abs >= 100000) {
    text = '${(abs / 100000).toStringAsFixed(1)}L';
  } else if (abs >= 1000) {
    text = '${(abs / 1000).toStringAsFixed(0)}K';
  } else {
    text = abs.round().toString();
  }
  return '${negative ? '-' : ''}₹$text';
}

String cleanText(String value) {
  return value
      .replaceAll(RegExp(r'[^\x00-\x7F]+'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String bondBarText(int value) {
  final filled = (value / 20).round().clamp(0, 5);
  return '${'|'.padRight(filled, '|')}${'.'.padRight(5 - filled, '.')}';
}

// ─── Colors ──────────────────────────────────────────────────────────────────
class AppColors {
  static const Color background = Color(0xFFF4F4F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1E9E54);
  static const Color warning = Color(0xFFE5A100);
  static const Color error = Color(0xFFD9534F);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF707070);
  static const Color outline = Color(0xFFD8D8D8);

  // Legacy aliases (mapped to new palette)
  static const Color scaffoldBg = background;
  static const Color cardBg = surface;
  static const Color rowBg = surface;
  static const Color rowPressed = Color(0xFFF4F4F7);
  static const Color textMuted = Color(0xFFD1D1D6);
  static const Color divider = Color(0xFFE5E5EA);
  static const Color dividerLight = Color(0xFFF2F2F7);
  static const Color success = primary;
  static const Color danger = error;
  static const Color info = primary;
  static const Color darkBg = Color(0xFF1C1C1E);
  static const Color iconBg = Color(0xFFF2F2F7);

  // Stat specific
  static const Color happiness = Color(0xFFFFCC00);
  static const Color health = Color(0xFF00B359);
  static const Color smarts = Color(0xFF007AFF);
  static const Color looks = Color(0xFFFF2D55);

  // Graduated primary opacities
  static Color primary10(double opacity) => primary.withValues(alpha: opacity);
}

// ─── Typography ──────────────────────────────────────────────────────────────
class AppTextStyles {
  // Display
  static TextStyle get displayLg => GoogleFonts.lexend(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.02,
        height: 40 / 32,
      );

  static TextStyle get displayMd => GoogleFonts.lexend(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.01,
        height: 32 / 24,
      );

  // Headline
  static TextStyle get headlineSm => GoogleFonts.lexend(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 28 / 20,
      );

  // Body
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 24 / 16,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 20 / 14,
      );

  // Labels
  static TextStyle get labelBold => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.05,
        height: 16 / 12,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 14 / 11,
      );

  // Legacy aliases
  static TextStyle get pageTitle => displayLg;
  static TextStyle get pageSubtitle => GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        height: 1.1,
      );
  static TextStyle get sectionLabel => GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
        height: 1.1,
      );
  static TextStyle get rowTitle => GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.1,
      );
  static TextStyle get rowSubtitle => GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.1,
      );
  static TextStyle get caption => GoogleFonts.lexend(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        height: 1.1,
      );
  static TextStyle get h1 => pageTitle;
  static TextStyle get h2 => pageTitle.copyWith(fontSize: 18);
  static TextStyle get h3 => rowTitle.copyWith(fontSize: 16);
  static TextStyle get bodyBold => rowTitle.copyWith(fontSize: 15);
  static TextStyle get bodyMedium => rowSubtitle.copyWith(fontSize: 15);
  static TextStyle get subtitle => rowSubtitle;
  static TextStyle get label => rowSubtitle;
  static TextStyle get financial => GoogleFonts.lexend(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      );
  static TextStyle get financialSmall => GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      );
  static TextStyle get metadata => caption;
  static TextStyle get ageSeparator => GoogleFonts.lexend(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 1.0,
      );
}

// ─── Spacing ─────────────────────────────────────────────────────────────────
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double cardGap = 12;
  static const double containerPadding = 16;
}

// ─── Border Radius ───────────────────────────────────────────────────────────
class AppBorderRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 8;
  static const double xl = 10;
  static const double full = 9999;
}

// ─── Shadows ─────────────────────────────────────────────────────────────────
class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];
}

// ─── Motion ──────────────────────────────────────────────────────────────────
class AppMotion {
  static const Duration tap = Duration(milliseconds: 80);
  static const Duration appearance = Duration(milliseconds: 150);
  static const Duration modal = Duration(milliseconds: 250);
  static const Curve tapCurve = Curves.easeOut;
}

// ═══════════════════════════════════════════════════════════════════════════════
// LEGACY WIDGETS (deprecated — kept for backward compat during Phase 1-3)
// ═══════════════════════════════════════════════════════════════════════════════

@Deprecated('Use AppStatusBanner from widgets/core/app_status_banner.dart instead')
class IdentityHeader extends StatelessWidget {
  final String name;
  final String occupation;
  final num balance;

  const IdentityHeader({
    super.key,
    required this.name,
    required this.occupation,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F7),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  occupation.toUpperCase(),
                  style: AppTextStyles.rowSubtitle.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatMoney(balance),
                style: AppTextStyles.pageTitle.copyWith(
                  fontSize: 14,
                  color: AppColors.success,
                ),
              ),
              Text(
                'BANK BALANCE',
                style: AppTextStyles.rowSubtitle.copyWith(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


