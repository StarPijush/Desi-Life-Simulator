import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../models/character.dart';
import '../../widgets/core/app_scaffold.dart';
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

  double get _monthlyCashflow =>
      (character.annualIncome - character.annualExpenses) / 12;

  double get _investmentTotal {
    double total = 0;
    for (final item in character.stockPortfolio) {
      final qty = (item['qty'] as num?)?.toDouble() ??
          (item['quantity'] as num?)?.toDouble() ??
          0;
      final price =
          (character.marketPrices[item['name']] as num?)?.toDouble() ??
              (item['price'] as num?)?.toDouble() ??
              (item['buyPrice'] as num?)?.toDouble() ??
              0;
      total += price * qty;
    }
    for (final item in character.cryptoPortfolio) {
      final qty = (item['qty'] as num?)?.toDouble() ??
          (item['quantity'] as num?)?.toDouble() ??
          0;
      final price =
          (character.marketPrices[item['name']] as num?)?.toDouble() ??
              (item['price'] as num?)?.toDouble() ??
              (item['buyPrice'] as num?)?.toDouble() ??
              0;
      total += price * qty;
    }
    for (final item in character.bondPortfolio) {
      final qty = (item['qty'] as num?)?.toDouble() ??
          (item['quantity'] as num?)?.toDouble() ??
          0;
      final price = (item['price'] as num?)?.toDouble() ??
          (item['buyPrice'] as num?)?.toDouble() ??
          0;
      total += price * qty;
    }
    return total;
  }

  double get _propertyValue {
    double total = 0;
    for (final assetId in character.ownedAssets) {
      final val =
          (character.marketPrices['asset_$assetId'] as num?)?.toDouble();
      if (val != null && val > 0) total += val;
    }
    return total;
  }

  double get _totalDebt {
    double debt =
        character.loans.fold(0.0, (s, l) => s + l.remainingAmount);
    if (character.loans.isEmpty && character.loanAmount > 0) {
      debt += character.loanAmount;
    }
    debt += character.creditUsed;
    return debt;
  }

  String get _statusLabel {
    if (character.age < 22 && character.jobTitle.isEmpty) return 'STUDENT';
    if (character.jobTitle.isNotEmpty) return character.jobTitle.toUpperCase();
    return 'UNEMPLOYED';
  }

  int get _creditScorePercent => ((character.cibilScore - 300) / 600.0 * 100)
      .clamp(0, 100)
      .round();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Finance',
      subtitle: 'Money, assets and financial growth',
      padding: const EdgeInsets.only(left: 16, right: 16),
      children: [
        const SizedBox(height: 24),
        _buildStatusCard(),
        const SizedBox(height: 16),
        _buildHealthGrid(),
        const SizedBox(height: 16),
        _buildActivePursuitCard(),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Explore Finance',
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
        ),
        _buildExploreRows(context),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Wealth Overview',
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
        ),
        _buildWealthOverview(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusCard() {
    return GameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: AppTextStyles.headlineSm.copyWith(
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _statusBadge('AGE ${character.age}'),
                        const SizedBox(width: 8),
                        _statusBadge(_statusLabel),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'BANK BALANCE',
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.08,
                    ),
                  ),
                  Text(
                    shortMoney(character.bankBalance),
                    style: AppTextStyles.displayMd.copyWith(
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _statColumn(
                    'Net Worth',
                    shortMoney(character.totalNetWorth),
                    null,
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.divider),
                Expanded(
                  child: _statColumn(
                    'Cash Flow',
                    '${_monthlyCashflow >= 0 ? '+' : ''}${shortMoney(_monthlyCashflow)}/mo',
                    AppColors.primary,
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.divider),
                Expanded(
                  child: _statColumn(
                    'Credit Score',
                    '${character.cibilScore}',
                    null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.slate200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelBold.copyWith(
          color: AppColors.journalText,
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value, Color? valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelBold.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthGrid() {
    return Row(
      children: [
        Expanded(
          child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                border: Border.all(
                    color: AppColors.outline.withValues(alpha: 0.85)),
                boxShadow: AppShadows.card,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Health',
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ProgressBar(
                    value: character.financialHealthScore.toDouble(),
                    color: AppColors.primary,
                    height: 8,
                    trackColor: const Color(0xFFE2E8F0),
                    trackBorderColor: Colors.transparent,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${character.financialHealthScore}%',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                border: Border.all(
                    color: AppColors.outline.withValues(alpha: 0.85)),
                boxShadow: AppShadows.card,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Credit Score',
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ProgressBar(
                    value: _creditScorePercent.toDouble(),
                    color: AppColors.primary,
                    height: 8,
                    trackColor: const Color(0xFFE2E8F0),
                    trackBorderColor: Colors.transparent,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$_creditScorePercent%',
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildActivePursuitCard() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🏦', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Savings Plan',
                    style: AppTextStyles.labelBold.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Currently saving for high-end properties.',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      );
  }

  Widget _buildExploreRows(BuildContext context) {
    return Column(
      children: [
          _exploreRow(
            emoji: '🏦',
            title: 'Banking',
            subtitle: 'Accounts and deposits',
            onTap: () => _push(context, _BankingSub(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
          const SizedBox(height: 8),
          _exploreRow(
            emoji: '💳',
            title: 'Loans',
            subtitle: 'Borrow and repay',
            onTap: () => _push(context, _LoansSub(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
          const SizedBox(height: 8),
          _exploreRow(
            emoji: '📈',
            title: 'Investments',
            subtitle: 'Stocks and mutual funds',
            onTap: () => _push(context, _InvestmentsSub(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
          const SizedBox(height: 8),
          _exploreRow(
            emoji: '🏠',
            title: 'Properties',
            subtitle: 'Real estate holdings',
            onTap: () => _push(context, AssetsPage(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
          const SizedBox(height: 8),
          _exploreRow(
            emoji: '💰',
            title: 'Assets',
            subtitle: 'Vehicles and valuables',
            onTap: () => _push(context, AssetsPage(
              character: character,
              onGameAction: onGameAction,
            )),
          ),
        ],
      );
  }

  Widget _exploreRow({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          border:
              Border.all(color: AppColors.outline.withValues(alpha: 0.85)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWealthOverview() {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          border:
              Border.all(color: AppColors.outline.withValues(alpha: 0.85)),
          boxShadow: AppShadows.card,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _wealthRow('Cash', shortMoney(character.bankBalance), null),
            const SizedBox(height: 12),
            _wealthRow('Investments', shortMoney(_investmentTotal), null),
            const SizedBox(height: 12),
            _wealthRow('Property Value', shortMoney(_propertyValue), null),
            const SizedBox(height: 12),
            _wealthRow('Debt', shortMoney(_totalDebt), AppColors.error),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Divider(
                height: 1,
                color: AppColors.divider,
                thickness: 1,
              ),
            ),
            const SizedBox(height: 4),
            _wealthTotalRow(
              'Total Net Worth',
              shortMoney(character.totalNetWorth),
            ),
          ],
        ),
      );
  }

  Widget _wealthRow(String label, String value, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _wealthTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLg.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
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
