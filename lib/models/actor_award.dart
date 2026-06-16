import 'package:hive/hive.dart';

part 'actor_award.g.dart';

@HiveType(typeId: 24)
class ActorAward extends HiveObject {
  @HiveField(0)
  final String awardName;

  @HiveField(1)
  final String projectTitle;

  @HiveField(2)
  final int year;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final bool won;

  ActorAward({
    required this.awardName,
    required this.projectTitle,
    required this.year,
    required this.category,
    required this.won,
  });

  Map<String, dynamic> toJson() => {
        'awardName': awardName,
        'projectTitle': projectTitle,
        'year': year,
        'category': category,
        'won': won,
      };

  factory ActorAward.fromJson(Map<String, dynamic> json) => ActorAward(
        awardName: json['awardName'] as String? ?? 'Acting Award',
        projectTitle: json['projectTitle'] as String? ?? '',
        year: json['year'] as int? ?? 0,
        category: json['category'] as String? ?? 'Actor',
        won: json['won'] as bool? ?? false,
      );

  factory ActorAward.fromLegacyString(String awardName) => ActorAward(
        awardName: awardName,
        projectTitle: 'Legacy Record',
        year: 0,
        category: 'Legacy',
        won: true,
      );
}
