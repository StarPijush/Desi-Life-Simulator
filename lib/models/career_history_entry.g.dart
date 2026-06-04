// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career_history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CareerHistoryEntryAdapter extends TypeAdapter<CareerHistoryEntry> {
  @override
  final int typeId = 21;

  @override
  CareerHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CareerHistoryEntry(
      careerName: fields[0] as String,
      startAge: fields[1] as int,
      endAge: fields[2] as int,
      yearsWorked: fields[3] as int,
      achievement: fields[4] as String,
      careerType: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CareerHistoryEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.careerName)
      ..writeByte(1)
      ..write(obj.startAge)
      ..writeByte(2)
      ..write(obj.endAge)
      ..writeByte(3)
      ..write(obj.yearsWorked)
      ..writeByte(4)
      ..write(obj.achievement)
      ..writeByte(5)
      ..write(obj.careerType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
