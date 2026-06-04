import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design_system.dart';

class EducationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const EducationAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF181C1F),
          letterSpacing: 0.5,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: Color(0xFF181C1F), size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: ColoredBox(
          color: Color(0xFFE4E4E7),
          child: SizedBox(height: 1.0, width: double.infinity),
        ),
      ),
    );
  }
}

class FlatBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  final Color backColor;
  final Color borderColor;
  final bool uppercase;

  const FlatBackAppBar({
    super.key,
    required this.title,
    this.trailing,
    this.backColor = const Color(0xFF10B981),
    this.borderColor = const Color(0xFFE4E4E7),
    this.uppercase = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.arrow_back, color: backColor, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  uppercase ? title.toUpperCase() : title,
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF181C1F),
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                if (trailing != null)
                  trailing!
                else if (uppercase)
                  const Icon(Icons.more_vert,
                      color: Color(0xFF71717A), size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;
  final bool uppercase;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? style;
  final double fontSize;
  final FontWeight fontWeight;
  final Color textColor;
  final double letterSpacing;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
    this.uppercase = false,
    this.backgroundColor,
    this.borderColor,
    this.style,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w700,
    this.textColor = const Color(0xFF5C5E62),
    this.letterSpacing = 1.2,
  });

  const AppSectionHeader.education(
    this.title, {
    super.key,
  })  : padding = const EdgeInsets.only(left: 16, top: 24, bottom: 8),
        uppercase = true,
        backgroundColor = null,
        borderColor = null,
        style = null,
        fontSize = 12,
        fontWeight = FontWeight.w700,
        textColor = const Color(0xFF5C5E62),
        letterSpacing = 1.2;

  const AppSectionHeader.activity(
    this.title, {
    super.key,
  })  : padding = const EdgeInsets.only(left: 16, bottom: 4),
        uppercase = false,
        backgroundColor = null,
        borderColor = null,
        style = null,
        fontSize = 10,
        fontWeight = FontWeight.w700,
        textColor = const Color(0xFFA1A1AA),
        letterSpacing = 1.5;

  const AppSectionHeader.band(
    this.title, {
    super.key,
    this.borderColor = const Color(0xFFF4F4F5),
    this.style,
  })  : padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        uppercase = false,
        backgroundColor = const Color(0xFFF1F3FF),
        fontSize = 11,
        fontWeight = FontWeight.w700,
        textColor = const Color(0xFF5C5E62),
        letterSpacing = 1.5;

  const AppSectionHeader.finance(
    this.title, {
    super.key,
  })  : padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        uppercase = false,
        backgroundColor = const Color(0xFFF1F3FF),
        borderColor = const Color(0xFFBBCBBB),
        style = null,
        fontSize = 11,
        fontWeight = FontWeight.w600,
        textColor = const Color(0xFF3D4A3E),
        letterSpacing = 1.5;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      uppercase ? title.toUpperCase() : title,
      style: style ??
          GoogleFonts.lexend(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
            letterSpacing: letterSpacing,
          ),
    );

    if (backgroundColor != null) {
      return Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderColor == null
              ? null
              : Border(bottom: BorderSide(color: borderColor!, width: 1)),
        ),
        child: text,
      );
    }

    return Padding(padding: padding, child: text);
  }
}

class AppFlatRowGroup extends StatelessWidget {
  final List<Widget> rows;
  final Color borderColor;
  final double borderWidth;
  final double dividerIndent;
  final bool showBorder;

  const AppFlatRowGroup({
    super.key,
    required this.rows,
    this.borderColor = const Color(0xFFE4E4E7),
    this.borderWidth = 1,
    this.dividerIndent = 0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: showBorder
            ? Border.symmetric(
                horizontal: BorderSide(color: borderColor, width: borderWidth),
              )
            : null,
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: const Color(0xFFF4F4F5),
                indent: dividerIndent,
              ),
          ],
        ],
      ),
    );
  }
}

