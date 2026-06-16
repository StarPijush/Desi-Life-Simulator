import 'package:flutter/widgets.dart';

enum EventCardMode {
  info,
  choice,
  success,
  failure,
  actions,
  offer,
  requirement,
}

enum EventCategory {
  military,
  politics,
  education,
  scholarship,
  career,
  freelance,
  relationships,
  family,
  health,
  crime,
  fame,
  actor,
  singer,
  business,
  cricketer,
  footballer,
  finance,
}

enum EventIllustrationType {
  emoji,
  asset,
  svg,
  portrait,
  custom,
}

class EventIllustration {
  final EventIllustrationType type;
  final String? value;
  final Widget? widget;
  final double size;

  const EventIllustration._({
    required this.type,
    this.value,
    this.widget,
    this.size = 72,
  });

  const EventIllustration.emoji(String emoji, {double size = 72})
      : this._(
          type: EventIllustrationType.emoji,
          value: emoji,
          size: size,
        );

  const EventIllustration.asset(String assetPath, {double size = 72})
      : this._(
          type: EventIllustrationType.asset,
          value: assetPath,
          size: size,
        );

  const EventIllustration.svg(String assetPath, {double size = 72})
      : this._(
          type: EventIllustrationType.svg,
          value: assetPath,
          size: size,
        );

  const EventIllustration.portrait(String assetPath, {double size = 72})
      : this._(
          type: EventIllustrationType.portrait,
          value: assetPath,
          size: size,
        );

  const EventIllustration.custom(Widget child, {double size = 72})
      : this._(
          type: EventIllustrationType.custom,
          widget: child,
          size: size,
        );
}

class EventInfoRow {
  final String label;
  final String value;
  final Color? valueColor;

  const EventInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });
}

class EventCardAction {
  final String label;
  final VoidCallback onPressed;

  const EventCardAction({
    required this.label,
    required this.onPressed,
  });
}

class EventRequirement {
  final String? emojiIcon;
  final String label;
  final bool isMet;
  final String? currentValue;
  final String? requiredValue;
  final String? guidance;

  const EventRequirement({
    this.emojiIcon,
    required this.label,
    required this.isMet,
    this.currentValue,
    this.requiredValue,
    this.guidance,
  });
}
