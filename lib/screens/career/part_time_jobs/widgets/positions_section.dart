import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system.dart';
import '../../../../core/part_time_jobs_data.dart';
import '../../../../models/character.dart';
import '../../../../models/part_time_job.dart';

class PositionsSection extends StatelessWidget {
  final Character character;
  final List<PartTimeJob> jobs;
  final ValueChanged<PartTimeJob> onSelectJob;

  const PositionsSection({
    super.key,
    required this.character,
    required this.jobs,
    required this.onSelectJob,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Available Positions'),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              for (final job in jobs)
                _PositionRow(
                  job: job,
                  lockReason: PartTimeJobsData.lockReason(job, character),
                  onTap: () => onSelectJob(job),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PositionRow extends StatefulWidget {
  final PartTimeJob job;
  final String? lockReason;
  final VoidCallback onTap;

  const _PositionRow({
    required this.job,
    required this.lockReason,
    required this.onTap,
  });

  @override
  State<_PositionRow> createState() => _PositionRowState();
}

class _PositionRowState extends State<_PositionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final locked = widget.lockReason != null;
    final background = locked
        ? const Color(0xFFF1F3FF)
        : _pressed
            ? const Color(0xFFE8EEFF)
            : Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: locked ? null : (_) => setState(() => _pressed = true),
      onTapUp: locked
          ? null
          : (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: Opacity(
        opacity: locked ? 0.8 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            border: const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: locked
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                        child: Text(widget.job.emoji,
                            style: const TextStyle(fontSize: 24, height: 1)),
                      )
                    : Text(widget.job.emoji,
                        style: const TextStyle(fontSize: 24, height: 1)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: locked
                            ? const Color(0xFF5C5E62)
                            : const Color(0xFF161C28),
                      ),
                    ),
                    Text(
                      locked
                          ? '🔒 ${widget.lockReason}'
                          : '${formatMoney(widget.job.salary)}/mo • ${widget.job.hoursPerWeek} hrs/week',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        height: 1.1,
                        fontWeight: locked ? FontWeight.w600 : FontWeight.w500,
                        color: locked
                            ? const Color(0xFFBA1A1A)
                            : const Color(0xFF5C5E62),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (locked)
                const Icon(Icons.lock, color: Color(0xFF6C7B6D), size: 24)
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Age ${widget.job.minAge}+',
                      style: GoogleFonts.lexend(
                        fontSize: 9,
                        height: 1.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5C5E62),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right,
                        color: Color(0xFF5C5E62), size: 24),
                  ],
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
          fontSize: 13,
          height: 1,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF5C5E62),
        ),
      ),
    );
  }
}
