import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MovieInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextAlign valueAlign;
  final Color valueColor;

  const MovieInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueAlign = TextAlign.left,
    this.valueColor = const Color(0xFF161C28),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
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
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: LayoutBuilder(
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
                        height: 1.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Color(0xFF6C7B6D)),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          Text(
            value,
            textAlign: valueAlign,
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
