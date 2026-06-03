// lib/screens/finance/finance_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../models/character.dart';
import '../../widgets/common_widgets.dart';
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
          const AppSectionHeader.finance('OVERVIEW'),
          FinanceListRow(
            icon: '💰',
            title: 'Net Worth: ${formatMoney(netWorth)}',
            showChevron: false,
            onTap: () {},
          ),
          FinanceListRow(
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
          const AppSectionHeader.finance('OPTIONS'),
          FinanceListRow(
            icon: '🏦',
            title: 'Banking',
            onTap: () => _push(context, _BankingSub(character: character, onGameAction: onGameAction)),
          ),
          FinanceListRow(
            icon: '💵',
            title: 'Loans',
            onTap: () => _push(context, _LoansSub(character: character, onGameAction: onGameAction)),
          ),
          FinanceListRow(
            icon: '📊',
            title: 'Investments',
            onTap: () => _push(context, _InvestmentsSub(character: character, onGameAction: onGameAction)),
          ),
          FinanceListRow(
            icon: '🏠',
            title: 'Assets',
            onTap: () => _push(context, AssetsPage(character: character, onGameAction: onGameAction)),
          ),
          FinanceListRow(
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

// Placeholder Sub-Screens for logic reconnection ───────────────────────────
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
          const AppSectionHeader.finance('ACTIONS'),
          FinanceListRow(icon: '🏦', title: 'Open Account', onTap: () => onGameAction(const GameAction('bank.open_account'))),
          FinanceListRow(icon: '💰', title: 'Deposit', onTap: () => onGameAction(const GameAction('bank.deposit_savings'))),
          FinanceListRow(icon: '💳', title: 'Credit Card', onTap: () => onGameAction(const GameAction('bank.apply_credit_card'))),
          FinanceListRow(icon: '👪', title: 'Ask Parents', onTap: () => onGameAction(const GameAction('bank.ask_parents'))),
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
          const AppSectionHeader.finance('BORROW'),
          FinanceListRow(icon: '🎓', title: 'Student Loan', onTap: () => onGameAction(const GameAction('bank.take_student_loan'))),
          FinanceListRow(icon: '💵', title: 'Personal Loan', onTap: () => onGameAction(const GameAction('bank.take_personal_loan'))),
          FinanceListRow(icon: '🏠', title: 'Home Loan', onTap: () => onGameAction(const GameAction('bank.take_home_loan'))),
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
          const AppSectionHeader.finance('MARKET'),
          FinanceListRow(
            icon: '📈',
            title: 'Stocks',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MarketPage(character: character, onGameAction: onGameAction, mode: 'stock'),
            )),
          ),
          FinanceListRow(
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
  return FlatBackAppBar(
    title: title,
    backColor: const Color(0xFF006D37),
    borderColor: const Color(0xFFBBCBBB),
    uppercase: false,
  );
}

