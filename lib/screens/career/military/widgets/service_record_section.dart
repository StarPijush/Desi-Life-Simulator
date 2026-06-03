import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceRecordSection extends StatelessWidget {
  final int fitness;
  final int discipline;
  final int leadership;
  final int deployments;
  final int medals;
  final int promotionScore;

  const ServiceRecordSection({
    super.key,
    required this.fitness,
    required this.discipline,
    required this.leadership,
    required this.deployments,
    required this.medals,
    required this.promotionScore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Service Record'),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StatBar(label: 'Fitness', value: fitness),
                    const SizedBox(height: 12),
                    _StatBar(label: 'Discipline', value: discipline),
                    const SizedBox(height: 12),
                    _StatBar(label: 'Leadership', value: leadership),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF4F4F5)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _RecordMetric(
                        value: deployments.toString(),
                        label: 'Deployments',
                        borderRight: true,
                      ),
                    ),
                    Expanded(
                      child: _RecordMetric(
                        value: medals.toString(),
                        label: 'Medals',
                        borderRight: true,
                      ),
                    ),
                    Expanded(
                      child: _RecordMetric(
                        value: '$promotionScore%',
                        label: 'PROMOTION',
                        valueColor: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
          height: 1.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF71717A),
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int value;

  const _StatBar({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: _labelStyle(const Color(0xFF52525B)),
            ),
            Text(
              '$clamped%',
              style: _labelStyle(const Color(0xFF52525B)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(height: 10, color: const Color(0xFFE5E7EB)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped / 100,
              child: Container(height: 10, color: const Color(0xFF10B981)),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecordMetric extends StatelessWidget {
  final String value;
  final String label;
  final bool borderRight;
  final Color valueColor;

  const _RecordMetric({
    required this.value,
    required this.label,
    this.borderRight = false,
    this.valueColor = const Color(0xFF18181B),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: borderRight
            ? const Border(
                right: BorderSide(color: Color(0xFFF4F4F5), width: 1),
              )
            : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: _labelStyle(const Color(0xFF71717A)),
          ),
        ],
      ),
    );
  }
}

TextStyle _labelStyle(Color color) {
  return GoogleFonts.lexend(
    fontSize: 13,
    height: 1.0,
    fontWeight: FontWeight.w600,
    color: color,
  );
}
