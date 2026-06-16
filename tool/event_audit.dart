import 'package:desilife/core/enums.dart';
import 'package:desilife/core/event_data.dart';
import 'package:desilife/core/events/data/premium_phase2_events.dart';

void main() {
  final events = EventData.allSmartEvents;
  final byCategory = <String, int>{};
  final byRarity = <EventRarity, int>{};

  for (final event in events) {
    byCategory.update(event.type, (count) => count + 1, ifAbsent: () => 1);
    byRarity.update(event.rarity, (count) => count + 1, ifAbsent: () => 1);
  }

  final premiumCount = premiumPhase2Events.length;
  final genericCount = events.where((event) {
    final title = event.title.toLowerCase();
    final desc = event.desc.toLowerCase();
    return title == 'success' ||
        title == 'failure' ||
        title == 'action complete' ||
        title == 'action failed' ||
        title == 'operation successful' ||
        title == 'completed successfully' ||
        desc.contains('placeholder') ||
        desc.contains('generic event');
  }).length;

  print('Total events: ${events.length}');
  print('Premium phase 2 events: $premiumCount');
  print('Legendary events: ${byRarity[EventRarity.legendary] ?? 0}');
  print('Epic events: ${byRarity[EventRarity.epic] ?? 0}');
  print('Generic events: $genericCount');

  print('\nEvents by category:');
  for (final entry in _sortedEntries(byCategory)) {
    print('${entry.key}: ${entry.value}');
  }

  print('\nEvents by rarity:');
  for (final rarity in EventRarity.values) {
    print('${rarity.name}: ${byRarity[rarity] ?? 0}');
  }
}

List<MapEntry<String, int>> _sortedEntries(Map<String, int> map) {
  return map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
}
