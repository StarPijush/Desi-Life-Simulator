import 'dart:math';
import '../../../../../../models/character.dart';

enum AuditionDifficulty {
  easy,
  medium,
  hard,
  elite,
  legendary,
}

class AuditionEngine {
  /// Calculates the required score based on an int difficulty (0-100)
  static int getRequiredScore(int rawDifficulty) {
    if (rawDifficulty > 90) return 95; // Legendary
    if (rawDifficulty > 70) return 80; // Elite
    if (rawDifficulty > 50) return 60; // Hard
    if (rawDifficulty > 30) return 40; // Medium
    return 20; // Easy
  }

  /// Calculates the player's total acting score
  static int calculatePlayerScore(Character character) {
    final stats = character.actorStats;
    if (stats == null) return 0;

    final actingSkill = stats.actingSkill;
    final fame = stats.fame;
    final reputation = stats.reputation;
    final experience = stats.experience;

    final baseScore = (actingSkill * 0.45) + (fame * 0.25) + (reputation * 0.20) + (experience * 0.10);
    final luckBonus = Random().nextInt(16); // 0-15

    return (baseScore + luckBonus).round().clamp(0, 100);
  }

  /// Returns true if accepted
  static bool processAudition(Character character, int rawDifficulty) {
    final requiredScore = getRequiredScore(rawDifficulty);
    final playerScore = calculatePlayerScore(character);

    return playerScore >= requiredScore;
  }
}
