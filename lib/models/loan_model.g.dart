// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually maintained to avoid build_runner dependency.

part of 'loan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanModelAdapter extends TypeAdapter<LoanModel> {
  @override
  final int typeId = 4;

  @override
  LoanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanModel(
      type: fields[0] as String? ?? 'Personal',
      startAge: fields[1] as int? ?? 0,
      durationYears: fields[2] as int? ?? 5,
      amount: (fields[3] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (fields[4] as num?)?.toDouble() ?? 0.0,
      interestRate: (fields[5] as num?)?.toDouble() ?? 0.12,
    );
  }

  @override
  void write(BinaryWriter writer, LoanModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.startAge)
      ..writeByte(2)
      ..write(obj.durationYears)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.remainingAmount)
      ..writeByte(5)
      ..write(obj.interestRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
