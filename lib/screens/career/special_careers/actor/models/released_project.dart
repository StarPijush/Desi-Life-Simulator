import 'package:hive/hive.dart';

part 'released_project.g.dart';

@HiveType(typeId: 23)
class ReleasedProject extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String type; // 'movie' or 'tv'

  @HiveField(2)
  final int year;

  @HiveField(3)
  final int releaseScore;

  @HiveField(4)
  final int criticScore;

  @HiveField(5)
  final int audienceScore;

  @HiveField(6)
  final String outcome; // FLOP, AVERAGE, HIT, SUPER HIT, BLOCKBUSTER

  ReleasedProject({
    required this.title,
    required this.type,
    required this.year,
    required this.releaseScore,
    required this.criticScore,
    required this.audienceScore,
    required this.outcome,
  });

  ReleasedProject copyWith({
    String? title,
    String? type,
    int? year,
    int? releaseScore,
    int? criticScore,
    int? audienceScore,
    String? outcome,
  }) {
    return ReleasedProject(
      title: title ?? this.title,
      type: type ?? this.type,
      year: year ?? this.year,
      releaseScore: releaseScore ?? this.releaseScore,
      criticScore: criticScore ?? this.criticScore,
      audienceScore: audienceScore ?? this.audienceScore,
      outcome: outcome ?? this.outcome,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type,
        'year': year,
        'releaseScore': releaseScore,
        'criticScore': criticScore,
        'audienceScore': audienceScore,
        'outcome': outcome,
      };

  factory ReleasedProject.fromJson(Map<String, dynamic> json) =>
      ReleasedProject(
        title: json['title'] ?? '',
        type: json['type'] ?? 'movie',
        year: json['year'] ?? 0,
        releaseScore: json['releaseScore'] ?? 0,
        criticScore: json['criticScore'] ?? 0,
        audienceScore: json['audienceScore'] ?? 0,
        outcome: json['outcome'] ?? 'AVERAGE',
      );
}
