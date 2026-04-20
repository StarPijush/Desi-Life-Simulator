import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/life_event.dart';
import '../models/relationship.dart';
import '../models/event_choice.dart';
import 'storage.dart';
import 'assets_data.dart';
import 'investments_data.dart';
import 'event_data.dart';
import 'enums.dart';

// Top-level worker for Isolate/Compute
// Using Map for strict serializable data crossing the isolate boundary
Map<String, dynamic> simulateAgeUp(Map<String, dynamic> characterJson) {
  final character = Character.fromJson(characterJson);
  final result = GameEngine.ageUp(character);
  return result.toJson();
}
const bool enableChaos = true;
const bool enableMomentum = true;
const bool enableRecovery = true;
const bool enableLogging = true;

// ── Age Up Result ─────────────────────────────────────────────────────────────
class AgeUpResult {
  final List<LifeEvent> events;
  final Map<String, int> statChanges;
  final bool triggeredChaos;
  final bool died;
  final List<String> newAchievements;
  final List<String> personalityFeedback;
  final Character character;
  final int sourceVersion;

  const AgeUpResult({
    required this.events,
    required this.statChanges,
    required this.character,
    required this.sourceVersion,
    this.triggeredChaos = false,
    this.died = false,
    this.newAchievements = const [],
    this.personalityFeedback = const [],
  });

  Map<String, dynamic> toJson() => {
        'events': events.map((e) => e.toJson()).toList(),
        'statChanges': statChanges,
        'triggeredChaos': triggeredChaos,
        'died': died,
        'newAchievements': newAchievements,
        'personalityFeedback': personalityFeedback,
        'character': character.toJson(),
        'sourceVersion': sourceVersion,
      };

  factory AgeUpResult.fromJson(Map<String, dynamic> json) => AgeUpResult(
        events: List<LifeEvent>.from((json['events'] as List).map((e) => LifeEvent.fromJson(e))),
        statChanges: Map<String, int>.from(json['statChanges']),
        triggeredChaos: json['triggeredChaos'] ?? false,
        died: json['died'] ?? false,
        newAchievements: List<String>.from(json['newAchievements'] ?? []),
        personalityFeedback: List<String>.from(json['personalityFeedback'] ?? []),
        character: Character.fromJson(json['character']),
        sourceVersion: json['sourceVersion'] as int? ?? 0,
      );
}

// ── Career Switch Offer ───────────────────────────────────────────────────────
class CareerSwitchOffer {
  final CareerGroup optionA;
  final CareerGroup optionB;
  const CareerSwitchOffer({required this.optionA, required this.optionB});
}

// ── Career Step (a single rung on the ladder) ─────────────────────────────────
class CareerStep {
  final String title;
  final double annualSalary;
  final int smartsToReach; // min smarts to be promoted TO this level
  final int minYearsToPromote; // min years in this role before promotion eligible
  final String emoji;

  const CareerStep({
    required this.title,
    required this.annualSalary,
    required this.emoji,
    this.smartsToReach = 0,
    this.minYearsToPromote = 1,
  });
}

// ── Career Tier (Category of work) ───────────────────────────────────────────
enum CareerTier {
  partTime,
  fullTime,
  freelance,
  special
}

// ── Career Group (a full path with hierarchy) ─────────────────────────────────
class CareerGroup {
  final String name;
  final String emoji;
  final String description;
  final int smartsToEnter;
  final String eduToEnter; // 'None', 'Secondary', 'Graduate', 'Higher Secondary'
  final List<CareerStep> steps;
  final CareerTier tier;

  const CareerGroup({
    required this.name,
    required this.emoji,
    required this.description,
    required this.smartsToEnter,
    required this.eduToEnter,
    required this.steps,
    this.tier = CareerTier.fullTime,
  });

  CareerStep get topStep => steps.last;
  bool get isFinalStep => false;
}

// ── Career System ─────────────────────────────────────────────────────────────
class CareerSystem {
  static const List<CareerGroup> allGroups = [
    CareerGroup(
      name: 'Tech',
      emoji: '💻',
      description: 'Software & Technology',
      smartsToEnter: 50,
      eduToEnter: 'Graduate',
      steps: [
        CareerStep(
            title: 'IT Intern',
            annualSalary: 144000,
            smartsToReach: 50,
            minYearsToPromote: 1,
            emoji: '🖥️'),
        CareerStep(
            title: 'Junior Developer',
            annualSalary: 360000,
            smartsToReach: 58,
            minYearsToPromote: 2,
            emoji: '👨‍💻'),
        CareerStep(
            title: 'Software Developer',
            annualSalary: 720000,
            smartsToReach: 65,
            minYearsToPromote: 3,
            emoji: '💻'),
        CareerStep(
            title: 'Senior Developer',
            annualSalary: 1440000,
            smartsToReach: 75,
            minYearsToPromote: 3,
            emoji: '🧑‍💻'),
        CareerStep(
            title: 'Tech Lead',
            annualSalary: 2400000,
            smartsToReach: 82,
            minYearsToPromote: 4,
            emoji: '🏗️'),
        CareerStep(
            title: 'CTO',
            annualSalary: 4800000,
            smartsToReach: 90,
            minYearsToPromote: 5,
            emoji: '⭐'),
      ],
    ),
    CareerGroup(
      name: 'Government',
      emoji: '🏛️',
      description: 'Civil Services & Government',
      smartsToEnter: 35,
      eduToEnter: 'Secondary',
      steps: [
        CareerStep(
            title: 'Government Peon',
            annualSalary: 120000,
            smartsToReach: 35,
            minYearsToPromote: 2,
            emoji: '📋'),
        CareerStep(
            title: 'Government Clerk',
            annualSalary: 300000,
            smartsToReach: 45,
            minYearsToPromote: 3,
            emoji: '🗂️'),
        CareerStep(
            title: 'Government Officer',
            annualSalary: 540000,
            smartsToReach: 58,
            minYearsToPromote: 4,
            emoji: '🏢'),
        CareerStep(
            title: 'Senior Officer',
            annualSalary: 840000,
            smartsToReach: 68,
            minYearsToPromote: 4,
            emoji: '🎖️'),
        CareerStep(
            title: 'IAS Officer',
            annualSalary: 1500000,
            smartsToReach: 80,
            minYearsToPromote: 5,
            emoji: '🏛️'),
        CareerStep(
            title: 'Chief Secretary',
            annualSalary: 2500000,
            smartsToReach: 88,
            minYearsToPromote: 6,
            emoji: '🌟'),
      ],
    ),
    CareerGroup(
      name: 'Corporate',
      emoji: '📊',
      description: 'Business & Management',
      smartsToEnter: 40,
      eduToEnter: 'Graduate',
      steps: [
        CareerStep(
            title: 'Corporate Trainee',
            annualSalary: 240000,
            smartsToReach: 40,
            minYearsToPromote: 1,
            emoji: '🧑‍💼'),
        CareerStep(
            title: 'Executive',
            annualSalary: 480000,
            smartsToReach: 50,
            minYearsToPromote: 2,
            emoji: '👔'),
        CareerStep(
            title: 'Manager',
            annualSalary: 840000,
            smartsToReach: 60,
            minYearsToPromote: 3,
            emoji: '📁'),
        CareerStep(
            title: 'Senior Manager',
            annualSalary: 1440000,
            smartsToReach: 68,
            minYearsToPromote: 3,
            emoji: '📈'),
        CareerStep(
            title: 'Director',
            annualSalary: 2400000,
            smartsToReach: 76,
            minYearsToPromote: 4,
            emoji: '🏆'),
        CareerStep(
            title: 'CEO',
            annualSalary: 6000000,
            smartsToReach: 85,
            minYearsToPromote: 5,
            emoji: '👑'),
      ],
    ),
    CareerGroup(
      name: 'Medical',
      emoji: '🩺',
      description: 'Healthcare & Medicine',
      smartsToEnter: 75,
      eduToEnter: 'Graduate',
      steps: [
        CareerStep(
            title: 'Medical Intern',
            annualSalary: 300000,
            smartsToReach: 75,
            minYearsToPromote: 2,
            emoji: '🏥'),
        CareerStep(
            title: 'Junior Doctor',
            annualSalary: 600000,
            smartsToReach: 78,
            minYearsToPromote: 2,
            emoji: '🩺'),
        CareerStep(
            title: 'Doctor',
            annualSalary: 1200000,
            smartsToReach: 82,
            minYearsToPromote: 3,
            emoji: '👨‍⚕️'),
        CareerStep(
            title: 'Senior Doctor',
            annualSalary: 2000000,
            smartsToReach: 86,
            minYearsToPromote: 4,
            emoji: '🔬'),
        CareerStep(
            title: 'Head of Department',
            annualSalary: 3600000,
            smartsToReach: 90,
            minYearsToPromote: 5,
            emoji: '🏆'),
        CareerStep(
            title: 'Chief Medical Officer',
            annualSalary: 6000000,
            smartsToReach: 94,
            minYearsToPromote: 5,
            emoji: '⭐'),
      ],
    ),
    CareerGroup(
      name: 'Business',
      emoji: '🏪',
      description: 'Entrepreneurship & Trade',
      smartsToEnter: 20,
      eduToEnter: 'None',
      steps: [
        CareerStep(
            title: 'Street Hawker',
            annualSalary: 96000,
            smartsToReach: 20,
            minYearsToPromote: 2,
            emoji: '🛒'),
        CareerStep(
            title: 'Shopkeeper',
            annualSalary: 240000,
            smartsToReach: 30,
            minYearsToPromote: 2,
            emoji: '🏪'),
        CareerStep(
            title: 'Small Business Owner',
            annualSalary: 600000,
            smartsToReach: 42,
            minYearsToPromote: 3,
            emoji: '🏬'),
        CareerStep(
            title: 'Business Owner',
            annualSalary: 1500000,
            smartsToReach: 55,
            minYearsToPromote: 3,
            emoji: '🏢'),
        CareerStep(
            title: 'Entrepreneur',
            annualSalary: 3000000,
            smartsToReach: 65,
            minYearsToPromote: 4,
            emoji: '🚀'),
        CareerStep(
            title: 'Business Tycoon',
            annualSalary: 10000000,
            smartsToReach: 80,
            minYearsToPromote: 5,
            emoji: '💎'),
      ],
    ),
    CareerGroup(
      name: 'Arts',
      emoji: '🎨',
      description: 'Creative & Entertainment',
      smartsToEnter: 25,
      eduToEnter: 'None',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Freelancer',
            annualSalary: 144000,
            smartsToReach: 25,
            minYearsToPromote: 1,
            emoji: '🎨'),
        CareerStep(
            title: 'Content Creator',
            annualSalary: 300000,
            smartsToReach: 35,
            minYearsToPromote: 2,
            emoji: '📱'),
        CareerStep(
            title: 'Influencer',
            annualSalary: 720000,
            smartsToReach: 42,
            minYearsToPromote: 2,
            emoji: '📸'),
        CareerStep(
            title: 'Artist / Director',
            annualSalary: 1500000,
            smartsToReach: 52,
            minYearsToPromote: 3,
            emoji: '🎬'),
        CareerStep(
            title: 'Celebrity',
            annualSalary: 3600000,
            smartsToReach: 60,
            minYearsToPromote: 4,
            emoji: '🌟'),
        CareerStep(
            title: 'Superstar',
            annualSalary: 12000000,
            smartsToReach: 68,
            minYearsToPromote: 5,
            emoji: '🏆'),
      ],
    ),
    CareerGroup(
      name: 'Part-Time',
      emoji: '🚲',
      description: 'Short-term earning for teens',
      smartsToEnter: 20,
      eduToEnter: 'Secondary',
      tier: CareerTier.partTime,
      steps: [
        CareerStep(
            title: 'Delivery Rider',
            annualSalary: 84000,
            smartsToReach: 20,
            minYearsToPromote: 1,
            emoji: '🚲'),
        CareerStep(
            title: 'Store Assistant',
            annualSalary: 120000,
            smartsToReach: 30,
            minYearsToPromote: 1,
            emoji: '🏪'),
      ],
    ),
    CareerGroup(
      name: 'Freelancing',
      emoji: '👩‍💻',
      description: 'Project-based professional work',
      smartsToEnter: 60,
      eduToEnter: 'Higher Secondary',
      tier: CareerTier.freelance,
      steps: [
        CareerStep(
            title: 'Gig Worker',
            annualSalary: 240000,
            smartsToReach: 60,
            minYearsToPromote: 1,
            emoji: '💻'),
        CareerStep(
            title: 'Expert consultant',
            annualSalary: 1200000,
            smartsToReach: 80,
            minYearsToPromote: 3,
            emoji: '🧠'),
      ],
    ),
  ];

  static CareerGroup? findGroup(String name) {
    try {
      return allGroups.firstWhere((g) => g.name == name);
    } catch (_) {
      return null;
    }
  }

  static bool canEnter(CareerGroup group, Character c) {
    return c.smarts >= group.smartsToEnter &&
        _eduLevel(c.educationLevel) >= _eduLevel(group.eduToEnter);
  }

  static List<CareerGroup> eligibleGroups(Character c, {CareerTier? tier}) {
    return allGroups.where((g) {
      final matchesTier = tier == null || g.tier == tier;
      return matchesTier && canEnter(g, c);
    }).toList();
  }

  static List<CareerGroup> alternativeGroups(Character c, {CareerTier? tier}) {
    final current = c.careerGroup;
    final eligible = eligibleGroups(c, tier: tier).where((g) => g.name != current).toList();
    eligible.sort(
        (a, b) => b.topStep.annualSalary.compareTo(a.topStep.annualSalary));
    return eligible;
  }

  static CareerGroup bestMatchGroup(Character c) {
    final eligible = eligibleGroups(c);
    if (eligible.isEmpty) return allGroups.last;
    eligible.sort(
        (a, b) => b.topStep.annualSalary.compareTo(a.topStep.annualSalary));
    return eligible.first;
  }

  static int _eduLevel(String edu) {
    switch (edu) {
      case 'Postgraduate':
        return 5;
      case 'Graduate':
        return 4;
      case 'Higher Secondary':
        return 3;
      case 'Secondary':
        return 2;
      case 'Primary':
        return 1;
      default:
        return 0;
    }
  }

  static void assignCareer(Character c, CareerGroup group) {
    c.careerGroup = group.name;
    c.careerStep = 0;
    c.yearsInRole = 0;
    final step = group.steps.first;
    c.jobTitle = step.title;
    c.annualIncome = step.annualSalary;
  }

  static String switchCareer(Character c, CareerGroup newGroup) {
    assignCareer(c, newGroup);
    c.smarts = (c.smarts - 5).clamp(0, 100);
    c.happiness = (c.happiness + 10).clamp(0, 100);
    return '🔄 Career Switch! You left your old career and joined ${newGroup.name} as a ${newGroup.steps.first.title}. Salary: ₹${GameEngine.formatMoney(newGroup.steps.first.annualSalary)}/yr';
  }

  static String? tryPromotion(Character c, Random rng) {
    final group = findGroup(c.careerGroup);
    if (group == null || c.careerGroup == 'None') return null;

    final currentStepIdx = c.careerStep;
    if (currentStepIdx >= group.steps.length - 1) return null;

    final currentStep = group.steps[currentStepIdx];
    final nextStep = group.steps[currentStepIdx + 1];

    if (c.yearsInRole < currentStep.minYearsToPromote) return null;
    if (c.smarts < nextStep.smartsToReach) return null;

    final score = (c.smarts * 0.6 + c.happiness * 0.4) / 100.0;
    double chance = 0.08 + score * 0.37;

    // Apply identity modifier (e.g. Unstoppable Force bonus)
    chance *= (c.hiddenModifiers['promotionChance'] ?? 1.0);

    final roll = rng.nextDouble();
    if (roll > chance) {
      // 🎯 NEAR-MISS SYSTEM: Failed by less than 5%
      if (roll - chance < 0.05) {
        c.tensionSignals.add('📉 "You were so close to that promotion," rumors whisper. "Just one more push."');
        c.updateStats(happinessDelta: -5); // Small frustration penalty
      }
      return null;
    }

    c.careerStep = currentStepIdx + 1;
    c.yearsInRole = 0;
    c.jobTitle = nextStep.title;

    c.annualIncome = nextStep.annualSalary;
    c.happiness = (c.happiness + 8).clamp(0, 100);

    if (nextStep.title == 'IAS Officer') c.addAchievement('ias_officer');
    if (nextStep.title == 'Business Tycoon') c.addAchievement('entrepreneur');
    if (nextStep.title == 'Doctor') c.addAchievement('doctor');

    if (c.careerStep == group.steps.length - 1) {
      return '🎉 PINNACLE! ${nextStep.emoji} You reached the top of your career — ${nextStep.title}! Salary: ₹${GameEngine.formatMoney(nextStep.annualSalary)}/yr! 🚀';
    }
    return '📈 PROMOTED! ${nextStep.emoji} You are now a ${nextStep.title}. New salary: ₹${GameEngine.formatMoney(nextStep.annualSalary)}/yr!';
  }

  static String? tryJobLoss(Character c, Random rng) {
    if (c.careerGroup == 'None' || c.annualIncome == 0) return null;
    if (c.age < 22) return null;

    final riskScore =
        ((30 - c.smarts).clamp(0, 30) + (20 - c.happiness).clamp(0, 20)) / 50.0;
    if (riskScore <= 0) return null;
    if (rng.nextDouble() > riskScore * 0.15) return null;

    c.jobTitle = 'Unemployed';
    c.annualIncome = 0;
    c.careerGroup = 'None';
    c.careerStep = 0;
    c.yearsInRole = 0;
    c.happiness = (c.happiness - 15).clamp(0, 100);
    return '😢 You were fired due to poor performance. You are now Unemployed.';
  }
}

