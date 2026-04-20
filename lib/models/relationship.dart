// lib/models/relationship.dart
import 'package:hive/hive.dart';

part 'relationship.g.dart';

@HiveType(typeId: 1)
class Relationship {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type; // 'Father', 'Mother', 'Sibling', 'Friend', 'Partner'

  @HiveField(2)
  int bond; // 0-100

  @HiveField(3)
  int age;

  @HiveField(4)
  bool isAlive;

  @HiveField(5)
  String initial;

  @HiveField(6)
  bool isRival;

  @HiveField(7)
  String rivalCareer;

  @HiveField(8)
  int rivalIntensity;

  Relationship({
    required this.name,
    required this.type,
    this.bond = 50,
    this.isAlive = true,
    required this.initial,
    this.age = 0,
    this.isRival = false,
    this.rivalCareer = '',
    this.rivalIntensity = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'bond': bond,
        'age': age,
        'isAlive': isAlive,
        'initial': initial,
        'isRival': isRival,
        'rivalCareer': rivalCareer,
        'rivalIntensity': rivalIntensity,
      };

  factory Relationship.fromJson(Map<String, dynamic> json) => Relationship(
        name: json['name'] as String,
        type: json['type'] as String,
        bond: json['bond'] as int? ?? 50,
        age: json['age'] as int? ?? 0,
        isAlive: json['isAlive'] as bool? ?? true,
        initial: json['initial'] as String? ?? '?',
        isRival: json['isRival'] as bool? ?? false,
        rivalCareer: json['rivalCareer'] as String? ?? '',
        rivalIntensity: json['rivalIntensity'] as int? ?? 0,
      );
}
