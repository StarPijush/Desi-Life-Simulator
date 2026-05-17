// lib/screens/market_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/engine.dart';
import '../core/investments_data.dart';
import '../models/character.dart';

// ── Market Page (Stocks or Crypto) ──────────────────────────────────────────
class MarketPage extends StatefulWidget {
  final Character character;
  final void Function(GameAction) onGameAction;
  final String mode; // 'stock' or 'crypto'

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
  // Simulate live prices with slight variance from base
  late final Map<String, double> _prices;

  @override
  void initState() {
    super.initState();
    _prices = {};
    for (final asset in _assets) {
      // Use character's saved market prices; fallback to initialPrice if not yet initialized by engine
      _prices[asset.name] = (widget.character.marketPrices[asset.name] as num?)?.toDouble() ?? asset.initialPrice;
    }
  }

  List<MarketAsset> get _assets =>
      widget.mode == 'crypto' ? InvestmentsData.crypto : InvestmentsData.stocks;

  String get _title => widget.mode == 'crypto' ? 'CRYPTO MARKET' : 'STOCK MARKET';

  // Compute % change from initial price
  double _change(MarketAsset a) {
    final current = _prices[a.name] ?? a.initialPrice;
    return (current - a.initialPrice) / a.initialPrice;
  }

  // Check if character owns this asset
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Color(0xFF006D37), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _title,
                    style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF181C1F), letterSpacing: 0.5),
                  ),
                  const Spacer(),
                  Text(
                    formatMoney(widget.character.bankBalance),
                    style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF006D37)),
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
          // Holdings bar
          if (_hasHoldings) _buildHoldingsHeader(),
          _buildSectionLabel(widget.mode == 'crypto' ? 'COINS' : 'EQUITIES'),
          ..._assets.map((a) => _buildAssetRow(context, a)),
          const SizedBox(height: 32),
          // Disclaimer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Prices fluctuate each year. Past performance does not guarantee future returns.',
              style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w500, color: const Color(0xFFA1A1AA), height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F5),
        border: Border(bottom: BorderSide(color: Color(0xFFE4E4E7), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PORTFOLIO VALUE', style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF71717A), letterSpacing: 1.0)),
              Text(formatMoney(totalValue), style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF161C28))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('P&L', style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF71717A), letterSpacing: 1.0)),
              Text(
                '${gain ? '+' : ''}${pnlPct.toStringAsFixed(1)}%',
                style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w900, color: gain ? const Color(0xFF059669) : const Color(0xFFDC2626)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      color: const Color(0xFFF4F4F5),
      child: Text(
        label,
        style: GoogleFonts.lexend(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF71717A), letterSpacing: 1.5),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white,
            child: Row(
              children: [
                Text(asset.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF161C28))),
                      if (owned > 0)
                        Text('$owned held', style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF006D37))),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      shortMoney(price),
                      style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF161C28)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      color: isUp ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6),
                      child: Text(
                        '${isUp ? '+' : ''}${(change * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.lexend(
                          fontSize: 9, fontWeight: FontWeight.w800,
                          color: isUp ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFFD4D4D8)),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE4E4E7), indent: 48),
      ],
    );
  }

  void _showTradeModal(BuildContext context, MarketAsset asset, double price) {
    final owned = _owned(asset);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
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

// ── Trade Bottom Sheet ───────────────────────────────────────────────────────
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
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 32, height: 3,
              color: const Color(0xFFD4D4D8),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Text(asset.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.name, style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF161C28))),
                      Text(asset.description, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF71717A))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Info rows
          _infoRow('PRICE', shortMoney(price)),
          _infoRow('VOLATILITY', '${(asset.volatility * 100).toInt()}% / yr'),
          _infoRow('YOU OWN', '$owned unit${owned == 1 ? '' : 's'}'),
          _infoRow('BALANCE', formatMoney(character.bankBalance)),
          const Divider(height: 1, color: Color(0xFFE4E4E7)),
          const SizedBox(height: 12),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: canBuy ? () { HapticFeedback.lightImpact(); onBuy(); } : null,
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: canBuy ? const Color(0xFF006D37) : const Color(0xFFE4E4E7),
                      child: Text('BUY 1 UNIT', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w900, color: canBuy ? Colors.white : const Color(0xFFA1A1AA))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: canSell ? () { HapticFeedback.lightImpact(); onSell(); } : null,
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      color: canSell ? const Color(0xFFDC2626) : const Color(0xFFE4E4E7),
                      child: Text('SELL 1 UNIT', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w900, color: canSell ? Colors.white : const Color(0xFFA1A1AA))),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF71717A), letterSpacing: 0.5)),
          Text(value, style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF161C28))),
        ],
      ),
    );
  }
}