// ── Achievement ────────────────────────────────────────────────────────────────
class Achievement {
  final String id;
  final String title;
  final String emoji;
  final String description;
  const Achievement(
      {required this.id,
      required this.title,
      required this.emoji,
      required this.description});
}

class Achievements {
  static const all = [
    Achievement(
        id: 'crorepati',
        title: 'Crorepati',
        emoji: '💰',
        description: 'Accumulated ₹1 Crore'),
    Achievement(
        id: 'lakhpati',
        title: 'Lakhpati',
        emoji: '💵',
        description: 'Accumulated ₹10 Lakh'),
    Achievement(
        id: 'doctor',
        title: 'Doctor',
        emoji: '🩺',
        description: 'Became a Doctor'),
    Achievement(
        id: 'ias_officer',
        title: 'IAS Officer',
        emoji: '🏛️',
        description: 'Became an IAS Officer'),
    Achievement(
        id: 'entrepreneur',
        title: 'Entrepreneur',
        emoji: '🚀',
        description: 'Reached the top of Business'),
    Achievement(
        id: 'saintly',
        title: 'Saintly Soul',
        emoji: '😇',
        description: 'Reached 90+ Karma'),
    Achievement(
        id: 'health_king',
        title: 'Health King',
        emoji: '💪',
        description: 'Maintained 90+ Health for 10 years'),
    Achievement(
        id: 'genius',
        title: 'Genius',
        emoji: '🧠',
        description: 'Reached 95+ Smarts'),
    Achievement(
        id: 'social_butterfly',
        title: 'Social Butterfly',
        emoji: '🦋',
        description: 'Reached 95+ Social'),
    Achievement(
        id: 'old_soul',
        title: 'Elder',
        emoji: '👴',
        description: 'Lived past age 90'),
    Achievement(
        id: 'viral_fame',
        title: 'Internet Famous',
        emoji: '🌟',
        description: 'Went viral online'),
    Achievement(
        id: 'lottery',
        title: 'Lucky Star',
        emoji: '🎰',
        description: 'Won a major lottery prize'),
    Achievement(
        id: 'postgrad',
        title: 'Scholar',
        emoji: '🎓',
        description: 'Completed Postgraduate studies'),
    Achievement(
        id: 'long_life',
        title: 'Centenarian',
        emoji: '🕯️',
        description: 'Reached age 100'),
    Achievement(
        id: 'cto',
        title: 'CTO',
        emoji: '⭐',
        description: 'Became a Chief Technology Officer'),
    Achievement(
        id: 'ceo',
        title: 'CEO',
        emoji: '👑',
        description: 'Became a Chief Executive Officer'),
    Achievement(
        id: 'superstar',
        title: 'Superstar',
        emoji: '🎬',
        description: 'Became a Superstar in Arts'),
  ];

