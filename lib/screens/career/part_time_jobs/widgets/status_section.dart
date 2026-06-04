import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../models/character.dart';
import '../../../../models/part_time_job.dart';

class PartTimeStatusSection extends StatelessWidget {
  final Character character;
  final PartTimeJob? currentJob;
  final int experience;
  final int responsibility;
  final int customerSkill;

  const PartTimeStatusSection({
    super.key,
    required this.character,
    required this.currentJob,
    required this.experience,
    required this.responsibility,
    required this.customerSkill,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Current Status'),
        Container(
          color: Colors.white,
          child: Column(
            children: [
              _InfoRow(label: 'Name', value: character.name),
              _InfoRow(label: 'Age', value: character.age.toString()),
              _InfoRow(label: 'Education', value: _educationLabel(character)),
              _InfoRow(label: 'Current Job', value: currentJob?.name ?? 'None'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    _MetricBar(label: 'Work Experience', value: experience),
                    const SizedBox(height: 6),
                    _MetricBar(label: 'Responsibility', value: responsibility),
                    const SizedBox(height: 6),
                    _MetricBar(label: 'Customer Skills', value: customerSkill),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _educationLabel(Character character) {
    if (character.age < 5) return 'Not In School';
    if (character.age < 18) return 'High School Student';
    if (character.educationLevel == 'None') return 'No Formal Education';
    if (character.degree != 'None') return character.degree;
    return character.educationLevel;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _bodyStyle(const Color(0xFF161C28))
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final int value;

  const _MetricBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 100).toInt();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.toUpperCase(),
                style: _labelStyle(const Color(0xFF5C5E62))),
            Text('$clamped%',
                style: _labelStyle(const Color(0xFF006D37))
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(height: 5, color: const Color(0xFFE5E7EB)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped / 100,
              child: Container(height: 5, color: const Color(0xFF2ECC71)),
            ),
          ],
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
      child: Text(title.toUpperCase(),
          style: _labelStyle(const Color(0xFF5C5E62))),
    );
  }
}

TextStyle _bodyStyle(Color color) => GoogleFonts.lexend(
      fontSize: 10,
      height: 1.15,
      fontWeight: FontWeight.w500,
      color: color,
    );

TextStyle _labelStyle(Color color) => GoogleFonts.lexend(
      fontSize: 9,
      height: 1.0,
      fontWeight: FontWeight.w600,
      color: color,
    );
