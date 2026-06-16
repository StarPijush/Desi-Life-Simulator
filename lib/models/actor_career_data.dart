import 'package:hive/hive.dart';
import 'actor_award.dart';
import 'actor_agency.dart';
import '../screens/career/special_careers/actor/models/released_project.dart';

part 'actor_career_data.g.dart';

@HiveType(typeId: 22)
class ActorCareerData extends HiveObject {
  @HiveField(0)
  int actingSkill;

  @HiveField(1)
  int fame;

  @HiveField(2)
  int reputation;

  @HiveField(3)
  int fanbase;

  @HiveField(4)
  int experience;

  @HiveField(5)
  List<String> completedMovieProjects;

  @HiveField(6)
  List<ActorAward> actorAwards;

  @HiveField(7)
  List<Map<dynamic, dynamic>> activeProjects;

  @HiveField(8)
  List<String> completedTVProjects;

  @HiveField(9)
  List<ReleasedProject> releasedMovieProjects;

  @HiveField(10)
  List<ReleasedProject> releasedTVProjects;

  @HiveField(11)
  int prestige;

  @HiveField(12)
  ActorAgency? agency;

  @HiveField(13)
  String stardomTier;

  ActorCareerData({
    this.actingSkill = 0,
    this.fame = 0,
    this.reputation = 50,
    this.fanbase = 0,
    this.experience = 0,
    List<String> completedMovieProjects = const [],
    List<dynamic> actorAwards = const [],
    List<Map<dynamic, dynamic>> activeProjects = const [],
    List<String> completedTVProjects = const [],
    List<ReleasedProject> releasedMovieProjects = const [],
    List<ReleasedProject> releasedTVProjects = const [],
    this.prestige = 0,
    this.agency,
    this.stardomTier = 'Newcomer',
  })  : completedMovieProjects = List<String>.from(completedMovieProjects),
        actorAwards = actorAwards
            .map((award) => award is ActorAward
                ? award
                : ActorAward.fromLegacyString(award.toString()))
            .toList(),
        activeProjects = List<Map<dynamic, dynamic>>.from(activeProjects),
        completedTVProjects = List<String>.from(completedTVProjects),
        releasedMovieProjects = List<ReleasedProject>.from(releasedMovieProjects),
        releasedTVProjects = List<ReleasedProject>.from(releasedTVProjects);

  Map<String, dynamic> toJson() => {
        'actingSkill': actingSkill,
        'fame': fame,
        'reputation': reputation,
        'fanbase': fanbase,
        'experience': experience,
        'completedMovieProjects': completedMovieProjects,
        'actorAwards': actorAwards.map((award) => award.toJson()).toList(),
        'activeProjects': activeProjects,
        'completedTVProjects': completedTVProjects,
        'releasedMovieProjects':
            releasedMovieProjects.map((project) => project.toJson()).toList(),
        'releasedTVProjects':
            releasedTVProjects.map((project) => project.toJson()).toList(),
        'prestige': prestige,
        'agency': agency?.toJson(),
        'stardomTier': stardomTier,
      };

  factory ActorCareerData.fromJson(Map<String, dynamic> json) =>
      ActorCareerData(
        actingSkill: json['actingSkill'] as int? ?? 0,
        fame: json['fame'] as int? ?? 0,
        reputation: json['reputation'] as int? ?? 50,
        fanbase: json['fanbase'] as int? ?? 0,
        experience: json['experience'] as int? ?? 0,
        completedMovieProjects:
            List<String>.from(json['completedMovieProjects'] as List? ?? []),
        actorAwards: (json['actorAwards'] as List? ?? [])
            .map((award) => award is ActorAward
                ? award
                : award is Map
                    ? ActorAward.fromJson(Map<String, dynamic>.from(award))
                    : ActorAward.fromLegacyString(award.toString()))
            .toList(),
        activeProjects: (json['activeProjects'] as List? ?? [])
            .map((project) => Map<dynamic, dynamic>.from(project as Map))
            .toList(),
        completedTVProjects:
            List<String>.from(json['completedTVProjects'] as List? ?? []),
        releasedMovieProjects: (json['releasedMovieProjects'] as List? ?? [])
            .map((project) => project is ReleasedProject
                ? project
                : ReleasedProject.fromJson(Map<String, dynamic>.from(project as Map)))
            .toList(),
        releasedTVProjects: (json['releasedTVProjects'] as List? ?? [])
            .map((project) => project is ReleasedProject
                ? project
                : ReleasedProject.fromJson(Map<String, dynamic>.from(project as Map)))
            .toList(),
        prestige: json['prestige'] as int? ?? 0,
        agency: json['agency'] != null
            ? ActorAgency.fromJson(Map<String, dynamic>.from(json['agency'] as Map))
            : null,
        stardomTier: json['stardomTier'] as String? ?? 'Newcomer',
      );
}
