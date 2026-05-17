// lib/screens/finance_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/engine.dart';
import '../models/character.dart';
import 'market_page.dart';
import 'assets_page.dart';

class FinancePage extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const FinancePage({
    super.key,
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    final netWorth = character.totalNetWorth;
    final healthScore = character.financialHealthScore;
    final annualCashflow = character.annualIncome - character.annualExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
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
                    child: const Icon(Icons.arrow_back, color: Color(0xFF006D37), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'FINANCE',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF181C1F),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatMoney(character.bankBalance),
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF006D37),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Identity Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STATUS',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5C5E62),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      character.name,
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF161C28),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Age: ${character.age}',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF006D37),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // OVERVIEW SECTION
          const _SectionHeader(title: 'OVERVIEW'),
          _FinanceRow(
            icon: '💰',
            title: 'Net Worth: ${formatMoney(netWorth)}',
            showChevron: false,
            onTap: () {},
          ),
          _FinanceRow(
            icon: '📈',
            title: 'Cash Flow: ${formatMoney(annualCashflow)}/yr',
            showChevron: false,
            onTap: () {},
          ),

          // FINANCIAL HEALTH SECTION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FINANCIAL HEALTH',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF161C28),
                      ),
                    ),
                    Text(
                      '$healthScore%',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: healthScore >= 60
                            ? const Color(0xFF006D37)
                            : healthScore >= 30
                                ? const Color(0xFFD97706)
                                : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDEDFE3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (healthScore / 100).clamp(0.01, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: healthScore >= 60
                            ? const Color(0xFF006D37)
                            : healthScore >= 30
                                ? const Color(0xFFD97706)
                                : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // OPTIONS SECTION
          const _SectionHeader(title: 'OPTIONS'),
          _FinanceRow(
            icon: '🏦',
            title: 'Banking',
            onTap: () => _push(context, _BankingSub(character: character, onGameAction: onGameAction)),
          ),
          _FinanceRow(
            icon: '💵',
            title: 'Loans',
            onTap: () => _push(context, _LoansSub(character: character, onGameAction: onGameAction)),
          ),
          _FinanceRow(
            icon: '📊',
            title: 'Investments',
            onTap: () => _push(context, _InvestmentsSub(character: character, onGameAction: onGameAction)),
          ),
          _FinanceRow(
            icon: '🏠',
            title: 'Assets',
            onTap: () => _push(context, AssetsPage(character: character, onGameAction: onGameAction)),
          ),
          _FinanceRow(
            icon: '🏙️',
            title: 'Properties',
            onTap: () => _push(context, AssetsPage(character: character, onGameAction: onGameAction)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F3FF),
        border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
      ),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3D4A3E),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _FinanceRow extends StatefulWidget {
  final String icon;
  final String title;
  final bool showChevron;
  final VoidCallback onTap;

  const _FinanceRow({
    required this.icon,
    required this.title,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  State<_FinanceRow> createState() => _FinanceRowState();
}

class _FinanceRowState extends State<_FinanceRow> {
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
          border: const Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
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
              const Icon(Icons.chevron_right, color: Color(0xFF5C5E62), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder Sub-Screens for logic reconnection ───────────────────────────
// These should ideally use the same flat style. Rebuilding them briefly.

class _BankingSub extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;
  const _BankingSub({required this.character, required this.onGameAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _subAppBar(context, 'BANKING'),
      body: ListView(
        children: [
          const _SectionHeader(title: 'ACTIONS'),
          _FinanceRow(icon: '🏦', title: 'Open Account', onTap: () => onGameAction(const GameAction('bank.open_account'))),
          _FinanceRow(icon: '💰', title: 'Deposit', onTap: () => onGameAction(const GameAction('bank.deposit_savings'))),
          _FinanceRow(icon: '💳', title: 'Credit Card', onTap: () => onGameAction(const GameAction('bank.apply_credit_card'))),
          _FinanceRow(icon: '👪', title: 'Ask Parents', onTap: () => onGameAction(const GameAction('bank.ask_parents'))),
        ],
      ),
    );
  }
}

class _LoansSub extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;
  const _LoansSub({required this.character, required this.onGameAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _subAppBar(context, 'LOANS'),
      body: ListView(
        children: [
          const _SectionHeader(title: 'BORROW'),
          _FinanceRow(icon: '🎓', title: 'Student Loan', onTap: () => onGameAction(const GameAction('bank.take_student_loan'))),
          _FinanceRow(icon: '💵', title: 'Personal Loan', onTap: () => onGameAction(const GameAction('bank.take_personal_loan'))),
          _FinanceRow(icon: '🏠', title: 'Home Loan', onTap: () => onGameAction(const GameAction('bank.take_home_loan'))),
        ],
      ),
    );
  }
}

class _InvestmentsSub extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;
  const _InvestmentsSub({required this.character, required this.onGameAction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: _subAppBar(context, 'INVESTMENTS'),
      body: ListView(
        children: [
          const _SectionHeader(title: 'MARKET'),
          _FinanceRow(
            icon: '📈',
            title: 'Stocks',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MarketPage(character: character, onGameAction: onGameAction, mode: 'stock'),
            )),
          ),
          _FinanceRow(
            icon: '📉',
            title: 'Crypto',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MarketPage(character: character, onGameAction: onGameAction, mode: 'crypto'),
            )),
          ),
        ],
      ),
    );
  }
}



PreferredSizeWidget _subAppBar(BuildContext context, String title) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(56),
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFBBCBBB), width: 1)),
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
                child: const Icon(Icons.arrow_back, color: Color(0xFF006D37), size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF181C1F),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
