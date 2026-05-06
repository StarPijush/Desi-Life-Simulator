// lib/models/loan_model.dart
import 'package:hive/hive.dart';

part 'loan_model.g.dart';

@HiveType(typeId: 4)
class LoanModel extends HiveObject {
  @HiveField(0)
  String type; // 'Student', 'Personal', 'Home'

  @HiveField(1)
  int startAge;

  @HiveField(2)
  int durationYears;

  @HiveField(3)
  double amount; // original principal

  @HiveField(4)
  double remainingAmount;

  @HiveField(5)
  double interestRate; // e.g. 0.06 for 6%

  LoanModel({
    required this.type,
    required this.startAge,
    required this.durationYears,
    required this.amount,
    required this.remainingAmount,
    required this.interestRate,
  });

  /// Dynamic computation — pass current character age
  int remainingYears(int currentAge) {
    final end = startAge + durationYears;
    return (end - currentAge).clamp(0, durationYears);
  }

  /// Yearly EMI approximation (flat annuity)
  double get yearlyEmi {
    if (durationYears <= 0) return remainingAmount;
    final r = interestRate;
    if (r == 0) return amount / durationYears;
    // Standard EMI formula (annual)
    final factor = (r * (1 + r) * durationYears) / (((1 + r) * durationYears) - 1);
    return amount * factor;
  }

  /// Risk level based on remaining amount vs original
  String get riskLabel {
    if (remainingAmount <= 0) return 'CLEAR';
    final ratio = remainingAmount / amount;
    if (ratio > 0.95) return 'CRITICAL';
    if (ratio > 0.7) return 'HIGH';
    if (ratio > 0.35) return 'MODERATE';
    return 'LOW';
  }

  LoanModel clone() => LoanModel(
        type: type,
        startAge: startAge,
        durationYears: durationYears,
        amount: amount,
        remainingAmount: remainingAmount,
        interestRate: interestRate,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'startAge': startAge,
        'durationYears': durationYears,
        'amount': amount,
        'remainingAmount': remainingAmount,
        'interestRate': interestRate,
      };

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        type: json['type'] as String? ?? 'Personal',
        startAge: json['startAge'] as int? ?? 0,
        durationYears: json['durationYears'] as int? ?? 5,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
        interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.12,
      );

  /// Migrate from legacy single-loan fields on Character
  factory LoanModel.fromLegacy({
    required String type,
    required double amount,
    required int currentAge,
  }) {
    final rate = type == 'Student' ? 0.06 : (type == 'Home' ? 0.08 : 0.12);
    final dur = type == 'Student' ? 7 : (type == 'Home' ? 15 : 5);
    return LoanModel(
      type: type,
      startAge: currentAge,
      durationYears: dur,
      amount: amount,
      remainingAmount: amount,
      interestRate: rate,
    );
  }
}
