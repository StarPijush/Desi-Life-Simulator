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
  final StatEffect effectA;
  final StatEffect effectB;
  final String resultA;
  final String resultB;
  final Map<String, int>? traitShiftsA;
  final Map<String, int>? traitShiftsB;

  const EventChoice({
    required this.title,
    required this.description,
    required this.optionA,
    required this.optionB,
    required this.effectA,
    required this.effectB,
    required this.resultA,
    required this.resultB,
    this.traitShiftsA,
    this.traitShiftsB,
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
        'traitShiftsA': traitShiftsA,
        'traitShiftsB': traitShiftsB,
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
        traitShiftsA: map['traitShiftsA'] != null
            ? Map<String, int>.from(map['traitShiftsA'])
            : null,
        traitShiftsB: map['traitShiftsB'] != null
            ? Map<String, int>.from(map['traitShiftsB'])
            : null,
      );
}
