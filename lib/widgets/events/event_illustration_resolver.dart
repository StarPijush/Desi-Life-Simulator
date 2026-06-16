import 'event_types.dart';

class EventIllustrationResolver {
  /// V4: Illustrations are no longer rendered in the universal popup.
  /// Returns null for all categories. Kept for API compatibility.
  static EventIllustration? resolve(EventCategory category, {String? subType}) {
    return null;
  }
}
