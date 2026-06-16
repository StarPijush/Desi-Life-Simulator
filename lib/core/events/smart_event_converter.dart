import 'package:flutter/material.dart';
import '../../models/character.dart';
import '../../models/smart_event.dart';
import '../../models/life_event.dart';
import '../../widgets/events/event_types.dart';
import '../enums.dart';

EventCategory _mapCategory(String type, String? category) {
  final t = type.toLowerCase();
  final c = category?.toLowerCase() ?? '';

  if (t == 'military' || c == 'military') return EventCategory.military;
  if (t == 'politics' || c == 'politics') return EventCategory.politics;
  if (t == 'education' || c == 'education') return EventCategory.education;
  if (t == 'scholarship' || c == 'scholarship') return EventCategory.scholarship;
  if (t == 'career' || c == 'career') return EventCategory.career;
  if (t == 'freelance' || c == 'freelance') return EventCategory.freelance;
  if (t == 'relationship' || t == 'relationships' || c == 'relationship') return EventCategory.relationships;
  if (t == 'family' || c == 'family') return EventCategory.family;
  if (t == 'health' || c == 'health') return EventCategory.health;
  if (t == 'crime' || c == 'crime') return EventCategory.crime;
  if (t == 'fame' || c == 'fame' || t == 'drama' || t == 'influencer') return EventCategory.fame;
  if (t == 'business' || c == 'business' || t == 'financial') return EventCategory.business;
  if (t == 'sports' || c == 'sports') {
    return EventCategory.cricketer; // Default fallback for sports
  }

  return EventCategory.family; // Ultimate fallback
}

ActionEvent? convertSmartEventToActionEvent(SmartEvent event, Character character) {
  EventCategory category = _mapCategory(event.type, event.category);

  // Sports strict gating adjustment
  if (category == EventCategory.cricketer && character.jobTitle == 'Footballer') {
    category = EventCategory.footballer;
  }

  EventCardMode mode = EventCardMode.info;
  String? emojiIllustration;

  final titleLower = event.title.toLowerCase();

  // Mode mapping based on content rules
  if (event.choice != null || titleLower.contains('proposal')) {
    mode = EventCardMode.choice;
    emojiIllustration = '🤔';
  } else if (titleLower.contains('promotion') || titleLower.contains('victory') || titleLower.contains('acceptance') || titleLower.contains('award') || titleLower.contains('success') || titleLower.contains('win') || titleLower.contains('launch') || titleLower.contains('recovery') || titleLower.contains('century') || titleLower.contains('hat trick') || titleLower.contains('milestone')) {
    mode = EventCardMode.success;
    emojiIllustration = '🎉';
  } else if (titleLower.contains('bankruptcy') || titleLower.contains('rejection') || titleLower.contains('defeat') || titleLower.contains('fired') || titleLower.contains('demotion') || titleLower.contains('scandal') || titleLower.contains('arrest') || titleLower.contains('prison') || titleLower.contains('breakdown') || titleLower.contains('divorce') || titleLower.contains('layoff') || titleLower.contains('court martial') || titleLower.contains('ban')) {
    mode = EventCardMode.failure;
    emojiIllustration = '⚠️';
  } else if (titleLower.contains('funding') || titleLower.contains('offer') || titleLower.contains('sponsorship')) {
    mode = EventCardMode.offer;
    emojiIllustration = '🤝';
  } else if (event.happiness < 0 || event.health < 0 || event.money < 0 || event.jobPerformance < 0 || event.stressLevel > 0) {
    mode = EventCardMode.failure;
    emojiIllustration = '📉';
  } else if (event.happiness > 0 || event.health > 0 || event.money > 0 || event.jobPerformance > 0) {
    mode = EventCardMode.success;
    emojiIllustration = '✨';
  }

  // Generate InfoRows
  List<EventInfoRow> infoRows = [];
  if (event.money != 0) {
    infoRows.add(EventInfoRow(
      label: 'Financial Impact',
      value: event.money > 0 ? '+₹${event.money.abs().toInt()}' : '-₹${event.money.abs().toInt()}',
      valueColor: event.money > 0 ? const Color(0xFF006D37) : const Color(0xFFDC2626),
    ));
  }
  if (event.annualIncomeMod != 1.0) {
    final diff = ((event.annualIncomeMod - 1.0) * 100).round();
    if (diff != 0) {
      infoRows.add(EventInfoRow(
        label: 'Salary Change',
        value: diff > 0 ? '+$diff%' : '$diff%',
        valueColor: diff > 0 ? const Color(0xFF006D37) : const Color(0xFFDC2626),
      ));
    }
  }
  if (event.happiness != 0) {
    infoRows.add(EventInfoRow(
      label: 'Happiness',
      value: event.happiness > 0 ? '+${event.happiness}%' : '${event.happiness}%',
      valueColor: event.happiness > 0 ? const Color(0xFF006D37) : const Color(0xFFDC2626),
    ));
  }
  if (event.health != 0) {
    infoRows.add(EventInfoRow(
      label: 'Health',
      value: event.health > 0 ? '+${event.health}%' : '${event.health}%',
      valueColor: event.health > 0 ? const Color(0xFF006D37) : const Color(0xFFDC2626),
    ));
  }
  if (event.fame != 0) {
    infoRows.add(EventInfoRow(
      label: 'Fame',
      value: event.fame > 0 ? '+${event.fame}%' : '${event.fame}%',
      valueColor: event.fame > 0 ? const Color(0xFF006D37) : const Color(0xFFDC2626),
    ));
  }

  return ActionEvent(
    title: event.title.toUpperCase(),
    description: event.desc,
    type: mode == EventCardMode.failure ? LifeEventType.negative : (mode == EventCardMode.success ? LifeEventType.positive : LifeEventType.milestone),
    category: category,
    mode: mode,
    infoRows: infoRows,
    emojiIllustration: emojiIllustration,
    choice: event.choice,
    metadata: {
      'age': character.age,
      'source': 'smart_event_converter',
      'priority': event.popupPriority,
      'category': event.type,
    },
    statChanges: {
      if (event.happiness != 0) 'happiness': event.happiness,
      if (event.health != 0) 'health': event.health,
      if (event.smarts != 0) 'smarts': event.smarts,
      if (event.social != 0) 'social': event.social,
      if (event.karma != 0) 'karma': event.karma,
    },
  );
}
