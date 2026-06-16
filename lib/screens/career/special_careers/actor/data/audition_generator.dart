import 'dart:math';
import '../models/movie_audition.dart';

class AuditionGenerator {
  static final _random = Random();

  static const _genres = [
    'Sci-Fi', 'Romance', 'Adventure', 'Horror', 'Comedy', 
    'Crime', 'Historical', 'Cyberpunk', 'Mystery', 'Drama',
    'Action', 'Fantasy', 'Thriller'
  ];

  static const _productionHouses = [
    'Stellar Pictures', 'Dharma Productions', 'YRF', 
    'Red Chillies', 'Eros International', 'Phantom Films'
  ];

  static const _eliteProductionHouses = [
    'Global Studios', 'Prestige Films', 'Royal Motion Pictures',
    'Crown Entertainment', 'Diamond Productions',
  ];

  static const _emojiMap = {
    'Sci-Fi': '🚀', 'Romance': '❤️', 'Adventure': '🌳', 
    'Horror': '👻', 'Comedy': '☕', 'Crime': '💰', 
    'Historical': '🏛️', 'Cyberpunk': '🤖', 'Mystery': '🔍', 
    'Drama': '🏙️', 'Action': '💥', 'Fantasy': '✨', 'Thriller': '🔪'
  };

  static const _titlePrefixes = [
    'The', 'Dark', 'Silent', 'Golden', 'Broken', 'Hidden', 
    'Last', 'First', 'Eternal', 'Savage', 'Wild', 'Neon'
  ];

  static const _titleNouns = [
    'Heart', 'Secret', 'Haveli', 'Echoes', 'Soul', 'Script', 
    'Dreams', 'Horizon', 'Kings', 'Desert', 'Empire', 'River'
  ];

  /// Generate auditions scaled to the actor's stardom tier and agency
  static List<MovieAudition> generateAuditionsForYear(
    int year, {
    int count = 5,
    String stardomTier = 'Newcomer',
    double salaryMultiplier = 1.0,
  }) {
    return List.generate(count, (index) {
      final genre = _genres[_random.nextInt(_genres.length)];
      
      // Tier-gated role types
      final availableRoles = _rolesForTier(stardomTier);
      final roleType = availableRoles[_random.nextInt(availableRoles.length)];
      
      // Tier-gated production houses
      final availableHouses = _housesForTier(stardomTier);
      final productionHouse = availableHouses[_random.nextInt(availableHouses.length)];
      
      final prefix = _titlePrefixes[_random.nextInt(_titlePrefixes.length)];
      final noun = _titleNouns[_random.nextInt(_titleNouns.length)];
      final title = '$prefix $noun';
      
      // Tier-scaled budget and salary
      final budgetRange = _budgetRangeForTier(stardomTier);
      final budget = budgetRange[0] + _random.nextInt(budgetRange[1] - budgetRange[0] + 1);
      
      final salaryRange = _salaryRangeForTier(stardomTier);
      final baseSalary = salaryRange[0] + _random.nextInt(salaryRange[1] - salaryRange[0] + 1);
      final salary = (baseSalary * salaryMultiplier).toInt();

      final directors = _directorsForTier(stardomTier);
      final director = directors[_random.nextInt(directors.length)];

      const potentials = ['Low', 'Medium', 'High'];
      const risks = ['Low', 'Medium', 'High'];

      // Scale difficulty down for higher tiers (better casting access)
      final difficultyRange = _difficultyRangeForTier(stardomTier);
      final difficulty = difficultyRange[0] + _random.nextInt(difficultyRange[1] - difficultyRange[0] + 1);

      return MovieAudition(
        id: 'aud_${year}_$index',
        movieTitle: title,
        genre: genre,
        roleType: roleType,
        productionHouse: productionHouse,
        director: director,
        budget: budget,
        salary: salary,
        signingBonus: (salary * 0.1).toInt(),
        revenueShare: _random.nextInt(3) > 0 ? 0.0 : (_random.nextInt(5) / 100.0),
        contractDuration: 30 + _random.nextInt(90),
        difficulty: difficulty,
        requiredFame: _fameRequirementForTier(stardomTier),
        requiredActing: _random.nextInt(50),
        requiredReputation: _random.nextInt(40),
        requiredAge: 18 + _random.nextInt(10),
        fameGain: 5 + _random.nextInt(20),
        reputationGain: 2 + _random.nextInt(15),
        awardPotential: potentials[_random.nextInt(potentials.length)],
        riskLevel: risks[_random.nextInt(risks.length)],
        status: 'Casting Phase',
        year: year,
        iconEmoji: _emojiMap[genre] ?? '🎬',
      );
    });
  }

