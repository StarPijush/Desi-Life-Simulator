import '../core/enums.dart';
import '../models/event_choice.dart';
import '../widgets/events/event_types.dart';

class LifeEvent {
  final String title;
  final String description;
  final LifeEventType type;
  final EventPriority priority;
  final Map<String, int> statChanges;
  final Map<String, dynamic> metadata;
  final EventChoice? choice;

  LifeEvent({
    required this.title,
    required this.description,
    required this.type,
    this.priority = EventPriority.normal,
    Map<String, int>? statChanges,
    Map<String, dynamic>? metadata,
    this.choice,
  })  : statChanges = Map<String, int>.from(statChanges ?? {}),
        metadata = Map<String, dynamic>.from(metadata ?? {});

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'type': type.index,
        'priority': priority.index,
        'statChanges': statChanges,
        'metadata': metadata,
        'choice': choice?.toMap(),
      };

  factory LifeEvent.fromJson(Map<String, dynamic> json) => LifeEvent(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        type: LifeEventType.values[json['type'] ?? 2],
        priority: EventPriority.values[json['priority'] ?? 0],
        statChanges: Map<String, int>.from(json['statChanges'] ?? {}),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        choice: json['choice'] != null ? EventChoice.fromMap(json['choice']) : null,
      );
}

class ActionEvent extends LifeEvent {
  final EventCategory category;
  final EventCardMode mode;
  final List<EventInfoRow> infoRows;
  final List<EventRequirement> requirements;
  final String? emojiIllustration;

  ActionEvent({
    required super.title,
    required super.description,
    required super.type,
    required this.category,
    required this.mode,
    this.infoRows = const [],
    this.requirements = const [],
    this.emojiIllustration,
    super.choice,
    super.statChanges,
    super.metadata,
  });
}
