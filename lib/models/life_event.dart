// lib/models/life_event.dart
import '../core/enums.dart';

class LifeEvent {
  final String title;
  final String description;
  final LifeEventType type;
  final EventPriority priority;
  final Map<String, int> statChanges;
  final Map<String, dynamic> metadata;

  const LifeEvent({
    required this.title,
    required this.description,
    required this.type,
    this.priority = EventPriority.normal,
    this.statChanges = const {},
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'type': type.index,
        'priority': priority.index,
        'statChanges': statChanges,
        'metadata': metadata,
      };

  factory LifeEvent.fromJson(Map<String, dynamic> json) => LifeEvent(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        type: LifeEventType.values[json['type'] ?? 2],
        priority: EventPriority.values[json['priority'] ?? 0],
        statChanges: Map<String, int>.from(json['statChanges'] ?? {}),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}
