import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system.dart';
import '../../../../models/part_time_job.dart';

class CurrentJobSection extends StatelessWidget {
  final PartTimeJob? job;
  final int performance;
  final int monthsWorked;

  const CurrentJobSection({
    super.key,
    required this.job,
    required this.performance,
    required this.monthsWorked,
  });

  @override
  Widget build(BuildContext context) {
    if (job == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Current Job'),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              _InfoRow(label: 'Employer', value: job!.name),
              _InfoRow(
                  label: 'Monthly Salary', value: formatMoney(job!.salary)),
              _InfoRow(label: 'Performance', value: '$performance%'),
              _InfoRow(label: 'Months Worked', value: monthsWorked.toString()),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _bodyStyle(const Color(0xFF5C5E62))),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: _bodyStyle(const Color(0xFF161C28))
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
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

TextStyle _bodyStyle(Color color) => GoogleFonts.lexend(
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: color,
    );
