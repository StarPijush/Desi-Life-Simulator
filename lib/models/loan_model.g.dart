// GENERATED CODE - DO NOT MODIFY BY HAND

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
      type: fields[0] as String,
      startAge: fields[1] as int,
      durationYears: fields[2] as int,
      amount: fields[3] as double,
      remainingAmount: fields[4] as double,
      interestRate: fields[5] as double,
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
