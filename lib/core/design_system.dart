// lib/core/design_system.dart — BitLife-style flat UI system
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

// ─── Motion ─────────────────────────────────────────────────────────────────
class AppMotion {
  static const Duration tap = Duration(milliseconds: 80);
  static const Duration appearance = Duration(milliseconds: 150);
  static const Duration modal = Duration(milliseconds: 250);
  static const Curve tapCurve = Curves.easeOut;
}

// ─── Colors ──────────────────────────────────────────────────────────────────
class AppColors {
  static const Color scaffoldBg = Color(0xFFFAFAFC);
  static const Color cardBg = Colors.white;
  static const Color rowBg = Colors.white;
  static const Color rowPressed = Color(0xFFF4F4F7);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF7E7E82);
  static const Color textMuted = Color(0xFFD1D1D6);
  static const Color divider = Color(0xFFE5E5EA);
  static const Color dividerLight = Color(0xFFF2F2F7);
  static const Color success = Color(0xFF0E9F6E);
  static const Color danger = Color(0xFFF05252);
  static const Color info = Color(0xFF0E9F6E); // Stitch Green
  static const Color warning = Color(0xFFFACA15);
  static const Color darkBg = Color(0xFF1C1C1E);
  static const Color iconBg = Color(0xFFF2F2F7);

  // Stat specific
  static const Color happiness = Color(0xFFFFCC00);
  static const Color health = Color(0xFF00B359);
  static const Color smarts = Color(0xFF007AFF);
  static const Color looks = Color(0xFFFF2D55);

  // Legacy aliases
  static const Color primary = info;
  static const Color primaryLight = info;
  static const Color highlightGreen = success;
  static const Color alertRed = danger;
  static const Color groupedBg = scaffoldBg;
  static const List<Color> mainBgGradient = [scaffoldBg, scaffoldBg];
  static const List<Color> primaryGradient = [info, info];
}

// ─── Typography ──────────────────────────────────────────────────────────────
class AppTextStyles {
  static TextStyle get pageTitle => GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get pageSubtitle => GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        height: 1.1,
      );

  static TextStyle get sectionLabel => GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF6E6E73),
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

  // Legacy aliases
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
        color: AppColors.success,
      );
  static TextStyle get metadata => caption;
  static TextStyle get ageSeparator => GoogleFonts.lexend(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
        letterSpacing: 1.0,
      );
}

// ─── App Top Bar ─────────────────────────────────────────────────────────────
class AppTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final num? balance;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.info, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.pageTitle.copyWith(fontSize: 14, letterSpacing: 0.5),
            ),
          ),
          if (balance != null)
            Text(
              formatMoney(balance!),
              style: AppTextStyles.pageTitle.copyWith(
                fontSize: 14,
                color: AppColors.info,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

// ─── Identity Header ─────────────────────────────────────────────────────────
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

// ─── App Page Template ───────────────────────────────────────────────────────
class AppPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBackButton;
  final Widget? bottomWidget;
  final String? characterName;
  final int? characterAge;
  final num? characterBalance;

  const AppPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.showBackButton = true,
    this.bottomWidget,
    this.characterName,
    this.characterAge,
    this.characterBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: title,
              subtitle: subtitle,
              showBackButton: showBackButton,
              balance: characterBalance,
            ),
            if (characterName != null)
              IdentityHeader(
                name: characterName!,
                occupation: subtitle ?? 'Student',
                balance: characterBalance ?? 0,
              ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  ...children,
                  const SizedBox(height: 16),
                ],
              ),
            ),
            if (bottomWidget != null) bottomWidget!,
          ],
        ),
      ),
    );
  }
}

// ─── Section Label ───────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String title;
  const SectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F2F7),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.sectionLabel.copyWith(fontSize: 9),
      ),
    );
  }
}

// ─── Flat Row Group ──────────────────────────────────────────────────────────
class RowGroup extends StatelessWidget {
  final List<Widget> rows;
  const RowGroup({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              const Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.dividerLight,
                indent: 44,
              ),
          ],
        ],
      ),
    );
  }
}

// ─── Game Row ────────────────────────────────────────────────────────────────
class GameRow extends StatefulWidget {
  final dynamic icon; // Can be String (emoji) or IconData
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool locked;
  final bool showChevron;
  final Color? iconBgColor;

  const GameRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.locked = false,
    this.showChevron = true,
    this.iconBgColor,
  });

  @override
  State<GameRow> createState() => _GameRowState();
}

class _GameRowState extends State<GameRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final locked = widget.locked;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: locked
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: AppMotion.tap,
        child: Opacity(
          opacity: locked ? 0.4 : 1.0,
          child: Container(
            height: 48,
            color: _pressed ? AppColors.rowPressed : AppColors.rowBg,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: widget.icon is String
                      ? Text(widget.icon, style: const TextStyle(fontSize: 16))
                      : Icon(widget.icon as IconData,
                          size: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.rowTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          style: AppTextStyles.rowSubtitle.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
                if (widget.showChevron) ...[
                  const SizedBox(width: 8),
                  Icon(
                    locked ? Icons.lock_outline : Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VitalsSection extends StatelessWidget {
  final int happiness;
  final int health;
  final int smarts;
  final int looks;
  final int karma;

  const VitalsSection({
    super.key,
    required this.happiness,
    required this.health,
    required this.smarts,
    required this.looks,
    required this.karma,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(title: 'CORE VITALS'),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              StatBar(emoji: '😊', label: 'Happiness', value: happiness, color: const Color(0xFFFFCC00)),
              StatBar(emoji: '❤️', label: 'Health', value: health, color: const Color(0xFF00B359)),
              StatBar(emoji: '🧠', label: 'Smarts', value: smarts, color: const Color(0xFF007AFF)),
              StatBar(emoji: '✨', label: 'Looks', value: looks, color: const Color(0xFFFF2D55)),
              StatBar(label: 'Karma', value: karma, color: const Color(0xFF00B359), isLast: true),
            ],
          ),
        ),
      ],
    );
  }
}

class BondBar extends StatelessWidget {
  final int value;
  const BondBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (value / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ─── Stat Bar ────────────────────────────────────────────────────────────────
class StatBar extends StatelessWidget {
  final String label;
  final String? emoji;
  final int value;
  final Color color;
  final bool isLast;

  const StatBar({
    super.key,
    required this.label,
    this.emoji,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
      child: Row(
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTextStyles.rowSubtitle.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                children: [
                  Container(height: 5, color: const Color(0xFFE5E5EA)),
                  AnimatedFractionallySizedBox(
                    widthFactor: clamped / 100,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    child: Container(height: 5, color: color),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$clamped%',
            style: AppTextStyles.rowSubtitle.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
