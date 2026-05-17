import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/loan_model.dart';
import '../models/life_event.dart';
import '../models/relationship.dart';
import '../models/event_choice.dart';
import 'assets_data.dart';
import 'investments_data.dart';
import 'event_data.dart';
import 'enums.dart';
import 'career_data.dart';
import 'institute_data.dart';

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

  AgeUpResult({
    required this.events,
    required this.statChanges,
    required this.character,
    required this.sourceVersion,
    this.triggeredChaos = false,
    this.died = false,
    List<String>? newAchievements,
    List<String>? personalityFeedback,
  })  : newAchievements =
            List<String>.from(newAchievements ?? [], growable: true),
        personalityFeedback =
            List<String>.from(personalityFeedback ?? [], growable: true);

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
        events: List<LifeEvent>.from(
          (json['events'] as List).map((e) => LifeEvent.fromJson(e)),
          growable: true,
        ),
        statChanges: Map<String, int>.from(json['statChanges']),
        triggeredChaos: json['triggeredChaos'] ?? false,
        died: json['died'] ?? false,
        newAchievements:
            List<String>.from(json['newAchievements'] ?? [], growable: true),
        personalityFeedback: List<String>.from(
            json['personalityFeedback'] ?? [],
            growable: true),
        character: Character.fromJson(json['character']),
        sourceVersion: json['sourceVersion'] as int? ?? 0,
      );
}

// ── Operation Results ────────────────────────────────────────────────────────
class ActionResult {
  final String message;
  final Character character;
  final bool success;
  final List<LifeEvent> events;
  final List<String> progressionHints;

  ActionResult({
    required this.message,
    required this.character,
    this.success = true,
    List<LifeEvent>? events,
    List<String>? progressionHints,
  })  : events = List<LifeEvent>.from(
          events == null
              ? [_actionEventFromMessage(message, character, success)]
              : events.isEmpty
                  ? [_quietFallbackEvent(character)]
                  : events,
          growable: true,
        ),
        progressionHints = List<String>.from(progressionHints ?? [], growable: true);
}

class GameAction {
  final String type;
  final Map<String, dynamic> payload;

  const GameAction(this.type, [this.payload = const {}]);

  @override
  String toString() => 'GameAction(type: $type, payload: $payload)';
}

typedef GameActionHandler = ActionResult Function(GameAction action);

LifeEvent _actionEventFromMessage(
    String message, Character character, bool success) {
  return LifeEvent(
    title: _actionEventTitle(message),
    description: message,
    type: success ? _actionEventType(message) : LifeEventType.negative,
    metadata: {
      'age': character.age,
      'source': 'action',
    },
  );
}

String _actionEventTitle(String message) {
  final clean = message.replaceFirst(RegExp(r'^[^A-Za-z0-9_]+'), '').trim();
  if (clean.isEmpty) return 'Life action';
  return clean.length <= 44 ? clean : '${clean.substring(0, 41)}...';
}

LifeEventType _actionEventType(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('failed') ||
      lower.contains('rejected') ||
      lower.contains('missed') ||
      lower.contains('insufficient') ||
      lower.contains('warning') ||
      lower.contains('fired') ||
      lower.contains('demoted') ||
      lower.contains('job lost') ||
      lower.contains('can\'t') ||
      lower.contains('cannot')) {
    return LifeEventType.negative;
  }
  if (lower.contains('approved') ||
      lower.contains('bought') ||
      lower.contains('passed') ||
      lower.contains('promoted') ||
      lower.contains('hired') ||
      lower.contains('success') ||
      lower.contains('started') ||
      lower.contains('profit') ||
      lower.contains('welcome') ||
      lower.contains('deposited') ||
      lower.contains('received')) {
    return LifeEventType.positive;
  }
  return LifeEventType.neutral;
}

class CareerSwitchOffer {
  final CareerGroup optionA;
  final CareerGroup optionB;
  const CareerSwitchOffer({required this.optionA, required this.optionB});
}

class CareerStep {
  final String title;
  final double annualSalary;
  final int smartsToReach;
  final int minYearsToPromote;
  final String emoji;

  const CareerStep({
    required this.title,
    required this.annualSalary,
    required this.emoji,
    this.smartsToReach = 0,
    this.minYearsToPromote = 1,
  });
}

class CareerGroup {
  final String name;
  final String emoji;
  final String description;
  final int smartsToEnter;
  final String eduToEnter;
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

LifeEvent _quietFallbackEvent(Character character) {
  return LifeEvent(
    title: 'A quiet year passes...',
    description: 'Nothing significant happened this year.',
    type: LifeEventType.neutral,
    metadata: {
      'age': character.age,
      'source': 'empty_result_fallback',
    },
  );
}

class SpecialCareerDefinition {
  final String name;
  final String entryTitle;
  final String description;
  final int minAge;
  final int smartsReq;
  final int socialReq;
  final String eduReq;
  final double startingSalary;
  final double risk;
  final String actionVerb;
  final String successEvent;
  final String failureEvent;

  const SpecialCareerDefinition({
    required this.name,
    required this.entryTitle,
    required this.description,
    required this.minAge,
    required this.smartsReq,
    required this.socialReq,
    required this.eduReq,
    required this.startingSalary,
    required this.risk,
    required this.actionVerb,
    required this.successEvent,
    required this.failureEvent,
  });
}

class CareerSystem {
  static const List<SpecialCareerDefinition> specialCareers = [
    SpecialCareerDefinition(
      name: 'Actor',
      entryTitle: 'Struggling Actor',
      description: 'Auditions, fame, and volatile paydays.',
      minAge: 18,
      smartsReq: 25,
      socialReq: 65,
      eduReq: 'None',
      startingSalary: 180000,
      risk: 0.55,
      actionVerb: 'auditioned for a major role',
      successEvent: 'A casting director loved your screen presence.',
      failureEvent: 'The audition went cold and confidence took a hit.',
    ),
    SpecialCareerDefinition(
      name: 'Musician',
      entryTitle: 'Local Musician',
      description: 'Gigs, albums, tours, and sudden viral fame.',
      minAge: 16,
      smartsReq: 20,
      socialReq: 60,
      eduReq: 'None',
      startingSalary: 120000,
      risk: 0.52,
      actionVerb: 'released new music',
      successEvent: 'Your track caught attention and bookings improved.',
      failureEvent: 'The release barely moved and expenses stung.',
    ),
    SpecialCareerDefinition(
      name: 'Athlete',
      entryTitle: 'District Athlete',
      description: 'Training, selection pressure, and short peak years.',
      minAge: 16,
      smartsReq: 20,
      socialReq: 45,
      eduReq: 'Secondary',
      startingSalary: 240000,
      risk: 0.6,
      actionVerb: 'trained for a championship',
      successEvent: 'Scouts noticed your performance.',
      failureEvent: 'A poor season slowed your momentum.',
    ),
    SpecialCareerDefinition(
      name: 'Politician',
      entryTitle: 'Party Worker',
      description: 'Campaigns, public approval, and reputation risk.',
      minAge: 25,
      smartsReq: 55,
      socialReq: 75,
      eduReq: 'Graduate',
      startingSalary: 360000,
      risk: 0.58,
      actionVerb: 'ran a public campaign',
      successEvent: 'Your campaign connected with voters.',
      failureEvent: 'A controversy damaged public trust.',
    ),
    SpecialCareerDefinition(
      name: 'Entrepreneur',
      entryTitle: 'Startup Founder',
      description: 'Build products, raise capital, and chase scale.',
      minAge: 21,
      smartsReq: 65,
      socialReq: 45,
      eduReq: 'Higher Secondary',
      startingSalary: 300000,
      risk: 0.62,
      actionVerb: 'pitched your venture',
      successEvent: 'Customers and mentors responded strongly.',
      failureEvent: 'The pitch missed and cash pressure rose.',
    ),
    SpecialCareerDefinition(
      name: 'Influencer',
      entryTitle: 'Micro Influencer',
      description: 'Content grind, brand deals, and relevance decay.',
      minAge: 16,
      smartsReq: 25,
      socialReq: 70,
      eduReq: 'None',
      startingSalary: 150000,
      risk: 0.5,
      actionVerb: 'posted a high-effort campaign',
      successEvent: 'The post took off and brands started calling.',
      failureEvent: 'The campaign flopped and engagement dipped.',
    ),
    SpecialCareerDefinition(
      name: 'Lawyer',
      entryTitle: 'Junior Lawyer',
      description: 'Cases, reputation, and high-stakes clients.',
      minAge: 23,
      smartsReq: 75,
      socialReq: 65,
      eduReq: 'Graduate',
      startingSalary: 600000,
      risk: 0.42,
      actionVerb: 'argued an important case',
      successEvent: 'Your argument impressed clients and seniors.',
      failureEvent: 'The case went badly and your reputation slipped.',
    ),
    SpecialCareerDefinition(
      name: 'Scientist',
      entryTitle: 'Research Associate',
      description: 'Research grants, discoveries, and slow prestige.',
      minAge: 22,
      smartsReq: 85,
      socialReq: 35,
      eduReq: 'Graduate',
      startingSalary: 540000,
      risk: 0.38,
      actionVerb: 'pursued a research breakthrough',
      successEvent: 'Your research produced a promising result.',
      failureEvent: 'Months of experiments produced little progress.',
    ),
    SpecialCareerDefinition(
      name: 'Army',
      entryTitle: 'Army Cadet',
      description: 'Service, discipline, danger, and honor.',
      minAge: 18,
      smartsReq: 45,
      socialReq: 45,
      eduReq: 'Secondary',
      startingSalary: 420000,
      risk: 0.57,
      actionVerb: 'completed a tough service assignment',
      successEvent: 'Your discipline earned respect from command.',
      failureEvent: 'The assignment was brutal and health suffered.',
    ),
    SpecialCareerDefinition(
      name: 'Director',
      entryTitle: 'Assistant Director',
      description: 'Shoots, budgets, critics, and blockbuster upside.',
      minAge: 21,
      smartsReq: 55,
      socialReq: 65,
      eduReq: 'Higher Secondary',
      startingSalary: 300000,
      risk: 0.54,
      actionVerb: 'directed a risky project',
      successEvent: 'The project won attention and your network grew.',
      failureEvent: 'The shoot overran and reviews were harsh.',
    ),
  ];

