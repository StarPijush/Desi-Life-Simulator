import '../core/enums.dart';
import '../models/character.dart';
import '../models/event_choice.dart';

class SmartEvent {
  final String title;
  final String desc;
  final String type;
  final String? tier;
  final String? category;
  final EventRarity rarity;
  final double weight;
  
  // Optional stats changes if it's not a choice event
  final int happiness;
  final int health;
  final int smarts;
  final int social;
  final int karma;
  final double money;
  final int fame;
  final int followers;
  final int stressLevel;
  final int looks;
  final int jobPerformance;
  final int discipline;
  final int reputation;
  final double annualIncomeMod;
  final int cibilDelta;

  final bool Function(Character) cond;
  final EventChoice? choice;

  final bool popupEligible;
  final int popupPriority;

  const SmartEvent({
    required this.title,
    required this.desc,
    required this.type,
    this.tier,
    this.category,
    this.rarity = EventRarity.common,
    this.weight = 1.0,
    this.happiness = 0,
    this.health = 0,
    this.smarts = 0,
    this.social = 0,
    this.karma = 0,
    this.money = 0.0,
    this.fame = 0,
    this.followers = 0,
    this.stressLevel = 0,
    this.looks = 0,
    this.jobPerformance = 0,
    this.discipline = 0,
    this.reputation = 0,
    this.annualIncomeMod = 1.0,
    this.cibilDelta = 0,
    required this.cond,
    this.choice,
    this.popupEligible = false,
    this.popupPriority = 0,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'desc': desc,
    'type': type,
    'tier': tier,
    'category': category,
    'rarity': rarity,
    'weight': weight,
    'happiness': happiness,
    'health': health,
    'smarts': smarts,
    'social': social,
    'karma': karma,
    'money': money,
    'fame': fame,
    'followers': followers,
    'stressLevel': stressLevel,
    'looks': looks,
    'jobPerformance': jobPerformance,
    'discipline': discipline,
    'reputation': reputation,
    'annualIncomeMod': annualIncomeMod,
    'cibilDelta': cibilDelta,
    'cond': cond,
    'choice': choice?.toMap(),
    'popupEligible': popupEligible,
    'popupPriority': popupPriority,
  };
}
