// lib/core/assets_data.dart


enum AssetCategory { vehicle, property, jewelry }
enum AssetRarity { common, rare, epic, legendary }

class Brand {
  final String id;
  final String name;
  final String countryFlag;
  final String tagline;
  final AssetCategory category;

  const Brand({
    required this.id,
    required this.name,
    required this.countryFlag,
    required this.tagline,
    required this.category,
  });
}

class GameAsset {
  final String id;
  final String name;
  final double purchasePrice;
  final double yearlyMaintenance;
  final AssetCategory category;
  final String emoji;
  final int minAge;
  final String description;
  final String? brandId;
  final AssetRarity rarity;
  final int statusBoost;
  final double netWorthRequired;
  final double incomeRequired;

  const GameAsset({
    required this.id,
    required this.name,
    required this.purchasePrice,
    required this.yearlyMaintenance,
    required this.category,
    required this.emoji,
    required this.minAge,
    required this.description,
    this.brandId,
    this.rarity = AssetRarity.common,
    this.statusBoost = 0,
    this.netWorthRequired = 0,
    this.incomeRequired = 0,
  });
}

class AssetsData {
  static const List<Brand> brands = [
    // Bikes
    Brand(id: 'bajaj', name: 'Bajaj', countryFlag: '🇮🇳', tagline: 'Affordable Reliability', category: AssetCategory.vehicle),
    Brand(id: 'hero', name: 'Hero', countryFlag: '🇮🇳', tagline: 'Mileage King', category: AssetCategory.vehicle),
    Brand(id: 'tvs', name: 'TVS', countryFlag: '🇮🇳', tagline: 'Racing DNA', category: AssetCategory.vehicle),
    Brand(id: 'royal_enfield', name: 'Royal Enfield', countryFlag: '🇮🇳', tagline: 'Made Like a Gun', category: AssetCategory.vehicle),
    Brand(id: 'honda_bike', name: 'Honda', countryFlag: '🇯🇵', tagline: 'Refined Performance', category: AssetCategory.vehicle),
    Brand(id: 'yamaha', name: 'Yamaha', countryFlag: '🇯🇵', tagline: 'Revs Your Heart', category: AssetCategory.vehicle),
    Brand(id: 'kawasaki', name: 'Kawasaki', countryFlag: '🇯🇵', tagline: 'Let the Good Times Roll', category: AssetCategory.vehicle),
    Brand(id: 'bmw_motorrad', name: 'BMW Motorrad', countryFlag: '🇩🇪', tagline: 'Make Life a Ride', category: AssetCategory.vehicle),
    Brand(id: 'ducati', name: 'Ducati', countryFlag: '🇮🇹', tagline: 'Style, Sophistication, Performance', category: AssetCategory.vehicle),
    
    // Cars
    Brand(id: 'maruti', name: 'Maruti Suzuki', countryFlag: '🇮🇳', tagline: 'Way of Life', category: AssetCategory.vehicle),
    Brand(id: 'tata', name: 'Tata Motors', countryFlag: '🇮🇳', tagline: 'Connecting Aspirations', category: AssetCategory.vehicle),
    Brand(id: 'mahindra', name: 'Mahindra', countryFlag: '🇮🇳', tagline: 'Rise', category: AssetCategory.vehicle),
    Brand(id: 'hyundai', name: 'Hyundai', countryFlag: '🇰🇷', tagline: 'New Thinking. New Possibilities.', category: AssetCategory.vehicle),
    Brand(id: 'honda_car', name: 'Honda Cars', countryFlag: '🇯🇵', tagline: 'The Power of Dreams', category: AssetCategory.vehicle),
    Brand(id: 'toyota', name: 'Toyota', countryFlag: '🇯🇵', tagline: 'Quality Revolution', category: AssetCategory.vehicle),
    Brand(id: 'bmw_car', name: 'BMW', countryFlag: '🇩🇪', tagline: 'Sheer Driving Pleasure', category: AssetCategory.vehicle),
    Brand(id: 'mercedes', name: 'Mercedes-Benz', countryFlag: '🇩🇪', tagline: 'The Best or Nothing', category: AssetCategory.vehicle),
    Brand(id: 'audi', name: 'Audi', countryFlag: '🇩🇪', tagline: 'Vorsprung durch Technik', category: AssetCategory.vehicle),
  ];