  // ── Tier-gated data ──────────────────────────────────────

  static List<String> _rolesForTier(String tier) {
    switch (tier) {
      case 'Legend':
        return ['Lead Role', 'Villain', 'Lead Role', 'Lead Role'];
      case 'Superstar':
        return ['Lead Role', 'Villain', 'Lead Role', 'Supporting Role'];
      case 'Star':
        return ['Lead Role', 'Supporting Role', 'Villain', 'Lead Role'];
      case 'Recognized Talent':
        return ['Lead Role', 'Supporting Role', 'Side Role', 'Villain'];
      case 'Working Actor':
        return ['Supporting Role', 'Side Role', 'Guest Appearance', 'Cameo'];
      default: // Newcomer
        return ['Side Role', 'Guest Appearance', 'Cameo', 'Supporting Role'];
    }
  }

  static List<String> _housesForTier(String tier) {
    switch (tier) {
      case 'Legend':
      case 'Superstar':
        return [..._productionHouses, ..._eliteProductionHouses];
      case 'Star':
        return [..._productionHouses, _eliteProductionHouses[0]];
      default:
        return _productionHouses;
    }
  }

  static List<int> _budgetRangeForTier(String tier) {
    switch (tier) {
      case 'Legend':
        return [500000000, 2000000000]; // 50Cr to 200Cr
      case 'Superstar':
        return [200000000, 1000000000]; // 20Cr to 100Cr
      case 'Star':
        return [100000000, 500000000]; // 10Cr to 50Cr
      case 'Recognized Talent':
        return [50000000, 200000000]; // 5Cr to 20Cr
      case 'Working Actor':
        return [20000000, 100000000]; // 2Cr to 10Cr
      default: // Newcomer
        return [10000000, 50000000]; // 1Cr to 5Cr
    }
  }

  static List<int> _salaryRangeForTier(String tier) {
    switch (tier) {
      case 'Legend':
        return [50000000, 200000000]; // 5Cr to 20Cr
      case 'Superstar':
        return [20000000, 100000000]; // 2Cr to 10Cr
      case 'Star':
        return [5000000, 30000000]; // 50L to 3Cr
      case 'Recognized Talent':
        return [2000000, 10000000]; // 20L to 1Cr
      case 'Working Actor':
        return [1000000, 5000000]; // 10L to 50L
      default: // Newcomer
        return [500000, 2000000]; // 5L to 20L
    }
  }

  static List<int> _difficultyRangeForTier(String tier) {
    switch (tier) {
      case 'Legend':
        return [10, 40]; // Easy access
      case 'Superstar':
        return [15, 50];
      case 'Star':
        return [20, 60];
      case 'Recognized Talent':
        return [25, 70];
      case 'Working Actor':
        return [30, 80];
      default: // Newcomer
        return [40, 100];
    }
  }

  static int _fameRequirementForTier(String tier) {
    switch (tier) {
      case 'Legend':
        return 0; // Legends get everything
      case 'Superstar':
        return 5;
      case 'Star':
        return 10;
      case 'Recognized Talent':
        return 15;
      case 'Working Actor':
        return 10;
      default: // Newcomer
        return 0;
    }
  }

  static List<String> _directorsForTier(String tier) {
    const standard = [
      'Advait Sharma', 'Rohit Shetty', 'Zoya Akhtar',
      'Karan Johar', 'Sanjay Leela', 'Anurag Kashyap'
    ];
    const elite = [
      'Rajkumar Hirani', 'Mani Ratnam', 'S.S. Rajamouli',
      'Imtiaz Ali', 'Vishal Bhardwaj'
    ];
    switch (tier) {
      case 'Legend':
      case 'Superstar':
        return [...standard, ...elite];
      case 'Star':
        return [...standard, elite[0], elite[1]];
      default:
        return standard;
    }
  }
}
