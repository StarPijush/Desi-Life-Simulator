// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legacy_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LegacyStoreAdapter extends TypeAdapter<LegacyStore> {
  @override
  final int typeId = 3;

  @override
  LegacyStore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LegacyStore(
      totalLegacyPoints: fields[0] as int,
      livesLived: fields[1] as int,
      permanentUnlocks: (fields[2] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, LegacyStore obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.totalLegacyPoints)
      ..writeByte(1)
      ..write(obj.livesLived)
      ..writeByte(2)
      ..write(obj.permanentUnlocks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegacyStoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
