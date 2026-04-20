// lib/core/investments_data.dart

class MarketAsset {
  final String name;
  final String description;
  final double initialPrice;
  final double volatility; // Max percentage change (e.g. 0.1 for 10%)
  final String type; // 'Stock', 'Crypto', 'Bond'
  final String emoji;

  const MarketAsset({
    required this.name,
    required this.description,
    required this.initialPrice,
    required this.volatility,
    required this.type,
    required this.emoji,
  });
}

class InvestmentsData {
  static const List<MarketAsset> stocks = [
    MarketAsset(
      name: 'TechCorp',
      description: 'Leading software exporter in India.',
      initialPrice: 1250.0,
      volatility: 0.10,
      type: 'Stock',
      emoji: '💻',
    ),
    MarketAsset(
      name: 'Bharat Bank',
      description: 'Massive public sector banking giant.',
      initialPrice: 550.0,
      volatility: 0.08,
      type: 'Stock',
      emoji: '🏦',
    ),
    MarketAsset(
      name: 'Tata Infra',
      description: 'Infrastructure and steel conglomerate.',
      initialPrice: 2100.0,
      volatility: 0.07,
      type: 'Stock',
      emoji: '🏗️',
    ),
    MarketAsset(
      name: 'Green Energy Ltd',
      description: 'Renewable energy and solar pioneer.',
      initialPrice: 150.0,
      volatility: 0.15,
      type: 'Stock',
      emoji: '🌱',
    ),
  ];

  static const List<MarketAsset> crypto = [
    MarketAsset(
      name: 'BitDesi',
      description: 'The digital gold for the Indian market.',
      initialPrice: 4500000.0,
      volatility: 0.25,
      type: 'Crypto',
      emoji: '🪙',
    ),
    MarketAsset(
      name: 'IndiCoin',
      description: 'Fast, scalable, and decentralized Indian coin.',
      initialPrice: 120.0,
      volatility: 0.35,
      type: 'Crypto',
      emoji: '🇮🇳',
    ),
    MarketAsset(
      name: 'MetaToken',
      description: 'Powering the future of the virtual world.',
      initialPrice: 1500.0,
      volatility: 0.20,
      type: 'Crypto',
      emoji: '🕶️',
    ),
  ];

  static const List<MarketAsset> bonds = [
    MarketAsset(
      name: 'Government Bonds',
      description: 'Sovereign backed long-term debt. Minimal risk.',
      initialPrice: 10000.0,
      volatility: 0.02, // Very low volatility, mostly fixed growth
      type: 'Bond',
      emoji: '📜',
    ),
  ];

  static List<MarketAsset> get all => [...stocks, ...crypto, ...bonds];
  
  static MarketAsset? findByName(String name) {
    try {
      return all.firstWhere((a) => a.name == name);
    } catch (_) {
      return null;
    }
  }
}