  static Achievement? find(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ── Main Game Engine ──────────────────────────────────────────────────────────
class GameEngine {
  static final Random _rng = Random();
  static const int _rareEventFrequency = 20;

  // ── formatMoney cache — avoids repeated string formatting for the same value
  static final _moneyCache = <double, String>{};
  static const int _moneyCacheMax = 64;

  static String formatMoney(double n) {
    final cached = _moneyCache[n];
    if (cached != null) return cached;

    final String result;
    if (n >= 10000000) {
      result = '${(n / 10000000).toStringAsFixed(1)}Cr';
    } else if (n >= 100000) {
      result = '${(n / 100000).toStringAsFixed(1)}L';
    } else if (n >= 1000) {
      result = '${(n / 1000).toStringAsFixed(0)}K';
    } else {
      result = n.toStringAsFixed(0);
    }

    // Evict oldest entries to bound cache size
    if (_moneyCache.length >= _moneyCacheMax) {
      _moneyCache.remove(_moneyCache.keys.first);
    }
    _moneyCache[n] = result;
    return result;
  }

  static void _addEvent(List<LifeEvent> list, int age, String title,
      {String description = '',
      LifeEventType type = LifeEventType.neutral,
      EventPriority priority = EventPriority.normal,
      Map<String, int> statChanges = const {},
      Map<String, dynamic> metadata = const {}}) {
    list.add(LifeEvent(
      title: title,
      description: description,
      type: type,
      priority: priority,
      statChanges: statChanges,
      metadata: {...metadata, 'age': age},
    ));
  }


  // ── Identity title cache — key is a fingerprint of the relevant stats
  static String? _cachedIdentityTitle;
  static int _cachedIdentityKey = 0;

  static String getIdentityTitle(Character c) {
    // Build a cheap fingerprint from the stats that influence the title
    final key = c.happiness * 1000000 +
        (c.bankBalance ~/ 100000) * 10000 +
        c.smarts * 100 +
        c.health +
        c.karma;

    if (key == _cachedIdentityKey && _cachedIdentityTitle != null) {
      return _cachedIdentityTitle!;
    }

    final String title;
    if (c.happiness < 20) {
      title = 'Broken Soul';
    } else if (c.bankBalance > 10000000) {
      title = 'Crorepati Tycoon';
    } else if (c.bankBalance > 1000000) {
      title = 'Wealthy Investor';
    } else if (c.careerGroup == 'Tech' && c.smarts > 80) {
      title = 'Tech Visionary';
    } else if (c.careerGroup == 'Finance' && c.bankBalance > 500000) {
      title = 'Wolf of Dalal Street';
    } else if (c.jobTitle.contains('Founder') || c.jobTitle.contains('CEO')) {
      title = 'Rising Entrepreneur';
    } else if (c.age < 22 && c.smarts > 85) {
      title = 'Scholar Prodigy';
    } else if (c.age < 22 && c.smarts < 40) {
      title = 'Struggling Backbencher';
    } else if (c.happiness > 85 && c.social > 80) {
      title = 'Life of the Party';
    } else if (c.health < 30) {
      title = 'Fragile Survivor';
    } else if (c.karma > 80) {
      title = 'Saint of India';
    } else if (c.karma < 20) {
      title = 'Shadow Figure';
    } else if (c.age < 13) {
      title = 'Innocent Dreamer';
    } else {
      title = 'Ordinary Citizen';
    }

    _cachedIdentityKey = key;
    _cachedIdentityTitle = title;
    return title;
  }

  static AgeUpResult ageUp(Character character) {
    final int sourceVersion = character.stateVersion;
    final oldStats = {
      'happiness': character.happiness,
      'health': character.health,
      'smarts': character.smarts,
      'social': character.social,
      'karma': character.karma,
      'money': character.bankBalance,
    };

    if (enableLogging) {
      debugPrint("[AGE UP] Starting age up for ${character.name} to age ${character.age + 1}");
    }

    character.age += 1;
    character.yearsInRole += 1;
    final List<LifeEvent> events = [];
    final List<String> newAchievements = [];
    bool triggeredChaos = false;

    _processEventChains(character, events);

    if (enableChaos) {
      triggeredChaos = _applyChaosAndHighStakes(character, events, newAchievements);
    }

    _applyEducationProgression(character, events);
    _updateMarketPrices(character, []);
    _applyCareerProgression(character, events, newAchievements);
    _applyFinancialsSilent(character, events);
    _applyNaturalAging(character);

    if (enableRecovery) {
      _applyRecoverySystem(character, events);
    }

    if (_rng.nextDouble() < 0.15) {
      _applySocialComparison(character, events);
    }

    _applyRelationshipDynamicsSilent(character, []);

    final deltas = {
      'happiness': character.happiness - (oldStats['happiness'] as int),
      'health': character.health - (oldStats['health'] as int),
      'smarts': character.smarts - (oldStats['smarts'] as int),
      'social': character.social - (oldStats['social'] as int),
      'karma': character.karma - (oldStats['karma'] as int),
      'money': (character.bankBalance - (oldStats['money'] as double)).round(),
    };

    if (enableMomentum) {
      _updateMomentum(character, deltas);
    }

    // ── NARRATIVE & SMART EVENTS ───────────────────────────────────────────
    final narrativeCount = (events.isEmpty) ? (_rng.nextInt(2) + 2) : 1;
    final smartPool = _pickSmartEvents(character, count: narrativeCount);
    events.addAll(smartPool);

    // ── AUTO-DECISIONS (Consequences of Neglect) ────────────────────────────
    _applyAutoDecisions(character, events);

    if (_rng.nextInt(_rareEventFrequency) == 0) {
      final rareEvent = _triggerRareEvent(character, newAchievements);
      if (rareEvent != null) {
        events.insert(0, LifeEvent(
          title: rareEvent,
          description: 'A life-changing occurrence.',
          type: LifeEventType.rare,
          priority: EventPriority.rare,
          metadata: {'age': character.age},
        ));
      }
    }

    // 10. Stat Nudges (Silent)
    _applyPassiveStatNudge(character, 2);

    // 11. Add Teaser Hooks (Psychological Hook System)
    if (_rng.nextDouble() < 0.4) {
      final hook = _getTeaserHook(character);
      events.add(LifeEvent(
        title: hook,
        description: '',
        type: LifeEventType.neutral,
        priority: EventPriority.normal,
        metadata: {'age': character.age},
      ));
    }

    // 10. Achievement & Death checks
    _checkAchievements(character, newAchievements);

    // ── IDENTITY STABILITY & FEEDBACK ───────────────────────
    final List<String> personalityFeedback = [];
    final currentIdentity = character.activeDominantTrait;
    final potentialIdentity = character.dominantTrait;
    final currentScore = character.personalityScores[currentIdentity] ?? 0;
    final potentialScore = character.personalityScores[potentialIdentity] ?? 0;

    // Hysteresis: Only shift if difference > 10 and at least 3 years passed
    if (potentialIdentity != currentIdentity && 
        potentialScore > currentScore + 10 && 
        (character.age - character.lastTraitShiftAge) >= 3) {
      
      character.activeDominantTrait = potentialIdentity;
      character.personality = potentialIdentity;
      character.lastTraitShiftAge = character.age;
      personalityFeedback.add('🌟 IDENTITY SHIFT: Your personality has solidified as $potentialIdentity.');
    }

    // Conflict System: Detect opposing high-intensity traits
    _detectPersonalityConflicts(character, personalityFeedback);

    // Momentum State Feedback
    if (character.momentumState != 'Steady') {
      personalityFeedback.add('💫 STATE: You are in a ${character.momentumState}.');
    }

    // Identity Phase & Breaking Points
    _updateIdentityPhase(character, personalityFeedback);
    _checkBreakingPoints(character, events, personalityFeedback);

    // ── NEW ENGAGEMENT SYSTEMS ──
    _updateRivals(character, events, personalityFeedback);
    _processRegrets(character, events, personalityFeedback);
    _generateTensionSignals(character);

    if (character.isDead) {
      if (enableLogging) debugPrint("[AGE UP] Character DIED at age ${character.age}");
      return AgeUpResult(
        events: events,
        statChanges: deltas,
        died: true,
        character: character,
        sourceVersion: sourceVersion,
        newAchievements: newAchievements,
        personalityFeedback: personalityFeedback,
      );
    }

    if (enableLogging) {
      debugPrint("[AGE UP] Generated ${events.length} events. Chaos: $triggeredChaos");
    }

    return AgeUpResult(
      events: events,
      statChanges: deltas,
      character: character,
      sourceVersion: sourceVersion,
      triggeredChaos: triggeredChaos,
      newAchievements: newAchievements,
      personalityFeedback: personalityFeedback,
    );
  }

  static void _checkBreakingPoints(Character c, List<LifeEvent> events, List<String> feedback) {
    c.personalityScores.forEach((trait, score) {
      if (score >= 95) {
        // Breaking Point Reached!
        switch (trait) {
          case 'Risk-taker':
            _addEvent(events, c.age, '🎲 THE GREAT GAMBLE', 
              description: 'Your appetite for risk is absolute. You bet everything on a single venture.',
              type: LifeEventType.rare, priority: EventPriority.critical);
            if (_rng.nextBool()) {
               c.bankBalance *= 5;
               feedback.add('🔥 BREAKING POINT: Your gamble paid off beyond your wildest dreams!');
            } else {
               c.bankBalance *= 0.1;
               c.updateStats(happinessDelta: -50);
               feedback.add('🛑 BREAKING POINT: You lost it all. The abyss stares back.');
            }
            break;
          case 'Kind':
            _addEvent(events, c.age, '🕊️ SAINTLY SACRIFICE', 
              description: 'You gave away a fortune to help those in need.',
              type: LifeEventType.milestone, priority: EventPriority.important);
            c.bankBalance *= 0.5;
            c.karma = 100;
            c.updateStats(happinessDelta: 40);
            feedback.add('🌟 BREAKING POINT: Your kindness has reached legendary levels.');
            break;
          case 'Disciplined':
             feedback.add('💎 BREAKING POINT: Your discipline is unshakeable. You are a machine of habit.');
             c.updateStats(smartsDelta: 10, healthDelta: 10);
            break;
          case 'Aggressive':
            _addEvent(events, c.age, '⚔️ TOTAL DOMINATION', 
              description: 'You crushed your rivals without mercy.',
              type: LifeEventType.critical, priority: EventPriority.critical);
            c.annualIncome *= 2.0;
            c.updateStats(socialDelta: -40, karmaDelta: -30);
            feedback.add('💀 BREAKING POINT: Your aggression has cleared the path, but the bridge is burnt.');
            break;
        }
        // Reset slightly after breaking point to prevent infinite loop
        c.personalityScores[trait] = 90;
      }
    });
  }

  static void _detectPersonalityConflicts(Character c, List<String> feedback) {
    void check(String t1, String t2, String conflictName) {
      if ((c.personalityScores[t1] ?? 0) > 70 && (c.personalityScores[t2] ?? 0) > 70) {
        feedback.add('⚖️ INTERNAL CONFLICT: Your $t1 nature clashing with $t2 tendencies ($conflictName).');
      }
    }
    check('Disciplined', 'Lazy', 'Procrastination Paradox');
    check('Logical', 'Emotional', 'Head vs Heart');
    check('Kind', 'Aggressive', 'Gentle Warrior');
  }


  static String _getTeaserHook(Character character) {
    final hooks = [
      "You have a strange feeling about next year...",
      "A big change is approaching.",
      "You feel like your hard work is about to pay off.",
      "A storm is brewing in your personal life.",
      "You might encounter an old friend soon.",
      if (character.age < 18) "Board exams are lurking around the corner...",
      if (character.annualIncome > 0) "Your performance at work is being noticed.",
      if (character.loanAmount > 0) "The bank is keeping a close eye on your payments."
    ];
    return hooks[_rng.nextInt(hooks.length)];
  }

  static void _processEventChains(Character character, List<LifeEvent> events) {
    // Example: JEE/IIT Chain
    if (character.age == 16) character.eventChains['jee'] = 1;

    if (character.eventChains.containsKey('jee')) {
      final step = character.eventChains['jee']!;
      if (step == 1 && character.age == 16) {
        _addEvent(events, character.age,
            "📚 Joined top coaching institute for JEE prep",
            description: "Intensive training begins.",
            type: LifeEventType.neutral);
        character.eventChains['jee'] = 2;
      } else if (step == 2 && character.age == 17) {
        _addEvent(events, character.age, "🧪 Intensive Chemistry Prep",
            description: "Struggling with organic... but pushing through.",
            type: LifeEventType.neutral);
        character.eventChains['jee'] = 3;
      } else if (step == 3 && character.age == 18) {
        _addEvent(events, character.age, "📝 JEE ADVANCED EXAM DAY",
            description: "The pressure is immense. Good luck!",
            type: LifeEventType.milestone,
            priority: EventPriority.important);
        character.eventChains['jee'] = 4;
      } else if (step == 4 && character.age == 19) {
        final success = character.smarts > 80;
        if (success) {
          _addEvent(events, character.age, "🌟 IIT BOMBAY! RESULT: AIR 432",
              description: "You cleared the cutoff and secured admission!",
              type: LifeEventType.critical,
              priority: EventPriority.critical);
          character.updateStats(
              happinessDelta: 40, smartsDelta: 15, socialDelta: 20);
        } else {
          _addEvent(events, character.age, "💔 JEE Result: Did not clear",
              description: "A tough pill to swallow. Don't give up.",
              type: LifeEventType.negative,
              priority: EventPriority.important);
          character.updateStats(happinessDelta: -20, smartsDelta: 5);
        }
        character.eventChains.remove('jee');
      }
    }

    // --- Startup Chain ---
    if (character.smarts > 70 && character.bankBalance > 200000 && !character.eventChains.containsKey('startup') && character.age > 22 && _rng.nextDouble() < 0.1) {
      character.eventChains['startup'] = 1;
    }

    if (character.eventChains.containsKey('startup')) {
      final step = character.eventChains['startup']!;
      if (step == 1) {
        _addEvent(events, character.age, "🚀 Startup Idea Spark!",
            description: "You've been thinking about a hyperlocal delivery app. Time to code?",
            type: LifeEventType.milestone);
        character.eventChains['startup'] = 2;
      } else if (step == 2) {
        _addEvent(events, character.age, "💻 MVP Built",
            description: "You stayed up for 3 months. The app is live!",
            type: LifeEventType.neutral);
        character.eventChains['startup'] = 3;
      } else if (step == 3) {
        final success = character.smarts > 75 && _rng.nextDouble() > 0.3;
        if (success) {
          _addEvent(events, character.age, "📈 Traction!",
              description: "10,000 users joined! Investors are sniffing around.",
              type: LifeEventType.positive);
          character.eventChains['startup'] = 4;
          character.updateStats(happinessDelta: 15, moneyDelta: 50000);
        } else {
          _addEvent(events, character.age, "📉 Low Growth",
              description: "Users aren't sticking around. Need a pivot?",
              type: LifeEventType.negative);
          character.eventChains['startup'] = 5; // Pivot path
        }
      } else if (step == 4) {
        _addEvent(events, character.age, "💰 Series A Funded!",
            description: "You raised ₹50 Lakhs! You're a founder now.",
            type: LifeEventType.critical,
            priority: EventPriority.critical);
        character.addAchievement('entrepreneur');
        character.updateStats(moneyDelta: 500000);
        character.eventChains.remove('startup');
      } else if (step == 5) {
        _addEvent(events, character.age, "🏳️ Startup Closed",
            description: "The pivot didn't work. Good experience though.",
            type: LifeEventType.negative);
        character.updateStats(happinessDelta: -10, smartsDelta: 10);
        character.eventChains.remove('startup');
      }
    }
  }

  static void _applyRecoverySystem(Character c, List<LifeEvent> events) {
    if (c.eventChains.containsKey('recovery_timer')) {
      int timer = c.eventChains['recovery_timer']!;
      if (timer > 1) {
        c.eventChains['recovery_timer'] = timer - 1;
      } else {
        // Trigger Comeback
        _addEvent(events, c.age, "🌅 REDEMPTION: The Second Chance",
            description:
                "After your recent struggles, a mentor offers guidance.",
            type: LifeEventType.milestone,
            priority: EventPriority.important);

        // Note: For now we'll skip the nested EventChoice inside the refactored domain model
        // until we decide how to handle interactive events in the new architecture.
        // But the core loop is now "engine owned".
        c.eventChains.remove('recovery_timer');
      }
    }
  }

  static void _applySocialComparison(Character c, List<LifeEvent> events) {
    final comparisons = [
      "Classmate bought a luxury villa. Pangs of envy.",
      "Cousin from village cleared UPSC. Non-stop family talk.",
      "Colleague got your promotion. Standing took a hit.",
      "Saw old rival at wedding. They look much more successful.",
    ];
    final text = comparisons[_rng.nextInt(comparisons.length)];
    _addEvent(events, c.age, "📊 Social Comparison",
        description: text, type: LifeEventType.negative);
    c.updateStats(happinessDelta: -10, socialDelta: -5);
  }

  static void _updateMomentum(Character c, Map<String, int> deltas) {
    // If net positive deltas
    int score = (deltas['happiness'] ?? 0) + (deltas['smarts'] ?? 0) + (deltas['money']! > 0 ? 5 : 0);
    if (score > 12) {
      c.momentumStreak = (c.momentumStreak > 0) ? c.momentumStreak + 1 : 1;
    } else if (score < -12) {
      c.momentumStreak = (c.momentumStreak < 0) ? c.momentumStreak - 1 : -1;
    } else {
      if (c.momentumStreak > 0) {
        c.momentumStreak--;
      } else if (c.momentumStreak < 0) {
        c.momentumStreak++;
      }
    }

    // Determine State
    final oldState = c.momentumState;
    if (c.momentumStreak >= 5) {
      c.momentumState = 'Flow State';
      c.updateStats(happinessDelta: 8, smartsDelta: 4); // Buff
    } else if (c.momentumStreak <= -4) {
      c.momentumState = 'Emotional Collapse';
      c.updateStats(happinessDelta: -10, healthDelta: -5); // Debuff
    } else if (c.momentumStreak.abs() >= 2) {
      c.momentumState = c.momentumStreak > 0 ? 'Steady Growth' : 'Struggling';
    } else {
      c.momentumState = 'Steady';
    }

    // Narrative feedback for major transitions
    if (c.momentumState != oldState && (c.momentumState == 'Flow State' || c.momentumState == 'Emotional Collapse')) {
      // Logic for adding a feedback message will be handled by the caller in ageUp
    }
  }

  static void _updateIdentityPhase(Character c, List<String> feedback) {
    c.phaseYearsStored++;
    
    // Only evaluate phase shifts Every 5 years
    if (c.phaseYearsStored < 10) return;

    final trait = c.activeDominantTrait;
    final oldPhase = c.identityPhase;
    
    String newPhase = oldPhase;
    final modifiers = Map<String, double>.from(c.hiddenModifiers);

    if (trait == 'Disciplined') {
      newPhase = 'The Architect of Life';
      modifiers['careerGrowthTerm'] = 1.25;
    } else if (trait == 'Risk-taker') {
      newPhase = 'The High Roller';
      modifiers['luckFactor'] = 1.30;
    } else if (trait == 'Lazy') {
      newPhase = 'The Content Minimalist';
      modifiers['expenseReduction'] = 0.80;
    } else if (trait == 'Aggressive') {
      newPhase = 'The Unstoppable Force';
      modifiers['promotionChance'] = 1.50;
      modifiers['socialFriction'] = 1.40;
    } else if (trait == 'Kind') {
      newPhase = 'The Guardian Spirit';
      modifiers['recoverySpeed'] = 1.50;
    }

    if (newPhase != oldPhase) {
      c.identityPhase = newPhase;
      c.hiddenModifiers = modifiers;
      c.phaseYearsStored = 0;
      feedback.add('💠 IDENTITY PHASE: You have entered $newPhase.');
    }
  }

  static bool _applyChaosAndHighStakes(
      Character c, List<LifeEvent> events, List<String> achievements) {
    double rand = _rng.nextDouble();

    // Illusion of Control: Bias based on Smarts/Karma
    if (c.smarts > 80) rand += 0.05; // 5% better luck
    if (c.karma > 80) rand += 0.05;
    if (c.smarts < 30) rand -= 0.05; // 5% worse luck

    // ── BIG WIN SYSTEM (Dopamine Spikes) ──
    if (rand < 0.02) {
      // 2% chance for a massive win
      final wins = [
        "💰 JACKPOT! Major prize win.",
        "🚀 VIRAL SUCCESS! Side project went viral.",
        "💎 TOP RANK! All-India Rank top 100!",
        "📈 BULL RUN! Investment exploded in value!",
      ];
      final title = wins[_rng.nextInt(wins.length)];
      _addEvent(events, c.age, title,
          description: "A rare high-reward moment that changes everything.",
          type: LifeEventType.rare,
          priority: EventPriority.critical);

      if (title.contains("JACKPOT")) c.bankBalance += 250000;
      if (title.contains("VIRAL")) {
        c.bankBalance += 100000;
        c.updateStats(happinessDelta: 30, socialDelta: 20);
      }
      if (title.contains("RANK")) {
        c.updateStats(smartsDelta: 20, happinessDelta: 40);
        c.addAchievement("National Scholar");
      }
      if (title.contains("BULL")) c.bankBalance *= 3;
      return true;
    }

    // ── EMOTIONAL DAMAGE & LOSS AVERSION ──
    else if (rand < 0.05) {
      // 3% chance for damage
      final damage = [
        "💔 BETRAYAL! Someone scammed you.",
        "🔥 CAREER CRASH! Skills obsolete.",
        "📉 MARKET COLLAPSE! Savings plummeted.",
        "😢 FAMILY DRAMA! Major fallout.",
        "🤒 HEALTH CRISIS! Sudden illness.",
      ];
      final title = damage[_rng.nextInt(damage.length)];
      _addEvent(events, c.age, title,
          description: "A devastating setback. High stakes consequences.",
          type: LifeEventType.critical,
          priority: EventPriority.critical);

      if (title.contains("BETRAYAL")) {
        c.bankBalance *= 0.5;
        c.updateStats(happinessDelta: -30, karmaDelta: -10);
      }
      if (title.contains("CAREER")) {
        c.bankBalance *= 0.8;
        c.updateStats(happinessDelta: -20, socialDelta: -10);
        c.careerGroup = 'None';
        c.jobTitle = 'Unemployed';
      }
      if (title.contains("MARKET")) {
        c.bankBalance *= 0.4;
        c.updateStats(happinessDelta: -15);
      }
      if (title.contains("FAMILY")) {
        c.updateStats(happinessDelta: -40, socialDelta: -30);
      }
      if (title.contains("HEALTH")) {
        c.bankBalance -= 50000;
        c.updateStats(healthDelta: -30, happinessDelta: -15);
      }

      // Inject recovery timer for major damage
      c.eventChains['recovery_timer'] = 2 + _rng.nextInt(2);
      return true;
    }

    // ── CHAOS SYSTEM (Unfairness for High Performers) ──
    else if (c.smarts > 85 && rand < 0.12) {
      final unfair = [
        "🤯 UNFAIR REJECTION! Despite high scores, politics kept you out.",
        "⚖️ LEGAL HASSLE! A jealous rival filed a frivolous lawsuit.",
        "😤 PROMOTION BYPASSED! The boss's nephew got the role instead.",
        "📉 AUDIT SCARE! A clerical error in your taxes triggered a scary audit.",
      ];
      final title = unfair[_rng.nextInt(unfair.length)];
      _addEvent(events, c.age, title,
          description: "Life isn't always fair, even for the best.",
          type: LifeEventType.negative,
          priority: EventPriority.important);
      c.updateStats(happinessDelta: -20, karmaDelta: -5);
      return true;
    }
    else if (c.bankBalance > 5000000 && rand < 0.08) {
      _addEvent(events, c.age, "🕵️ WEALTH TAX SCRUTINY!",
          description: "Being rich has its downsides. Authorities are digging deep.",
          type: LifeEventType.negative,
          priority: EventPriority.important);
      c.updateStats(moneyDelta: -100000, happinessDelta: -10);
      return true;
    }
    return false;
  }


  static void _applyFinancialsSilent(Character c, List<LifeEvent> events) {
    if (c.age < 6) return;
    
    final income = c.annualIncome;
    double expenses = c.annualExpenses * (c.hiddenModifiers['expenseReduction'] ?? 1.0);
    
    // Automated banking
    if (c.loanAmount > 0) {
      double annualRate = c.loanType == 'Student'
          ? 0.06
          : (c.loanType == 'Home' ? 0.08 : 0.12);
      c.loanAmount += c.loanAmount * annualRate;
      if (income >= expenses * 1.5) {
        double annualEMI = (income * 0.15).clamp(0, c.loanAmount);
        c.loanAmount -= annualEMI;
        expenses += annualEMI;
        if (c.loanAmount <= 0) {
          c.loanType = 'None';
          _addEvent(events, c.age, '🎉 LOAN PAID OFF!',
              description: 'You are now debt-free.',
              type: LifeEventType.positive);
        }
      }
    }

    // Consolidate into one event if income is major
    final net = income - expenses;
    c.bankBalance = (c.bankBalance + net).clamp(0.0, double.infinity);
    if (income > 0) {
      c.totalEarned += income;
      // Only show if major change or first time
      if (c.age % 5 == 0 || net < -50000) {
        _addEvent(events, c.age, '💸 Financial Update',
            description:
                'Earned ₹${formatMoney(income)} | Spent ₹${formatMoney(expenses)} this year.',
            type: net >= 0 ? LifeEventType.neutral : LifeEventType.negative);
      }
    }
  }

  static void _applyRelationshipDynamicsSilent(
      Character c, List<LifeEvent> events) {
    if (c.relationships.isEmpty) return;
    final toRemove = <Relationship>[];
    for (var rel in c.relationships) {
      if (!rel.isAlive) continue;
      rel.age += 1;
      rel.bond = (rel.bond - _rng.nextInt(3)).clamp(0, 100);
      if (rel.bond < 15 && rel.type == 'Partner') {
        toRemove.add(rel);
        _addEvent(events, c.age, '😭 BREAKUP!',
            description: '${rel.name} has ended the relationship.',
            type: LifeEventType.negative,
            priority: EventPriority.important);
      }
    }
    c.relationships.removeWhere((r) => toRemove.contains(r));
  }

  static String applyChoiceEffect(
      Character character, EventChoice choice, bool choseA) {
    final effect = choseA ? choice.effectA : choice.effectB;
    final shifts = choseA ? choice.traitShiftsA : choice.traitShiftsB;

    // Perk/Trait Multipliers
    double intensity = 1.0;
    if (character.dominantTrait == 'Emotional') intensity = 1.25;
    if (character.dominantTrait == 'Logical') intensity = 0.8;

    character.updateStats(
      happinessDelta: (effect.happiness * intensity).round(),
      healthDelta: effect.health,
      smartsDelta: effect.smarts,
      socialDelta: effect.social,
      karmaDelta: effect.karma,
      moneyDelta: effect.money,
    );

    // Evolution
    if (shifts != null) {
      shifts.forEach((trait, delta) {
        character.shiftPersonality(trait, delta);
      });
    }

    // Logic for Regret System: Record High-Impact Decisions
    if ((effect.happiness.abs() > 15 || effect.karma.abs() > 10) && character.age >= 13) {
      character.majorDecisions = List<Map<String, dynamic>>.from(character.majorDecisions)..add({
        'age': character.age,
        'choice': choseA ? choice.optionA : choice.optionB,
        'regretPotential': (effect.happiness < 0 || effect.karma < 0) ? 70 : 15,
      });
    }

    StorageService.saveCharacter(character);
    return choseA ? choice.resultA : choice.resultB;
  }

  static String applyCareerSwitch(Character character, CareerGroup newGroup) {
    final result = CareerSystem.switchCareer(character, newGroup);
    StorageService.saveCharacter(character);
    return result;
  }

  static String? buyAsset(Character character, GameAsset asset) {
    if (character.bankBalance < asset.purchasePrice) {
      return '❌ You don\'t have enough money in your bank account!';
    }
    if (character.ownedAssets.contains(asset.id) &&
        asset.category != AssetCategory.jewelry) {
      return '❌ You already own a ${asset.name}!';
    }

    character.stateVersion++;
    character.bankBalance -= asset.purchasePrice;
    character.ownedAssets = List.from(character.ownedAssets)..add(asset.id);
    character.happiness = (character.happiness + 20).clamp(0, 100);
    StorageService.saveCharacter(character);
    return '✅ PURCHASED! ${asset.emoji} You are now the proud owner of a ${asset.name}!';
  }

  static Character createNewCharacter({
    required String name,
    required String city,
    String gender = 'Male',
    String personality = 'Balanced',
    int karmaBonus = 0,
  }) {
    final legacyPoints = StorageService.getLegacyPoints();
    final statMods = _personalityMods(personality);
    final rels = _generateFamily(city);

    // Legacy Rivalry Logic: 40% chance one friend/cousin is a rival
    if (rels.length > 2 && _rng.nextDouble() < 0.4) {
      final rival = rels[_rng.nextInt(rels.length)];
      if (rival.type != 'Father' && rival.type != 'Mother') {
        rival.isRival = true;
        rival.rivalIntensity = 20;
      }
    }

    // Apply Legacy Scaling
    double legacyCash = 5000.0 + (karmaBonus * 100) + (legacyPoints * 50);
    int legacySmartsMod = (legacyPoints ~/ 20).clamp(0, 20);
    int legacyKarmaMod = (legacyPoints ~/ 10).clamp(0, 30);

    return Character(
      name: name,
      age: 0,
      city: city,
      gender: gender,
      personality: personality,
      bankBalance: legacyCash,
      jobTitle: 'Newborn',
      happiness:
          (70 + statMods['happiness']! + (karmaBonus ~/ 5)).clamp(0, 100),
      health: (80 + statMods['health']!).clamp(0, 100),
      smarts: (50 + statMods['smarts']! + (karmaBonus ~/ 10) + legacySmartsMod)
          .clamp(0, 100),
      social: (60 + statMods['social']!).clamp(0, 100),
      karma: (50 + statMods['karma']! + (karmaBonus ~/ 5) + legacyKarmaMod)
          .clamp(0, 100),
      educationLevel: 'None',
      degree: 'None',
      annualIncome: 0,
      annualExpenses: 36000,
      careerGroup: 'None',
      careerStep: 0,
      yearsInRole: 0,
      achievements: [],
      ownedAssets: [],
      relationships: rels,
      legacyPoints: (StorageService.getLegacyPoints() / 10).round(), // Store for next life
    );
  }

  static Relationship generateDatingCandidate(int playerAge) {
    final firstNames = [
      'Arjun',
      'Ishan',
      'Karan',
      'Mira',
      'Sana',
      'Zoya',
      'Rahul',
      'Nisha',
      'Aman',
      'Tanya'
    ];
    final lastNames = [
      'Sharma',
      'Kapoor',
      'Mehta',
      'Verma',
      'Patel',
      'Reddy',
      'Iyer',
      'Khan',
      'Singh',
      'Deshmukh'
    ];
    final name =
        '${firstNames[_rng.nextInt(firstNames.length)]} ${lastNames[_rng.nextInt(lastNames.length)]}';
    final age = (playerAge + _rng.nextInt(5) - 2).clamp(16, 100);
    return Relationship(
        name: name,
        type: 'Partner',
        bond: 50 + _rng.nextInt(20),
        initial: name[0],
        age: age);
  }

  static void addPartner(Character c, Relationship partner) {
    c.stateVersion++;
    c.relationships.add(partner);
    c.happiness = (c.happiness + 20).clamp(0, 100);
  }

  static String interactWithRelation(
      Character c, Relationship r, String action) {
    c.stateVersion++;
    String result = '';
    switch (action) {
      case 'Spend Time':
        r.bond = (r.bond + 12).clamp(0, 100);
        c.happiness = (c.happiness + 5).clamp(0, 100);
        c.social = (c.social + 3).clamp(0, 100);
        result =
            '😊 You spent quality time with ${r.name}. The bond grew stronger!';
        break;
      case 'Give Gift':
        double cost = r.type == 'Partner' ? 5000 : 2000;
        if (c.bankBalance < cost) return '❌ You can\'t afford a decent gift!';
        c.bankBalance -= cost;
        r.bond = (r.bond + 25).clamp(0, 100);
        c.happiness = (c.happiness + 8).clamp(0, 100);
        result = '🎁 You gave ${r.name} a meaningful gift. They are delighted!';
        break;
      case 'Ask for Money':
        if (r.type != 'Father' && r.type != 'Mother') {
          return '❌ Only parents might give you money!';
        }
        if (r.bond < 60) {
          return '😒 Your bond isn\'t strong enough. They refused.';
        }
        final amount = 5000.0 + _rng.nextInt(15000);
        c.bankBalance += amount;
        r.bond = (r.bond - 15).clamp(0, 100);
        result =
            '💵 They gave you ₹${formatMoney(amount)}, but seemed a bit disappointed.';
        break;
      case 'Argue':
        r.bond = (r.bond - 15).clamp(0, 100);
        c.happiness = (c.happiness - 10).clamp(0, 100);
        result =
            '🗯️ You had a heated argument with ${r.name}. Bond decreased.';
        break;
      case 'Talk':
        r.bond = (r.bond + 5).clamp(0, 100);
        result = '🗣️ You and ${r.name} had a deep conversation.';
        break;
      case 'Go on Date':
        if (c.bankBalance < 3000) {
          return '❌ You can\'t afford a date right now!';
        }
        c.bankBalance -= 3000;
        r.bond = (r.bond + 18).clamp(0, 100);
        c.happiness = (c.happiness + 12).clamp(0, 100);
        result = '💘 You had a wonderful date with ${r.name}!';
        break;
    }
    return result;
  }

  static String askParentsForBank(Character c) {
    if (c.age < 10) return '❌ You are too young to even think about banking!';
    if (c.bankName.isNotEmpty) return '❌ You already have a bank account!';

    // Chance based on parent bond
    final parents = c.relationships
        .where((r) => r.type == 'Father' || r.type == 'Mother')
        .toList();
    if (parents.isEmpty) return '😔 You don\'t have parents to ask.';

    double avgBond =
        parents.map((p) => p.bond).reduce((a, b) => a + b) / parents.length;
    if (_rng.nextInt(100) < avgBond) {
      c.bankName = 'SBI (Parental)';
      c.accountType = 'Basic';
      return '😊 Your parents agreed! They helped you open a Basic Account at SBI.';
    } else {
      return '😔 Your parents refused to open a bank account for you right now.';
    }
  }

  static String openBankAccount(Character c, String bank, String type) {
    if (c.age < 10) return '❌ No bank access until age 10.';
    if (c.age < 18 && c.bankName.isEmpty) {
      return '❌ At your age, you need your parents to open an account for you.';
    }

    c.bankName = bank;
    c.accountType = type;
    return '🏦 Welcome to $bank! You opened a $type Account.';
  }

  static String applyForCreditCard(Character c) {
    if (c.age < 18) {
      return '❌ You must be at least 18 years old to apply for a credit card.';
    }
    if (c.hasCreditCard) return '❌ You already have a credit card!';

    if (c.cibilScore >= 650) {
      c.stateVersion++;
      c.hasCreditCard = true;
      return '💳 APPROVED! Your credit card application was successful. CIBIL: ${c.cibilScore}';
    } else {
      return '❌ REJECTED! Your CIBIL score (${c.cibilScore}) is too low for a credit card.';
    }
  }

  static String takeStudentLoan(Character c, double amount) {
    if (c.loanAmount > 0) return '❌ You already have an active loan!';
    if (c.age < 10) return '❌ You must be at least 10 years old.';
    if (c.smarts < 60) {
      return '❌ Rejection! Your smarts (${c.smarts}) are too low for a student loan.';
    }
    if (amount > 1000000) return '❌ Maximum student loan allowed is ₹10 Lakhs.';

    c.loanAmount = amount;
    c.loanType = 'Student';
    c.bankBalance += amount;
    return '🎓 Student Loan Granted! ₹${formatMoney(amount)} credited for your studies. Interest: 6%.';
  }

  static String takePersonalLoan(Character c, double amount) {
    if (c.loanAmount > 0) return '❌ You already have an active loan!';
    if (c.age < 18) return '❌ You must be at least 18 years old.';
    if (c.annualIncome <= 0) {
      return '❌ You need a job to qualify for a personal loan.';
    }
    if (c.cibilScore < 600) {
      return '❌ Rejected! Your CIBIL score (${c.cibilScore}) is too low.';
    }

    double maxLoan = c.annualIncome * 1.5;
    if (amount > maxLoan) {
      return '❌ Based on your income, max loan allowed is ₹${formatMoney(maxLoan)}.';
    }

    c.loanAmount = amount;
    c.loanType = 'Personal';
    c.bankBalance += amount;
    c.cibilScore = (c.cibilScore - 20).clamp(300, 900);
    return '🏦 Personal Loan Approved! ₹${formatMoney(amount)} credited. Interest: 12%.';
  }

  static String takeHomeLoan(Character c, double amount) {
    if (c.loanAmount > 0) return '❌ You already have an active loan!';
    if (c.age < 21) return '❌ You must be at least 21 years old.';
    if (c.annualIncome < 1000000) {
      return '❌ Income requirement of ₹10L/year not met.';
    }
    if (c.cibilScore < 700) {
      return '❌ Rejected! Need CIBIL > 700 for Home Loan.';
    }

    c.loanAmount = amount;
    c.loanType = 'Home';
    c.bankBalance += amount;
    c.cibilScore = (c.cibilScore - 10).clamp(300, 900);
    return '🏠 Home Loan Granted! ₹${formatMoney(amount)} credited for your dream home. Interest: 8%.';
  }

  static String depositToSavings(Character c, double amount) {
    if (c.bankBalance < amount) return '❌ Insufficient bank balance!';
    c.bankBalance -= amount;
    c.savingsBalance += amount;
    return '✅ Deposited ₹${formatMoney(amount)} to your savings account.';
  }

  static String withdrawFromSavings(Character c, double amount) {
    if (c.savingsBalance < amount) return '❌ Insufficient savings balance!';
    c.savingsBalance -= amount;
    c.bankBalance += amount;
    return '✅ Withdrawn ₹${formatMoney(amount)} to your bank account.';
  }

  static String repayCreditCard(Character c, double amount) {
    if (c.bankBalance < amount) return '❌ Insufficient bank balance!';
    if (amount > c.creditUsed) amount = c.creditUsed;

    c.bankBalance -= amount;
    c.creditUsed -= amount;

    // Boost CIBIL if repayment is significant
    if (amount > 0) {
      int boost = 5 + _rng.nextInt(6); // +5 to +10
      c.cibilScore = (c.cibilScore + boost).clamp(300, 900);
    }

    return '💳 Credit Repaid! You paid ₹${formatMoney(amount)}. Current debt: ₹${formatMoney(c.creditUsed)}';
  }

  static String repayLoanPartially(Character c, double amount) {
    if (c.bankBalance < amount) return '❌ Insufficient bank balance!';
    if (amount > c.loanAmount) amount = c.loanAmount;

    c.bankBalance -= amount;
    c.loanAmount -= amount;
    int boost = 5 + _rng.nextInt(6); // +5 to +10
    c.cibilScore = (c.cibilScore + boost).clamp(300, 900);

    if (c.loanAmount <= 0) {
      c.loanType = 'None';
      return '🎉 LOAN CLEARED! You have fully repaid your loan. CIBIL boosted!';
    }

    return '🏦 Loan Payment! You paid extra ₹${formatMoney(amount)}. Remaining: ₹${formatMoney(c.loanAmount)}';
  }

  static String performActivity(Character c, String activityId) {
    if (c.bankBalance < 0 &&
        (activityId == 'Go to Party' || activityId == 'Go on Date')) {
      return '❌ You can\'t afford this.';
    }

    String result = '';
    switch (activityId) {
      case 'Gym Workout':
        if (c.bankBalance < 500) return '❌ You can\'t afford the gym!';
        c.bankBalance -= 500;
        c.health = (c.health + 8).clamp(0, 100);
        c.happiness = (c.happiness + 5).clamp(0, 100);
        c.shiftPersonality('Disciplined', 3);
        c.shiftPersonality('Risk-taker', -1);
        result = '🏋️ You hit the gym and improved your health! (-₹500)';
        break;
      case 'Study Hard':
        c.smarts = (c.smarts + 6).clamp(0, 100);
        c.happiness = (c.happiness - 4).clamp(0, 100);
        c.shiftPersonality('Disciplined', 5);
        c.shiftPersonality('Logical', 2);
        c.shiftPersonality('Lazy', -4);
        result =
            '📚 You studied hard. Your focus is sharp! (-4 Happiness)';
        break;
      case 'Skip School':
        c.smarts = (c.smarts - 8).clamp(0, 100);
        c.happiness = (c.happiness + 12).clamp(0, 100);
        c.shiftPersonality('Disciplined', -6);
        c.shiftPersonality('Lazy', 6);
        result =
            '🎮 You skipped school to play games. Fun, but your grades will suffer! (+12 Happiness, -8 Smarts)';
        break;
      case 'Socialize':
        c.smarts = (c.smarts - 2).clamp(0, 100);
        c.social = (c.social + 10).clamp(0, 100);
        c.happiness = (c.happiness + 5).clamp(0, 100);
        c.shiftPersonality('Emotional', 3);
        result =
            '🤝 You spent time catching up with friends. (+10 Social)';
        break;
      case 'Temple Visit':
        c.karma = (c.karma + 10).clamp(0, 100);
        c.happiness = (c.happiness + 5).clamp(0, 100);
        c.shiftPersonality('Kind', 4);
        c.shiftPersonality('Emotional', 2);
        result =
            '🛕 You visited the temple. You feel peaceful and blessed. (+10 Karma)';
        break;
      case 'Go to Party':
        if (c.bankBalance < 2000) {
          return '❌ You can\'t afford to party! (Need ₹2,000)';
        }
        c.bankBalance -= 2000;
        c.happiness = (c.happiness + 15).clamp(0, 100);
        c.health = (c.health - 5).clamp(0, 100);
        c.social = (c.social + 10).clamp(0, 100);
        c.shiftPersonality('Aggressive', 3);
        c.shiftPersonality('Emotional', 4);
        c.shiftPersonality('Disciplined', -3);
        result =
            '🎉 What a night! You had a blast at the party. (-₹2,000, -5 Health)';
        break;
      case 'Side Hustle':
        final earned = 5000.0 + _rng.nextInt(5000);
        c.bankBalance += earned;
        c.happiness = (c.happiness - 10).clamp(0, 100);
        c.health = (c.health - 2).clamp(0, 100);
        c.shiftPersonality('Disciplined', 4);
        c.shiftPersonality('Logical', 3);
        c.shiftPersonality('Lazy', -5);
        result =
            '💼 Worked a side hustle and earned ₹${formatMoney(earned)}! (-10 Happiness)';
        break;
      case 'Go on Date':
        // Actually this is handled by relationship interactions but leaving as fallback just in case
        if (c.bankBalance < 3000) {
          return '❌ You can\'t afford a date right now!';
        }
        c.bankBalance -= 3000;
        c.happiness = (c.happiness + 10).clamp(0, 100);
        result = '💘 You had a wonderful date!';
        break;
    }

    c.lastActivityAge = c.age;
    return result;
  }

  static List<Relationship> _generateFamily(String city) {
    final List<Relationship> res = [];
    final lastNames = [
      'Sharma',
      'Kapoor',
      'Mehta',
      'Verma',
      'Patel',
      'Reddy',
      'Iyer',
      'Khan',
      'Singh',
      'Deshmukh'
    ];
    final lastName = lastNames[_rng.nextInt(lastNames.length)];

    final maleNames = [
      'Sanjay',
      'Rajesh',
      'Amit',
      'Vijay',
      'Vikram',
      'Anil',
      'Sunil',
      'Pankaj'
    ];
    final femaleNames = [
      'Sunita',
      'Anjali',
      'Meena',
      'Priya',
      'Kavita',
      'Rekha',
      'Deepa',
      'Lata'
    ];

    final fatherName = '${maleNames[_rng.nextInt(maleNames.length)]} $lastName';
    final motherName =
        '${femaleNames[_rng.nextInt(femaleNames.length)]} $lastName';

    res.add(Relationship(
        name: fatherName,
        type: 'Father',
        bond: 80 + _rng.nextInt(10),
        initial: fatherName[0],
        age: 25 + _rng.nextInt(15)));
    res.add(Relationship(
        name: motherName,
        type: 'Mother',
        bond: 85 + _rng.nextInt(10),
        initial: motherName[0],
        age: 22 + _rng.nextInt(15)));

    if (_rng.nextBool()) {
      final isMale = _rng.nextBool();
      final siblingBase = isMale ? maleNames : femaleNames;
      final sibName =
          '${siblingBase[_rng.nextInt(siblingBase.length)]} $lastName';
      res.add(Relationship(
          name: sibName,
          type: 'Sibling',
          bond: 65 + _rng.nextInt(15),
          initial: sibName[0],
          age: _rng.nextInt(10)));
    }
    return res;
  }

  // ── PRIVATE HELPERS ──────────────────────────────────────────────────────────

  static Map<String, int> _personalityMods(String personality) {
    switch (personality) {
      case 'Smart':
        return {
          'happiness': 0,
          'health': 0,
          'smarts': 15,
          'social': -5,
          'karma': 5
        };
      case 'Kind':
        return {
          'happiness': 10,
          'health': 5,
          'smarts': 0,
          'social': 10,
          'karma': 15
        };
      case 'Lazy':
        return {
          'happiness': 10,
          'health': -10,
          'smarts': -10,
          'social': 0,
          'karma': -5
        };
      case 'Aggressive':
        return {
          'happiness': -5,
          'health': 10,
          'smarts': 5,
          'social': -10,
          'karma': -10
        };
      case 'Lucky':
        return {
          'happiness': 10,
          'health': 5,
          'smarts': 5,
          'social': 5,
          'karma': 10
        };
      default:
        return {
          'happiness': 0,
          'health': 0,
          'smarts': 0,
          'social': 0,
          'karma': 0
        };
    }
  }

  static void _applyEducationProgression(Character c, List<LifeEvent> events) {
    // Current Indian-style progression
    if (c.age == 5 && c.educationLevel == 'None') {
      c.educationLevel = 'Primary';
      _addEvent(events, c.age, '🏫 Enrolled in Primary School',
          description: 'Your education journey officially begins!',
          type: LifeEventType.milestone);
    }
    if (c.age == 11 && c.educationLevel == 'Primary') {
      c.educationLevel = 'Secondary';
      _addEvent(events, c.age, '🎒 Entered Secondary School',
          description: 'Middle school phase! Time to get serious.',
          type: LifeEventType.milestone);
    }
    if (c.age == 17 && c.educationLevel == 'Secondary') {
      c.educationLevel = 'Higher Secondary';
      _addEvent(events, c.age, '📚 11th & 12th Grade',
          description: 'The critical board exam years. Choose your stream wisely.',
          type: LifeEventType.milestone);
    }
    if (c.age == 19 && c.educationLevel == 'Higher Secondary' && !c.isDroppedYear) {
      // Auto-graduation from school if not dropping
      if (c.degree == 'None' && _rng.nextDouble() > 0.1) {
        _addEvent(events, c.age, '🎓 Completed Schooling',
            description: 'You finished your higher secondary education!',
            type: LifeEventType.positive);
      }
    }

    // Traditional post-school milestones (for NPC/Auto-progression or Legacy)
    if (c.age == 22 && c.educationLevel == 'Graduate' && c.degree != 'None') {
       _addEvent(events, c.age, '🎓 Graduated University',
            description: 'Congratulations! You earned your ${c.degree} degree!',
            type: LifeEventType.positive,
            priority: EventPriority.important);
        c.annualExpenses = (c.annualExpenses - 60000).clamp(36000, double.infinity);
    }
  }

  static String takeEntranceExam(Character c, String examType) {
    if (c.age < 17 || c.age > 19) return '❌ You can only take entrance exams during 11th/12th grade.';
    if (c.examResults.containsKey(examType)) return '❌ You already took the $examType exam this year!';
    
    // Results based on Smarts, Discipline, and Luck
    int discipline = c.personalityScores['Disciplined'] ?? 30;
    int roll = _rng.nextInt(20);
    int score = ((c.smarts * 0.7) + (discipline * 0.3) + roll).round().clamp(0, 100);
    
    c.examResults = Map<String, int>.from(c.examResults)..[examType] = score;
    c.happiness = (c.happiness - 10).clamp(0, 100);
    
    if (score > 90) return '🌟 SPECTACULAR! You aced the $examType with a score of $score! Elite colleges await.';
    if (score > 75) return '✅ Great job! You scored $score in $examType. You have solid options.';
    if (score > 50) return '😐 You passed $examType with a score of $score. Competition will be tough.';
    return '💔 Ouch. You scored only $score in $examType. Admission might be difficult.';
  }

  static String chooseCollege(Character c, String universityType) {
    if (c.educationLevel != 'Higher Secondary' && c.educationLevel != 'Graduate') {
      return '❌ You need to complete school first!';
    }
    if (c.universityType != 'None') return '❌ You are already enrolled in a college!';
    
    if (universityType == 'Government') {
      bool canEnter = c.smarts > 75 || (c.examResults.values.any((s) => s > 80));
      if (!canEnter) return '❌ Rejection! Your academic record isn\'t strong enough for a Government seat.';
      
      c.universityType = 'Government';
      c.educationLevel = 'Graduate';
      c.degree = 'Bachelors'; // Default
      c.annualExpenses += 20000;
      StorageService.saveCharacter(c);
      return '🏦 GOVERNMENT COLLEGE! You secured a merit seat. High prestige and low fees! (-₹20k/yr)';
    } else if (universityType == 'Private') {
      if (c.bankBalance < 100000) return '❌ You can\'t afford the admission fees for a Private University!';
      c.bankBalance -= 50000;
      c.universityType = 'Private';
      c.educationLevel = 'Graduate';
      c.degree = 'Bachelors'; // Default
      c.annualExpenses += 150000;
      StorageService.saveCharacter(c);
      return '🏢 PRIVATE UNIVERSITY! You enrolled in a top-tier private college. (-₹50k admission, -₹1.5L/yr)';
    } else {
      c.isDroppedYear = true;
      return '⏳ DROP YEAR! You decided to take a year off to prepare or relax.';
    }
  }

  static void _applyCareerProgression(
      Character c, List<LifeEvent> events, List<String> newAchievements) {
    // Pre-work ages
    if (c.age < 18) {
      c.jobTitle = c.age < 6
          ? 'Newborn'
          : c.age < 13
              ? 'Student'
              : 'School Student';
      c.annualIncome = 0;
      return;
    }
    if (c.age < 22 && c.educationLevel == 'Graduate') {
      c.jobTitle = 'College Student';
      c.annualIncome = 12000;
      return;
    }

    // First job assignment at 22 (or when school done at 18 without college)
    final isFirstJob = c.careerGroup == 'None' &&
        c.annualIncome == 0 &&
        (c.age == 22 || (c.age == 18 && c.educationLevel != 'Graduate'));
    if (isFirstJob) {
      final group = CareerSystem.bestMatchGroup(c);
      CareerSystem.assignCareer(c, group);
      _addEvent(events, c.age, '${group.emoji} Career Start!',
          description:
              'You joined the ${group.name} field as a ${group.steps.first.title}. Salary: ₹${GameEngine.formatMoney(group.steps.first.annualSalary)}/yr!',
          type: LifeEventType.milestone);
      return;
    }

    // If unemployed, try to find a new job after 2 years
    if (c.careerGroup == 'None' && c.age > 22 && c.smarts > 30) {
      if (_rng.nextInt(4) == 0) {
        final group = CareerSystem.bestMatchGroup(c);
        CareerSystem.assignCareer(c, group);
        _addEvent(events, c.age, '${group.emoji} New Beginning!',
            description: 'You found a job as a ${group.steps.first.title}.',
            type: LifeEventType.positive);
      }
      return;
    }

    // Try promotion
    final promotionResult = CareerSystem.tryPromotion(c, _rng);
    if (promotionResult != null) {
      _addEvent(events, c.age, '📈 Promoted!',
          description: promotionResult,
          type: LifeEventType.positive,
          priority: EventPriority.important);
      // Achievement for top roles
      if (c.jobTitle == 'CTO') c.addAchievement('cto');
      if (c.jobTitle == 'CEO') c.addAchievement('ceo');
      if (c.jobTitle == 'Superstar') c.addAchievement('superstar');
      return;
    }

    // Try job loss
    final fireResult = CareerSystem.tryJobLoss(c, _rng);
    if (fireResult != null) {
      _addEvent(events, c.age, '😢 Job Lost',
          description: fireResult,
          type: LifeEventType.negative,
          priority: EventPriority.critical);
      return;
    }

    // Experience bonus (3% salary increase for each year in role beyond minimum)
    final group = CareerSystem.findGroup(c.careerGroup);
    if (group != null && c.careerStep < group.steps.length) {
      final step = group.steps[c.careerStep];
      final experienceYears =
          (c.yearsInRole - step.minYearsToPromote).clamp(0, 10);
      
      // Apply identity term (e.g. Architect growth)
      double termMod = c.hiddenModifiers['careerGrowthTerm'] ?? 1.0;
      
      // Lazy Ceiling: Cannot reach CEO/CTO level
      bool restricted = c.activeDominantTrait == 'Lazy' && c.careerStep >= 3;
      if (restricted) termMod *= 0.5;

      c.annualIncome = step.annualSalary * (1.0 + experienceYears * 0.03 * termMod);
    }
  }


  static void _applyNaturalAging(Character c) {
    if (c.age > 60) c.health = (c.health - _rng.nextInt(2)).clamp(0, 100);
    if (c.age > 75) c.health = (c.health - _rng.nextInt(3)).clamp(0, 100);
    if (c.age > 90) c.health = (c.health - _rng.nextInt(5)).clamp(0, 100);
    if (c.age >= 100) {
      c.isDead = true;
      c.addAchievement('long_life');
    }
    if (c.age == 90) c.addAchievement('old_soul');
  }

  static void _applyPassiveStatNudge(Character c, int eventCount) {
    for (int i = 0; i < eventCount; i++) {
      final delta = _rng.nextInt(4) + 1;
      final stat = _rng.nextInt(5);
      final mult = c.personality == 'Lucky' ? 1.3 : 1.0;
      final sign = _rng.nextBool() ? 1 : -1;
      switch (stat) {
        case 0:
          c.happiness =
              (c.happiness + (sign * delta * mult).round()).clamp(0, 100);
          break;
        case 1:
          final hm = c.personality == 'Aggressive' ? 0.5 : 1.5;
          c.health = (c.health + (sign < 0 ? -(delta * hm).round() : delta))
              .clamp(0, 100);
          break;
        case 2:
          final sm = c.personality == 'Smart' ? 2.0 : 1.0;
          c.smarts = (c.smarts + (sign * delta * sm).round()).clamp(0, 100);
          break;
        case 3:
          c.social = (c.social + (sign * delta).round()).clamp(0, 100);
          break;
        case 4:
          if (c.karma > 50) c.karma -= 1;
          if (c.karma < 50) c.karma += 1;
          break;
      }
    }
    if (c.health <= 0) c.isDead = true;
  }

  static String? _triggerRareEvent(Character c, List<String> newAchievements) {
    final roll = _rng.nextInt(10);
    if (c.karma > 70 && roll < 4) {
      switch (_rng.nextInt(5)) {
        case 0:
          c.bankBalance += 500000;
          c.totalEarned += 500000;
          c.addAchievement('lottery');
          newAchievements.add('lottery');
          return '🎰 INCREDIBLE! You won ₹5,00,000 in a lucky draw!';
        case 1:
          c.social = (c.social + 20).clamp(0, 100);
          c.happiness = (c.happiness + 15).clamp(0, 100);
          c.bankBalance += 100000;
          c.addAchievement('viral_fame');
          newAchievements.add('viral_fame');
          return '🌟 Your video went VIRAL — 10M views! Brands are calling!';
        case 2:
          c.bankBalance += 200000;
          c.totalEarned += 200000;
          return '🤝 A chance encounter led to a life-changing business deal!';
        case 3:
          c.smarts = (c.smarts + 10).clamp(0, 100);
          return '🏆 You were featured in Forbes India\'s 30 Under 30!';
        case 4:
          c.annualIncome = (c.annualIncome * 1.5).roundToDouble();
          return '🚀 Your company got acquired! You received a massive equity payout!';
      }
    } else if (c.karma < 40 && roll < 4) {
      switch (_rng.nextInt(4)) {
        case 0:
          final loss = (c.bankBalance * 0.3).clamp(1000.0, 500000.0);
          c.bankBalance -= loss;
          c.happiness = (c.happiness - 20).clamp(0, 100);
          return '📉 A fraudulent scheme wiped out ₹${_formatNum(loss)} of your savings!';
        case 1:
          c.health = (c.health - 25).clamp(0, 100);
          c.bankBalance -= 50000;
          return '🏥 A serious accident. ₹50,000 in medical bills.';
        case 2:
          c.bankBalance -= c.bankBalance * 0.2;
          return '💸 Tax raid! Authorities penalized you heavily.';
        case 3:
          c.social = (c.social - 15).clamp(0, 100);
          return '📰 False rumours about you spread on social media.';
      }
    }
    return null;
  }

  static void _checkAchievements(Character c, List<String> newAchievements) {
    void grant(String id) {
      if (!c.achievements.contains(id)) {
        c.addAchievement(id);
        newAchievements.add(id);
      }
    }

    if (c.bankBalance >= 10000000) grant('crorepati');
    if (c.bankBalance >= 1000000) grant('lakhpati');
    if (c.karma >= 90) grant('saintly');
    if (c.smarts >= 95) grant('genius');
    if (c.social >= 95) grant('social_butterfly');
  }

  static List<LifeEvent> _pickSmartEvents(Character c, {int count = 1}) {
    final eligible = EventData.allSmartEvents.where((e) {
      try {
        final dynamic cond = e['cond'];
        if (cond is bool Function(Character)) {
          return cond(c) == true;
        }
        return false;
      } catch (e) {
        debugPrint("Error evaluating event condition: $e");
        return false;
      }
    }).toList();

    if (eligible.isEmpty) return [];

    final List<LifeEvent> results = [];
    final Random r = Random();

    for (int i = 0; i < count; i++) {
      if (eligible.isEmpty) break;

      // Calculate total weight with modifiers
      double totalWeight = 0;
      final List<double> weights = [];

      for (var e in eligible) {
        double w = (e['weight'] as num).toDouble();

        // Personality Modifiers
        if (c.activeDominantTrait == 'Smart' && e['type'] == 'Education') w *= 2.0;
        if (c.activeDominantTrait == 'Kind' && e['type'] == 'Relationships') w *= 2.0;
        if (c.activeDominantTrait == 'Aggressive' && e['type'] == 'Chaos') w *= 1.5;
        if (c.activeDominantTrait == 'Lucky' && e['type'] == 'Rare') w *= 3.0;

        // Personality-Trait Multipliers
        final scores = c.personalityScores;
        if (e['type'] == 'Financial') {
          if (scores['Risk-taker']! > 60) w *= 1.4;
          if (scores['Logical']! > 60) w *= 1.2;
          if (scores['Lazy']! > 60) w *= 0.8;
        } else if (e['type'] == 'Relationships') {
          if (scores['Kind']! > 60) w *= 1.5;
          if (scores['Aggressive']! > 60) w *= 0.7;
        } else if (e['type'] == 'Education' || e['type'] == 'Personal Growth') {
          if (scores['Disciplined']! > 60) w *= 1.6;
          if (scores['Lazy']! > 60) w *= 0.6;
        } else if (e['type'] == 'Chaos') {
          if (scores['Risk-taker']! > 60) w *= 2.0;
          if (scores['Logical']! > 60) w *= 0.7;
        } else if (e['type'] == 'Rare') {
          if (scores['Risk-taker']! > 60) w *= 1.5;
        }

        // Momentum Modifiers
        if (c.momentumStreak > 2 && (e['money'] ?? 0) > 0) w *= 1.5;
        if (c.momentumStreak < -2 && (e['money'] ?? 0) < 0) w *= 1.5;

        // Stat Modifiers
        if (c.health < 40 && e['type'] == 'Chaos' && (e['health'] ?? 0) < 0) {
          w *= 2.0;
        }
        if (c.happiness > 80 && e['type'] == 'Personal Growth') w *= 1.5;

        // Safety Net for Risk-Takers: Better recovery chance if karma/health is low
        if (c.activeDominantTrait == 'Risk-taker' && 
            (c.health < 50 || c.karma < 40) && 
            e['type'] == 'Personal Growth') {
          w *= 2.2;
        }

        weights.add(w);
        totalWeight += w;
      }

      // Weighted selection
      double roll = r.nextDouble() * totalWeight;
      double cursor = 0;
      int selectedIdx = 0;

      for (int j = 0; j < weights.length; j++) {
        cursor += weights[j];
        if (cursor >= roll) {
          selectedIdx = j;
          break;
        }
      }

      final selected = eligible[selectedIdx];
      results.add(LifeEvent(
        title: selected['title'],
        description: selected['desc'],
        type: _inferType(selected['type']),
        priority: selected['type'] == 'Rare'
            ? EventPriority.rare
            : EventPriority.normal,
        statChanges: {
          if (selected['happiness'] != null)
            'happiness': selected['happiness'] as int,
          if (selected['health'] != null) 'health': selected['health'] as int,
          if (selected['smarts'] != null) 'smarts': selected['smarts'] as int,
          if (selected['social'] != null) 'social': selected['social'] as int,
          if (selected['karma'] != null) 'karma': selected['karma'] as int,
        },
        metadata: {
          'age': c.age,
          'category': selected['type'],
        },
      ));

      // Apply trait-based intensity modifiers
      double intensity = 1.0;
      if (c.activeDominantTrait == 'Emotional') intensity = 1.35;
      if (c.activeDominantTrait == 'Logical') intensity = 0.85;

      c.updateStats(
        happinessDelta: ((selected['happiness'] as int? ?? 0) * intensity).round(),
        healthDelta: ((selected['health'] as int? ?? 0)).round(),
        smartsDelta: ((selected['smarts'] as int? ?? 0)).round(),
        socialDelta: ((selected['social'] as int? ?? 0)).round(),
        karmaDelta: ((selected['karma'] as int? ?? 0)).round(),
        moneyDelta: (selected['money'] as num?)?.toDouble() ?? 0,
      );

      eligible.removeAt(selectedIdx);
    }

    return results;
  }

  static void _applyAutoDecisions(Character c, List<LifeEvent> events) {
    // Cooldown check: 3 year minimum gap between autonomous actions
    if (c.lastAutoDecisionAge != -1 && (c.age - c.lastAutoDecisionAge) < 3) {
      return;
    }

    for (var e in EventData.autoDecisionEvents) {
      final cond = e['cond'] as bool Function(Character);
      if (cond(c)) {
        // Triggered!
        c.lastAutoDecisionAge = c.age;
        _addEvent(events, c.age, e['title'],
            description: e['desc'],
            type: LifeEventType.negative,
            priority: EventPriority.important);

        c.updateStats(
          happinessDelta: e['happinessDelta'] as int? ?? 0,
          socialDelta: e['socialDelta'] as int? ?? 0,
          healthDelta: e['healthDelta'] as int? ?? 0,
          smartsDelta: e['smartsDelta'] as int? ?? 0,
          karmaDelta: e['karmaDelta'] as int? ?? 0,
          moneyDelta: (e['moneyDelta'] as num?)?.toDouble() ?? 0.0,
        );

        if (e['annualIncomeMod'] != null) {
          c.annualIncome *= (e['annualIncomeMod'] as num).toDouble();
        }

        if (e['cibilDelta'] != null) {
          c.cibilScore = (c.cibilScore + (e['cibilDelta'] as int)).clamp(300, 900);
        }
      }
    }
  }

  static LifeEventType _inferType(String category) {
    switch (category) {
      case 'Financial':
        return LifeEventType.neutral;
      case 'Relationships':
        return LifeEventType.neutral;
      case 'Education':
        return LifeEventType.milestone;
      case 'Rare':
        return LifeEventType.rare;
      case 'Chaos':
        return LifeEventType.negative;
      default:
        return LifeEventType.neutral;
    }
  }



  static String _formatNum(double n) {
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(1)}Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }

  // ── NEW EVENT LOGIC ─────────────────────────────────────────────────────────

  static LifeEventType inferEventType(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('born') ||
        lower.contains('promoted') ||
        lower.contains('earned') ||
        lower.contains('welcome') ||
        lower.contains('unlocked') ||
        lower.contains('blessed') ||
        lower.contains('achievement') ||
        lower.contains('🌟') ||
        lower.contains('🎉') ||
        lower.contains('💰')) {
      return LifeEventType.positive;
    }
    if (lower.contains('lost') ||
        lower.contains('died') ||
        lower.contains('failed') ||
        lower.contains('fired') ||
        lower.contains('debt') ||
        lower.contains('sick') ||
        lower.contains('❌') ||
        lower.contains('💸')) {
      return LifeEventType.negative;
    }
    if (lower.contains('began') ||
        lower.contains('joined') ||
        lower.contains('started') ||
        lower.contains('🎓') ||
        lower.contains('🏠')) {
      return LifeEventType.milestone;
    }
    return LifeEventType.neutral;
  }

