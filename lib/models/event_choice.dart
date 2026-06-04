// lib/models/event_choice.dart

class StatEffect {
  final int happiness;
  final int health;
  final int smarts;
  final int social;
  final int karma;
  final double money;

  const StatEffect({
    this.happiness = 0,
    this.health = 0,
    this.smarts = 0,
    this.social = 0,
    this.karma = 0,
    this.money = 0,
  });

  Map<String, dynamic> toMap() => {
        'happiness': happiness,
        'health': health,
        'smarts': smarts,
        'social': social,
        'karma': karma,
        'money': money,
      };

  factory StatEffect.fromMap(Map<String, dynamic> map) => StatEffect(
        happiness: map['happiness'] ?? 0,
        health: map['health'] ?? 0,
        smarts: map['smarts'] ?? 0,
        social: map['social'] ?? 0,
        karma: map['karma'] ?? 0,
        money: (map['money'] ?? 0).toDouble(),
      );
}

class EventChoice {
  final String title;
  final String description;
  final String optionA;
  final String optionB;
  
  // Success Outcomes
  final StatEffect effectA;
  final StatEffect effectB;
  final String resultA;
  final String resultB;

  // Failure Outcomes (Optional)
  final StatEffect? effectAFail;
  final StatEffect? effectBFail;
  final String? resultAFail;
  final String? resultBFail;

  // Probability and Flags
  final double successChanceA; // 0.0 to 1.0
  final double successChanceB; // 0.0 to 1.0
  final bool hiddenRiskA;
  final bool hiddenRiskB;
  final bool isTemptation;

  final String? gameActionA;
  final String? gameActionB;

  final Map<String, int>? traitShiftsA;
  final Map<String, int>? traitShiftsB;
  final String? memoryFlagA;
  final String? memoryFlagB;
  final String? memoryFlagAFail;
  final String? memoryFlagBFail;

  const EventChoice({
    required this.title,
    required this.description,
    required this.optionA,
    required this.optionB,
    required this.effectA,
    required this.effectB,
    required this.resultA,
    required this.resultB,
    this.effectAFail,
    this.effectBFail,
    this.resultAFail,
    this.resultBFail,
    this.successChanceA = 1.0,
    this.successChanceB = 1.0,
    this.hiddenRiskA = false,
    this.hiddenRiskB = false,
    this.isTemptation = false,
    this.traitShiftsA,
    this.traitShiftsB,
    this.memoryFlagA,
    this.memoryFlagB,
    this.memoryFlagAFail,
    this.memoryFlagBFail,
    this.gameActionA,
    this.gameActionB,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'optionA': optionA,
        'optionB': optionB,
        'effectA': effectA.toMap(),
        'effectB': effectB.toMap(),
        'resultA': resultA,
        'resultB': resultB,
        'effectAFail': effectAFail?.toMap(),
        'effectBFail': effectBFail?.toMap(),
        'resultAFail': resultAFail,
        'resultBFail': resultBFail,
        'successChanceA': successChanceA,
        'successChanceB': successChanceB,
        'hiddenRiskA': hiddenRiskA,
        'hiddenRiskB': hiddenRiskB,
        'isTemptation': isTemptation,
        'traitShiftsA': traitShiftsA,
        'traitShiftsB': traitShiftsB,
        'memoryFlagA': memoryFlagA,
        'memoryFlagB': memoryFlagB,
        'memoryFlagAFail': memoryFlagAFail,
        'memoryFlagBFail': memoryFlagBFail,
        'gameActionA': gameActionA,
        'gameActionB': gameActionB,
      };

  factory EventChoice.fromMap(Map<String, dynamic> map) => EventChoice(
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        optionA: map['optionA'] ?? '',
        optionB: map['optionB'] ?? '',
        effectA: StatEffect.fromMap(map['effectA'] ?? {}),
        effectB: StatEffect.fromMap(map['effectB'] ?? {}),
        resultA: map['resultA'] ?? '',
        resultB: map['resultB'] ?? '',
        effectAFail: map['effectAFail'] != null ? StatEffect.fromMap(map['effectAFail']) : null,
        effectBFail: map['effectBFail'] != null ? StatEffect.fromMap(map['effectBFail']) : null,
        resultAFail: map['resultAFail'],
        resultBFail: map['resultBFail'],
        successChanceA: (map['successChanceA'] ?? 1.0).toDouble(),
        successChanceB: (map['successChanceB'] ?? 1.0).toDouble(),
        hiddenRiskA: map['hiddenRiskA'] ?? false,
        hiddenRiskB: map['hiddenRiskB'] ?? false,
        isTemptation: map['isTemptation'] ?? false,
        traitShiftsA: map['traitShiftsA'] != null ? Map<String, int>.from(map['traitShiftsA']) : null,
        traitShiftsB: map['traitShiftsB'] != null ? Map<String, int>.from(map['traitShiftsB']) : null,
        memoryFlagA: map['memoryFlagA'],
        memoryFlagB: map['memoryFlagB'],
        memoryFlagAFail: map['memoryFlagAFail'],
        memoryFlagBFail: map['memoryFlagBFail'],
        gameActionA: map['gameActionA'],
        gameActionB: map['gameActionB'],
      );
}