  static const List<GameAsset> marketplace = [
    // ── Bikes (Common/Rare/Epic) ──────────────────────────
    GameAsset(
      id: 'honda_activa',
      brandId: 'honda_bike',
      name: 'Honda Activa 6G',
      purchasePrice: 85000,
      yearlyMaintenance: 5000,
      category: AssetCategory.vehicle,
      emoji: '🛵',
      minAge: 18,
      description: 'The classic Indian scooter. Reliable and efficient.',
      rarity: AssetRarity.common,
      statusBoost: 1,
    ),
    GameAsset(
      id: 'hero_splendor',
      brandId: 'hero',
      name: 'Hero Splendor Plus',
      purchasePrice: 75000,
      yearlyMaintenance: 4000,
      category: AssetCategory.vehicle,
      emoji: '🏍️',
      minAge: 18,
      description: 'The mileage king of India.',
      rarity: AssetRarity.common,
    ),
    GameAsset(
      id: 'bajaj_pulsar',
      brandId: 'bajaj',
      name: 'Bajaj Pulsar 150',
      purchasePrice: 110000,
      yearlyMaintenance: 8000,
      category: AssetCategory.vehicle,
      emoji: '🏍️',
      minAge: 18,
      description: 'Definitely Male.',
      rarity: AssetRarity.common,
      statusBoost: 2,
    ),
    GameAsset(
      id: 'royal_enfield',
      brandId: 'royal_enfield',
      name: 'Royal Enfield Classic 350',
      purchasePrice: 220000,
      yearlyMaintenance: 12000,
      category: AssetCategory.vehicle,
      emoji: '🏍️',
      minAge: 18,
      description: 'The thumping heartbeat of Indian roads.',
      rarity: AssetRarity.rare,
      statusBoost: 5,
      incomeRequired: 300000,
    ),
    GameAsset(
      id: 'ktm_duke',
      brandId: 'bajaj', // KTM partner in India
      name: 'KTM Duke 390',
      purchasePrice: 310000,
      yearlyMaintenance: 15000,
      category: AssetCategory.vehicle,
      emoji: '🏍️',
      minAge: 18,
      description: 'Ready to Race.',
      rarity: AssetRarity.rare,
      statusBoost: 8,
      incomeRequired: 500000,
    ),
    GameAsset(
      id: 'kawasaki_ninja',
      brandId: 'kawasaki',
      name: 'Kawasaki Ninja ZX-10R',
      purchasePrice: 1650000,
      yearlyMaintenance: 40000,
      category: AssetCategory.vehicle,
      emoji: '🏍️',
      minAge: 21,
      description: 'A track weapon for the streets.',
      rarity: AssetRarity.epic,
      statusBoost: 15,
      netWorthRequired: 5000000,
    ),
    GameAsset(
      id: 'ducati_panigale',
      brandId: 'ducati',
      name: 'Ducati Panigale V4',
      purchasePrice: 2800000,
      yearlyMaintenance: 70000,
      category: AssetCategory.vehicle,
      emoji: '🏍️',
      minAge: 21,
      description: 'Italian masterpiece.',
      rarity: AssetRarity.legendary,
      statusBoost: 25,
      netWorthRequired: 10000000,
    ),

    // ── Cars (Common/Rare/Epic/Legendary) ──────────────────────────
    GameAsset(
      id: 'maruti_alto',
      brandId: 'maruti',
      name: 'Maruti Alto 800',
      purchasePrice: 400000,
      yearlyMaintenance: 15000,
      category: AssetCategory.vehicle,
      emoji: '🚗',
      minAge: 18,
      description: 'The first car for many Indians.',
      rarity: AssetRarity.common,
      statusBoost: 2,
    ),
    GameAsset(
      id: 'maruti_swift',
      brandId: 'maruti',
      name: 'Maruti Swift',
      purchasePrice: 750000,
      yearlyMaintenance: 25000,
      category: AssetCategory.vehicle,
      emoji: '🚗',
      minAge: 18,
      description: 'The favorite family hatchback.',
      rarity: AssetRarity.common,
      statusBoost: 5,
    ),
    GameAsset(
      id: 'tata_nexon',
      brandId: 'tata',
      name: 'Tata Nexon',
      purchasePrice: 1200000,
      yearlyMaintenance: 30000,
      category: AssetCategory.vehicle,
      emoji: '🚙',
      minAge: 18,
      description: '5-star safety for your family.',
      rarity: AssetRarity.rare,
      statusBoost: 8,
      incomeRequired: 600000,
    ),
    GameAsset(
      id: 'hyundai_creta',
      brandId: 'hyundai',
      name: 'Hyundai Creta',
      purchasePrice: 1800000,
      yearlyMaintenance: 40000,
      category: AssetCategory.vehicle,
      emoji: '🚙',
      minAge: 18,
      description: 'The ultimate compact SUV.',
      rarity: AssetRarity.rare,
      statusBoost: 12,
      incomeRequired: 1000000,
    ),
    GameAsset(
      id: 'toyota_fortuner',
      brandId: 'toyota',
      name: 'Toyota Fortuner',
      purchasePrice: 4500000,
      yearlyMaintenance: 80000,
      category: AssetCategory.vehicle,
      emoji: '🚙',
      minAge: 21,
      description: 'The ultimate symbol of road presence and power.',
      rarity: AssetRarity.epic,
      statusBoost: 25,
      netWorthRequired: 10000000,
    ),
    GameAsset(
      id: 'bmw_3series',
      brandId: 'bmw_car',
      name: 'BMW 3 Series',
      purchasePrice: 6500000,
      yearlyMaintenance: 120000,
      category: AssetCategory.vehicle,
      emoji: '🏎️',
      minAge: 21,
      description: 'Entry into luxury driving.',
      rarity: AssetRarity.epic,
      statusBoost: 30,
      netWorthRequired: 20000000,
    ),
    GameAsset(
      id: 'mercedes_sclass',
      brandId: 'mercedes',
      name: 'Mercedes-Benz S-Class',
      purchasePrice: 18000000,
      yearlyMaintenance: 350000,
      category: AssetCategory.vehicle,
      emoji: '🏎️',
      minAge: 25,
      description: 'The epitome of automotive luxury.',
      rarity: AssetRarity.legendary,
      statusBoost: 50,
      netWorthRequired: 100000000, // 10 Cr
    ),

    // ── Properties (Dynamic based on wealth) ────────────────────────
    GameAsset(
      id: 'slum_hut',
      name: 'Slum Dwelling',
      purchasePrice: 200000,
      yearlyMaintenance: 5000,
      category: AssetCategory.property,
      emoji: '🏚️',
      minAge: 18,
      description: 'Basic shelter. Better than nothing.',
      rarity: AssetRarity.common,
    ),
    GameAsset(
      id: '1bhk_flat',
      name: '1BHK Apartment',
      purchasePrice: 4500000,
      yearlyMaintenance: 36000,
      category: AssetCategory.property,
      emoji: '🏢',
      minAge: 21,
      description: 'A cozy startup home in the suburbs.',
      rarity: AssetRarity.rare,
      statusBoost: 10,
    ),
    GameAsset(
      id: '2bhk_flat',
      name: '2BHK Premium Flat',
      purchasePrice: 8500000,
      yearlyMaintenance: 60000,
      category: AssetCategory.property,
      emoji: '🏠',
      minAge: 21,
      description: 'Perfect for a growing family in a prime location.',
      rarity: AssetRarity.rare,
      statusBoost: 15,
      netWorthRequired: 2000000,
    ),
    GameAsset(
      id: 'independent_villa',
      name: 'Independent Villa',
      purchasePrice: 25000000,
      yearlyMaintenance: 180000,
      category: AssetCategory.property,
      emoji: '🏰',
      minAge: 25,
      description: 'Luxury living with a private garden and space.',
      rarity: AssetRarity.epic,
      statusBoost: 35,
      netWorthRequired: 10000000,
    ),
    GameAsset(
      id: 'farmhouse',
      name: 'Goa Holiday Farmhouse',
      purchasePrice: 15000000,
      yearlyMaintenance: 120000,
      category: AssetCategory.property,
      emoji: '🌴',
      minAge: 25,
      description: 'Your dream getaway home near the beach.',
      rarity: AssetRarity.epic,
      statusBoost: 25,
      netWorthRequired: 20000000,
    ),
    GameAsset(
      id: 'luxury_penthouse',
      name: 'Mumbai Luxury Penthouse',
      purchasePrice: 85000000, // 8.5 Cr
      yearlyMaintenance: 600000,
      category: AssetCategory.property,
      emoji: '🏢',
      minAge: 25,
      description: 'A towering testament to your success.',
      rarity: AssetRarity.legendary,
      statusBoost: 80,
      netWorthRequired: 50000000, // 5 Cr
    ),
    
    // ── Jewelry ──────────────────────────────────────────
    GameAsset(
      id: 'gold_necklace',
      name: 'Gold Necklace Set',
      purchasePrice: 200000,
      yearlyMaintenance: 0,
      category: AssetCategory.jewelry,
      emoji: '📿',
      minAge: 18,
      description: '24K Gold set. Traditional and holds value well.',
      rarity: AssetRarity.rare,
      statusBoost: 10,
    ),
    GameAsset(
      id: 'diamond_ring',
      name: 'Solitaire Diamond Ring',
      purchasePrice: 500000,
      yearlyMaintenance: 0,
      category: AssetCategory.jewelry,
      emoji: '💍',
      minAge: 18,
      description: 'A pristine 2-carat diamond ring.',
      rarity: AssetRarity.epic,
      statusBoost: 20,
    ),
    GameAsset(
      id: 'rolex_watch',
      name: 'Luxury Swiss Watch',
      purchasePrice: 1200000,
      yearlyMaintenance: 5000,
      category: AssetCategory.jewelry,
      emoji: '⌚',
      minAge: 18,
      description: 'A symbol of precision and success.',
      rarity: AssetRarity.legendary,
      statusBoost: 30,
      netWorthRequired: 5000000,
    ),
  ];

  static GameAsset? findById(String id) {
    try {
      return marketplace.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<GameAsset> getByCategory(AssetCategory category) {
    return marketplace.where((a) => a.category == category).toList();
  }

  static List<GameAsset> getByBrand(String brandId) {
    return marketplace.where((a) => a.brandId == brandId).toList();
  }

  static Brand? getBrand(String brandId) {
    try {
      return brands.firstWhere((b) => b.id == brandId);
    } catch (_) {
      return null;
    }
  }

  static List<Brand> getBrandsByCategory(AssetCategory category) {
    return brands.where((b) => b.category == category).toList();
  }
}
