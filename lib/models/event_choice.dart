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
}