  static EventPriority inferPriority(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('iit') || lower.contains('ias') || lower.contains('ceo')) return EventPriority.critical;
    if (lower.contains('win') || lower.contains('viral') || lower.contains('billionaire')) return EventPriority.rare;
    if (lower.contains('promoted') || lower.contains('graduated')) return EventPriority.important;
    return EventPriority.normal;
  }

  // ── INVESTMENT SYSTEM LOGIC ──────────────────────────────────────────────────

  static void _updateMarketPrices(Character c, List<LifeEvent> events) {
    bool pricesInitialized = c.marketPrices.isNotEmpty;

    // Initialize if first time
    if (!pricesInitialized) {
      final newPool = <dynamic, dynamic>{};
      for (var asset in InvestmentsData.all) {
        newPool[asset.name] = asset.initialPrice;
      }
      c.marketPrices = newPool;
    }

    final newPrices = Map<dynamic, dynamic>.from(c.marketPrices);

    // Random market events
    bool marketCrash = _rng.nextDouble() < 0.05;
    bool marketBoom = _rng.nextDouble() < 0.05;

    for (var asset in InvestmentsData.all) {
      double currentPrice = (newPrices[asset.name] as num).toDouble();
      double volatility = asset.volatility;

      // Calculate basic change
      double change;
      if (asset.type == 'Bond') {
        // Bonds are stable: 6-8% growth
        change = 0.06 + (_rng.nextDouble() * 0.02);
      } else {
        // Stocks and Crypto use volatility
        double range = volatility * 2;
        change = (_rng.nextDouble() * range) - volatility;

        // Smart AI: slightly bias towards positive if smart
        if (c.smarts > 75) change += 0.02;
        if (c.smarts < 40) change -= 0.02;

        // Apply global events
        if (marketCrash && asset.type != 'Bond') {
          change -= 0.15;
        }
        if (marketBoom && asset.type != 'Bond') {
          change += 0.15;
        }
      }

      double updatedPrice = currentPrice * (1 + change);
      newPrices[asset.name] = updatedPrice.clamp(1.0, double.infinity);
    }

    c.marketPrices = newPrices;

    // Update portfolios with current prices
    _syncPortfolioPrices(c);

    // Add summary event
    if (marketCrash) {
      _addEvent(events, c.age, '🚨 MARKET CRASH!',
          description: 'Stocks and Crypto have plummeted globally!',
          type: LifeEventType.critical,
          priority: EventPriority.important);
    }
    if (marketBoom) {
      _addEvent(events, c.age, '🚀 MARKET BOOM!',
          description: 'Investors are celebrating as prices soar!',
          type: LifeEventType.positive,
          priority: EventPriority.important);
    }
  }

  static void _syncPortfolioPrices(Character c) {
    _syncList(c.stockPortfolio, c.marketPrices);
    _syncList(c.cryptoPortfolio, c.marketPrices);
    _syncList(c.bondPortfolio, c.marketPrices);
  }

  static void _syncList(
      List<Map<dynamic, dynamic>> portfolio, Map<dynamic, dynamic> prices) {
    for (var item in portfolio) {
      if (prices.containsKey(item['name'])) {
        item['currentPrice'] = prices[item['name']];
      }
    }
  }

  static String buyInvestment(Character c, MarketAsset asset, double quantity) {
    double totalCost = asset.initialPrice *
        quantity; // This should use market price, fixing below
    double marketPrice = (c.marketPrices[asset.name] as num).toDouble();
    totalCost = marketPrice * quantity;

    if (c.bankBalance < totalCost) {
      return '❌ You don\'t have enough cash!';
    }

    c.bankBalance -= totalCost;

    List<Map<dynamic, dynamic>> portfolio;
    if (asset.type == 'Stock') {
      portfolio = c.stockPortfolio;
    } else if (asset.type == 'Crypto') {
      portfolio = c.cryptoPortfolio;
    } else {
      portfolio = c.bondPortfolio;
    }

    // Check if already in portfolio to update avg price
    int existingIdx =
        portfolio.indexWhere((item) => item['name'] == asset.name);
    if (existingIdx != -1) {
      final item = Map<dynamic, dynamic>.from(portfolio[existingIdx]);
      double oldQty = (item['quantity'] as num).toDouble();
      double oldBuyPrice = (item['buyPrice'] as num).toDouble();

      double newQty = oldQty + quantity;
      double newBuyPrice =
          ((oldBuyPrice * oldQty) + (marketPrice * quantity)) / newQty;

      item['quantity'] = newQty;
      item['buyPrice'] = newBuyPrice;
      item['currentPrice'] = marketPrice;
      portfolio[existingIdx] = item;
    } else {
      portfolio.add({
        'name': asset.name,
        'quantity': quantity,
        'buyPrice': marketPrice,
        'currentPrice': marketPrice,
      });
    }

    return '✅ BOUGHT! You acquired $quantity units of ${asset.name}.';
  }

  static String sellInvestment(Character c, String type, int index) {
    List<Map<dynamic, dynamic>> portfolio;
    if (type == 'Stock') {
      portfolio = c.stockPortfolio;
    } else if (type == 'Crypto') {
      portfolio = c.cryptoPortfolio;
    } else {
      portfolio = c.bondPortfolio;
    }

    if (index < 0 || index >= portfolio.length) {
      return '❌ Invalid asset selection.';
    }

    final item = portfolio[index];
    double qty = (item['quantity'] as num).toDouble();
    double currentPrice = (item['currentPrice'] as num).toDouble();
    double buyPrice = (item['buyPrice'] as num).toDouble();

    double saleValue = qty * currentPrice;
    double profit = saleValue - (qty * buyPrice);

    c.bankBalance += saleValue;
    portfolio.removeAt(index);

    String pStr = profit >= 0
        ? 'Profit: ₹${_formatNum(profit)}'
        : 'Loss: ₹${_formatNum(profit.abs())}';
    return '${profit >= 0 ? '💰' : '📉'} SOLD! You received ₹${_formatNum(saleValue)}. ($pStr)';
  }

  static void _updateRivals(Character c, List<LifeEvent> events, List<String> feedback) {
    if (c.age < 18) return;
    for (var rel in c.relationships) {
      if (rel.isRival && rel.isAlive) {
        rel.rivalIntensity = (rel.rivalIntensity + _rng.nextInt(5)).clamp(0, 100);
        if (_rng.nextDouble() < 0.15) {
          final achievements = ['got promoted.', 'bought a car.', 'won an award.'];
          final text = achievements[_rng.nextInt(achievements.length)];
          _addEvent(events, c.age, '⚔️ RIVALRY: ${rel.name}', 
            description: '${rel.name} $text The pressure is on.',
            type: LifeEventType.negative);
          c.updateStats(happinessDelta: -10);
          feedback.add('😟 SOCIAL PRESSURE: ${rel.name} is pulling ahead.');
        }
      }
    }
  }

  static void _processRegrets(Character c, List<LifeEvent> events, List<String> feedback) {
    if (c.majorDecisions.isEmpty || _rng.nextDouble() > 0.10) return;
    final decision = c.majorDecisions[_rng.nextInt(c.majorDecisions.length)];
    if (c.age - (decision['age'] as int? ?? 0) > 10) {
      _addEvent(events, c.age, '💭 Echoes of the Past', 
        description: 'You regret choice: ${decision['choice']}.', type: LifeEventType.negative);
      c.updateStats(happinessDelta: -12);
      feedback.add('🧠 REGRET: Past decisions are haunting you.');
    }
  }

  static void _generateTensionSignals(Character c) {
    c.tensionSignals.clear();
    if (c.health < 40) c.tensionSignals.add('⚠️ Your body feels heavy.');
    if (c.bankBalance < c.annualExpenses) c.tensionSignals.add('💸 Money is tight.');
  }
}
