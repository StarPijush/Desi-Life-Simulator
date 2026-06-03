import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MilitaryHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final VoidCallback? onMore;

  const MilitaryHeader({
    super.key,
    this.onBack,
    this.onMore,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (onBack != null) {
                      onBack!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const SizedBox(
                    width: 24,
                    height: 40,
                    child: Icon(
                      Icons.arrow_back,
                      color: Color(0xFF71717A),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'MILITARY',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF10B981),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMore,
              child: const SizedBox(
                width: 24,
                height: 40,
                child: Icon(
                  Icons.more_vert,
                  color: Color(0xFF71717A),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
