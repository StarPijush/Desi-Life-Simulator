import 'dart:math';
import '../models/tv_show_audition.dart';

class TVAuditionGenerator {
  static final _random = Random();

  static const _genres = [
    'Drama', 'Crime', 'Action', 'Comedy', 'Romance',
    'Fantasy', 'Mystery', 'Sci-Fi', 'Horror', 'Soap Opera',
    'Historical', 'Thriller', 'Reality Show', 'Cooking',
    'Medical', 'Legal', 'Family',
  ];

  static const _networks = [
    'Star Plus', 'Colors TV', 'Zee TV', 'Sony TV',
    'SAB TV', 'Netflix India', 'Amazon Prime', 'JioCinema',
    'Disney+ Hotstar', 'Voot',
  ];

  static const _emojiMap = {
    'Drama': '🎭', 'Crime': '🔫', 'Action': '🛡️', 'Comedy': '😂',
    'Romance': '💖', 'Fantasy': '🏰', 'Mystery': '📂', 'Sci-Fi': '🤖',
    'Horror': '🏚️', 'Soap Opera': '📺', 'Historical': '⚔️',
    'Thriller': '🔪', 'Reality Show': '🎤', 'Cooking': '🍳',
    'Medical': '🏥', 'Legal': '⚖️', 'Family': '👨‍👩‍👧‍👦',
  };

  static const _titlePrefixes = [
    'The', 'Dark', 'Secret', 'Golden', 'Broken', 'Hidden',
    'Last', 'Daily', 'Urban', 'Royal', 'Modern', 'Neon',
    'Mumbai', 'Delhi', 'Desi', 'Indian',
  ];

  static const _titleNouns = [
    'Pulse', 'Kitchen', 'Files', 'Stand', 'Bones', 'Quest',
    'Legends', 'Soap', 'Dynasty', 'Hearts', 'Network', 'Secrets',
    'Street', 'Detectives', 'Family', 'Dreams',
  ];

  static const _eliteNetworks = [
    'Netflix Global', 'Amazon Prime Global', 'HBO Max', 'Apple TV+'
  ];

  /// Generate TV auditions scaled to the actor's stardom tier and agency
  static List<TVShowAudition> generateAuditionsForYear(
    int year, {
    int count = 10,
    String stardomTier = 'Newcomer',
    double salaryMultiplier = 1.0,
  }) {
    final usedTitles = <String>{};

    return List.generate(count, (index) {
      final genre = _genres[_random.nextInt(_genres.length)];
      
      final availableRoles = _rolesForTier(stardomTier);
      final roleType = availableRoles[_random.nextInt(availableRoles.length)];
      
      final availableNetworks = _networksForTier(stardomTier);
      final network = availableNetworks[_random.nextInt(availableNetworks.length)];

      String title;
      do {
        final prefix = _titlePrefixes[_random.nextInt(_titlePrefixes.length)];
        final noun = _titleNouns[_random.nextInt(_titleNouns.length)];
        title = '$prefix $noun';
      } while (usedTitles.contains(title));
      usedTitles.add(title);

      final salaryRange = _salaryRangeForTier(stardomTier);
      final baseSalary = salaryRange[0] + _random.nextInt(salaryRange[1] - salaryRange[0] + 1);
      final salary = (baseSalary * salaryMultiplier).toInt();

      final difficultyRange = _difficultyRangeForTier(stardomTier);
      final difficulty = difficultyRange[0] + _random.nextInt(difficultyRange[1] - difficultyRange[0] + 1);

      return TVShowAudition(
        id: 'tv_aud_${year}_$index',
        showTitle: title,
        genre: genre,
        roleType: roleType,
        network: network,
        episodes: 10 + _random.nextInt(41), // 10–50 episodes
        seasonNumber: 1 + _random.nextInt(5),
        salaryPerEpisode: salary,
        difficulty: difficulty,
        requiredFame: _fameRequirementForTier(stardomTier),
        requiredActing: _random.nextInt(50),
        year: year,
        iconEmoji: _emojiMap[genre] ?? '📺',
      );
    });
  }

  // ── Tier-gated data ──────────────────────────────────────

  static List<String> _rolesForTier(String tier) {
    switch (tier) {
      case 'Legend':
      case 'Superstar':
      case 'Star':
        return ['Lead Role', 'Recurring Character', 'Lead Role', 'Villain'];
      case 'Recognized Talent':
        return ['Lead Role', 'Supporting Role', 'Recurring Character', 'Villain'];
      case 'Working Actor':
        return ['Supporting Role', 'Side Role', 'Recurring Character', 'Guest Appearance'];
      default: // Newcomer
        return ['Side Role', 'Guest Appearance', 'Supporting Role'];
    }
  }

  static List<String> _networksForTier(String tier) {
    switch (tier) {
      case 'Legend':
      case 'Superstar':
        return [..._networks, ..._eliteNetworks];
      case 'Star':
        return [..._networks, _eliteNetworks[0], _eliteNetworks[1]];
      default:
        return _networks;
    }
  }

  static List<int> _salaryRangeForTier(String tier) {
    switch (tier) {
      case 'Legend':
        return [5000000, 20000000]; // 50L to 2Cr per episode
      case 'Superstar':
        return [2000000, 10000000]; // 20L to 1Cr
      case 'Star':
        return [500000, 3000000]; // 5L to 30L
      case 'Recognized Talent':
        return [200000, 1000000]; // 2L to 10L
      case 'Working Actor':
        return [100000, 500000]; // 1L to 5L
      default: // Newcomer
        return [25000, 100000]; // 25K to 1L
    }
  }

  static List<int> _difficultyRangeForTier(String tier) {
    switch (tier) {
      case 'Legend': return [10, 30];
      case 'Superstar': return [15, 40];
      case 'Star': return [20, 50];
      case 'Recognized Talent': return [25, 60];
      case 'Working Actor': return [30, 80];
      default: return [40, 100];
    }
  }

  static int _fameRequirementForTier(String tier) {
    switch (tier) {
      case 'Legend': return 0;
      case 'Superstar': return 10;
      case 'Star': return 15;
      case 'Recognized Talent': return 20;
      case 'Working Actor': return 15;
      default: return 0;
    }
  }
}
