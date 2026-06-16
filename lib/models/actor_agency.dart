import 'package:hive/hive.dart';

part 'actor_agency.g.dart';

@HiveType(typeId: 25)
class ActorAgency extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int reputation;

  @HiveField(2)
  int commission;

  ActorAgency({
    required this.name,
    this.reputation = 50,
    this.commission = 15,
  });

  /// Salary multiplier based on agency tier
  double get salaryMultiplier {
    if (name == 'Global Agency') return 3.0;
    if (name == 'Elite Agency') return 2.0;
    if (name == 'National Agency') return 1.5;
    if (name == 'Regional Agency') return 1.25;
    if (name == 'Local Agency') return 1.1;
    return 1.0;
  }

  /// Agency tier name for display
  String get tierName {
    if (name.contains('Global')) return 'Global';
    if (name.contains('Elite')) return 'Elite';
    if (name.contains('National')) return 'National';
    if (name.contains('Regional')) return 'Regional';
    if (name.contains('Local')) return 'Local';
    return 'Independent';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'reputation': reputation,
        'commission': commission,
      };

  factory ActorAgency.fromJson(Map<String, dynamic> json) => ActorAgency(
        name: json['name'] as String? ?? 'Local Agency',
        reputation: json['reputation'] as int? ?? 50,
        commission: json['commission'] as int? ?? 15,
      );
}