class AppFlatRow extends StatefulWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool locked;
  final bool isPrestige;
  final double height;
  final Color pressedColor;
  final Color lockedColor;
  final double lockedOpacity;
  final bool showChevron;
  final double subtitleFontSize;
  final FontWeight subtitleWeight;
  final bool trailingBeforeGap;

  const AppFlatRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.trailing,
    required this.onTap,
    this.locked = false,
    this.isPrestige = false,
    this.height = 50,
    this.pressedColor = const Color(0xFFFAFAFA),
    this.lockedColor = const Color(0x99F1F3FF),
    this.lockedOpacity = 0.6,
    this.showChevron = true,
    this.subtitleFontSize = 10,
    this.subtitleWeight = FontWeight.w500,
    this.trailingBeforeGap = false,
  });

  @override
  State<AppFlatRow> createState() => _AppFlatRowState();
}

class _AppFlatRowState extends State<AppFlatRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.locked
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: _pressed
            ? widget.pressedColor
            : (widget.locked ? widget.lockedColor : Colors.white),
        child: Opacity(
          opacity: widget.locked ? widget.lockedOpacity : 1.0,
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: widget.icon,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: widget.titleStyle ??
                                GoogleFonts.lexend(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isPrestige
                                      ? const Color(0xFFB58A3D)
                                      : const Color(0xFF181C1F),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isPrestige) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.stars,
                              color: Color(0xFFFFD700), size: 18),
                        ],
                      ],
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: widget.subtitleStyle ??
                            GoogleFonts.lexend(
                              fontSize: widget.subtitleFontSize,
                              fontWeight: widget.subtitleWeight,
                              color: const Color(0xFF71717A),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.trailing != null && widget.trailingBeforeGap) ...[
                widget.trailing!,
                const SizedBox(width: 8),
              ] else if (widget.trailing != null) ...[
                const SizedBox(width: 8),
                widget.trailing!,
              ],
              if (widget.showChevron)
                Icon(
                  widget.locked ? Icons.lock : Icons.chevron_right,
                  color: widget.isPrestige
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFD4D4D8),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FinanceListRow extends StatefulWidget {
  final String icon;
  final String title;
  final bool showChevron;
  final VoidCallback onTap;

  const FinanceListRow({
    super.key,
    required this.icon,
    required this.title,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  State<FinanceListRow> createState() => _FinanceListRowState();
}

class _FinanceListRowState extends State<FinanceListRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFE8EEFF) : Colors.white,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1),
          ),
        ),
        child: Row(
          children: [
            Text(widget.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.title,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF161C28),
                ),
              ),
            ),
            if (widget.showChevron)
              const Icon(Icons.chevron_right,
                  color: Color(0xFF5C5E62), size: 20),
          ],
        ),
      ),
    );
  }
}

class PressableRow extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final Color pressedColor;
  final Color backgroundColor;

  const PressableRow({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.pressedColor = const Color(0xFFFAFAFA),
    this.backgroundColor = Colors.white,
  });

  @override
  State<PressableRow> createState() => _PressableRowState();
}

class _PressableRowState extends State<PressableRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        padding: widget.padding,
        color: _pressed ? widget.pressedColor : widget.backgroundColor,
        child: widget.child,
      ),
    );
  }
}

class LinearStatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final double labelWidth;
  final double height;
  final bool showPercent;

  const LinearStatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.labelWidth = 72,
    this.height = 12,
    this.showPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showPercent) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label(label),
              _label('$value%'),
            ],
          ),
          const SizedBox(height: 4),
          _bar(),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(width: labelWidth, child: _label(label.toUpperCase())),
        Expanded(child: _bar()),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF5C5E62),
      ),
    );
  }

  Widget _bar() {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFE4E4E7),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (value / 100).clamp(0.01, 1.0),
        child: Container(color: color),
      ),
    );
  }
}

class ActivityListRow extends StatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool locked;
  final int? cost;
  final VoidCallback onTap;

  const ActivityListRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.locked = false,
    this.cost,
    required this.onTap,
  });

  @override
  State<ActivityListRow> createState() => _ActivityListRowState();
}

class _ActivityListRowState extends State<ActivityListRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.locked
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: _pressed ? const Color(0xFFF9FAFB) : Colors.white,
        child: Opacity(
          opacity: widget.locked ? 0.5 : 1.0,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Center(
                  child:
                      Text(widget.icon, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF161C28),
                        height: 1.2,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF71717A),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.cost != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '-${formatMoney(widget.cost!)}',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              const Icon(Icons.chevron_right,
                  color: Color(0xFFD4D4D8), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
