import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MovieDetailInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const MovieDetailInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF161C28),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5C5E62),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const _DottedLine(),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 2.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 2.0,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFBBCBBB)),
              ),
            );
          }),
        );
      },
    );
  }
}
