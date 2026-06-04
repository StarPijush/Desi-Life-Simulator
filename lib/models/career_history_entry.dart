import 'package:hive/hive.dart';

part 'career_history_entry.g.dart';

@HiveType(typeId: 21) // Incrementing from Character (20)
class CareerHistoryEntry extends HiveObject {
  @HiveField(0)
  final String careerName;

  @HiveField(1)
  final int startAge;

  @HiveField(2)
  final int endAge;

  @HiveField(3)
  final int yearsWorked;

  @HiveField(4)
  final String achievement;

  @HiveField(5)
  final String careerType;

  CareerHistoryEntry({
    required this.careerName,
    required this.startAge,
    required this.endAge,
    required this.yearsWorked,
    required this.achievement,
    required this.careerType,
  });

  Map<String, dynamic> toJson() => {
        'careerName': careerName,
        'startAge': startAge,
        'endAge': endAge,
        'yearsWorked': yearsWorked,
        'achievement': achievement,
        'careerType': careerType,
      };

  factory CareerHistoryEntry.fromJson(Map<String, dynamic> json) =>
      CareerHistoryEntry(
        careerName: json['careerName'] as String,
        startAge: json['startAge'] as int,
        endAge: json['endAge'] as int,
        yearsWorked: json['yearsWorked'] as int,
        achievement: json['achievement'] as String,
        careerType: json['careerType'] as String,
      );
}
