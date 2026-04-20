// lib/core/assets_data.dart

enum AssetCategory { vehicle, property, jewelry }

class GameAsset {
  final String id;
  final String name;
  final double purchasePrice;
  final double yearlyMaintenance;
  final AssetCategory category;
  final String emoji;
  final int minAge;
  final String description;

  const GameAsset({
    required this.id,
    required this.name,
    required this.purchasePrice,
    required this.yearlyMaintenance,
    required this.category,
    required this.emoji,
    required this.minAge,
    required this.description,
  });
}

class AssetsData {
  static const List<GameAsset> marketplace = [
    // ── Vehicles ──────────────────────────────────────────
    GameAsset(
      id: 'honda_activa',
      name: 'Honda Activa',
      purchasePrice: 85000,
      yearlyMaintenance: 5000,
      category: AssetCategory.vehicle,
      emoji: '🛵',
      minAge: 18,
      description: 'The classic Indian scooter. Reliable and efficient.',
    ),
    GameAsset(
      id: 'royal_enfield',
      name: 'Royal Enfield Classic 350',
      purchasePrice: 220000,
      yearlyMaintenance: 12000,
      category: AssetCategory.vehicle,
      emoji: '🏍️',
      minAge: 18,
      description: 'The thumping heartbeat of Indian roads.',
    ),
    GameAsset(
      id: 'maruti_swift',
      name: 'Maruti Swift',
      purchasePrice: 750000,
      yearlyMaintenance: 25000,
      category: AssetCategory.vehicle,
      emoji: '🚗',
      minAge: 18,
      description: 'The favorite family hatchback.',
    ),
    GameAsset(
      id: 'toyota_fortuner',
      name: 'Toyota Fortuner',
      purchasePrice: 4500000,
      yearlyMaintenance: 80000,
      category: AssetCategory.vehicle,
      emoji: '🚙',
      minAge: 18,
      description: 'The ultimate symbol of road presence and power.',
    ),

    // ── Properties ────────────────────────────────────────
    GameAsset(
      id: '1bhk_flat',
      name: '1BHK Apartment',
      purchasePrice: 4500000,
      yearlyMaintenance: 36000,
      category: AssetCategory.property,
      emoji: '🏢',
      minAge: 21,
      description: 'A cozy startup home in the suburbs.',
    ),
    GameAsset(
      id: '2bhk_flat',
      name: '2BHK Apartment',
      purchasePrice: 8500000,
      yearlyMaintenance: 60000,
      category: AssetCategory.property,
      emoji: '🏠',
      minAge: 21,
      description: 'Perfect for a growing family in a prime location.',
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
}