  static const List<CareerGroup> allGroups = [
    CareerGroup(
      name: 'Tech',
      emoji: '??',
      description: 'Software & Technology',
      smartsToEnter: 50,
      eduToEnter: 'Graduate',
      steps: [
        CareerStep(
            title: 'IT Intern',
            annualSalary: 144000,
            smartsToReach: 50,
            minYearsToPromote: 1,
            emoji: '???'),
        CareerStep(
            title: 'Junior Developer',
            annualSalary: 360000,
            smartsToReach: 58,
            minYearsToPromote: 2,
            emoji: '?????'),
        CareerStep(
            title: 'Software Developer',
            annualSalary: 720000,
            smartsToReach: 65,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Senior Developer',
            annualSalary: 1440000,
            smartsToReach: 75,
            minYearsToPromote: 3,
            emoji: '?????'),
        CareerStep(
            title: 'Tech Lead',
            annualSalary: 2400000,
            smartsToReach: 82,
            minYearsToPromote: 4,
            emoji: '???'),
        CareerStep(
            title: 'CTO',
            annualSalary: 4800000,
            smartsToReach: 90,
            minYearsToPromote: 5,
            emoji: '?'),
      ],
    ),
    CareerGroup(
      name: 'Government',
      emoji: '???',
      description: 'Civil Services & Government',
      smartsToEnter: 35,
      eduToEnter: 'Secondary',
      steps: [
        CareerStep(
            title: 'Government Peon',
            annualSalary: 120000,
            smartsToReach: 35,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Government Clerk',
            annualSalary: 300000,
            smartsToReach: 45,
            minYearsToPromote: 3,
            emoji: '???'),
        CareerStep(
            title: 'Government Officer',
            annualSalary: 540000,
            smartsToReach: 58,
            minYearsToPromote: 4,
            emoji: '??'),
        CareerStep(
            title: 'Senior Officer',
            annualSalary: 840000,
            smartsToReach: 68,
            minYearsToPromote: 4,
            emoji: '???'),
        CareerStep(
            title: 'IAS Officer',
            annualSalary: 1500000,
            smartsToReach: 80,
            minYearsToPromote: 5,
            emoji: '???'),
        CareerStep(
            title: 'Chief Secretary',
            annualSalary: 2500000,
            smartsToReach: 88,
            minYearsToPromote: 6,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Corporate',
      emoji: '??',
      description: 'Business & Management',
      smartsToEnter: 40,
      eduToEnter: 'Graduate',
      steps: [
        CareerStep(
            title: 'Corporate Trainee',
            annualSalary: 240000,
            smartsToReach: 40,
            minYearsToPromote: 1,
            emoji: '?????'),
        CareerStep(
            title: 'Executive',
            annualSalary: 480000,
            smartsToReach: 50,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Manager',
            annualSalary: 840000,
            smartsToReach: 60,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Senior Manager',
            annualSalary: 1440000,
            smartsToReach: 68,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Director',
            annualSalary: 2400000,
            smartsToReach: 76,
            minYearsToPromote: 4,
            emoji: '??'),
        CareerStep(
            title: 'CEO',
            annualSalary: 6000000,
            smartsToReach: 85,
            minYearsToPromote: 5,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Medical',
      emoji: '??',
      description: 'Healthcare & Medicine',
      smartsToEnter: 75,
      eduToEnter: 'Graduate',
      steps: [
        CareerStep(
            title: 'Medical Intern',
            annualSalary: 300000,
            smartsToReach: 75,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Junior Doctor',
            annualSalary: 600000,
            smartsToReach: 78,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Doctor',
            annualSalary: 1200000,
            smartsToReach: 82,
            minYearsToPromote: 3,
            emoji: '?????'),
        CareerStep(
            title: 'Senior Doctor',
            annualSalary: 2000000,
            smartsToReach: 86,
            minYearsToPromote: 4,
            emoji: '??'),
        CareerStep(
            title: 'Head of Department',
            annualSalary: 3600000,
            smartsToReach: 90,
            minYearsToPromote: 5,
            emoji: '??'),
        CareerStep(
            title: 'Chief Medical Officer',
            annualSalary: 6000000,
            smartsToReach: 94,
            minYearsToPromote: 5,
            emoji: '?'),
      ],
    ),
    CareerGroup(
      name: 'Business',
      emoji: '??',
      description: 'Entrepreneurship & Trade',
      smartsToEnter: 20,
      eduToEnter: 'None',
      steps: [
        CareerStep(
            title: 'Street Hawker',
            annualSalary: 96000,
            smartsToReach: 20,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Shopkeeper',
            annualSalary: 240000,
            smartsToReach: 30,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Small Business Owner',
            annualSalary: 600000,
            smartsToReach: 42,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Business Owner',
            annualSalary: 1500000,
            smartsToReach: 55,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Entrepreneur',
            annualSalary: 3000000,
            smartsToReach: 65,
            minYearsToPromote: 4,
            emoji: '??'),
        CareerStep(
            title: 'Business Tycoon',
            annualSalary: 10000000,
            smartsToReach: 80,
            minYearsToPromote: 5,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Arts',
      emoji: '??',
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
            emoji: '??'),
        CareerStep(
            title: 'Content Creator',
            annualSalary: 300000,
            smartsToReach: 35,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Influencer',
            annualSalary: 720000,
            smartsToReach: 42,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Artist / Director',
            annualSalary: 1500000,
            smartsToReach: 52,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Celebrity',
            annualSalary: 3600000,
            smartsToReach: 60,
            minYearsToPromote: 4,
            emoji: '??'),
        CareerStep(
            title: 'Superstar',
            annualSalary: 12000000,
            smartsToReach: 68,
            minYearsToPromote: 5,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Part-Time',
      emoji: '??',
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
            emoji: '??'),
        CareerStep(
            title: 'Store Assistant',
            annualSalary: 120000,
            smartsToReach: 30,
            minYearsToPromote: 1,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Freelancing',
      emoji: '?????',
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
            emoji: '??'),
        CareerStep(
            title: 'Expert consultant',
            annualSalary: 1200000,
            smartsToReach: 80,
            minYearsToPromote: 3,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Actor',
      emoji: '??',
      description: 'Film, TV, and fame',
      smartsToEnter: 25,
      eduToEnter: 'None',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Struggling Actor',
            annualSalary: 180000,
            smartsToReach: 25,
            minYearsToPromote: 1,
            emoji: '??'),
        CareerStep(
            title: 'TV Actor',
            annualSalary: 600000,
            smartsToReach: 35,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Film Actor',
            annualSalary: 2400000,
            smartsToReach: 45,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Superstar Actor',
            annualSalary: 12000000,
            smartsToReach: 60,
            minYearsToPromote: 4,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Musician',
      emoji: '??',
      description: 'Songs, gigs, and tours',
      smartsToEnter: 20,
      eduToEnter: 'None',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Local Musician',
            annualSalary: 120000,
            smartsToReach: 20,
            minYearsToPromote: 1,
            emoji: '??'),
        CareerStep(
            title: 'Indie Artist',
            annualSalary: 480000,
            smartsToReach: 30,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Touring Musician',
            annualSalary: 1800000,
            smartsToReach: 42,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Music Icon',
            annualSalary: 9000000,
            smartsToReach: 58,
            minYearsToPromote: 4,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Athlete',
      emoji: '??',
      description: 'Sporting career with injury risk',
      smartsToEnter: 20,
      eduToEnter: 'Secondary',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'District Athlete',
            annualSalary: 240000,
            smartsToReach: 20,
            minYearsToPromote: 1,
            emoji: '??'),
        CareerStep(
            title: 'State Athlete',
            annualSalary: 900000,
            smartsToReach: 30,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'National Athlete',
            annualSalary: 3600000,
            smartsToReach: 40,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Sports Legend',
            annualSalary: 15000000,
            smartsToReach: 50,
            minYearsToPromote: 4,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Politician',
      emoji: '??',
      description: 'Public life and power',
      smartsToEnter: 55,
      eduToEnter: 'Graduate',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Party Worker',
            annualSalary: 360000,
            smartsToReach: 55,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Councillor',
            annualSalary: 900000,
            smartsToReach: 62,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'MLA',
            annualSalary: 1800000,
            smartsToReach: 72,
            minYearsToPromote: 4,
            emoji: '??'),
        CareerStep(
            title: 'Cabinet Minister',
            annualSalary: 4200000,
            smartsToReach: 84,
            minYearsToPromote: 5,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Entrepreneur',
      emoji: '??',
      description: 'Startup risk and reward',
      smartsToEnter: 65,
      eduToEnter: 'Higher Secondary',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Startup Founder',
            annualSalary: 300000,
            smartsToReach: 65,
            minYearsToPromote: 1,
            emoji: '??'),
        CareerStep(
            title: 'Funded Founder',
            annualSalary: 1500000,
            smartsToReach: 72,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Scale-up CEO',
            annualSalary: 6000000,
            smartsToReach: 82,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Unicorn Founder',
            annualSalary: 25000000,
            smartsToReach: 92,
            minYearsToPromote: 4,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Influencer',
      emoji: '??',
      description: 'Audience and brand deals',
      smartsToEnter: 25,
      eduToEnter: 'None',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Micro Influencer',
            annualSalary: 150000,
            smartsToReach: 25,
            minYearsToPromote: 1,
            emoji: '??'),
        CareerStep(
            title: 'Content Creator',
            annualSalary: 720000,
            smartsToReach: 35,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Brand Influencer',
            annualSalary: 3000000,
            smartsToReach: 45,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Internet Celebrity',
            annualSalary: 12000000,
            smartsToReach: 60,
            minYearsToPromote: 4,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Lawyer',
      emoji: '??',
      description: 'Cases and clients',
      smartsToEnter: 75,
      eduToEnter: 'Graduate',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Junior Lawyer',
            annualSalary: 600000,
            smartsToReach: 75,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Associate Lawyer',
            annualSalary: 1500000,
            smartsToReach: 80,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Senior Advocate',
            annualSalary: 4800000,
            smartsToReach: 88,
            minYearsToPromote: 4,
            emoji: '??'),
        CareerStep(
            title: 'Legal Legend',
            annualSalary: 12000000,
            smartsToReach: 95,
            minYearsToPromote: 5,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Scientist',
      emoji: '??',
      description: 'Research and discovery',
      smartsToEnter: 85,
      eduToEnter: 'Graduate',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Research Associate',
            annualSalary: 540000,
            smartsToReach: 85,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Scientist',
            annualSalary: 1500000,
            smartsToReach: 90,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Principal Scientist',
            annualSalary: 3600000,
            smartsToReach: 94,
            minYearsToPromote: 4,
            emoji: '??'),
        CareerStep(
            title: 'National Laureate',
            annualSalary: 9000000,
            smartsToReach: 98,
            minYearsToPromote: 5,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Army',
      emoji: '??',
      description: 'Service and discipline',
      smartsToEnter: 45,
      eduToEnter: 'Secondary',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Army Cadet',
            annualSalary: 420000,
            smartsToReach: 45,
            minYearsToPromote: 1,
            emoji: '??'),
        CareerStep(
            title: 'Lieutenant',
            annualSalary: 900000,
            smartsToReach: 55,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Major',
            annualSalary: 1800000,
            smartsToReach: 68,
            minYearsToPromote: 4,
            emoji: '??'),
        CareerStep(
            title: 'General',
            annualSalary: 4200000,
            smartsToReach: 82,
            minYearsToPromote: 5,
            emoji: '??'),
      ],
    ),
    CareerGroup(
      name: 'Director',
      emoji: '??',
      description: 'Films, budgets, and critics',
      smartsToEnter: 55,
      eduToEnter: 'Higher Secondary',
      tier: CareerTier.special,
      steps: [
        CareerStep(
            title: 'Assistant Director',
            annualSalary: 300000,
            smartsToReach: 55,
            minYearsToPromote: 1,
            emoji: '??'),
        CareerStep(
            title: 'TV Director',
            annualSalary: 1200000,
            smartsToReach: 62,
            minYearsToPromote: 2,
            emoji: '??'),
        CareerStep(
            title: 'Film Director',
            annualSalary: 4800000,
            smartsToReach: 72,
            minYearsToPromote: 3,
            emoji: '??'),
        CareerStep(
            title: 'Award-winning Director',
            annualSalary: 15000000,
            smartsToReach: 85,
            minYearsToPromote: 4,
            emoji: '??'),
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

  static SpecialCareerDefinition? findSpecial(String name) {
    try {
      return specialCareers.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }

  static bool canEnterSpecial(SpecialCareerDefinition career, Character c) {
    return c.age >= career.minAge &&
        c.smarts >= career.smartsReq &&
        c.social >= career.socialReq &&
        _eduLevel(c.educationLevel) >= _eduLevel(career.eduReq);
  }

  static List<CareerGroup> eligibleGroups(Character c, {CareerTier? tier}) {
    return allGroups.where((g) {
      final matchesTier =
          tier == null ? g.tier != CareerTier.special : g.tier == tier;
      return matchesTier && canEnter(g, c);
    }).toList();
  }

  static List<CareerGroup> alternativeGroups(Character c, {CareerTier? tier}) {
    final current = c.careerGroup;
    final eligible =
        eligibleGroups(c, tier: tier).where((g) => g.name != current).toList();
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
    c.jobLevel = 0;
    c.yearsInJob = 0;
    c.jobPerformance = 50;
    c.hasCareerWarning = false;
    final step = group.steps.first;
    c.jobTitle = step.title;
    c.annualIncome = step.annualSalary;
  }

  static String switchCareer(Character c, CareerGroup newGroup) {
    assignCareer(c, newGroup);
    c.smarts = (c.smarts - 5).clamp(0, 100);
    c.happiness = (c.happiness + 10).clamp(0, 100);
    return 'Career switch: you joined ${newGroup.name} as ${newGroup.steps.first.title}. Salary: ${GameEngine.formatMoney(newGroup.steps.first.annualSalary)}/yr.';
  }

  static String? tryPromotion(Character c, Random rng) {
    final group = findGroup(c.careerGroup);
    if (group == null || c.careerGroup == 'None') return null;

    final currentStepIdx = c.careerStep;
    if (currentStepIdx >= group.steps.length - 1) return null;

    final currentStep = group.steps[currentStepIdx];
    final nextStep = group.steps[currentStepIdx + 1];

    if (c.yearsInRole < currentStep.minYearsToPromote || c.yearsInJob < 1) {
      return null;
    }
    if (c.smarts < nextStep.smartsToReach) return null;
    if (c.jobPerformance <= 70) return null;

    final lacksEdu = _eduLevel(c.educationLevel) < _eduLevel(group.eduToEnter);
    if (lacksEdu && c.smarts < 95) {
      if (rng.nextDouble() < 0.1) {
        c.tensionSignals.add(
          'Career ceiling: you need more education before this promotion can happen.',
        );
      }
      return null;
    }

    double chanceScore =
        (c.jobPerformance + (c.ambition / 5) + rng.nextInt(21)).clamp(0, 100).toDouble();
    chanceScore *= (c.hiddenModifiers['promotionChance'] ?? 1.0);
    chanceScore = chanceScore.clamp(0, 100);

    final roll = rng.nextInt(100);
    if (roll >= chanceScore) {
      if ((roll - chanceScore).abs() <= 5) {
        c.tensionSignals.add(
          'You were close to a promotion. One stronger year could push it through.',
        );
        c.updateStats(happinessDelta: -5);
      }
      return null;
    }

    c.careerStep = currentStepIdx + 1;
    c.yearsInRole = 0;
    c.jobLevel = c.careerStep;
    c.yearsInJob = 0;
    c.jobTitle = nextStep.title;

    c.majorDecisions.add({
      'age': c.age,
      'type': 'Promotion',
      'title': nextStep.title,
      'salary': nextStep.annualSalary,
    });

    final inflationIndex = c.hiddenModifiers['economy_inflation'] ?? 1.0;
    final promotionBoost = 1.4 + rng.nextDouble() * 0.4;
    c.annualIncome = max(nextStep.annualSalary * inflationIndex,
        c.annualIncome * promotionBoost);
    c.happiness = (c.happiness + 8).clamp(0, 100);
    c.jobPerformance = (c.jobPerformance + 10).clamp(0, 100);
    c.hasCareerWarning = false;

    if (nextStep.title == 'IAS Officer') c.addAchievement('ias_officer');
    if (nextStep.title == 'Business Tycoon') c.addAchievement('entrepreneur');
    if (nextStep.title == 'Doctor') c.addAchievement('doctor');

    // High ambition = High stress upon promotion
    if (c.ambition > 70) {
      c.stressLevel = (c.stressLevel + 15).clamp(0, 100);
    }

    if (c.careerStep == group.steps.length - 1) {
      return 'Pinnacle reached: you are now ${nextStep.title}. Salary: ${GameEngine.formatMoney(nextStep.annualSalary)}/yr.';
    }
    return 'Promoted: you are now ${nextStep.title}. New salary: ${GameEngine.formatMoney(nextStep.annualSalary)}/yr.';
  }

  static String? tryDemotion(Character c, Random rng) {
    if (c.careerGroup == 'None' || c.annualIncome == 0) return null;
    if (c.age < 22) return null;
    if (c.lastDemotionAge == c.age || c.lastDemotionAge == c.age - 1) {
      return null;
    }

    if (c.jobPerformance >= 30) {
      c.hasCareerWarning = false;
      return null;
    }

    if (c.jobPerformance < 20) {
      final reputationPenalty = (100 - c.reputation) / 100.0;
      final fireChance = 0.40 + ((20 - c.jobPerformance) / 100) + (reputationPenalty * 0.2);
      if (rng.nextDouble() < fireChance) {
        c.jobTitle = 'Unemployed';
        c.annualIncome = 0;
        c.careerGroup = 'None';
        c.careerStep = 0;
        c.yearsInRole = 0;
        c.jobLevel = 0;
        c.yearsInJob = 0;
        c.jobPerformance = 50;
        c.hasCareerWarning = false;
        c.happiness = (c.happiness - 30).clamp(0, 100);
        return 'Fired: your performance fell too low and the company let you go.';
      }
    }

    if (!c.hasCareerWarning) {
      final warningChance = (0.4 + ((30 - c.jobPerformance) / 100)).clamp(
        0.0,
        0.8,
      );
      if (rng.nextDouble() < warningChance) {
        c.hasCareerWarning = true;
        return 'WARNING: your performance is slipping. Improve soon or your job could be at risk.';
      }
      return null;
    }

    final group = findGroup(c.careerGroup);
    if (group == null) return null;

    if (c.careerStep > 0) {
      c.careerStep -= 1;
      final step = group.steps[c.careerStep];
      c.jobTitle = step.title;
      c.annualIncome = step.annualSalary;
      c.jobLevel = c.careerStep;
      c.yearsInJob = 0;
      c.jobPerformance = 35;
      c.hasCareerWarning = false;
      c.lastDemotionAge = c.age;
      c.happiness = (c.happiness - 20).clamp(0, 100);
      c.stressLevel = (c.stressLevel + 15).clamp(0, 100);
      return 'Demoted: you were moved down to ${c.jobTitle} after a poor year. Your salary dropped.';
    }

    c.jobTitle = 'Unemployed';
    c.annualIncome = 0;
    c.careerGroup = 'None';
    c.careerStep = 0;
    c.yearsInRole = 0;
    c.jobLevel = 0;
    c.yearsInJob = 0;
    c.jobPerformance = 50;
    c.hasCareerWarning = false;
    c.happiness = (c.happiness - 30).clamp(0, 100);
    return 'Job lost: repeated warnings caught up with you and you are now unemployed.';
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
// ── Helpers ──────────────────────────────────────────────────────────────────
class DatingCandidate {
  final String name;
  final String initial;
  final int age;
  DatingCandidate(
      {required this.name, required this.initial, required this.age});
}

class GameEngine {
  static const List<String> _namesM = [
    'Arjun',
    'Rohan',
    'Vikram',
    'Aditya',
    'Karan',
    'Raj',
    'Amit',
    'Rahul',
    'Siddharth',
    'Varun'
  ];
  static const List<String> _namesF = [
    'Priya',
    'Ananya',
    'Kavya',
    'Meera',
    'Shruti',
    'Divya',
    'Pooja',
    'Nisha',
    'Ishani',
    'Kiara'
  ];

  static final Random _rng = Random();
  static const int _rareEventFrequency = 20;

  // ── formatMoney cache — avoids repeated string formatting for the same value
  static final _moneyCache = <double, String>{};
  static const int _moneyCacheMax = 64;

  static String formatMoney(double n) {
    final cached = _moneyCache[n];
    if (cached != null) return cached;

    final String val;
    if (n >= 10000000) {
      val = '${(n / 10000000).toStringAsFixed(1)}Cr';
    } else if (n >= 100000) {
      val = '${(n / 100000).toStringAsFixed(1)}L';
    } else if (n >= 1000) {
      val = '${(n / 1000).toStringAsFixed(0)}K';
    } else {
      val = n.toStringAsFixed(0);
    }
    final result = '₹$val';

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
      Map<String, int>? statChanges,
      Map<String, dynamic>? metadata}) {
    list.add(LifeEvent(
      title: title,
      description: description,
      type: type,
      priority: priority,
      statChanges: Map<String, int>.from(statChanges ?? {}),
      metadata:
          Map<String, dynamic>.from({...Map.from(metadata ?? {}), 'age': age}),
    ));
  }

  static List<LifeEvent> _guaranteeAgeUpEvents(
    Character character,
    List<LifeEvent> events,
  ) {
    if (events.isEmpty) {
      return [
        LifeEvent(
          title: 'A quiet year passes...',
          description: 'You focus on your routine. Nothing major happened.',
          type: LifeEventType.neutral,
          metadata: {'age': character.age, 'source': 'age_up_fallback'},
        )
      ];
    }

    // 1. Score events based on priority
    final scoredEvents = events.map((e) {
      int score = 0;
      switch (e.priority) {
        case EventPriority.critical:
          score = 4;
          break;
        case EventPriority.rare:
          score = 3;
          break;
        case EventPriority.important:
          score = 2;
          break;
        case EventPriority.normal:
          score = 1;
          break;
      }
      return MapEntry(e, score);
    }).toList();

    // 2. Sort by score descending
    scoredEvents.sort((a, b) => b.value.compareTo(a.value));

    // 3. Select Dominant Event
    final dominant = scoredEvents.first.key;

    // 4. Filter secondary events (Max 2)
    final List<LifeEvent> result = [dominant];
    final secondaryCandidates = scoredEvents.skip(1).map((e) => e.key).toList();
    
    int added = 0;
    for (var e in secondaryCandidates) {
      if (added >= 2) break;
      
      // Suppress lower-tier events if stronger events exist
      bool allowed = true;
      if (dominant.priority == EventPriority.critical || dominant.priority == EventPriority.rare) {
        if (e.priority == EventPriority.normal) {
          allowed = false; // Suppress normal events if we have a critical/rare focus
        }
      }
      
      if (allowed) {
        result.add(e);
        added++;
      }
    }

    return result;
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
    } else if (c.fame > 70) {
      title = 'Rising Star';
    } else if (c.financialIntelligence > 70 && c.bankBalance > 200000) {
      title = 'Strategic Investor';
    } else if (c.ambition > 80 && c.jobPerformance > 80) {
      title = 'Power Striver';
    } else if (c.reputation > 80) {
      title = 'Respected Icon';
    } else if (c.age < 13) {
      title = 'Innocent Dreamer';
    } else {
      title = 'Ordinary Citizen';
    }

    _cachedIdentityKey = key;
    _cachedIdentityTitle = title;
    return title;
  }

  static String calculateFinancialHealth(Character c) {
    if (c.bankBalance < 0 ||
        c.loanAmount > (c.annualIncome.clamp(1.0, double.infinity) * 5))
      return 'Critical';

    double emiLoad = 0;
    for (var l in c.loans) {
      emiLoad += l.yearlyEmi;
    }

    final income = c.annualIncome.clamp(1.0, double.infinity);
    final emiRatio = emiLoad / income;
    final debtRatio = c.loanAmount / income;

    if (emiRatio > 0.5 || debtRatio > 4) return 'Critical';
    if (emiRatio > 0.3 || debtRatio > 2) return 'Stable';
    return 'Strong';
  }

  static Character createNewCharacter({
    required String name,
    required String city,
    required String gender,
    required String personality,
  }) {
    final char = Character(
      name: name,
      city: city,
      gender: gender,
      personality: personality,
      age: 0,
    );
    // Ensure relationship list is a regular mutable List, not a HiveList.
    char.relationships = List<Relationship>.from(_generateFamily(char.city));
    return char;
  }

  static ActionResult processAction(Character input, GameAction action) {
    if (enableLogging) {
      debugPrint('[ACTION] Engine processing ${action.type}');
    }

    try {
      final result = _processAction(input.copyWith(), action);
      if (enableLogging) {
        debugPrint(
          '[ACTION] Events generated: ${result.events.length} for ${action.type}',
        );
      }
      return result;
    } catch (e, stack) {
      debugPrint('[ACTION] Engine failure for ${action.type}: $e');
      debugPrint('$stack');
      return ActionResult(
        message: 'Action failed safely: ${action.type}',
        character: input.copyWith(),
        success: false,
      );
    }
  }

  static ActionResult _processAction(Character character, GameAction action) {
    final payload = action.payload;
    switch (action.type) {
      case 'activity.perform':
        return performActivity(character, payload['activityId'] as String);
      case 'activity.add_partner':
        return addPartner(character, payload['candidate'] as DatingCandidate);
      case 'activity.find_love':
        return addPartner(character, generateDatingCandidate(character.age));
      case 'career.perform':
        return performCareerAction(character, payload['actionId'] as String);
      case 'bank.open_account':
        return openBankAccount(
          character,
          payload['bankName'] as String,
          payload['accountType'] as String,
          interestRate: (payload['interestRate'] as num?)?.toDouble(),
        );
      case 'bank.deposit_savings':
        return depositToSavings(
            character, (payload['amount'] as num).toDouble());
      case 'bank.withdraw_savings':
        return withdrawFromSavings(
            character, (payload['amount'] as num).toDouble());
      case 'bank.apply_credit_card':
        return applyForCreditCard(character);
      case 'bank.repay_credit_card':
        return repayCreditCard(
            character, (payload['amount'] as num).toDouble());
      case 'bank.take_student_loan':
        return takeStudentLoan(
            character, (payload['amount'] as num).toDouble());
      case 'bank.take_personal_loan':
        return takePersonalLoan(
            character, (payload['amount'] as num).toDouble());
      case 'bank.take_home_loan':
        return takeHomeLoan(character, (payload['amount'] as num).toDouble());
      case 'bank.repay_loan':
        return repayLoanAtIndex(
          character,
          payload['loanIndex'] as int,
          (payload['amount'] as num).toDouble(),
        );
      case 'bank.ask_parents':
        return askParentsForBank(character);
      case 'asset.buy':
        return buyAsset(character, payload['asset'] as GameAsset);
      case 'asset.repair':
        return repairAsset(character, payload['asset'] as GameAsset);
      case 'asset.sell':
        return sellAsset(character, payload['asset'] as GameAsset);
      case 'investment.buy':
        return buyInvestment(
          character,
          payload['asset'] as MarketAsset,
          (payload['quantity'] as num).toDouble(),
        );
      case 'investment.sell':
        return sellInvestment(
          character,
          payload['investmentType'] as String,
          payload['index'] as int,
        );
      case 'relation.interact':
        return interactWithRelationById(
          character,
          payload['relationshipId'] as String,
          payload['interactionType'] as String,
        );
    }

    return ActionResult(
      message: 'Unknown action: ${action.type}',
      character: character,
      success: false,
    );
  }

  static void _updateProgression(Character char, List<String> hints, {
    int reputation = 0,
    int fame = 0,
    int ambition = 0,
    int financialIntelligence = 0,
    int discipline = 0,
  }) {
    if (reputation != 0) {
      char.reputation = (char.reputation + reputation).clamp(0, 100);
      hints.add('Reputation ${reputation > 0 ? "↑" : "↓"}');
    }
    if (fame != 0) {
      char.fame = (char.fame + fame).clamp(0, 100);
      hints.add('Fame ${fame > 0 ? "↑" : "↓"}');
    }
    if (ambition != 0) {
      char.ambition = (char.ambition + ambition).clamp(0, 100);
      hints.add('Ambition ${ambition > 0 ? "↑" : "↓"}');
    }
    if (financialIntelligence != 0) {
      char.financialIntelligence = (char.financialIntelligence + financialIntelligence).clamp(0, 100);
      hints.add('Financial Intelligence ${financialIntelligence > 0 ? "↑" : "↓"}');
    }
    if (discipline != 0) {
      char.discipline = (char.discipline + discipline).clamp(0, 100);
      hints.add('Discipline ${discipline > 0 ? "↑" : "↓"}');
    }
  }

  static ActionResult performActivity(Character char, String activityId) {
    char = char.copyWith();
    String message = '';
    bool success = true;
    final List<String> hints = [];

    switch (activityId) {
      case 'Gym Workout':
        if (char.bankBalance < 500) {
          message = 'You don\'t have ₹500 for the gym membership.';
          success = false;
        } else {
          char.bankBalance -= 500;
          char.updateStats(healthDelta: 10, happinessDelta: 5);
          _updateProgression(char, hints, discipline: 3);
          message = 'You crushed your workout! You feel stronger and more disciplined.';
        }
        break;
      case 'Meditate for Focus':
      case 'Temple Visit':
        char.updateStats(karmaDelta: 5, happinessDelta: 5, stressDelta: -10);
        _updateProgression(char, hints, reputation: 2);
        message = 'You found inner peace. Your stress has melted away.';
        break;
      case 'Study Extra Hard':
      case 'Study Hard':
        char.updateStats(smartsDelta: 12, happinessDelta: -10, stressDelta: 15);
        _updateProgression(char, hints, ambition: 5, discipline: 5);
        message = 'You pushed yourself to the limit studying. You\'re becoming a top-tier scholar.';
        break;
      case 'Socialize':
        char.updateStats(socialDelta: 10, happinessDelta: 10);
        _updateProgression(char, hints, reputation: 3);
        message = 'You spent quality time building your social circle.';
        break;
      case 'Party with Friends':
      case 'Go to Party':
        if (char.bankBalance < 2000) {
          message = 'You don\'t have ₹2,000 to party.';
          success = false;
        } else {
          char.bankBalance -= 2000;
          char.updateStats(socialDelta: 15, happinessDelta: 15, healthDelta: -5);
          _updateProgression(char, hints, fame: 2, discipline: -2);
          message = 'The party was legendary! People are starting to know your name.';
        }
        break;
      case 'Launch a Side Hustle':
      case 'Side Hustle':
        char.updateStats(moneyDelta: 25000, happinessDelta: -12, stressDelta: 20, healthDelta: -5);
        _updateProgression(char, hints, ambition: 8, financialIntelligence: 10, reputation: -2);
        message = 'You worked tirelessly on your project. It\'s hard work, but you\'re building something.';
        break;
      case 'Visit the Temple':
        char.updateStats(karmaDelta: 8, happinessDelta: 5);
        _updateProgression(char, hints, reputation: 2);
        message = 'A peaceful visit. You feel morally grounded.';
        break;
      default:
        message = 'Activity performed.';
    }
    return ActionResult(
      message: message, 
      character: char, 
      success: success,
      progressionHints: hints,
    );
  }

  static DatingCandidate generateDatingCandidate(int charAge) {
    final isFemale = _rng.nextBool();
    final names = isFemale ? _namesF : _namesM;
    final name = names[_rng.nextInt(names.length)];
    return DatingCandidate(
      name: name,
      initial: name[0],
      age: (charAge + _rng.nextInt(5) - 2).clamp(16, 100),
    );
  }

  static ActionResult addPartner(Character char, DatingCandidate candidate) {
    char = char.copyWith();
    final rel = Relationship(
      id: 'rel_partner_${DateTime.now().microsecondsSinceEpoch}',
      name: candidate.name,
      type: 'Partner',
      age: candidate.age,
      initial: candidate.initial,
      bond: 70,
    );
    char.relationships.add(rel);
    char.updateStats(happinessDelta: 20);
    return ActionResult(
        message: 'You are now dating ${candidate.name}!', character: char);
  }

  static ActionResult openBankAccount(
    Character char,
    String bankName,
    String accountType, {
    double? interestRate,
  }) {
    char = char.copyWith();
    char.bankName = bankName;
    char.accountType = accountType;
    char.bankInterestRate = interestRate ?? 0.04;
    return ActionResult(
        message: 'You opened a $accountType account at $bankName.',
        character: char);
  }

  static ActionResult depositToSavings(Character char, double amount) {
    char = char.copyWith();
    if (char.bankBalance < amount)
      return ActionResult(
          message: 'Insufficient balance.', character: char, success: false);
    char.bankBalance -= amount;
    char.savingsBalance += amount;
    return ActionResult(
        message: 'Deposited ${formatMoney(amount)} into savings.',
        character: char);
  }

  static ActionResult withdrawFromSavings(Character char, double amount) {
    char = char.copyWith();
    if (char.savingsBalance < amount)
      return ActionResult(
          message: 'Insufficient savings.', character: char, success: false);
    char.savingsBalance -= amount;
    char.bankBalance += amount;
    return ActionResult(
        message: 'Withdrew ${formatMoney(amount)} from savings.',
        character: char);
  }

  static ActionResult applyForCreditCard(Character char) {
    char = char.copyWith();
    if (char.cibilScore < 700)
      return ActionResult(
          message: 'Your CIBIL score is too low for a credit card.',
          character: char,
          success: false);
    char.hasCreditCard = true;
    return ActionResult(
        message: 'Your credit card application was approved!', character: char);
  }

  static ActionResult repayCreditCard(Character char, double amount) {
    char = char.copyWith();
    if (char.bankBalance < amount)
      return ActionResult(
          message: 'Insufficient balance.', character: char, success: false);
    double actualPay = amount.clamp(0.0, char.creditUsed);
    char.bankBalance -= actualPay;
    char.creditUsed -= actualPay;
    return ActionResult(
        message: 'Repaid ${formatMoney(actualPay)} on your credit card.',
        character: char);
  }

  static ActionResult takeStudentLoan(Character char, double amount) {
    char = char.copyWith();
    if (char.cibilScore < 600)
      return ActionResult(
          message: 'Loan rejected: Low CIBIL score.',
          character: char,
          success: false);
    final loan = LoanModel.fromLegacy(
        type: 'Student', amount: amount, currentAge: char.age);
    char.loans.add(loan);
    char.bankBalance += amount;
    return ActionResult(
        message: 'Student loan of ${formatMoney(amount)} approved!',
        character: char);
  }

  static ActionResult takePersonalLoan(Character char, double amount) {
    char = char.copyWith();
    if (char.cibilScore < 650)
      return ActionResult(
          message: 'Loan rejected: Low CIBIL score.',
          character: char,
          success: false);
    final loan = LoanModel.fromLegacy(
        type: 'Personal', amount: amount, currentAge: char.age);
    char.loans.add(loan);
    char.bankBalance += amount;
    return ActionResult(
        message: 'Personal loan of ${formatMoney(amount)} approved!',
        character: char);
  }

  static ActionResult takeHomeLoan(Character char, double amount) {
    char = char.copyWith();
    if (char.cibilScore < 700)
      return ActionResult(
          message: 'Loan rejected: Low CIBIL score.',
          character: char,
          success: false);
    final loan = LoanModel.fromLegacy(
        type: 'Home', amount: amount, currentAge: char.age);
    char.loans.add(loan);
    char.bankBalance += amount;
    return ActionResult(
        message: 'Home loan of ${formatMoney(amount)} approved!',
        character: char);
  }

  static ActionResult repayLoanPartially(
      Character char, LoanModel loan, double amount) {
    char = char.copyWith();
    final loanIndex = char.loans.indexWhere((item) =>
        item.type == loan.type &&
        item.startAge == loan.startAge &&
        item.amount == loan.amount &&
        item.remainingAmount == loan.remainingAmount);
    if (loanIndex == -1) {
      return ActionResult(
          message: 'Loan not found.', character: char, success: false);
    }
    loan = char.loans[loanIndex];
    if (char.bankBalance < amount)
      return ActionResult(
          message: 'Insufficient balance.', character: char, success: false);
    double actualPay = amount.clamp(0.0, loan.remainingAmount);
    char.bankBalance -= actualPay;
    loan.remainingAmount -= actualPay;
    if (loan.remainingAmount <= 0) char.loans.remove(loan);
    return ActionResult(
        message: 'Repaid ${formatMoney(actualPay)} towards your loan.',
        character: char);
  }

  static ActionResult askParentsForBank(Character char) {
    char = char.copyWith();
    if (char.karma > 60 && _rng.nextDouble() < 0.7) {
      char.bankBalance += 10000;
      return ActionResult(
          message: 'Your parents gave you ₹10,000 for your savings!',
          character: char);
    }
    return ActionResult(
        message: 'Your parents refused to give you money.',
        character: char,
        success: false);
  }

  static ActionResult repayLoanAtIndex(
      Character char, int loanIndex, double amount) {
    final c = char.copyWith();
    if (loanIndex < 0 || loanIndex >= c.loans.length) {
      return ActionResult(
          message: 'Loan not found.',
          character: char.copyWith(),
          success: false);
    }
    return repayLoanPartially(c, c.loans[loanIndex], amount);
  }

  static ActionResult interactWithRelation(
      Character char, Relationship relation, String interactionType) {
    char = char.copyWith();
    final relationIndex =
        char.relationships.indexWhere((item) => item.id == relation.id);
    if (relationIndex == -1) {
      return ActionResult(
          message: 'Relationship not found.', character: char, success: false);
    }
    relation = char.relationships[relationIndex];
    String msg = '';
    bool success = true;
    // Personality Multipliers
    double bondMult = 1.0;
    if (relation.personality == 'Supportive') bondMult = 1.5;
    if (relation.personality == 'Strict') bondMult = 0.7;
    if (relation.personality == 'Toxic') bondMult = 0.5;

    switch (interactionType) {
      case 'Talk':
        relation.bond = (relation.bond + (5 * bondMult).round()).clamp(0, 100);
        msg = 'You had a conversation with ${relation.name}.';
        if (relation.personality == 'Strict') msg += " They seemed a bit uninterested.";
        if (relation.personality == 'Caring') msg += " They listened intently.";
        break;
      case 'Spend Time':
        relation.bond = (relation.bond + (10 * bondMult).round()).clamp(0, 100);
        char.updateStats(happinessDelta: 5);
        msg = 'You spent some time with ${relation.name}.';
        if (relation.personality == 'Toxic') {
          msg = 'You spent time with ${relation.name}, but they spent the whole time complaining.';
          char.updateStats(happinessDelta: -5);
        }
        break;
      case 'Give Gift':
        double cost = (relation.type == 'Partner') ? 5000 : 2000;
        if (char.bankBalance < cost) {
          msg = 'Not enough money for a gift.';
          success = false;
        } else {
          char.bankBalance -= cost;
          double giftMult = bondMult;
          if (relation.personality == 'Jealous') giftMult = 0.5; // Harder to please
          relation.bond = (relation.bond + (15 * giftMult).round()).clamp(0, 100);
          char.updateStats(happinessDelta: 5);
          msg = 'You gave a gift to ${relation.name}.';
          if (relation.personality == 'Jealous') msg += " They liked it, but mentioned someone else got a better one.";
        }
        break;
      case 'Go on Date':
        if (char.bankBalance < 3000) {
          msg = 'Not enough money for a date.';
          success = false;
        } else {
          char.bankBalance -= 3000;
          relation.bond = (relation.bond + (20 * bondMult).round()).clamp(0, 100);
          char.updateStats(happinessDelta: 15);
          msg = 'You had a date with ${relation.name}.';
          if (relation.personality == 'Ambitious') msg += " They spent most of the time talking about their career.";
        }
        break;
      case 'Argue':
        relation.bond = (relation.bond - 15).clamp(0, 100);
        char.updateStats(happinessDelta: -10);
        msg = 'You had a heated argument with ${relation.name}.';
        break;
      case 'Ask for Money':
        if (relation.bond > 80 && _rng.nextDouble() < 0.3) {
          double amount = relation.type == 'Partner' ? 2000 : 5000;
          char.bankBalance += amount;
          relation.bond -= 10;
          msg = '${relation.name} lent you ${formatMoney(amount)}.';
        } else {
          relation.bond -= 5;
          msg = '${relation.name} refused to lend you money.';
          success = false;
        }
        break;
      default:
        msg = 'Interaction performed.';
    }
    return ActionResult(message: msg, character: char, success: success);
  }

  static ActionResult interactWithRelationById(
    Character char,
    String relationshipId,
    String interactionType,
  ) {
    final relation = char.relationships.firstWhere(
      (item) => item.id == relationshipId,
      orElse: () => Relationship(
        id: '',
        name: '',
        type: '',
        age: char.age,
        initial: '?',
      ),
    );
    if (relation.id.isEmpty) {
      return ActionResult(
        message: 'Relationship not found.',
        character: char.copyWith(),
        success: false,
      );
    }
    return interactWithRelation(char, relation, interactionType);
  }

  static AgeUpResult ageUp(Character input) {
    // ENGINE PURITY: Clone input to ensure we never mutate the original reference
    final character = input.copyWith(tensionSignals: []);
    final int sourceVersion = character.stateVersion;
    final oldStats = {
      'happiness': character.happiness,
      'health': character.health,
      'smarts': character.smarts,
      'social': character.social,
      'karma': character.karma,
      'money': character.bankBalance,
      'cibil': character.cibilScore,
    };

    if (enableLogging) {
      debugPrint(
          "[AGE UP] Starting age up for ${character.name} to age ${character.age + 1}");
    }

    character.age += 1;
    character.yearsInRole += 1;
    if (character.annualIncome > 0 && character.careerGroup != 'None') {
      character.yearsInJob += 1;
    }
    character.memories.remove('prepped_this_year');

    // HARD SYNC: Recalculate all unlocks based on new age/stats
    _syncUnlocks(character);

    final List<LifeEvent> events = [];
    final List<String> newAchievements = [];
    bool triggeredChaos = false;

    _processEventChains(character, events);

    if (enableChaos) {
      triggeredChaos =
          _applyChaosAndHighStakes(character, events, newAchievements);
    }

    _applyEducationProgression(character, events);
    _updateMarketPrices(character, []);
    _applyCareerProgression(character, events, newAchievements);
    _applyFinancialsSilent(character, events, oldStats);
    _applyNaturalAging(character);

    if (enableRecovery) {
      _applyRecoverySystem(character, events);
    }

    if (_rng.nextDouble() < 0.15) {
      _applySocialComparison(character, events);
    }

    _applyRelationshipDynamicsSilent(character, []);

    // ── STRESS SYSTEM IMPACT ──
    double performanceMod = 1.0;
    if (character.stressLevel < 30) {
      performanceMod = 0.8; // Under-stimulated
    } else if (character.stressLevel <= 70) {
      performanceMod = 1.2; // Optimal Zone
    } else {
      performanceMod = 0.7; // Burnout Zone
      character.updateStats(healthDelta: -5, happinessDelta: -10);
    }

    final deltas = {
      'happiness': ((character.happiness - (oldStats['happiness'] as int)) *
              performanceMod)
          .round(),
      'health': character.health - (oldStats['health'] as int),
      'smarts':
          ((character.smarts - (oldStats['smarts'] as int)) * performanceMod)
              .round(),
      'social':
          ((character.social - (oldStats['social'] as int)) * performanceMod)
              .round(),
      'karma': character.karma - (oldStats['karma'] as int),
      'money': (character.bankBalance - (oldStats['money'] as double)).round(),
    };

    if (enableMomentum) {
      _updateMomentum(character, deltas);
    }

    // ── NARRATIVE & SMART EVENTS ───────────────────────────────────────────
    // Clean Flow: Ensure life feels focused. 1-2 events per year + contextual additions
    int narrativeCount = _rng.nextInt(2) + 1; 
    if (character.social > 70) narrativeCount += 1; // Socially active people get more drama
    if (character.reputation < 30) narrativeCount += 1; // Infamous people get more gossip

    final smartPool = _pickSmartEvents(character, count: narrativeCount);

    if (smartPool.isEmpty && events.isEmpty) {
      final reflection = _getQuietReflection(character);
      _addEvent(events, character.age, reflection['title']!,
          description: reflection['desc']!,
          type: LifeEventType.neutral,
          priority: EventPriority.normal);
    } else {
      events.addAll(smartPool);
    }

    // ── AUTO-DECISIONS (Consequences of Neglect) ────────────────────────────
    _applyAutoDecisions(character, events);

    // ── CONSEQUENCE CHAINS (Drama & Memories) ───────────────────────────────
    _applyConsequenceDrama(character, events);

    if (_rng.nextInt(_rareEventFrequency) == 0) {
      final rareEvent = _triggerRareEvent(character, newAchievements);
      if (rareEvent != null) {
        events.insert(
            0,
            LifeEvent(
              title: rareEvent,
              description: 'A life-changing occurrence.',
              type: LifeEventType.rare,
              priority: EventPriority.rare,
              metadata: {'age': character.age},
            ));
      }
    }

    // --- RANDOM YEARLY EVENTS (Add variety) ---
    _applyRandomYearlyEvents(character, events);

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
      personalityFeedback.add(
          '🌟 IDENTITY SHIFT: Your personality has solidified as $potentialIdentity.');
    }

    // Conflict System: Detect opposing high-intensity traits
    _detectPersonalityConflicts(character, personalityFeedback);

    // Momentum State Feedback
    if (character.momentumState != 'Steady') {
      personalityFeedback
          .add('💫 STATE: You are in a ${character.momentumState}.');
    }

    // Identity Phase & Breaking Points
    _updateIdentityPhase(character, personalityFeedback);
    _checkBreakingPoints(character, events, personalityFeedback);

    // ── NEW ENGAGEMENT SYSTEMS ──
    _updateRivals(character, events, personalityFeedback);
    _processRegrets(character, events, personalityFeedback);
    _generateTensionSignals(character, events);

    if (character.isDead) {
      final guaranteedEvents = _guaranteeAgeUpEvents(character, events);
      if (enableLogging)
        debugPrint("[AGE UP] Character DIED at age ${character.age}");
      if (enableLogging) {
        debugPrint(
            "[AGE UP] Generated ${guaranteedEvents.length} events. Chaos: $triggeredChaos");
      }
      return AgeUpResult(
        events: guaranteedEvents,
        statChanges: deltas,
        died: true,
        character: character,
        sourceVersion: sourceVersion,
        newAchievements: newAchievements,
        personalityFeedback: personalityFeedback,
      );
    }

    final guaranteedEvents = _guaranteeAgeUpEvents(character, events);

    if (enableLogging) {
      debugPrint(
          "[AGE UP] Generated ${guaranteedEvents.length} events. Chaos: $triggeredChaos");
    }

    return AgeUpResult(
      events: guaranteedEvents,
      statChanges: deltas,
      character: character,
      sourceVersion: sourceVersion,
      triggeredChaos: triggeredChaos,
      newAchievements: newAchievements,
      personalityFeedback: personalityFeedback,
    );
  }

  static void _checkBreakingPoints(
      Character c, List<LifeEvent> events, List<String> feedback) {
    c.personalityScores.forEach((trait, score) {
      if (score >= 95) {
        // Breaking Point Reached!
        switch (trait) {
          case 'Risk-taker':
            _addEvent(events, c.age, '🎲 THE GREAT GAMBLE',
                description:
                    'Your appetite for risk is absolute. You bet everything on a single venture.',
                type: LifeEventType.rare,
                priority: EventPriority.critical);
            if (_rng.nextBool()) {
              c.bankBalance *= 5;
              feedback.add(
                  '🔥 BREAKING POINT: Your gamble paid off beyond your wildest dreams!');
            } else {
              c.bankBalance *= 0.1;
              c.updateStats(happinessDelta: -50);
              feedback.add(
                  '🛑 BREAKING POINT: You lost it all. The abyss stares back.');
            }
            break;
          case 'Kind':
            _addEvent(events, c.age, '🕊️ SAINTLY SACRIFICE',
                description: 'You gave away a fortune to help those in need.',
                type: LifeEventType.milestone,
                priority: EventPriority.important);
            c.bankBalance *= 0.5;
            c.karma = 100;
            c.updateStats(happinessDelta: 40);
            feedback.add(
                '🌟 BREAKING POINT: Your kindness has reached legendary levels.');
            break;
          case 'Disciplined':
            feedback.add(
                '💎 BREAKING POINT: Your discipline is unshakeable. You are a machine of habit.');
            c.updateStats(smartsDelta: 10, healthDelta: 10);
            break;
          case 'Aggressive':
            _addEvent(events, c.age, '⚔️ TOTAL DOMINATION',
                description: 'You crushed your rivals without mercy.',
                type: LifeEventType.critical,
                priority: EventPriority.critical);
            c.annualIncome *= 2.0;
            c.updateStats(socialDelta: -40, karmaDelta: -30);
            feedback.add(
                '💀 BREAKING POINT: Your aggression has cleared the path, but the bridge is burnt.');
            break;
        }
        // Reset slightly after breaking point to prevent infinite loop
        c.personalityScores[trait] = 90;
      }
    });
  }

  static void _detectPersonalityConflicts(Character c, List<String> feedback) {
    void check(String t1, String t2, String conflictName) {
      if ((c.personalityScores[t1] ?? 0) > 70 &&
          (c.personalityScores[t2] ?? 0) > 70) {
        feedback.add(
            '⚖️ INTERNAL CONFLICT: Your $t1 nature clashing with $t2 tendencies ($conflictName).');
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
      if (character.annualIncome > 0)
        "Your performance at work is being noticed.",
      if (character.loanAmount > 0)
        "The bank is keeping a close eye on your payments."
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
    if (character.smarts > 70 &&
        character.bankBalance > 200000 &&
        !character.eventChains.containsKey('startup') &&
        character.age > 22 &&
        _rng.nextDouble() < 0.1) {
      character.eventChains['startup'] = 1;
    }

    if (character.eventChains.containsKey('startup')) {
      final step = character.eventChains['startup']!;
      if (step == 1) {
        _addEvent(events, character.age, "🚀 Startup Idea Spark!",
            description:
                "You've been thinking about a hyperlocal delivery app. Time to code?",
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
              description:
                  "10,000 users joined! Investors are sniffing around.",
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
    int score = (deltas['happiness'] ?? 0) +
        (deltas['smarts'] ?? 0) +
        (deltas['money']! > 0 ? 5 : 0);
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
    if (c.momentumState != oldState &&
        (c.momentumState == 'Flow State' ||
            c.momentumState == 'Emotional Collapse')) {
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
    } else if (c.phaseYearsStored % 5 == 0) {
      // Periodic path progress feedback
      if (c.ambition > 75) feedback.add('🔥 Your ambition is driving you toward high-stakes power.');
      if (c.financialIntelligence > 75) feedback.add('📈 You are building a legacy of financial stability.');
      if (c.fame > 75) feedback.add('🤳 Your name is becoming a household brand.');
      if (c.reputation > 85) feedback.add('🏆 You are widely respected in your community.');
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
    } else if (c.bankBalance > 5000000 && rand < 0.08) {
      _addEvent(events, c.age, "🕵️ WEALTH TAX SCRUTINY!",
          description:
              "Being rich has its downsides. Authorities are digging deep.",
          type: LifeEventType.negative,
          priority: EventPriority.important);
      c.updateStats(moneyDelta: -100000, happinessDelta: -10);
      return true;
    }
    return false;
  }

  static void _syncUnlocks(Character c) {
    if (enableLogging)
      debugPrint(
          "[ENGINE] Recalculating hard-sync unlocks for age ${c.age}...");

    // ── Activities Sync ──────────────────────────────
    final activityIds = <String>[];
    if (c.age >= 0) activityIds.add('Temple Visit');
    if (c.age >= 5) activityIds.add('Study Hard');
    if (c.age >= 10) activityIds.add('Socialize');
    if (c.age >= 12) activityIds.add('Gym Workout');
    if (c.age >= 16) {
      activityIds.add('Go to Party');
      activityIds.add('Side Hustle');
      activityIds.add('Find Love');
      activityIds.add('Go on Date');
    }
    c.unlockedActivityIds = activityIds;

    // ── Career Modules Sync ──────────────────────────
    final careerIds = <String>[];
    if (c.age >= 5) careerIds.add('School');

    // Board Exams / Entrance Exams
    final hasHigherSecondary = c.educationLevel == 'Higher Secondary' ||
        c.educationLevel == 'Graduate' ||
        c.educationLevel == 'Postgraduate';

    if (hasHigherSecondary && c.universityType == 'None' && c.age >= 17) {
      careerIds.add('Exams');
    }

    if (c.age >= 18 && c.universityType == 'None' && c.annualIncome <= 0) {
      careerIds.add('College');
    }

    if (c.age >= 16) careerIds.add('Job');

    if (c.age >= 18 && c.smarts >= 60 && hasHigherSecondary) {
      careerIds.add('Freelancing');
    }

    final hasHighStats = c.smarts > 80 || c.social > 80;
    final hasWealth = c.bankBalance >= 5000000;
    final hasMilestone = c.achievements.contains('viral_fame') ||
        c.achievements.contains('superstar') ||
        c.achievements.contains('entrepreneur');
    if (c.age >= 18 && (hasHighStats || hasWealth || hasMilestone)) {
      careerIds.add('Special Career');
    }
    if (c.age >= 21 && c.bankBalance >= 500000 && c.smarts >= 60) {
      careerIds.add('Business');
    }

    c.unlockedCareerModuleIds = careerIds;
  }

  static void _applyFinancialsSilent(
      Character c, List<LifeEvent> events, Map<String, dynamic> oldStats) {
    if (c.age < 6) return;

    // ── Inflation System ──
    double inflationIndex = (c.hiddenModifiers['economy_inflation'] ?? 1.0);
    inflationIndex *=
        (1.02 + _rng.nextDouble() * 0.04); // 2-6% yearly inflation
    c.hiddenModifiers['economy_inflation'] = inflationIndex;

    // ── Interest Rate Volatility ──
    if (c.bankName.isNotEmpty) {
      double currentRate = c.bankInterestRate;
      double fluctuation = (_rng.nextDouble() * 0.01) - 0.005; // ±0.5%
      c.bankInterestRate = (currentRate + fluctuation).clamp(0.01, 0.10);

      // Random Bank Events
      double eventRoll = _rng.nextDouble();
      if (eventRoll < 0.03) {
        // 3% chance for Rate Hike
        c.bankInterestRate += 0.015;
        _addEvent(events, c.age, '📈 BANK RATE HIKE',
            description:
                '${c.bankName} has increased interest rates due to market conditions.',
            type: LifeEventType.positive);
      } else if (eventRoll < 0.06) {
        // 3% chance for Maintenance Fee
        double fee = (c.bankBalance * 0.01).clamp(500, 5000);
        c.bankBalance -= fee;
        _addEvent(events, c.age, '🏧 BANK SERVICE FEE',
            description:
                '${c.bankName} deducted a yearly maintenance fee of ${formatMoney(fee)}.',
            type: LifeEventType.negative);
      }
    }

    double baseIncome = c.annualIncome;
    if (baseIncome > 0 && c.careerGroup != 'None') {
      final highPerformanceBonus = c.jobPerformance >= 80
          ? baseIncome * (0.04 + _rng.nextDouble() * 0.08)
          : 0.0;
      if (highPerformanceBonus > 0) {
        baseIncome += highPerformanceBonus;
        _addEvent(
          events,
          c.age,
          'Performance bonus',
          description:
              'Strong performance earned you a bonus of ${formatMoney(highPerformanceBonus)}.',
          type: LifeEventType.positive,
        );
      }
    }

    // ── Lifestyle System ──
    double lifestyleMode = c.hiddenModifiers['lifestyle_mode'] ?? 1.0;
    double baseExpensesMultiplier = 1.0;

    if (lifestyleMode == 0.0) {
      // Frugal
      baseExpensesMultiplier = 0.7;
      c.updateStats(happinessDelta: -10, socialDelta: -5);
    } else if (lifestyleMode == 2.0) {
      // Luxury
      baseExpensesMultiplier = 1.5;
      c.updateStats(happinessDelta: 10, socialDelta: 10);
    }

    double baseExpenses = c.annualExpenses *
        (c.hiddenModifiers['expenseReduction'] ?? 1.0) *
        inflationIndex *
        baseExpensesMultiplier;

    double rentalIncome = 0;
    double assetMaintenance = 0;
    double totalNetWorthEstimator = c.bankBalance;

    // Note: Seized assets are directly removed inside the seizure logic loop.

    // ── Asset Processing ──
    for (String assetId in c.ownedAssets) {
      final asset = AssetsData.findById(assetId);
      if (asset != null) {
        final valKey = 'asset_$assetId';
        final condKey = 'cond_$assetId';
        double currentVal =
            (c.marketPrices[valKey] as num?)?.toDouble() ?? asset.purchasePrice;
        double condition =
            (c.marketPrices[condKey] as num?)?.toDouble() ?? 100.0;

        double maint = asset.yearlyMaintenance * inflationIndex;

        if (asset.category == AssetCategory.property) {
          condition -= 5;
          // Random Events (Vacancy / Major repair)
          if (_rng.nextDouble() < 0.15) {
            _addEvent(events, c.age, '🏚️ PROPERTY VACANT',
                description:
                    'Your ${asset.name} sat empty this year. Zero rental income.',
                type: LifeEventType.negative);
          } else {
            rentalIncome += currentVal * 0.03;
          }

          if (_rng.nextDouble() < 0.05) {
            maint *= 3;
            _addEvent(events, c.age, '🔧 MAJOR REPAIR',
                description: 'Your ${asset.name} needed huge structural fixes.',
                type: LifeEventType.negative);
          }

          double appreciate = 1.04 + _rng.nextDouble() * 0.03;
          if (condition < 50)
            appreciate = 1.01; // Stunted appreciation if degraded
          currentVal *= appreciate;
        } else if (asset.category == AssetCategory.vehicle) {
          condition -= 10;
          double depreciate = 0.85 + _rng.nextDouble() * 0.05;
          if (condition < 50) depreciate *= 0.85; // Double penalty
          currentVal *= depreciate;
        }

        c.marketPrices[valKey] = currentVal;
        c.marketPrices[condKey] = condition.clamp(0.0, 100.0);
        totalNetWorthEstimator += currentVal;
        assetMaintenance += maint;
      }
    }

    // Investment dividends (e.g., bonds give 3% yield)
    double investmentIncome = 0;
    for (var bond in c.bondPortfolio) {
      investmentIncome += ((bond['currentPrice'] as num).toDouble() *
              (bond['quantity'] as num).toDouble()) *
          0.03;
    }

    // ── Lifestyle Creep ──
    // Base expenses naturally increase as player gets richer (0.5% of net worth)
    double lifestyleCreep = totalNetWorthEstimator * 0.005;
    if (lifestyleMode == 2.0) lifestyleCreep *= 2; // Luxury creep

    double totalIncome = baseIncome + rentalIncome + investmentIncome;
    double totalExpenses = baseExpenses + assetMaintenance + lifestyleCreep;
    double mandatoryEMI = 0;

    // ── Automated Banking / Loans ──
    double totalLoanAmount = 0;
    mandatoryEMI = 0;

    for (var loan in c.loans) {
      // Apply annual interest
      loan.remainingAmount += loan.remainingAmount * loan.interestRate;

      // Calculate EMI for this year (approx 15% of current balance for game balance)
      double loanEMI =
          (loan.remainingAmount * 0.15).clamp(0.0, loan.remainingAmount);

      // Store EMI in the model temporarily or calculate it here
      mandatoryEMI += loanEMI;
      totalLoanAmount += loan.remainingAmount;
    }

    // Sync legacy fields for backward compatibility
    c.loanAmount = totalLoanAmount;
    if (c.loans.isNotEmpty) {
      c.loanType = c.loans.first.type;

      // ── CONSEQUENCE ENGINE ──
      final income = c.annualIncome.clamp(1.0, double.infinity);
      final emiLoad = mandatoryEMI;
      final emiRatio = emiLoad / income;

      // EMI > 50% income: Stress +15
      if (emiRatio > 0.5) {
        c.stressLevel = (c.stressLevel + 15).clamp(0, 100);
        c.tensionSignals.add(
            '💸 FINANCIAL PRESSURE: Your EMI load is over 50% of your income. You feel the squeeze.');
      }

      // Multiple loans: Happiness -10
      if (c.loans.length > 1) {
        c.updateStats(happinessDelta: -10);
        c.tensionSignals
            .add('⚖️ DEBT BURDEN: Balancing multiple loans is exhausting.');
      }

      // Debt Stress Nudge (Legacy updated)
      double debtRatio = c.loanAmount / income;
      if (debtRatio > 3) {
        c.stressLevel = (c.stressLevel + 10).clamp(0, 100);
      }
    } else {
      c.loanType = 'None';
    }

    // ── Credit Evolution ──
    if (c.hasCreditCard) {
      if (c.creditUsed > 0) {
        double usageRatio = c.creditUsed / c.creditLimit;
        if (usageRatio > 0.8) {
          c.stressLevel = (c.stressLevel + 5).clamp(0, 100);
          c.cibilScore =
              (c.cibilScore - 10).clamp(300, 900); // Penalty for high usage
        } else if (usageRatio > 0.4) {
          // Limit progression for active users
          c.hiddenModifiers['credit_limit_multiplier'] =
              (c.hiddenModifiers['credit_limit_multiplier'] ?? 1.0) + 0.05;
        }
      } else {
        // Slight CIBIL boost for healthy card
        c.cibilScore = (c.cibilScore + 2).clamp(300, 900);
      }
    }

    // ── CREDIT MILESTONES ──
    final oldCibil = oldStats['cibil'] ?? 300; // I should add cibil to oldStats
    if (c.cibilScore >= 800 && oldCibil < 800) {
      _addEvent(events, c.age, '🏆 ELITE FINANCIAL STATUS',
          description:
              'Your CIBIL reached 800! You are now considered a top-tier borrower.',
          type: LifeEventType.milestone,
          priority: EventPriority.important);
      c.updateStats(happinessDelta: 10);
    } else if (c.cibilScore >= 750 && oldCibil < 750) {
      _addEvent(events, c.age, '📈 LOAN LIMITS INCREASED',
          description:
              'With a 750+ score, banks are willing to lend you much higher amounts.',
          type: LifeEventType.positive);
    } else if (c.cibilScore >= 700 && oldCibil < 700) {
      _addEvent(events, c.age, '💳 PREMIUM CARD UNLOCKED',
          description:
              'Your 700+ score has unlocked access to premium credit cards with better rewards.',
          type: LifeEventType.positive);
    }

    // ── Payment Processing ──
    double totalPayable = totalExpenses + mandatoryEMI;

    if (c.bankBalance + totalIncome >= totalPayable) {
      // Payment Successful
      c.bankBalance = (c.bankBalance + totalIncome - totalPayable)
          .clamp(0.0, double.infinity);

      if (c.loans.isNotEmpty) {
        for (var loan in c.loans) {
          double loanEMI =
              (loan.remainingAmount * 0.15).clamp(0.0, loan.remainingAmount);
          loan.remainingAmount -= loanEMI;
        }

        bool hadDebt = c.loans.isNotEmpty;
        c.loans.removeWhere((l) => l.remainingAmount <= 0);

        // Sync legacy
        c.loanAmount = c.loans.fold(0, (sum, l) => sum + l.remainingAmount);
        if (c.loans.isEmpty) {
          c.loanType = 'None';
          if (hadDebt) {
            _addEvent(events, c.age, '🎉 ALL LOANS PAID OFF!',
                description: 'You are now completely debt-free.',
                type: LifeEventType.positive);
          }
        }
      }

      // Reset missed EMI streak
      c.eventChains.remove('missed_emis');

      if (totalIncome > 0) c.totalEarned += totalIncome;

      // Credit Score Reward
      if (c.loanAmount > 0 || c.creditUsed > 0) {
        c.cibilScore = (c.cibilScore + 8).clamp(300, 900);
      }
    } else {
      // DEFAULT STATE
      c.bankBalance =
          (c.bankBalance + totalIncome - baseExpenses - assetMaintenance)
              .clamp(0.0, double.infinity);

      // Attempt to deduct whatever is left towards EMI
      if (c.bankBalance > 0 && c.loans.isNotEmpty) {
        double partialPay = c.bankBalance;
        c.bankBalance = 0; // All remaining funds used for debt

        double remainingToPay = partialPay;
        for (var loan in c.loans) {
          if (remainingToPay <= 0) break;
          double payment = min(remainingToPay, loan.remainingAmount);
          loan.remainingAmount -= payment;
          remainingToPay -= payment;
        }

        c.loans.removeWhere((l) => l.remainingAmount <= 0);
        c.loanAmount = c.loans.fold(0, (sum, l) => sum + l.remainingAmount);
        if (c.loans.isEmpty) c.loanType = 'None';
      }

      int missedCount = (c.eventChains['missed_emis'] ?? 0) + 1;
      c.eventChains['missed_emis'] = missedCount;

      c.cibilScore = (c.cibilScore - 50).clamp(300, 900);
      c.updateStats(happinessDelta: -50, healthDelta: -10);
      c.stressLevel = (c.stressLevel + 40).clamp(0, 100);

      if (missedCount == 1) {
        _addEvent(events, c.age, '❌ EMI DEFAULT!',
            description:
                'You missed your loan payment. CIBIL crashed. Bank is furious.',
            type: LifeEventType.critical,
            priority: EventPriority.critical);
      } else if (missedCount == 2) {
        _addEvent(events, c.age, '⚠️ FINAL DEMAND NOTICE!',
            description:
                'URGENT: Refinance or liquidate assets NOW. The bank will seize properties next year!',
            type: LifeEventType.critical,
            priority: EventPriority.critical);
      }

      // Asset Seizure Logic
      if (missedCount >= 3 && c.ownedAssets.isNotEmpty) {
        // Confiscate the highest value asset
        String targetRepo = c.ownedAssets.first;
        double highestVal = 0;
        for (String aid in c.ownedAssets) {
          final amt = (c.marketPrices['asset_$aid'] as num?)?.toDouble() ?? 0;
          if (amt > highestVal) {
            highestVal = amt;
            targetRepo = aid;
          }
        }

        c.ownedAssets.remove(targetRepo);
        c.marketPrices.remove('asset_$targetRepo');
        c.loanAmount = (c.loanAmount - highestVal).clamp(0.0, double.infinity);

        final repossessedAsset = AssetsData.findById(targetRepo);
        final aname = repossessedAsset?.name ?? 'Asset';

        _addEvent(events, c.age, '🚨 ASSET SEIZED!',
            description: 'The bank repossessed your $aname to cover bad debts.',
            type: LifeEventType.negative,
            priority: EventPriority.critical);

        c.eventChains['missed_emis'] = 0; // reset strictly on repo
      }
    }

    // ── Random Macroeconomic Events ──
    if (_rng.nextDouble() < 0.08) {
      int roll = _rng.nextInt(3);
      if (roll == 0 && totalNetWorthEstimator > 1000000) {
        _addEvent(events, c.age, '📉 MARKET CRASH!',
            description: 'Property bubbles burst. Your assets lost 15% value.',
            type: LifeEventType.critical,
            priority: EventPriority.important);
        for (String aid in c.ownedAssets) {
          final valKey = 'asset_$aid';
          if (c.marketPrices[valKey] != null)
            c.marketPrices[valKey] = (c.marketPrices[valKey] as double) * 0.85;
        }
      } else if (roll == 1 && totalNetWorthEstimator > 1000000) {
        _addEvent(events, c.age, '📈 HOUSING BOOM!',
            description: 'Property values skyrocketed in your city!',
            type: LifeEventType.positive,
            priority: EventPriority.important);
        for (String aid in c.ownedAssets) {
          final valKey = 'asset_$aid';
          if (c.marketPrices[valKey] != null &&
              AssetsData.findById(aid)?.category == AssetCategory.property) {
            c.marketPrices[valKey] = (c.marketPrices[valKey] as double) * 1.30;
          }
        }
      } else if (c.bankBalance > 50000) {
        double hit = c.bankBalance * (_rng.nextDouble() * 0.10 + 0.05); // 5-15%
        c.bankBalance -= hit;
        _addEvent(events, c.age, '🚑 UNEXPECTED EMERGENCY!',
            description: 'A medical issue cost you ${formatMoney(hit)}.',
            type: LifeEventType.negative,
            priority: EventPriority.important);
      }
    }

    // ── Cash Flow Summary Generation ──
    if (c.age % 5 == 0 || (totalIncome - totalPayable) < -50000) {
      _addEvent(events, c.age, '💸 Financial Update',
          description:
              'Total Income: ${formatMoney(totalIncome)} | Expenses: ${formatMoney(totalPayable)}',
          type: (totalIncome - totalPayable >= 0)
              ? LifeEventType.neutral
              : LifeEventType.negative);
    }
  }

  static void _applyRelationshipDynamicsSilent(
      Character c, List<LifeEvent> events) {
    if (c.relationships.isEmpty) return;
    final toRemove = <Relationship>[];
    for (var rel in c.relationships) {
      if (!rel.isAlive) continue;
      rel.age += 1;

      // Personality-driven Bond Logic
      int decay = _rng.nextInt(3);
      if (rel.personality == 'Toxic') decay += 2;
      if (rel.personality == 'Strict' && c.happiness < 40) decay += 2;
      if (rel.personality == 'Jealous' && c.annualIncome > 500000) decay += 3;
      if (rel.personality == 'Supportive') decay = _rng.nextInt(2); // Lower decay

      rel.bond = (rel.bond - decay).clamp(0, 100);

      // Random Supportive Boost
      if (rel.personality == 'Supportive' && _rng.nextDouble() < 0.1) {
        rel.bond = (rel.bond + 5).clamp(0, 100);
      }

      // Toxic/Jealous Drama Triggers
      if (rel.personality == 'Toxic' && _rng.nextDouble() < 0.05) {
        _addEvent(events, c.age, '🎭 Toxic Interaction',
            description: '${rel.name} made a hurtful comment about your lifestyle.',
            type: LifeEventType.negative);
        c.happiness = (c.happiness - 10).clamp(0, 100);
      }

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

  static ActionResult applyChoiceEffect(
      Character input, EventChoice choice, bool choseA) {
    final character = input.copyWith();
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

    // Narrative persistence: Memory Flags
    final flag = choseA ? choice.memoryFlagA : choice.memoryFlagB;
    if (flag != null) {
      final newMemories = Map<String, bool>.from(character.memories);
      newMemories[flag] = true;
      character.memories = newMemories;
    }

    // Logic for Regret System: Record High-Impact Decisions
    if ((effect.happiness.abs() > 15 || effect.karma.abs() > 10) &&
        character.age >= 13) {
      final newDecisions = List<Map<String, dynamic>>.from(character.majorDecisions);
      newDecisions.add({
              'age': character.age,
              'choice': choseA ? choice.optionA : choice.optionB,
              'regretPotential':
                  (effect.happiness < 0 || effect.karma < 0) ? 70 : 15,
            });
      character.majorDecisions = newDecisions;
    }

    return ActionResult(
      message: choseA ? choice.resultA : choice.resultB,
      character: character,
    );
  }

  static ActionResult applyCareerSwitch(Character input, CareerGroup newGroup) {
    final c = input.copyWith();
    final result = CareerSystem.switchCareer(c, newGroup);
    return ActionResult(message: result, character: c);
  }

  static ActionResult performCareerAction(Character input, String actionId) {
    final c = input.copyWith();
    final hasHigherSecondary = CareerSystem._eduLevel(c.educationLevel) >=
        CareerSystem._eduLevel('Higher Secondary');

    const specialApplyPrefix = 'career.special.apply::';
    if (actionId.startsWith(specialApplyPrefix)) {
      final careerName = actionId.substring(specialApplyPrefix.length);
      final career = CareerSystem.findSpecial(careerName);
      final group = CareerSystem.findGroup(careerName);
      if (career == null || group == null) {
        return ActionResult(
          message: 'That special career is not available right now.',
          character: c,
          success: false,
        );
      }
      if (!CareerSystem.canEnterSpecial(career, c)) {
        return ActionResult(
          message:
              '${career.name} needs Age ${career.minAge}+, Smarts ${career.smartsReq}+, Social ${career.socialReq}+, and ${career.eduReq} education.',
          character: c,
          success: false,
        );
      }
      if (c.careerGroup == career.name && c.annualIncome > 0) {
        return ActionResult(
          message: 'You are already building your ${career.name} career.',
          character: c,
          success: false,
        );
      }
      if (c.careerGroup != 'None' && c.annualIncome > 0) {
        return applyCareerSwitch(c, group);
      }
      CareerSystem.assignCareer(c, group);
      c.jobTitle = career.entryTitle;
      c.annualIncome = career.startingSalary;
      c.jobPerformance = 45;
      c.happiness = (c.happiness + 12).clamp(0, 100);
      final List<String> hints = [];
      _updateProgression(c, hints, ambition: 10, fame: 5);
      return ActionResult(
        message:
            'You entered ${career.name} as ${career.entryTitle}. Risk is high, but the upside is real.',
        character: c,
        progressionHints: hints,
      );
    }

    const specialActionPrefix = 'career.special.perform::';
    if (actionId.startsWith(specialActionPrefix)) {
      final careerName = actionId.substring(specialActionPrefix.length);
      return _performSpecialCareerAction(c, careerName);
    }

    const businessPrefix = 'career.business.';
    if (actionId.startsWith(businessPrefix)) {
      return _performBusinessAction(
          c, actionId.substring(businessPrefix.length));
    }

    const applyGroupPrefix = 'career.apply_group::';
    if (actionId.startsWith(applyGroupPrefix)) {
      final groupName = actionId.substring(applyGroupPrefix.length);
      final group = CareerSystem.findGroup(groupName);
      if (group == null) {
        return ActionResult(
          message: 'That career opening is no longer available.',
          character: c,
          success: false,
        );
      }

      if (!CareerSystem.canEnter(group, c)) {
        return ActionResult(
          message:
              'You do not meet the requirements for ${group.name} yet. Build your education or smarts first.',
          character: c,
          success: false,
        );
      }

      if (c.careerGroup == group.name && c.annualIncome > 0) {
        return ActionResult(
          message: 'You are already on the ${group.name} path.',
          character: c,
          success: false,
        );
      }

      if (c.careerGroup != 'None' && c.annualIncome > 0) {
        return applyCareerSwitch(c, group);
      }

      CareerSystem.assignCareer(c, group);
      c.happiness = (c.happiness + 10).clamp(0, 100);
      final List<String> hints = [];
      _updateProgression(c, hints, ambition: 5, reputation: 5);
      return ActionResult(
        message:
            'You joined ${group.name} as ${group.steps.first.title}. Salary: ${formatMoney(group.steps.first.annualSalary)}/yr.',
        character: c,
        progressionHints: hints,
      );
    }

    const applyJobPrefix = 'career.job.apply::';
    if (actionId.startsWith(applyJobPrefix)) {
      final groupName = actionId.substring(applyJobPrefix.length);
      final group = CareerSystem.findGroup(groupName);
      if (group == null) {
        return ActionResult(
          message: 'That job opening is no longer available.',
          character: c,
          success: false,
        );
      }

      final minAge = group.tier == CareerTier.partTime ? 16 : 18;
      if (c.age < minAge) {
        return ActionResult(
          message: '${group.steps.first.title} unlocks at age $minAge.',
          character: c,
          success: false,
        );
      }

      if (!CareerSystem.canEnter(group, c)) {
        return ActionResult(
          message:
              'You do not meet the requirements for ${group.steps.first.title} yet.',
          character: c,
          success: false,
        );
      }

      if (c.careerGroup == group.name && c.annualIncome > 0) {
        return ActionResult(
          message: 'You already work on the ${group.name} path.',
          character: c,
          success: false,
        );
      }

      final eduScore = CareerSystem._eduLevel(c.educationLevel) / 5.0;
      final smartsScore = c.smarts / 100.0;
      final reputationScore = c.reputation / 100.0;
      double difficulty = 0.58;
      switch (group.name) {
        case 'Part-Time':
          difficulty = 0.40;
          break;
        case 'Government':
          difficulty = 0.52;
          break;
        case 'Corporate':
          difficulty = 0.62;
          break;
        case 'Tech':
          difficulty = 0.68;
          break;
        case 'Medical':
          difficulty = 0.76;
          break;
      }

      final candidateScore =
          (smartsScore * 0.45) + (eduScore * 0.30) + (reputationScore * 0.15) + (_rng.nextDouble() * 0.1);

      if (candidateScore < difficulty) {
        return ActionResult(
          message:
              'Rejected for ${group.steps.first.title}. Build more smarts or education and try again.',
          character: c,
          success: false,
        );
      }

      if (c.careerGroup != 'None' && c.annualIncome > 0) {
        return applyCareerSwitch(c, group);
      }

      CareerSystem.assignCareer(c, group);
      c.happiness = (c.happiness + 12).clamp(0, 100);
      final List<String> hints = [];
      _updateProgression(c, hints, ambition: 5, reputation: 5);
      return ActionResult(
        message:
            'Hired: you got the ${group.steps.first.title} role for ${formatMoney(group.steps.first.annualSalary)}/yr.',
        character: c,
        progressionHints: hints,
      );
    }

    const enrollPrefix = 'education.enroll::';
    if (actionId.startsWith(enrollPrefix)) {
      final String instName = actionId.substring(enrollPrefix.length);
      final InstituteDefinition inst = InstituteData.topInstitutes.firstWhere(
        (i) => i.name == instName,
        orElse: () => InstituteData.topInstitutes.first,
      );
      return enrollInInstitute(c, inst);
    }

    const examMultiplierPrefix = 'career.take_exam_with_multiplier::';
    if (actionId.startsWith(examMultiplierPrefix)) {
      if (!hasHigherSecondary) {
        return ActionResult(
          message: 'You can only take entrance exams after Higher Secondary.',
          character: c,
          success: false,
        );
      }
      final multiplierStr = actionId.substring(examMultiplierPrefix.length);
      final multiplier = double.tryParse(multiplierStr) ?? 1.0;
      String examType = 'JEE';
      if (c.specialization == 'PCB') {
        examType = 'NEET';
      } else if (c.memories.containsKey('track_commerce')) {
        examType = 'CA Foundation';
      } else if (c.memories.containsKey('track_arts')) {
        examType = 'CLAT';
      }
      return takeEntranceExam(c, examType, multiplier: multiplier);
    }

    switch (actionId) {
      case 'career.job.work_hard':
        if (c.annualIncome <= 0 || c.careerGroup == 'None') {
          return ActionResult(
            message: 'You need a job before you can work hard at it.',
            character: c,
            success: false,
          );
        }
        c.smarts = (c.smarts + 2).clamp(0, 100);
        c.happiness = (c.happiness - 3).clamp(0, 100);
        c.stressLevel = (c.stressLevel + 10).clamp(0, 100);
        c.jobPerformance = (c.jobPerformance + 15).clamp(0, 100);
        final List<String> hints = [];
        _updateProgression(c, hints, ambition: 4, reputation: 4);
        return ActionResult(
          message: 'You worked hard and your performance improved.',
          character: c,
          progressionHints: hints,
        );

      case 'career.job.slack_off':
        if (c.annualIncome <= 0 || c.careerGroup == 'None') {
          return ActionResult(
            message: 'You need a job before you can slack off from it.',
            character: c,
            success: false,
          );
        }
        c.happiness = (c.happiness + 5).clamp(0, 100);
        c.jobPerformance = (c.jobPerformance - 12).clamp(0, 100);
        final List<String> hints = [];
        _updateProgression(c, hints, ambition: -4, reputation: -6);
        return ActionResult(
          message:
              'You slacked off at work. It felt good now, but your reputation took a hit.',
          character: c,
          progressionHints: hints,
        );

      case 'career.job.take_break':
        if (c.annualIncome <= 0 || c.careerGroup == 'None') {
          return ActionResult(
            message: 'You need a job before you can take a break from it.',
            character: c,
            success: false,
          );
        }
        c.happiness = (c.happiness + 8).clamp(0, 100);
        c.stressLevel = (c.stressLevel - 10).clamp(0, 100);
        c.jobPerformance = (c.jobPerformance - 4).clamp(0, 100);
        final List<String> hints = [];
        _updateProgression(c, hints, ambition: -2);
        return ActionResult(
          message:
              'You took a breather. Stress dropped, but you\'re not pushing as hard.',
          character: c,
          progressionHints: hints,
        );

      case 'career.job.quit':
        if (c.annualIncome <= 0 || c.careerGroup == 'None') {
          return ActionResult(
            message: 'You do not have a job to quit.',
            character: c,
            success: false,
          );
        }
        c.jobTitle = 'Unemployed';
        c.annualIncome = 0;
        c.careerGroup = 'None';
        c.careerStep = 0;
        c.yearsInRole = 0;
        c.jobLevel = 0;
        c.yearsInJob = 0;
        c.jobPerformance = 50;
        c.happiness = (c.happiness + 4).clamp(0, 100);
        return ActionResult(
          message: 'You quit your job and stepped back into the job market.',
          character: c,
        );

      case 'career.study_hard':
        if (c.age < 5) {
          return ActionResult(
            message: 'You need to be at least 5 to start studying seriously.',
            character: c,
            success: false,
          );
        }
        c.smarts = (c.smarts + 5).clamp(0, 100);
        c.prepLevel = (c.prepLevel + 6).clamp(0, 100);
        c.studyConsistency = (c.studyConsistency + 8).clamp(0, 100);
        c.discipline = (c.discipline + 6).clamp(0, 100);
        c.stressLevel = (c.stressLevel + 4).clamp(0, 100);
        c.happiness = (c.happiness - 3).clamp(0, 100);
        c.shiftPersonality('Disciplined', 4);
        return ActionResult(
          message:
              'You studied hard and sharpened your prep for the next milestone.',
          character: c,
        );

      case 'career.attend_classes':
        if (c.age < 5) {
          return ActionResult(
            message: 'Class routines begin once you are old enough for school.',
            character: c,
            success: false,
          );
        }
        c.smarts = (c.smarts + 3).clamp(0, 100);
        c.studyConsistency = (c.studyConsistency + 6).clamp(0, 100);
        c.discipline = (c.discipline + 4).clamp(0, 100);
        c.social = (c.social + 2).clamp(0, 100);
        c.stressLevel = (c.stressLevel + 2).clamp(0, 100);
        return ActionResult(
          message: 'You attended classes and kept your learning streak alive.',
          character: c,
        );

      case 'career.prepare_exams':
        if (!hasHigherSecondary) {
          return ActionResult(
            message:
                'Finish Higher Secondary first to unlock focused exam prep.',
            character: c,
            success: false,
          );
        }
        c.prepLevel = (c.prepLevel + 14).clamp(0, 100);
        c.studyConsistency = (c.studyConsistency + 5).clamp(0, 100);
        c.smarts = (c.smarts + 2).clamp(0, 100);
        c.stressLevel = (c.stressLevel + 8).clamp(0, 100);
        c.happiness = (c.happiness - 2).clamp(0, 100);
        return ActionResult(
          message:
              'You put in a serious prep session and feel more exam-ready.',
          character: c,
        );

      case 'career.take_exam':
        if (!hasHigherSecondary) {
          return ActionResult(
            message: 'You can only take entrance exams after Higher Secondary.',
            character: c,
            success: false,
          );
        }
        String ceExamType = 'JEE';
        if (c.memories.containsKey('track_pcb')) ceExamType = 'NEET';
        else if (c.memories.containsKey('track_commerce')) ceExamType = 'CA Foundation';
        else if (c.memories.containsKey('track_arts')) ceExamType = 'CLAT';
        return takeEntranceExam(c, ceExamType, multiplier: 1.0);

      case 'career.prepare_upsc':
        if (c.educationLevel != 'Graduate' && c.educationLevel != 'Postgraduate') {
          return ActionResult(message: '❌ UPSC requires a graduation degree first.', character: c, success: false);
        }
        if (c.memories.containsKey('prepped_this_year')) {
          return ActionResult(message: '❌ You have already done focused preparation this year. Age up to process the year.', character: c, success: false);
        }
        c.prepLevel = (c.prepLevel + 10).clamp(0, 100);
        c.smarts = (c.smarts + 2).clamp(0, 100);
        c.stressLevel = (c.stressLevel + 10).clamp(0, 100);
        c.happiness = (c.happiness - 5).clamp(0, 100);
        c.memories['upsc_prep'] = true;
        c.memories['prepped_this_year'] = true;
        return ActionResult(message: '📚 You dedicated this year entirely to UPSC prep. You isolated yourself in coaching libraries. Your social life faded during preparation.', character: c);

      case 'career.take_upsc':
        if (!c.memories.containsKey('upsc_prep') || c.prepLevel < 30) {
          return ActionResult(message: '❌ You need dedicated UPSC preparation (Prep level 30+) before attempting.', character: c, success: false);
        }
        final upscScore = (c.smarts * 0.5 + c.prepLevel * 0.4 + c.discipline * 0.1);
        
        c.examResults['pending_UPSC'] = upscScore.toInt();
        c.memories['attempted_UPSC'] = true; // For tracking
        
        return ActionResult(
          message: '📝 You have appeared for the UPSC Civil Services Examination. The results will be declared in the next year. The agonizing wait begins.',
          character: c,
          success: true,
        );

      case 'career.prepare_ssc':
        if (c.educationLevel != 'Graduate' && c.educationLevel != 'Postgraduate') {
          return ActionResult(message: '❌ SSC requires graduation.', character: c, success: false);
        }
        if (c.memories.containsKey('prepped_this_year')) {
          return ActionResult(message: '❌ You have already done focused preparation this year. Age up to process the year.', character: c, success: false);
        }
        c.prepLevel = (c.prepLevel + 12).clamp(0, 100);
        c.smarts = (c.smarts + 1).clamp(0, 100);
        c.stressLevel = (c.stressLevel + 6).clamp(0, 100);
        c.memories['ssc_prep'] = true;
        c.memories['prepped_this_year'] = true;
        return ActionResult(message: '📖 You dedicated this year to SSC preparation. You spent hours solving mock tests and analyzing cutoffs.', character: c);

      case 'career.take_ssc':
        if (!c.memories.containsKey('ssc_prep') || c.prepLevel < 20) {
          return ActionResult(message: '❌ More preparation needed for SSC (Prep 20+ required).', character: c, success: false);
        }
        final sscScore = (c.smarts * 0.5 + c.prepLevel * 0.5);
        
        c.examResults['pending_SSC'] = sscScore.toInt();
        
        return ActionResult(
          message: '📝 You have appeared for the SSC exam. The results will be declared in the next year.',
          character: c,
          success: true,
        );

      case 'career.take_bank_po':
        if (c.educationLevel != 'Graduate' && c.educationLevel != 'Postgraduate') {
          return ActionResult(message: '❌ Bank PO requires graduation.', character: c, success: false);
        }
        final bankScore = (c.smarts * 0.5 + c.prepLevel * 0.4 + c.social * 0.1);
        
        c.examResults['pending_BankPO'] = bankScore.toInt();
        
        return ActionResult(
          message: '📝 You have appeared for the Bank PO exam. The results will be declared in the next year.',
          character: c,
          success: true,
        );

      case 'career.apply_jobs':
        if (c.age < 18) {
          return ActionResult(
            message:
                'You need to be at least 18 before employers take you seriously.',
            character: c,
            success: false,
          );
        }
        if (c.careerGroup != 'None' && c.annualIncome > 0) {
          final alternatives = CareerSystem.alternativeGroups(c);
          if (alternatives.isEmpty) {
            return ActionResult(
              message:
                  'No stronger openings right now. Build more skills first.',
              character: c,
              success: false,
            );
          }
          return applyCareerSwitch(c, alternatives.first);
        }

        final group = CareerSystem.bestMatchGroup(c);
        CareerSystem.assignCareer(c, group);
        c.happiness = (c.happiness + 8).clamp(0, 100);
        return ActionResult(
          message:
              'Job offer: you joined ${group.name} as ${group.steps.first.title}. Salary: ${formatMoney(group.steps.first.annualSalary)}/yr.',
          character: c,
        );

      case 'career.freelancing':
        final freelanceGroup = CareerSystem.findGroup('Freelancing');
        if (freelanceGroup == null ||
            !CareerSystem.canEnter(freelanceGroup, c)) {
          return ActionResult(
            message: 'Freelancing needs Higher Secondary and Smarts 60+.',
            character: c,
            success: false,
          );
        }
        if (c.careerGroup == 'Freelancing') {
          c.freelanceEffort = (c.freelanceEffort + 16).clamp(0, 100);
          c.bankBalance += 12000;
          c.happiness = (c.happiness + 4).clamp(0, 100);
          return ActionResult(
            message:
                'You took on freelance work, built momentum, and earned ${formatMoney(12000)}.',
            character: c,
          );
        }
        CareerSystem.assignCareer(c, freelanceGroup);
        c.freelanceEffort = (c.freelanceEffort + 12).clamp(0, 100);
        return ActionResult(
          message:
              'You started freelancing as ${freelanceGroup.steps.first.title}. Your independent grind begins now.',
          character: c,
        );

      case 'career.start_internship':
        if (c.age < 16) {
          return ActionResult(
            message: 'Internships unlock at age 16.',
            character: c,
            success: false,
          );
        }
        c.bankBalance += 8000;
        c.smarts = (c.smarts + 3).clamp(0, 100);
        c.social = (c.social + 4).clamp(0, 100);
        c.studyConsistency = (c.studyConsistency + 4).clamp(0, 100);
        c.happiness = (c.happiness + 2).clamp(0, 100);
        return ActionResult(
          message:
              'You started an internship, gained experience, and earned ${formatMoney(8000)}.',
          character: c,
        );

      case 'career.learn_skill':
        if (c.age < 12) {
          return ActionResult(
            message: 'Skill-building becomes meaningful from age 12 onward.',
            character: c,
            success: false,
          );
        }
        c.smarts = (c.smarts + 4).clamp(0, 100);
        c.prepLevel = (c.prepLevel + 4).clamp(0, 100);
        c.freelanceEffort = (c.freelanceEffort + 6).clamp(0, 100);
        c.happiness = (c.happiness + 3).clamp(0, 100);
        return ActionResult(
          message:
              'You learned a useful skill and widened your future options.',
          character: c,
        );
    }

    return ActionResult(
      message: 'That career action is not available yet.',
      character: c,
      success: false,
    );
  }

  static ActionResult buyAsset(Character input, GameAsset asset) {
    final character = input.copyWith();
    if (character.bankBalance < asset.purchasePrice) {
      return ActionResult(
        message: 'You do not have enough money in your bank account!',
        character: character,
        success: false,
      );
    }
    if (character.ownedAssets.contains(asset.id) &&
        asset.category != AssetCategory.jewelry) {
      return ActionResult(
        message: 'You already own a ${asset.name}!',
        character: character,
        success: false,
      );
    }

    character.stateVersion++;
    character.bankBalance -= asset.purchasePrice;
    character.ownedAssets = List.from(character.ownedAssets)..add(asset.id);
    character.happiness = (character.happiness + 20).clamp(0, 100);
    return ActionResult(
      message: 'Purchased: ${asset.name} is now yours.',
      character: character,
    );
  }

  static ActionResult repairAsset(Character input, GameAsset asset) {
    final character = input.copyWith();
    final valKey = 'asset_${asset.id}';
    final condKey = 'cond_${asset.id}';
    if (!character.ownedAssets.contains(asset.id)) {
      return ActionResult(
        message: 'You do not own ${asset.name}.',
        character: character,
        success: false,
      );
    }

    final currentVal = (character.marketPrices[valKey] as num?)?.toDouble() ??
        asset.purchasePrice;
    final condition =
        (character.marketPrices[condKey] as num?)?.toDouble() ?? 100.0;
    final conditionMissing = 100.0 - condition;
    final repairCost = (conditionMissing / 10.0) * (currentVal * 0.02);
    if (condition >= 100) {
      return ActionResult(
        message: '${asset.name} is already in perfect condition.',
        character: character,
      );
    }
    if (character.bankBalance < repairCost) {
      return ActionResult(
        message: 'You do not have enough money to repair ${asset.name}.',
        character: character,
        success: false,
      );
    }

    character.stateVersion++;
    character.bankBalance -= repairCost;
    character.marketPrices = Map<dynamic, dynamic>.from(character.marketPrices)
      ..[condKey] = 100.0;
    return ActionResult(
      message: 'Repaired ${asset.name} for ${formatMoney(repairCost)}.',
      character: character,
    );
  }

  static ActionResult sellAsset(Character input, GameAsset asset) {
    final character = input.copyWith();
    final valKey = 'asset_${asset.id}';
    final condKey = 'cond_${asset.id}';
    if (!character.ownedAssets.contains(asset.id)) {
      return ActionResult(
        message: 'You do not own ${asset.name}.',
        character: character,
        success: false,
      );
    }

    final currentVal = (character.marketPrices[valKey] as num?)?.toDouble() ??
        asset.purchasePrice;
    character.stateVersion++;
    character.ownedAssets = List<String>.from(character.ownedAssets)
      ..remove(asset.id);
    character.bankBalance += currentVal;
    character.marketPrices = Map<dynamic, dynamic>.from(character.marketPrices)
      ..remove(valKey)
      ..remove(condKey);
    return ActionResult(
      message: 'Sold ${asset.name} for ${formatMoney(currentVal)}.',
      character: character,
    );
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
    final personalities = [
      'Strict',
      'Supportive',
      'Jealous',
      'Toxic',
      'Ambitious',
      'Manipulative',
      'Caring',
      'Irresponsible'
    ];

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
        id: 'father_${DateTime.now().microsecondsSinceEpoch}',
        name: fatherName,
        type: 'Father',
        bond: 80 + _rng.nextInt(10),
        initial: fatherName[0],
        personality: personalities[_rng.nextInt(personalities.length)],
        age: 25 + _rng.nextInt(15)));
    res.add(Relationship(
        id: 'mother_${DateTime.now().microsecondsSinceEpoch}',
        name: motherName,
        type: 'Mother',
        bond: 85 + _rng.nextInt(10),
        initial: motherName[0],
        personality: personalities[_rng.nextInt(personalities.length)],
        age: 22 + _rng.nextInt(15)));

    if (_rng.nextBool()) {
      final isMale = _rng.nextBool();
      final siblingBase = isMale ? maleNames : femaleNames;
      final sibName =
          '${siblingBase[_rng.nextInt(siblingBase.length)]} $lastName';
      res.add(Relationship(
          id: 'sibling_${DateTime.now().microsecondsSinceEpoch}',
          name: sibName,
          type: 'Sibling',
          bond: 65 + _rng.nextInt(15),
          initial: sibName[0],
          personality: personalities[_rng.nextInt(personalities.length)],
          age: _rng.nextInt(10)));
    }
    return res;
  }

  // ── PRIVATE HELPERS ──────────────────────────────────────────────────────────

  static Map<String, int> personalityMods(String personality) {
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
      if (enableLogging)
        debugPrint("[EDUCATION] 🎒 Starting Primary School for ${c.name}");
      _assignInitialSchool(c, events);
      c.educationLevel = 'Primary';
    }

    if (c.age == 11 && c.educationLevel == 'Primary') {
      if (enableLogging)
        debugPrint("[EDUCATION] 📐 Moving to Secondary School");
      c.educationLevel = 'Secondary';
      _addEvent(events, c.age, '🎒 Entered Secondary School',
          description: 'Middle school phase! Time to get serious.',
          type: LifeEventType.milestone);
    }

    if (c.age == 16 && c.educationLevel == 'Secondary') {
      // Class 10 Board Results
      final boardScore = (c.smarts * 0.8 + c.studyConsistency * 0.2 + _rng.nextInt(10)).clamp(0, 100);
      c.hiddenModifiers['class10_score'] = boardScore.toDouble();
      
      String desc = '';
      LifeEventType type = LifeEventType.neutral;
      if (boardScore >= 90) {
        desc = 'You topped the boards with ${boardScore.toInt()}%! Your parents are distributing sweets and telling everyone in the society.';
        type = LifeEventType.positive;
        c.updateStats(happinessDelta: 20, karmaDelta: 10);
      } else if (boardScore >= 75) {
        desc = 'You scored a solid ${boardScore.toInt()}%. Your family is pleased, but suggests you could have done better.';
        type = LifeEventType.positive;
        c.updateStats(happinessDelta: 10);
      } else if (boardScore >= 50) {
        desc = 'You scored ${boardScore.toInt()}%. "Average," says your father. The comparison with Sharma Ji\'s son begins.';
        type = LifeEventType.neutral;
      } else {
        desc = 'You scored only ${boardScore.toInt()}%. The disappointment at home is heavy. Silence speaks louder than words.';
        type = LifeEventType.negative;
        c.updateStats(happinessDelta: -20, socialDelta: -10);
      }
      
      _addEvent(events, c.age, '📜 Class 10 Board Results',
          description: desc,
          type: type,
          priority: EventPriority.critical);
          
      // Stream Selection Popup (Part 1: Science vs Non-Science)
      events.add(LifeEvent(
        title: 'Choose Your Stream',
        description: 'Your board results are in. What stream do you want to pursue?',
        type: LifeEventType.milestone,
        priority: EventPriority.critical,
        metadata: {'age': c.age},
        choice: const EventChoice(
          title: 'Select Stream',
          description: 'This choice will shape your future careers.',
          optionA: 'Science (PCM/PCB)',
          optionB: 'Commerce or Arts',
          effectA: StatEffect(happiness: -5, smarts: 5),
          effectB: StatEffect(happiness: 5, smarts: 0),
          resultA: 'You chose the Science stream. Prepare for long nights of study.',
          resultB: 'You chose to pursue Commerce or Arts.',
          memoryFlagA: 'stream_science_pending',
          memoryFlagB: 'stream_non_science_pending',
        ),
      ));
    }

    if (c.age == 17 && c.educationLevel == 'Secondary') {
      if (enableLogging)
        debugPrint("[EDUCATION] 🧪 Starting Higher Secondary (Board Years)");
      
      // Check flags from age 16 choice
      if (c.memories.containsKey('stream_science_pending')) {
        events.add(LifeEvent(
          title: 'Science Branch Split',
          description: 'You are in Science. Which track do you want to focus on?',
          type: LifeEventType.milestone,
          priority: EventPriority.critical,
          metadata: {'age': c.age},
          choice: const EventChoice(
            title: 'Select Track',
            description: 'Engineering (JEE) or Medical (NEET)?',
            optionA: 'Engineering (PCM)',
            optionB: 'Medical (PCB)',
            effectA: StatEffect(smarts: 10),
            effectB: StatEffect(smarts: 10),
            resultA: 'You chose PCM. Time to start JEE coaching.',
            resultB: 'You chose PCB. Time to start NEET coaching.',
            memoryFlagA: 'track_pcm',
            memoryFlagB: 'track_pcb',
          ),
        ));
        c.educationLevel = 'Higher Secondary';
      } else if (c.memories.containsKey('stream_non_science_pending')) {
        events.add(LifeEvent(
          title: 'Commerce or Arts?',
          description: 'You chose the non-science path. Which stream do you prefer?',
          type: LifeEventType.milestone,
          priority: EventPriority.critical,
          metadata: {'age': c.age},
          choice: const EventChoice(
            title: 'Select Stream',
            description: 'Commerce or Arts?',
            optionA: 'Commerce',
            optionB: 'Arts/Humanities',
            effectA: StatEffect(karma: 5),
            effectB: StatEffect(happiness: 10),
            resultA: 'You chose Commerce. Accountancy and Economics await.',
            resultB: 'You chose Arts. History, Literature, and Philosophy await.',
            memoryFlagA: 'track_commerce',
            memoryFlagB: 'track_arts',
          ),
        ));
        c.educationLevel = 'Higher Secondary';
      } else {
        // Fallback if no choice was made or flags missing
        c.educationLevel = 'Higher Secondary';
        _addEvent(events, c.age, '📚 11th & 12th Grade',
            description: 'The critical board exam years. Your study consistency matters now more than ever.',
            type: LifeEventType.milestone);
      }
    }

    // ── SCHOOL CONSISTENCY & REPEATED NEGLECT ──
    if (c.age >= 6 && c.age <= 18 && c.educationLevel != 'None') {
      // Natural Consistency decay
      c.studyConsistency = (c.studyConsistency - 5).clamp(0, 100);

      // Repeated Neglect: If consistency stays below 20 for multiple years
      if (c.studyConsistency < 20) {
        c.hiddenModifiers['neglectYears'] =
            (c.hiddenModifiers['neglectYears'] ?? 0) + 1;
        if (c.hiddenModifiers['neglectYears']! >= 2) {
          c.updateStats(smartsDelta: -3, happinessDelta: -5);
          c.discipline = (c.discipline - 10).clamp(0, 100);
          if (c.hiddenModifiers['neglectYears'] == 2) {
            c.tensionSignals.add(
                '⚠️ NEGLECT: Your grades are slipping. Teachers are noticing your lack of effort.');
          }
        }
      } else {
        c.hiddenModifiers['neglectYears'] = 0;
      }

      // School-type based growth
      double growthMult = 1.0;
      if (c.schoolType == 'Elite') {
        growthMult = 1.4;
        c.stressLevel = (c.stressLevel + 2).clamp(0, 100);
      } else if (c.schoolType == 'Private') {
        growthMult = 1.1;
      } else if (c.schoolType == 'Government') {
        c.discipline = (c.discipline + 2).clamp(0, 100);
      }

      // Base smarts growth if studying consistently
      if (c.studyConsistency > 60) {
        c.updateStats(smartsDelta: (2 * growthMult).round());
      }

      // Stream-specific preparation (Ages 16-18)
      if (c.age >= 16 && c.age <= 18) {
        if (c.memories.containsKey('track_pcm') || c.memories.containsKey('track_pcb')) {
          // Science students get more stress but also more prep
          c.stressLevel = (c.stressLevel + 5).clamp(0, 100);
          if (c.studyConsistency > 70) {
            c.prepLevel = (c.prepLevel + 10).clamp(0, 100);
          }
        } else if (c.memories.containsKey('track_commerce')) {
          if (c.studyConsistency > 60) {
            c.prepLevel = (c.prepLevel + 8).clamp(0, 100);
          }
        } else if (c.memories.containsKey('track_arts')) {
          if (c.studyConsistency > 50) {
            c.prepLevel = (c.prepLevel + 7).clamp(0, 100);
          }
        }
      }
    }

    if (c.age == 18 && c.educationLevel == 'Higher Secondary') {
      String examName = '';
      int examTypeId = 0; // 1: PCM/JEE, 2: PCB/NEET, 3: Commerce, 4: Arts
      
      if (c.memories.containsKey('track_pcm')) {
        examName = 'JEE';
        examTypeId = 1;
      } else if (c.memories.containsKey('track_pcb')) {
        examName = 'NEET';
        examTypeId = 2;
      } else if (c.memories.containsKey('track_commerce')) {
        examName = 'CA Foundation';
        examTypeId = 3;
      } else if (c.memories.containsKey('track_arts')) {
        examName = 'CLAT';
        examTypeId = 4;
      }
      
      if (examTypeId > 0) {
        final stressFactor = (120 - c.stressLevel).clamp(0, 100) / 100.0;
        final score = ((c.smarts * 0.4 + c.discipline * 0.2 + c.prepLevel * 0.4) * stressFactor).clamp(0, 100);
        
        c.examResults['pending_score'] = score.toInt();
        c.examResults['pending_type'] = examTypeId;
        
        _addEvent(events, c.age, '📝 Attempted $examName',
            description: 'You gave the exam. Now begins the agonizing wait for the results. Cutoff rumors are already spreading.',
            type: LifeEventType.neutral,
            priority: EventPriority.important);
            
        c.stressLevel = (c.stressLevel + 15).clamp(0, 100);
      }
    }

    if (c.age == 19 && c.educationLevel == 'Higher Secondary') {
      final score = c.examResults['pending_score'];
      final typeId = c.examResults['pending_type'];
      
      if (score != null && typeId != null) {
        String examName = 'JEE';
        String trackName = 'PCM';
        if (typeId == 2) { examName = 'NEET'; trackName = 'PCB'; }
        else if (typeId == 3) { examName = 'CA Foundation'; trackName = 'Commerce'; }
        else if (typeId == 4) { examName = 'CLAT'; trackName = 'Arts'; }
        
        // Calculate rank based on score (simulated)
        int rank;
        if (score >= 90) rank = _rng.nextInt(100) + 1;
        else if (score >= 75) rank = _rng.nextInt(900) + 101;
        else if (score >= 60) rank = _rng.nextInt(4000) + 1001;
        else if (score >= 50) rank = _rng.nextInt(15000) + 5001;
        else rank = _rng.nextInt(100000) + 20001;
        
        c.examResults[examName] = rank; // Store final rank
        
        String desc = '';
        LifeEventType type = LifeEventType.neutral;
        
        if (score >= 75) {
          desc = 'The results are OUT! You cleared $examName with AIR $rank! Your family is distributing sweets and celebrating.';
          type = LifeEventType.positive;
          c.updateStats(happinessDelta: 25, socialDelta: 15);
          c.memories['cleared_$trackName'] = true;
        } else if (score >= 50) {
          desc = 'The results are OUT. You cleared $examName with AIR $rank. You can get a decent college.';
          type = LifeEventType.positive;
          c.updateStats(happinessDelta: 10);
          c.memories['cleared_$trackName'] = true;
        } else {
          desc = 'The results are OUT. You failed to clear $examName (Rank $rank). The disappointment at home is heavy. Your father is silent.';
          type = LifeEventType.negative;
          c.updateStats(happinessDelta: -20, healthDelta: -5);
          c.memories['failed_$trackName'] = true;
        }
        
        _addEvent(events, c.age, '📜 $examName Results',
            description: desc,
            type: type,
            priority: EventPriority.critical);
            
        // Clear pending
        c.examResults.remove('pending_score');
        c.examResults.remove('pending_type');
      }
    }

    // --- UPSC REVEAL ---
    if (c.examResults.containsKey('pending_UPSC')) {
      final score = c.examResults['pending_UPSC']!;
      c.examResults.remove('pending_UPSC');
      
      String desc = '';
      LifeEventType type = LifeEventType.neutral;
      
      if (score >= 75 && _rng.nextDouble() < 0.3) {
        c.memories['passed_UPSC'] = true;
        desc = '🏛️ THE RESULTS ARE OUT! You have cleared UPSC! Your family is crying tears of joy. You are now an officer of India.';
        type = LifeEventType.positive;
        c.updateStats(happinessDelta: 30, socialDelta: 20);
      } else if (score >= 60) {
        desc = '😔 So close. You missed the UPSC cutoff this attempt by a narrow margin. You feel emotionally crushed. The silence at home speaks louder than any lecture. You avoid making eye contact with your father.';
        type = LifeEventType.negative;
        c.updateStats(happinessDelta: -15, healthDelta: -5);
      } else {
        desc = '❌ UPSC Results: You failed to clear the exam. The competition was too brutal. You feel a sense of failure settling in. Your parents don\'t say anything, but their silence hurts more.';
        type = LifeEventType.negative;
        c.updateStats(happinessDelta: -20, healthDelta: -10);
      }
      
      _addEvent(events, c.age, '📜 UPSC Results',
          description: desc,
          type: type,
          priority: EventPriority.critical);
    }

    // --- SSC REVEAL ---
    if (c.examResults.containsKey('pending_SSC')) {
      final score = c.examResults['pending_SSC']!;
      c.examResults.remove('pending_SSC');
      
      String desc = '';
      LifeEventType type = LifeEventType.neutral;
      
      if (score >= 55 && _rng.nextDouble() < 0.5) {
        c.memories['passed_SSC'] = true;
        desc = '✅ SSC CLEARED! Government job secured. Your parents finally stop asking when you\'ll get a job.';
        type = LifeEventType.positive;
        c.updateStats(happinessDelta: 20, socialDelta: 10);
      } else {
        desc = '❌ SSC attempt failed this time. You can try again after more preparation.';
        type = LifeEventType.negative;
        c.updateStats(happinessDelta: -10);
      }
      
      _addEvent(events, c.age, '📜 SSC Results',
          description: desc,
          type: type,
          priority: EventPriority.critical);
    }

    // --- BANK PO REVEAL ---
    if (c.examResults.containsKey('pending_BankPO')) {
      final score = c.examResults['pending_BankPO']!;
      c.examResults.remove('pending_BankPO');
      
      String desc = '';
      LifeEventType type = LifeEventType.neutral;
      
      if (score >= 60 && _rng.nextDouble() < 0.45) {
        c.memories['passed_BankPO'] = true;
        desc = '🏦 BANK PO CLEARED! Your relatives are already calling to congratulate. Stable job, good salary, government benefits.';
        type = LifeEventType.positive;
        c.updateStats(happinessDelta: 25, socialDelta: 15);
      } else {
        desc = '❌ Bank PO exam not cleared this time. The cutoff was tough. Prepare harder next time.';
        type = LifeEventType.negative;
        c.updateStats(happinessDelta: -10);
      }
      
      _addEvent(events, c.age, '📜 Bank PO Results',
          description: desc,
          type: type,
          priority: EventPriority.critical);
    }

    if (c.age == 19 &&
        c.educationLevel == 'Higher Secondary' &&
        !c.isDroppedYear) {
      if (c.degree == 'None' && _rng.nextDouble() > 0.1) {
        _addEvent(events, c.age, '🎓 Completed Schooling',
            description: 'You finished your higher secondary education!',
            type: LifeEventType.positive);
      }
    }

    // Traditional post-school milestones (for NPC/Auto-progression or Legacy)
    if (c.age == 22 && c.educationLevel == 'Undergraduate' && c.degree != 'None') {
      c.educationLevel = 'Graduate';
      _addEvent(events, c.age, '🎓 Graduated University',
          description: 'Congratulations! You earned your ${c.degree} degree!',
          type: LifeEventType.positive,
          priority: EventPriority.important);
      c.annualExpenses =
          (c.annualExpenses - 60000).clamp(36000, double.infinity);

      c.majorDecisions.add({
        'age': c.age,
        'type': 'Graduation',
        'degree': c.degree,
        'college': c.universityType,
      });
    }
  }

  static void _assignInitialSchool(Character c, List<LifeEvent> events) {
    if (c.parentWealth == 'High') {
      c.schoolType = 'Elite';
      c.social = (c.social + 15).clamp(0, 100);
      _addEvent(events, c.age, '🏫 Enrolled in Elite Private School',
          description:
              'Your wealthy parents secured a spot in the best school in the city.',
          type: LifeEventType.positive);
    } else if (c.parentWealth == 'Mid') {
      c.schoolType = 'Private';
      c.social = (c.social + 5).clamp(0, 100);
      _addEvent(events, c.age, '🎒 Enrolled in Private School',
          description: 'You joined a respectable private school.',
          type: LifeEventType.neutral);
    } else {
      c.schoolType = 'Government';
      if (c.smarts > 70 || _rng.nextDouble() < 0.05) {
        c.schoolType = 'Private';
        _addEvent(events, c.age, '🌟 SCHOLARSHIP AWARDED!',
            description:
                'Your early intelligence caught the eye of a private academy.',
            type: LifeEventType.rare,
            priority: EventPriority.important);
      } else {
        c.discipline = (c.discipline + 15).clamp(0, 100);
        _addEvent(events, c.age, '🏫 Enrolled in Government School',
            description:
                'Resources are tight, but you are learning the ways of the world.',
            type: LifeEventType.neutral);
      }
    }
  }

  static ActionResult takeEntranceExam(Character input, String examType,
      {double multiplier = 1.0}) {
    final c = input.copyWith();
    if (c.age < 17 || c.age > 21) {
      return ActionResult(
          message:
              '❌ You can only take entrance exams after completing higher secondary.',
          character: c,
          success: false);
    }
    if (c.examResults.containsKey(examType)) {
      return ActionResult(
          message: '❌ You already took the $examType exam this year!',
          character: c,
          success: false);
    }
    if (c.dropYearsCount >= 2 && !c.examResults.containsKey(examType)) {
      return ActionResult(
          message: '❌ Max attempts reached. You must choose a path now.',
          character: c,
          success: false);
    }

    // Normalized Exam Score (0-1000)
    // Formula: (Smarts * 0.4 + PrepLevel * 0.4 + StressMult * 0.2) * QuizMultiplier
    double stressScore = 0;
    if (c.stressLevel >= 30 && c.stressLevel <= 70) {
      stressScore = 100; // Optimal
    } else if (c.stressLevel > 70) {
      stressScore = 30; // Choking under pressure
    } else {
      stressScore = 60; // Under-stimulated
    }

    double rawScore = ((c.smarts * 4) + (c.prepLevel * 4) + (stressScore * 2));
    double finalScore = (rawScore * multiplier).clamp(0, 1000);

    // AIR Rank Mapping (Lower is better)
    int rank;
    if (finalScore >= 980) {
      rank = _rng.nextInt(100) + 1;
    } else if (finalScore >= 900) {
      rank = _rng.nextInt(900) + 101;
    } else if (finalScore >= 800) {
      rank = _rng.nextInt(4000) + 1001;
    } else if (finalScore >= 700) {
      rank = _rng.nextInt(15000) + 5001;
    } else if (finalScore >= 600) {
      rank = _rng.nextInt(30000) + 20001;
    } else if (finalScore >= 500) {
      rank = _rng.nextInt(50000) + 50001;
    } else {
      rank = _rng.nextInt(200000) + 100001;
    }

    // Store as pending instead of final result
    c.examResults = Map<String, int>.from(c.examResults)..['pending_$examType'] = rank;

    // Track attempt history
    c.majorDecisions.add({
      'age': c.age,
      'type': 'Exam',
      'exam': examType,
      'rank': rank,
      'score': finalScore.round(),
      'attempt': c.dropYearsCount + 1,
    });

    c.updateStats(happinessDelta: -10, healthDelta: -5);
    c.stressLevel = (c.stressLevel + 40).clamp(0, 100);

    final String msg = '📝 You have completed the $examType exam! Now begins the agonizing wait for the results. Cutoff rumors are already spreading online.';

    return ActionResult(
      message: msg,
      character: c,
      success: true,
    );
  }

  static List<JobDefinition> getFilteredJobs(Character c) {
    if (c.age < 18) return [];

    // Derive a clean list of the player's qualification tags
    final quals = <String>{
      c.educationLevel,
      c.specialization,
      c.degree,
      ...c.memories.keys, // cleared_PCM, cleared_Commerce, track_pcb, etc.
    };

    const all = CareerData.allJobs;
    final relevant = all.where((j) {
      // --- EDUCATION LEVEL GATE (Hard) ---
      final edu = j.eduReq;
      if (edu == 'Postgraduate' && c.educationLevel != 'Postgraduate') return false;
      if (edu == 'Graduate' &&
          c.educationLevel != 'Graduate' &&
          c.educationLevel != 'Postgraduate') return false;
      if (edu == 'Higher Secondary' &&
          c.educationLevel != 'Higher Secondary' &&
          c.educationLevel != 'Undergraduate' &&
          c.educationLevel != 'Graduate' &&
          c.educationLevel != 'Postgraduate') return false;
      if (edu == 'Secondary' && c.age < 16) return false;

      // --- SPECIALIZATION GATE (Strict — No Smarts Bypass) ---
      final spec = j.specializationReq;
      if (spec != null) {
        // Check against specialization, degree field, OR qualifying memory flag
        final hasSpec = c.specialization == spec ||
            c.degree == spec ||
            c.degree.toLowerCase().contains(spec.toLowerCase()) ||
            quals.any((q) => q.toLowerCase().contains(spec.toLowerCase()));
        if (!hasSpec) return false;
      }

      // --- COMPETITIVE EXAM GATE ---
      final examReq = j.examReq;
      if (examReq != null && !c.memories.containsKey('passed_$examReq')) {
        return false;
      }

      return true;
    }).toList();

    relevant.sort((a, b) {
      int aScore =
          (a.smartsReq - c.smarts).abs() + (a.socialReq - c.social).abs();
      int bScore =
          (b.smartsReq - c.smarts).abs() + (b.socialReq - c.social).abs();
      return aScore.compareTo(bScore);
    });

    final top = relevant.take(6).toList();
    if (relevant.length > 8) {
      top.add(relevant[_rng.nextInt(relevant.length - 6) + 6]);
      top.add(relevant[_rng.nextInt(relevant.length - 6) + 6]);
    }
    return top;
  }

  static ActionResult enrollInInstitute(
      Character input, InstituteDefinition inst) {
    final c = input.copyWith();
    if (c.universityType != 'None') {
      return ActionResult(
          message: '❌ You are already enrolled in a college!',
          character: c,
          success: false);
    }
    if (c.bankBalance < inst.feesPerYear * 0.5) {
      return ActionResult(
        message:
            '❌ You can\'t afford the initial admission and hostel fees (₹${GameEngine.formatMoney(inst.feesPerYear * 0.5)})!',
        character: c,
        success: false,
      );
    }

    c.universityType = inst.tier;
    c.educationLevel = 'Undergraduate';
    // Degree strictly follows player's chosen stream track, not institute's list
    if (c.memories.containsKey('track_pcb')) {
      c.degree = 'MBBS';
      c.specialization = 'PCB';
    } else if (c.memories.containsKey('track_pcm')) {
      c.degree = 'B.Tech';
      c.specialization = 'PCM';
    } else if (c.memories.containsKey('track_commerce')) {
      c.degree = 'B.Com';
      c.specialization = 'Commerce';
    } else if (c.memories.containsKey('track_arts')) {
      c.degree = 'B.A';
      c.specialization = 'Arts';
    } else {
      // Fallback to stream-based detection
      c.degree = c.specialization == 'PCB'
          ? 'MBBS'
          : c.specialization == 'PCM'
              ? 'B.Tech'
              : c.specialization == 'Commerce'
                  ? 'B.Com'
                  : 'B.A';
    }

    c.annualExpenses += inst.feesPerYear;
    c.bankBalance -= inst.feesPerYear * 0.5; // Initial deposit
    c.happiness = (c.happiness + 20).clamp(0, 100);

    return ActionResult(
      message:
          '🎓 ENROLLED! You are now a student at ${inst.name}, ${inst.city}. Welcome to college life!',
      character: c,
      success: true,
    );
  }

  static ActionResult handleDropYear(Character input) {
    final c = input.copyWith();
    if (c.dropYearsCount >= 2) {
      return ActionResult(
          message:
              '❌ You have already taken 2 drop years. You must move forward now.',
          character: c,
          success: false);
    }
    if (c.universityType != 'None') {
      return ActionResult(
          message: '❌ You are already in college!',
          character: c,
          success: false);
    }

    c.dropYearsCount += 1;
    c.isDroppedYear = true;
    c.examResults.clear(); // Reset for new attempt
    c.prepLevel = (c.prepLevel + 20).clamp(0, 100);
    c.stressLevel = (c.stressLevel + 35).clamp(0, 100);
    c.updateStats(happinessDelta: -15);

    return ActionResult(
      message:
          '⏳ DROP YEAR #${c.dropYearsCount}! You decided to skip college this year to prepare harder. Stress is rising, and friends are moving ahead.',
      character: c,
      success: true,
    );
  }

  static bool _hasActiveBusiness(Character c) =>
      (c.hiddenModifiers['business_active'] ?? 0) == 1;

  static bool _canStartBusiness(Character c) =>
      c.age >= 21 && c.bankBalance >= 500000 && c.smarts >= 60;

  static ActionResult _performBusinessAction(Character c, String action) {
    if (action == 'start') {
      if (_hasActiveBusiness(c)) {
        return ActionResult(
          message: 'You already own an active business.',
          character: c,
          success: false,
        );
      }
      if (!_canStartBusiness(c)) {
        return ActionResult(
          message: 'Starting a business needs Age 21+, Rs 5L, and Smarts 60+.',
          character: c,
          success: false,
        );
      }
      const seedCapital = 500000.0;
      c.bankBalance -= seedCapital;
      c.hiddenModifiers['business_active'] = 1.0;
      c.hiddenModifiers['business_revenue'] = 350000.0;
      c.hiddenModifiers['business_expense'] = 300000.0;
      c.hiddenModifiers['business_growth'] = 8.0;
      c.hiddenModifiers['business_loss_streak'] = 0.0;
      c.majorDecisions.add({
        'age': c.age,
        'type': 'Business Started',
        'investment': seedCapital,
      });
      return ActionResult(
        message:
            'Business started: you invested ${formatMoney(seedCapital)} and opened your first venture.',
        character: c,
      );
    }

    if (!_hasActiveBusiness(c)) {
      return ActionResult(
        message: 'Start a business before taking owner actions.',
        character: c,
        success: false,
      );
    }

    final revenue = c.hiddenModifiers['business_revenue'] ?? 0.0;
    final expense = c.hiddenModifiers['business_expense'] ?? 0.0;
    final growth = c.hiddenModifiers['business_growth'] ?? 0.0;

    switch (action) {
      case 'invest':
        final amount = min(c.bankBalance, 100000.0).toDouble();
        if (amount < 25000) {
          return ActionResult(
            message:
                'You need at least Rs 25K available to invest meaningfully.',
            character: c,
            success: false,
          );
        }
        c.bankBalance -= amount;
        c.hiddenModifiers['business_revenue'] = revenue + amount * 0.55;
        c.hiddenModifiers['business_growth'] =
            (growth + 7).clamp(-50, 100).toDouble();
        c.stressLevel = (c.stressLevel + 4).clamp(0, 100);
        return ActionResult(
          message:
              'You invested ${formatMoney(amount)} into the business. Growth potential improved.',
          character: c,
        );

      case 'cut_cost':
        c.hiddenModifiers['business_expense'] =
            (expense * 0.9).clamp(50000, double.infinity).toDouble();
        c.hiddenModifiers['business_growth'] =
            (growth - 4).clamp(-50, 100).toDouble();
        c.happiness = (c.happiness - 4).clamp(0, 100);
        return ActionResult(
          message:
              'You cut costs. Expenses dropped, but morale and growth took a small hit.',
          character: c,
        );

      case 'hire':
        const hiringCost = 75000.0;
        if (c.bankBalance < hiringCost) {
          return ActionResult(
            message: 'Hiring needs ${formatMoney(hiringCost)} in cash.',
            character: c,
            success: false,
          );
        }
        c.bankBalance -= hiringCost;
        c.hiddenModifiers['business_expense'] = expense + 90000;
        c.hiddenModifiers['business_revenue'] = revenue + 140000;
        c.hiddenModifiers['business_growth'] =
            (growth + 5).clamp(-50, 100).toDouble();
        c.social = (c.social + 2).clamp(0, 100);
        return ActionResult(
          message:
              'You hired help. Payroll rose, but capacity and revenue improved.',
          character: c,
        );

      case 'expand':
        const expandCost = 250000.0;
        if (c.bankBalance < expandCost) {
          return ActionResult(
            message: 'Expansion needs ${formatMoney(expandCost)} in cash.',
            character: c,
            success: false,
          );
        }
        c.bankBalance -= expandCost;
        c.hiddenModifiers['business_revenue'] = revenue * 1.35;
        c.hiddenModifiers['business_expense'] = expense * 1.18;
        c.hiddenModifiers['business_growth'] =
            (growth + 12).clamp(-50, 100).toDouble();
        c.stressLevel = (c.stressLevel + 10).clamp(0, 100);
        return ActionResult(
          message:
              'You expanded the business. The upside grew, and so did the pressure.',
          character: c,
        );
    }

    return ActionResult(
      message: 'Unknown business action.',
      character: c,
      success: false,
    );
  }

  static ActionResult _performSpecialCareerAction(
    Character c,
    String careerName,
  ) {
    final career = CareerSystem.findSpecial(careerName);
    if (career == null) {
      return ActionResult(
        message: 'That special career action is unavailable.',
        character: c,
        success: false,
      );
    }
    if (c.careerGroup != career.name || c.annualIncome <= 0) {
      return ActionResult(
        message: 'Enter the ${career.name} path before performing this action.',
        character: c,
        success: false,
      );
    }

    final talentScore =
        (c.smarts * 0.35) + (c.social * 0.45) + (c.jobPerformance * 0.2);
    final successChance =
        ((talentScore / 100) - career.risk + 0.55).clamp(0.12, 0.9).toDouble();
    final success = _rng.nextDouble() < successChance;

    if (success) {
      final reward = c.annualIncome * (0.08 + _rng.nextDouble() * 0.18);
      c.bankBalance += reward;
      c.totalEarned += reward;
      c.jobPerformance = (c.jobPerformance + 14).clamp(0, 100);
      c.social = (c.social + 3).clamp(0, 100);
      c.happiness = (c.happiness + 5).clamp(0, 100);
      return ActionResult(
        message:
            'Success: you ${career.actionVerb}. ${career.successEvent} You earned ${formatMoney(reward)}.',
        character: c,
      );
    }

    final loss =
        min(c.bankBalance, c.annualIncome * (0.03 + career.risk * 0.04))
            .toDouble();
    c.bankBalance -= loss;
    c.jobPerformance = (c.jobPerformance - 10).clamp(0, 100);
    c.stressLevel = (c.stressLevel + 8).clamp(0, 100);
    c.happiness = (c.happiness - 6).clamp(0, 100);
    return ActionResult(
      message:
          'Setback: you ${career.actionVerb}. ${career.failureEvent} It cost Rs ${formatMoney(loss)}.',
      character: c,
      success: false,
    );
  }

  static void _applyBusinessProgression(Character c, List<LifeEvent> events) {
    if (!_hasActiveBusiness(c)) return;

    double revenue = c.hiddenModifiers['business_revenue'] ?? 0.0;
    double expense = c.hiddenModifiers['business_expense'] ?? 0.0;
    double growth = c.hiddenModifiers['business_growth'] ?? 0.0;

    final marketSwing = 0.92 + _rng.nextDouble() * 0.2;
    final growthMultiplier = 1 + (growth / 100);
    revenue = revenue * marketSwing * growthMultiplier;
    expense = expense * (1.02 + _rng.nextDouble() * 0.08);

    final eventRoll = _rng.nextDouble();
    if (eventRoll < 0.14) {
      revenue *= 1.25;
      growth += 5;
      _addEvent(
        events,
        c.age,
        'Business surge',
        description: 'A strong sales year lifted your business revenue.',
        type: LifeEventType.positive,
      );
    } else if (eventRoll < 0.28) {
      expense *= 1.25;
      growth -= 6;
      _addEvent(
        events,
        c.age,
        'Business trouble',
        description: 'Supplier issues and delays increased business costs.',
        type: LifeEventType.negative,
      );
    }

    final profit = revenue - expense;
    if (profit >= 0) {
      c.bankBalance += profit;
      c.totalEarned += profit;
      c.hiddenModifiers['business_loss_streak'] = 0;
      c.happiness = (c.happiness + 3).clamp(0, 100);
      _addEvent(
        events,
        c.age,
        'Business profit',
        description:
            'Your business made Rs ${formatMoney(profit)} profit this year.',
        type: LifeEventType.positive,
      );
    } else {
      final loss = -profit;
      c.bankBalance = (c.bankBalance - loss).clamp(0, double.infinity);
      final streak = (c.hiddenModifiers['business_loss_streak'] ?? 0.0) + 1;
      c.hiddenModifiers['business_loss_streak'] = streak;
      c.stressLevel = (c.stressLevel + 12).clamp(0, 100);
      _addEvent(
        events,
        c.age,
        'Business loss',
        description:
            'Your business lost Rs ${formatMoney(loss)} this year. Loss streak: ${streak.round()}.',
        type: LifeEventType.negative,
      );
      if (streak >= 3) {
        c.hiddenModifiers['business_active'] = 0.0;
        c.hiddenModifiers['business_revenue'] = 0.0;
        c.hiddenModifiers['business_expense'] = 0.0;
        c.hiddenModifiers['business_growth'] = 0.0;
        c.hiddenModifiers['business_loss_streak'] = 0.0;
        _addEvent(
          events,
          c.age,
          'Business closed',
          description:
              'After repeated losses, you closed the business before it drained everything.',
          type: LifeEventType.critical,
          priority: EventPriority.important,
        );
      }
    }

    c.hiddenModifiers['business_revenue'] =
        revenue.clamp(0, double.infinity).toDouble();
    c.hiddenModifiers['business_expense'] =
        expense.clamp(0, double.infinity).toDouble();
    c.hiddenModifiers['business_growth'] = growth.clamp(-50, 100).toDouble();
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
      c.jobLevel = 0;
      c.yearsInJob = 0;
      return;
    }
    if (c.age < 22 && c.educationLevel == 'Undergraduate') {
      c.jobTitle = 'College Student';
      c.annualIncome = 12000;
      c.jobLevel = 0;
      c.yearsInJob = 0;
      return;
    }

    _applyBusinessProgression(c, events);

    // First job assignment at 22 (or when school done at 18 without college)
    final isFirstJob = c.careerGroup == 'None' &&
        c.annualIncome == 0 &&
        (c.age == 22 || (c.age == 18 && c.educationLevel != 'Undergraduate' && c.educationLevel != 'Graduate'));
    if (isFirstJob) {
      final group = CareerSystem.bestMatchGroup(c);
      if (enableLogging)
        debugPrint("[CAREER] 💼 First Job Assignment: ${group.name}");
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
        c.hasCareerWarning = false; // Reset warning on new job
        _addEvent(events, c.age, '${group.emoji} New Beginning!',
            description: 'You found a job as a ${group.steps.first.title}.',
            type: LifeEventType.positive);
      }
      return;
    }

    // ── FREELANCING PROGRESSION ──
    if (c.careerGroup == 'Freelancing') {
      // Scale based on Smarts and years of consistency (freelanceEffort)
      double base = CareerData.freelancingRoles
          .firstWhere((j) => j.tier == CareerTier.freelance)
          .startingSalary;

      // Tier Logic: Beginner -> Regular -> Premium
      double tierMult = 1.0;
      if (c.freelanceEffort > 85 && c.smarts > 75) {
        tierMult = 4.0; // Premium
        c.jobTitle = 'Premium Specialist';
      } else if (c.freelanceEffort > 50) {
        tierMult = 1.8; // Regular
        c.jobTitle = 'Regular Freelancer';
      } else {
        c.jobTitle = 'Gig Worker';
      }

      double multiplier =
          tierMult * (1.0 + (c.yearsInRole * 0.05) + (c.smarts / 200));
      c.annualIncome = base * multiplier;

      // Passive decay of freelance effort if not working
      c.freelanceEffort = (c.freelanceEffort - 8).clamp(0, 100);
      c.stressLevel = (c.stressLevel + 10).clamp(0, 100);
    }

    if (c.annualIncome > 0 && c.careerGroup != 'None') {
      c.jobPerformance = (c.jobPerformance - 5).clamp(0, 100);

      final eventRoll = _rng.nextDouble();
      if (eventRoll < 0.18) {
        c.jobPerformance = (c.jobPerformance + 8).clamp(0, 100);
        _addEvent(events, c.age, 'Boss impressed',
            description:
                'Your recent effort stood out and boosted your workplace momentum.',
            type: LifeEventType.positive);
      } else if (eventRoll < 0.33) {
        c.jobPerformance = (c.jobPerformance - 8).clamp(0, 100);
        _addEvent(events, c.age, 'Work mistake',
            description: 'A mistake at work hurt your standing this year.',
            type: LifeEventType.negative);
      } else if (eventRoll < 0.48) {
        final politicsUp = _rng.nextBool();
        c.jobPerformance =
            (c.jobPerformance + (politicsUp ? 5 : -5)).clamp(0, 100);
        _addEvent(events, c.age, 'Office politics',
            description: politicsUp
                ? 'You navigated office politics well and gained influence.'
                : 'Office politics dragged down your reputation a little.',
            type: politicsUp ? LifeEventType.neutral : LifeEventType.negative);
      }

      final currentGroup = CareerSystem.findGroup(c.careerGroup);
      if (currentGroup?.tier == CareerTier.special &&
          _rng.nextDouble() < 0.28) {
        final upside = _rng.nextBool();
        if (upside) {
          final windfall = c.annualIncome * (0.05 + _rng.nextDouble() * 0.2);
          c.bankBalance += windfall;
          c.totalEarned += windfall;
          c.jobPerformance = (c.jobPerformance + 10).clamp(0, 100);
          _addEvent(
            events,
            c.age,
            'Special career breakthrough',
            description:
                'Your ${c.careerGroup} career had a breakthrough worth Rs ${formatMoney(windfall)}.',
            type: LifeEventType.positive,
          );
        } else {
          final hit = min(c.bankBalance, c.annualIncome * 0.08).toDouble();
          c.bankBalance -= hit;
          c.jobPerformance = (c.jobPerformance - 10).clamp(0, 100);
          c.stressLevel = (c.stressLevel + 10).clamp(0, 100);
          _addEvent(
            events,
            c.age,
            'Special career setback',
            description:
                'A risky ${c.careerGroup} year cost Rs ${formatMoney(hit)} and hurt momentum.',
            type: LifeEventType.negative,
          );
        }
      }
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

    // Try demotion
    final demotionResult = CareerSystem.tryDemotion(c, _rng);
    if (demotionResult != null) {
      _addEvent(
          events,
          c.age,
          demotionResult.contains('WARNING')
              ? '⚠️ Performance Warning'
              : '📉 Demoted',
          description: demotionResult,
          type: LifeEventType.negative,
          priority: EventPriority.important);
      return;
    }

    // Experience, inflation, and performance-based salary growth.
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

      final inflationIndex = c.hiddenModifiers['economy_inflation'] ?? 1.0;
      final experienceGrowth = 1.0 + experienceYears * 0.04 * termMod;
      final performanceGrowth =
          c.jobPerformance >= 70 ? 1.0 + ((c.jobPerformance - 70) / 1000) : 1.0;

      c.annualIncome = step.annualSalary *
          inflationIndex *
          experienceGrowth *
          performanceGrowth;
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
      // --- EVENT DEDUPLICATION (COOLDOWN) ---
      final title = e['title'] as String?;
      if (title != null && c.eventHistory.containsKey(title)) {
        if (c.age - c.eventHistory[title]! < 20) return false;
      }

      // --- CONTEXTUAL FILTERING (LIFESTYLE TIERS) ---
      final requiredTier = e['tier'] as String?;
      if (requiredTier != null && c.lifestyleTier != requiredTier) return false;

      // 1. Wealth Filtering (Rich people don't get minor money stress)
      if (c.bankBalance > 2000000 && e['type'] == 'Financial' && (e['money'] ?? 0) > -50000 && (e['money'] ?? 0) < 0) return false;
      
      // 2. Fame Filtering (Famous people get more drama, less generic neutral events)
      if (c.fame > 75 && e['type'] == 'Neutral' && _rng.nextDouble() < 0.5) return false;

      // 3. Identity Insecurity (High-fame/Wealthy characters don't get "Sharma Ji" type insecurity)
      if ((c.bankBalance > 5000000 || c.fame > 80) && e['title'] != null && e['title'].contains('Sharma')) return false;

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
        if (c.activeDominantTrait == 'Smart' && e['type'] == 'Education')
          w *= 2.0;
        if (c.activeDominantTrait == 'Kind' && e['type'] == 'Relationships')
          w *= 2.0;
        if (c.activeDominantTrait == 'Aggressive' && e['type'] == 'Chaos')
          w *= 1.5;
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
      
      // Update Event History (Deduplication)
      if (selected['title'] != null) {
        c.eventHistory[selected['title']] = c.age;
      }
      
      EventChoice? choice;
      if (selected['choice'] != null) {
        final cMap = selected['choice'];
        choice = EventChoice(
          title: cMap['title'],
          description: cMap['desc'],
          optionA: cMap['optionA'],
          optionB: cMap['optionB'],
          effectA: StatEffect.fromMap(cMap['effectA']),
          effectB: StatEffect.fromMap(cMap['effectB']),
          resultA: cMap['resultA'],
          resultB: cMap['resultB'],
          memoryFlagA: cMap['memoryFlagA'],
          memoryFlagB: cMap['memoryFlagB'],
        );
      }

      results.add(LifeEvent(
        title: selected['title'],
        description: selected['desc'],
        type: _inferType(selected['type']),
        choice: choice,
        priority: selected['type'] == 'Rare'
            ? EventPriority.rare
            : (selected['choice'] != null ? EventPriority.important : EventPriority.normal),
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
        happinessDelta:
            ((selected['happiness'] as int? ?? 0) * intensity).round(),
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
      final dynamic cond = e['cond'];
      bool shouldTrigger = false;
      if (cond != null) {
        try {
          shouldTrigger = cond(c) == true;
        } catch (err) {
          debugPrint("Error evaluating auto decision condition: $err");
        }
      }
      if (shouldTrigger) {
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
          c.cibilScore =
              (c.cibilScore + (e['cibilDelta'] as int)).clamp(300, 900);
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
    if (lower.contains('iit') || lower.contains('ias') || lower.contains('ceo'))
      return EventPriority.critical;
    if (lower.contains('win') ||
        lower.contains('viral') ||
        lower.contains('billionaire')) return EventPriority.rare;
    if (lower.contains('promoted') || lower.contains('graduated'))
      return EventPriority.important;
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

  static ActionResult buyInvestment(
      Character input, MarketAsset asset, double quantity) {
    final c = input.copyWith();
    double marketPrice = (c.marketPrices[asset.name] as num).toDouble();
    double totalCost = marketPrice * quantity;

    if (c.bankBalance < totalCost) {
      return ActionResult(
          message: '❌ You don\'t have enough cash!',
          character: c,
          success: false);
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

    return ActionResult(
      message: '✅ BOUGHT! You acquired $quantity units of ${asset.name}.',
      character: c,
    );
  }

  static ActionResult sellInvestment(Character input, String type, int index) {
    final c = input.copyWith();
    List<Map<dynamic, dynamic>> portfolio;
    if (type == 'Stock') {
      portfolio = c.stockPortfolio;
    } else if (type == 'Crypto') {
      portfolio = c.cryptoPortfolio;
    } else {
      portfolio = c.bondPortfolio;
    }

    if (index < 0 || index >= portfolio.length) {
      return ActionResult(
          message: '❌ Invalid asset selection.', character: c, success: false);
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

    return ActionResult(
      message:
          '${profit >= 0 ? '💰' : '📉'} SOLD! You received ₹${_formatNum(saleValue)}. ($pStr)',
      character: c,
    );
  }

  static void _updateRivals(
      Character c, List<LifeEvent> events, List<String> feedback) {
    if (c.age < 18) return;
    for (var rel in c.relationships) {
      if (rel.isRival && rel.isAlive) {
        rel.rivalIntensity =
            (rel.rivalIntensity + _rng.nextInt(5)).clamp(0, 100);
        if (_rng.nextDouble() < 0.15) {
          final achievements = [
            'got promoted.',
            'bought a car.',
            'won an award.'
          ];
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

  static void _processRegrets(
      Character c, List<LifeEvent> events, List<String> feedback) {
    if (c.majorDecisions.isEmpty || _rng.nextDouble() > 0.10) return;
    final decision = c.majorDecisions[_rng.nextInt(c.majorDecisions.length)];
    if (c.age - (decision['age'] as int? ?? 0) > 10) {
      _addEvent(events, c.age, '💭 Echoes of the Past',
          description: 'You regret choice: ${decision['choice']}.',
          type: LifeEventType.negative);
      c.updateStats(happinessDelta: -12);
      feedback.add('🧠 REGRET: Past decisions are haunting you.');
    }
  }

  static void _generateTensionSignals(Character c, List<LifeEvent> events) {
    final roll = _rng.nextDouble();
    
    // --- VARIABLE OUTCOME TENSION ---
    // Instead of guaranteed signals, they are now probabilistic
    
    // Health Dread (Hidden Risk)
    if (c.health < 45 && roll < 0.25) {
      _addEvent(events, c.age, '⌛ A lingering fatigue...',
          description: 'Your body hasn\'t felt right lately. You feel a constant, dull ache.',
          type: LifeEventType.negative);
      c.hiddenModifiers['health_decay'] = (c.hiddenModifiers['health_decay'] ?? 0) + 1.0;
    }
    
    // Career Dread (Contextual)
    if (c.jobPerformance < 40 && c.annualIncome > 0 && roll < 0.2) {
      _addEvent(events, c.age, '🏢 Office whispers...',
          description: 'You noticed your boss becoming distant. The atmosphere at work is chilly.',
          type: LifeEventType.negative);
      c.reputation = (c.reputation - 5).clamp(0, 100);
    }

    // Relationship Dread (Echoes)
    if (c.relationships.any((r) => r.type == 'Partner' && r.bond < 50) && roll < 0.15) {
      _addEvent(events, c.age, '🥀 Emotional distance...',
          description: 'Your partner seems emotionally withdrawn. Conversations are brief and forced.',
          type: LifeEventType.negative);
    }
    
    // --- NARRATIVE ECHOES (LATE LIFE) ---
    if (c.age > 50 && roll < 0.2) {
      if (c.memories.containsKey('school_fighter') && _rng.nextBool()) {
        _addEvent(events, c.age, '🦴 A ghostly ache...',
            description: 'That old injury from the school fight at age 14 is hurting again. Time is catching up.',
            type: LifeEventType.negative);
        c.health -= 5;
      }
      
      if (c.memories.containsKey('corrupt_worker') && _rng.nextDouble() < 0.1) {
         _addEvent(events, c.age, '⚖️ A restless night...',
            description: 'You woke up sweating, thinking about the sales you inflated decades ago. Will anyone ever find out?',
            type: LifeEventType.neutral);
         c.happiness -= 10;
      }
    }
  }

  static Map<String, String> _getQuietReflection(Character c) {
    final trait = c.activeDominantTrait;
    
    if (c.age < 12) {
      return {
        'title': 'A year of play',
        'desc': 'You spent most of your time playing and exploring the world.'
      };
    }

    if (trait == 'Disciplined') {
      return {
        'title': 'The Architect of Life',
        'desc': 'You continued building your future quietly, one brick at a time.'
      };
    } else if (trait == 'Risk-taker') {
      return {
        'title': 'Quiet before the storm',
        'desc': 'You spent the year waiting for the next big opportunity to strike.'
      };
    } else if (trait == 'Lazy') {
      return {
        'title': 'Unbothered existence',
        'desc': 'You enjoyed a peaceful year doing as little as possible.'
      };
    } else if (trait == 'Aggressive') {
      return {
        'title': 'Controlled energy',
        'desc': 'You focused your intensity on routine tasks, keeping your edge sharp.'
      };
    } else if (trait == 'Kind') {
      return {
        'title': 'A year of harmony',
        'desc': 'You maintained peace in your circle and enjoyed simple connections.'
      };
    } else if (c.age > 60) {
      return {
        'title': 'A peaceful sunset',
        'desc': 'You enjoyed a quiet year of reflection and rest.'
      };
    }
    
    return {
      'title': 'Steady momentum',
      'desc': 'A year of routine and steady progress in ${c.city}.'
    };
  }

  static void _applyRandomYearlyEvents(Character c, List<LifeEvent> events) {
    final roll = _rng.nextDouble();
    
    // 1. Career Bonuses & Setbacks
    if (c.annualIncome > 0 && c.careerGroup != 'None') {
      if (roll < 0.08 && c.jobPerformance > 70) {
        final bonus = c.annualIncome * 0.15;
        c.bankBalance += bonus;
        _addEvent(events, c.age, '💰 PERFORMANCE BONUS',
            description: 'Your hard work paid off! You received a ₹${formatMoney(bonus)} bonus.',
            type: LifeEventType.positive,
            priority: EventPriority.important);
      } else if (roll < 0.12 && c.jobPerformance < 40) {
        final cut = c.annualIncome * 0.05;
        c.bankBalance -= cut;
        _addEvent(events, c.age, '💸 REVENUE LOSS',
            description: 'Due to poor performance, you were fined ₹${formatMoney(cut)}.',
            type: LifeEventType.negative,
            priority: EventPriority.normal);
      }
    }

    // 2. Health Scares
    if (c.age > 40 && roll > 0.90 && c.health < 60) {
      c.health -= 15;
      _addEvent(events, c.age, '🏥 HEALTH SCARE',
          description: 'You had a sudden health complication. Time to take care of yourself.',
          type: LifeEventType.negative,
          priority: EventPriority.important);
    }

    // 3. Unexpected Expenses (Reduced by Financial Intelligence)
    double expenseRisk = 0.85;
    if (c.financialIntelligence > 60) expenseRisk += 0.05;
    if (c.financialIntelligence > 85) expenseRisk += 0.05;

    if (c.age > 18 && roll > expenseRisk && roll < 0.95) {
      final expense = (c.bankBalance * 0.05).clamp(2000.0, 50000.0);
      c.bankBalance -= expense;
      final reasons = ['Car broke down', 'Home repair needed', 'Lost your wallet', 'Gadget failure'];
      final reason = reasons[_rng.nextInt(reasons.length)];
      _addEvent(events, c.age, '💸 UNEXPECTED EXPENSE',
          description: '$reason cost you ${formatMoney(expense)}.',
          type: LifeEventType.negative);
    }

    // 4. Fame Opportunities
    if (c.fame > 50 && roll < 0.10) {
      final reward = (c.fame * 1000).toDouble();
      c.bankBalance += reward;
      _addEvent(events, c.age, '🤳 BRAND COLLAB',
          description: 'A brand reached out for a collab! You earned ₹${formatMoney(reward)}.',
          type: LifeEventType.positive,
          priority: EventPriority.important);
    }

    // 5. Asset Appreciation/Depreciation
    if (c.ownedAssets.isNotEmpty && roll < 0.15) {
       _addEvent(events, c.age, '📈 ASSET UPDATE',
          description: 'The market value of your property changed slightly.',
          type: LifeEventType.neutral);
    }

    // 6. SAMPLE INTERACTIVE DECISION (Testing system)
    if (c.age > 18 && roll < 0.5 && !events.any((e) => e.choice != null)) {
      events.add(LifeEvent(
        title: 'Workplace Opportunity',
        description: 'Your boss asks if you can stay late for a month to help with a critical project.',
        type: LifeEventType.neutral,
        metadata: {'age': c.age},
        choice: const EventChoice(
          title: 'Extra Work?',
          description: 'This will be exhausting but might pay off.',
          optionA: 'Accept',
          optionB: 'Refuse',
          effectA: StatEffect(happiness: -10, health: -5, smarts: 5, karma: 5, money: 50000),
          effectB: StatEffect(happiness: 5, health: 5, karma: -5),
          resultA: 'You stayed late every night. The project was a success! You earned a bonus.',
          resultB: 'You chose your health over work. You feel refreshed, but your boss looks disappointed.',
        ),
      ));
    }
  }
  static void _applyConsequenceDrama(Character c, List<LifeEvent> events) {
    // 1. Rejected Marriage Consequence (Echoes)
    if (c.memories.containsKey('rejected_arranged_marriage') &&
        c.age % 4 == 0 &&
        _rng.nextDouble() < 0.4) {
      _addEvent(events, c.age, '🏛️ Family Tension',
          description:
              'Your parents are still cold to you after you rejected their marriage proposal years ago. The atmosphere at home is heavy.',
          type: LifeEventType.negative,
          priority: EventPriority.important);
      c.updateStats(happinessDelta: -15, socialDelta: -10);
    }

    // 2. Corrupt Worker Consequence (Echoes)
    if (c.memories.containsKey('corrupt_worker') && _rng.nextDouble() < 0.05) {
      _addEvent(events, c.age, '⚖️ Workplace Audit',
          description:
              'An internal audit discovered your past inflated numbers. You have been fired and blacklisted from the industry.',
          type: LifeEventType.critical,
          priority: EventPriority.rare);
      c.annualIncome = 0;
      c.careerGroup = 'None';
      c.jobTitle = 'Unemployed';
      c.updateStats(reputationDelta: -50, happinessDelta: -30);
    }

    // --- NEW RIVAL SYSTEM ---
    if (c.memories.containsKey('school_fighter') && c.age > 25 && c.age < 45 && _rng.nextDouble() < 0.08) {
       _addEvent(events, c.age, '⚔️ THE RETURN OF THE RIVAL',
          description: 'You bumped into that kid you fought in school. He is now a senior executive at your competitor\'s firm.',
          type: LifeEventType.negative,
          priority: EventPriority.important);
       c.memories['active_rival'] = true;
       c.updateStats(stressDelta: 20);
    }

    if (c.memories.containsKey('active_rival') && c.age % 6 == 0 && _rng.nextDouble() < 0.5) {
       _addEvent(events, c.age, '📉 RIVAL SABOTAGE',
          description: 'Your industry rival blocked a major deal your company was chasing.',
          type: LifeEventType.negative);
       c.updateStats(jobPerformanceDelta: -15, happinessDelta: -5);
    }
    
    // --- REPUTATION GOSSIP ---
    if (c.reputation < 35 && _rng.nextDouble() < 0.3) {
      final gossips = [
        'The neighbors are whispering about your recent behavior. You feel their eyes on you.',
        'A local WhatsApp group is circulating a story about your "scandalous" choices.',
        'You were uninvited from a neighborhood function. The reason given was "lack of space".',
      ];
      _addEvent(events, c.age, '🗣️ Local Gossip',
          description: gossips[_rng.nextInt(gossips.length)],
          type: LifeEventType.negative);
      c.updateStats(happinessDelta: -10, socialDelta: -5);
    }

    // --- LATE LIFE MORAL ECHOES ---
    if (c.age > 65 && _rng.nextDouble() < 0.1) {
      if (c.karma > 80) {
        _addEvent(events, c.age, '🕊️ A Peaceful Legacy',
            description: 'Your life of kindness has come full circle. People speak of you with genuine respect.',
            type: LifeEventType.positive);
        c.updateStats(happinessDelta: 20);
      } else if (c.karma < 30) {
        _addEvent(events, c.age, '🏚️ A Lonely Winter',
            description: 'The bridges you burnt in your youth have left you isolated in your old age.',
            type: LifeEventType.negative);
        c.updateStats(happinessDelta: -25, socialDelta: -20);
      }
    }
  }
}
