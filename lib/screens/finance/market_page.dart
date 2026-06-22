import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/design_system.dart';
import '../../core/engine.dart';
import '../../core/investments_data.dart';
import '../../models/character.dart';
import '../../widgets/core/app_scaffold.dart';
import '../../widgets/game/section_header.dart';

class MarketPage extends StatefulWidget {
  final Character character;
  final void Function(GameAction) onGameAction;
  final String mode;

  const MarketPage({
    super.key,
    required this.character,
    required this.onGameAction,
    required this.mode,
  });

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  late final Map<String, double> _prices;

  @override
  void initState() {
    super.initState();
    _prices = {};
    for (final asset in _assets) {
      _prices[asset.name] = (widget.character.marketPrices[asset.name] as num?)?.toDouble() ?? asset.initialPrice;
    }
  }

  List<MarketAsset> get _assets =>
      widget.mode == 'crypto' ? InvestmentsData.crypto : InvestmentsData.stocks;

  String get _title => widget.mode == 'crypto' ? 'CRYPTO MARKET' : 'STOCK MARKET';

  double _change(MarketAsset a) {
    final current = _prices[a.name] ?? a.initialPrice;
    return (current - a.initialPrice) / a.initialPrice;
  }

  int _owned(MarketAsset a) {
    final portfolio = widget.mode == 'crypto'
        ? widget.character.cryptoPortfolio
        : widget.character.stockPortfolio;
    int count = 0;
    for (final item in portfolio) {
      if (item['name'] == a.name) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _title,
      showBack: true,
      trailing: Text(
        formatMoney(widget.character.bankBalance),
        style: AppTextStyles.labelBold.copyWith(fontSize: 12, color: AppColors.primary),
      ),
      children: [
        if (_hasHoldings) _buildHoldingsHeader(),
        const SizedBox(height: AppSpacing.xs),
        SectionHeader(title: widget.mode == 'crypto' ? 'COINS' : 'EQUITIES'),
        ..._assets.map((a) => _buildAssetRow(context, a)),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: AppSpacing.sm),
          child: Text(
            'Prices fluctuate each year. Past performance does not guarantee future returns.',
            style: AppTextStyles.caption.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }

  bool get _hasHoldings {
    final p = widget.mode == 'crypto'
        ? widget.character.cryptoPortfolio
        : widget.character.stockPortfolio;
    return p.isNotEmpty;
  }

  Widget _buildHoldingsHeader() {
    final portfolio = widget.mode == 'crypto'
        ? widget.character.cryptoPortfolio
        : widget.character.stockPortfolio;
    double totalValue = 0;
    double totalCost = 0;
    for (final item in portfolio) {
      final price = _prices[item['name']] ?? (item['price'] as num).toDouble();
      totalValue += price * (item['qty'] as num).toDouble();
      totalCost += (item['price'] as num).toDouble() * (item['qty'] as num).toDouble();
    }
    final pnl = totalValue - totalCost;
    final pnlPct = totalCost > 0 ? pnl / totalCost * 100 : 0.0;
    final gain = pnl >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.iconBg,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PORTFOLIO VALUE', style: AppTextStyles.sectionLabel),
              Text(formatMoney(totalValue), style: AppTextStyles.financial),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('P&L', style: AppTextStyles.sectionLabel),
              Text(
                '${gain ? '+' : ''}${pnlPct.toStringAsFixed(1)}%',
                style: AppTextStyles.financial.copyWith(
                  color: gain ? const Color(0xFF059669) : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow(BuildContext context, MarketAsset asset) {
    final price = _prices[asset.name] ?? asset.initialPrice;
    final change = _change(asset);
    final owned = _owned(asset);
    final isUp = change >= 0;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _showTradeModal(context, asset, price),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
            color: AppColors.surface,
            child: Row(
              children: [
                Text(asset.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: AppTextStyles.rowTitle),
                      if (owned > 0)
                        Text('$owned held', style: AppTextStyles.rowSubtitle.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      shortMoney(price),
                      style: AppTextStyles.rowTitle.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      color: isUp ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6),
                      child: Text(
                        '${isUp ? '+' : ''}${(change * 100).toStringAsFixed(1)}%',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isUp ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.outline),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider, indent: 48),
      ],
    );
  }

  void _showTradeModal(BuildContext context, MarketAsset asset, double price) {
    final owned = _owned(asset);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => _TradeSheet(
        asset: asset,
        price: price,
        owned: owned,
        character: widget.character,
        onBuy: () {
          Navigator.of(context).pop();
          widget.onGameAction(GameAction('investment.buy', {
            'asset': asset,
            'quantity': 1.0,
          }));
        },
        onSell: () {
          Navigator.of(context).pop();
          final portfolio = widget.mode == 'crypto'
              ? widget.character.cryptoPortfolio
              : widget.character.stockPortfolio;
          final idx = portfolio.indexWhere((m) => m['name'] == asset.name);
          if (idx >= 0) {
            widget.onGameAction(GameAction('investment.sell', {
              'investmentType': widget.mode == 'crypto' ? 'crypto' : 'stock',
              'index': idx,
            }));
          }
        },
      ),
    );
  }
}

class _TradeSheet extends StatelessWidget {
  final MarketAsset asset;
  final double price;
  final int owned;
  final Character character;
  final VoidCallback onBuy;
  final VoidCallback onSell;

  const _TradeSheet({
    required this.asset,
    required this.price,
    required this.owned,
    required this.character,
    required this.onBuy,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    final canBuy = character.bankBalance >= price;
    final canSell = owned > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
              width: 32, height: 3,
              color: AppColors.outline,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.containerPadding, AppSpacing.xs, AppSpacing.containerPadding, AppSpacing.cardGap),
            child: Row(
              children: [
                Text(asset.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: AppSpacing.cardGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: AppTextStyles.headlineSm),
                      Text(asset.description, style: AppTextStyles.labelSm),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _infoRow('PRICE', shortMoney(price)),
          _infoRow('VOLATILITY', '${(asset.volatility * 100).toInt()}% / yr'),
          _infoRow('YOU OWN', '$owned unit${owned == 1 ? '' : 's'}'),
          _infoRow('BALANCE', formatMoney(character.bankBalance)),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.cardGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: canBuy ? () { HapticFeedback.lightImpact(); onBuy(); } : null,
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: canBuy ? AppColors.primary : AppColors.divider,
                      child: Text('BUY 1 UNIT', style: AppTextStyles.labelBold.copyWith(
                        fontSize: 12,
                        color: canBuy ? AppColors.surface : AppColors.textMuted,
                      )),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: canSell ? () { HapticFeedback.lightImpact(); onSell(); } : null,
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: canSell ? const Color(0xFFDC2626) : AppColors.divider,
                      child: Text('SELL 1 UNIT', style: AppTextStyles.labelBold.copyWith(
                        fontSize: 12,
                        color: canSell ? AppColors.surface : AppColors.textMuted,
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.pageSubtitle),
          Text(value, style: AppTextStyles.rowTitle.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
