import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../models/character.dart';
import '../../widgets/core/app_scaffold.dart';
import '../../widgets/core/app_status_banner.dart';
import '../../widgets/game/action_tile.dart';
import '../../widgets/game/game_card.dart';
import '../../widgets/game/progress_bar.dart';
import '../../widgets/game/section_header.dart';
import 'assets_page.dart';
import 'market_page.dart';

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

    return AppScaffold(
      title: 'Finance',
      children: [
        AppStatusBanner(
          label: 'CURRENT STATUS',
          title: character.name,
          subtitle: 'Age: ${character.age}',
          trailing: Text(
            formatMoney(character.bankBalance),
            style: AppTextStyles.displayMd.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SectionHeader(
          title: 'Overview',
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
            vertical: AppSpacing.sm,
          ),
        ),
        GameCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('💰', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Net Worth: ${formatMoney(netWorth)}',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Text('📈', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Cash Flow: ${formatMoney(annualCashflow)}/yr',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GameCard(
          child: ProgressBarRow(
            label: 'FINANCIAL HEALTH',
            value: healthScore.toDouble(),
            barHeight: 12,
            showPercent: true,
            color: healthScore >= 60
                ? AppColors.primary
                : healthScore >= 30
                    ? AppColors.warning
                    : AppColors.error,
          ),
        ),
        const SizedBox(height: 12),
        const SectionHeader(
          title: 'Options',
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
            vertical: AppSpacing.sm,
          ),
        ),
        _buildOptionsGrid(context),
      ],
    );
  }

  Widget _buildOptionsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
        children: [
          ActionTile(
            emoji: '🏦',
            label: 'Banking',
            onTap: () => _push(context, _BankingSub(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
          ActionTile(
            emoji: '💵',
            label: 'Loans',
            onTap: () => _push(context, _LoansSub(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
          ActionTile(
            emoji: '📊',
            label: 'Investments',
            onTap: () => _push(context, _InvestmentsSub(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
          ActionTile(
            emoji: '🏠',
            label: 'Assets',
            onTap: () => _push(context, AssetsPage(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
          ActionTile(
            emoji: '🏙️',
            label: 'Properties',
            onTap: () => _push(context, AssetsPage(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _BankingSub extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _BankingSub({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Banking',
      children: [
        const SectionHeader(
          title: 'Actions',
          padding: EdgeInsets.only(
            left: AppSpacing.containerPadding,
            bottom: AppSpacing.sm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
            children: [
              ActionTile(
                emoji: '🏦',
                label: 'Open Account',
                onTap: () => onGameAction(
                  const GameAction('bank.open_account'),
                ),
              ),
              ActionTile(
                emoji: '💰',
                label: 'Deposit',
                onTap: () => onGameAction(
                  const GameAction('bank.deposit_savings'),
                ),
              ),
              ActionTile(
                emoji: '💳',
                label: 'Credit Card',
                onTap: () => onGameAction(
                  const GameAction('bank.apply_credit_card'),
                ),
              ),
              ActionTile(
                emoji: '👪',
                label: 'Ask Parents',
                onTap: () => onGameAction(
                  const GameAction('bank.ask_parents'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoansSub extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _LoansSub({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Loans',
      children: [
        const SectionHeader(
          title: 'Borrow',
          padding: EdgeInsets.only(
            left: AppSpacing.containerPadding,
            bottom: AppSpacing.sm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
            children: [
              ActionTile(
                emoji: '🎓',
                label: 'Student Loan',
                onTap: () => onGameAction(
                  const GameAction('bank.take_student_loan'),
                ),
              ),
              ActionTile(
                emoji: '💵',
                label: 'Personal Loan',
                onTap: () => onGameAction(
                  const GameAction('bank.take_personal_loan'),
                ),
              ),
              ActionTile(
                emoji: '🏠',
                label: 'Home Loan',
                onTap: () => onGameAction(
                  const GameAction('bank.take_home_loan'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvestmentsSub extends StatelessWidget {
  final Character character;
  final void Function(GameAction) onGameAction;

  const _InvestmentsSub({
    required this.character,
    required this.onGameAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Investments',
      children: [
        const SectionHeader(
          title: 'Market',
          padding: EdgeInsets.only(
            left: AppSpacing.containerPadding,
            bottom: AppSpacing.sm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerPadding,
          ),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
            children: [
              ActionTile(
                emoji: '📈',
                label: 'Stocks',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MarketPage(
                    character: character,
                    onGameAction: onGameAction,
                    mode: 'stock',
                  ),
                )),
              ),
              ActionTile(
                emoji: '📉',
                label: 'Crypto',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MarketPage(
                    character: character,
                    onGameAction: onGameAction,
                    mode: 'crypto',
                  ),
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
