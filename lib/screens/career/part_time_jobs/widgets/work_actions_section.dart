import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkActionsSection extends StatelessWidget {
  final bool hasJob;
  final VoidCallback onWorkShift;
  final VoidCallback onHelpCustomer;
  final VoidCallback onExtraShift;
  final VoidCallback onAskForRaise;
  final VoidCallback onQuitJob;

  const WorkActionsSection({
    super.key,
    required this.hasJob,
    required this.onWorkShift,
    required this.onHelpCustomer,
    required this.onExtraShift,
    required this.onAskForRaise,
    required this.onQuitJob,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Work Actions'),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              _ActionRow(
                icon: Icons.inventory_2_outlined,
                title: 'Work Shift',
                subtitle: '+Money, +Experience, +Stress',
                enabled: hasJob,
                onTap: onWorkShift,
              ),
              _ActionRow(
                icon: Icons.volunteer_activism_outlined,
                title: 'Help Customer',
                subtitle: '+Customer Skill',
                enabled: hasJob,
                onTap: onHelpCustomer,
              ),
              _ActionRow(
                icon: Icons.star_outline,
                title: 'Extra Shift',
                subtitle: 'More Money, More Stress',
                enabled: hasJob,
                onTap: onExtraShift,
              ),
              _ActionRow(
                icon: Icons.trending_up,
                title: 'Ask For Raise',
                subtitle: 'Uses performance and responsibility',
                enabled: hasJob,
                onTap: onAskForRaise,
              ),
              _ActionRow(
                icon: Icons.logout,
                title: 'Quit Job',
                subtitle: 'Keep experience, leave employer',
                enabled: hasJob,
                onTap: onQuitJob,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFF2ECC71) : Colors.white,
            border: const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: const Color(0xFF006D37), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF161C28),
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5C5E62),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.lexend(
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF5C5E62),
        ),
      ),
    );
  }
}
