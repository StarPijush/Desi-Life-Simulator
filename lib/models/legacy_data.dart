// lib/models/legacy_data.dart
import 'package:hive/hive.dart';

part 'legacy_data.g.dart';

@HiveType(typeId: 3)
class LegacyStore {
  @HiveField(0)
  int totalLegacyPoints;

  @HiveField(1)
  int livesLived;

  @HiveField(2)
  Map<String, int> permanentUnlocks; // e.g. {'start_cash_rank': 1}

  LegacyStore({
    this.totalLegacyPoints = 0,
    this.livesLived = 0,
    this.permanentUnlocks = const {},
  });
}
