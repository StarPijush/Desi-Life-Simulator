// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RelationshipAdapter extends TypeAdapter<Relationship> {
  @override
  final int typeId = 1;

  @override
  Relationship read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Relationship(
      name: fields[0] as String,
      type: fields[1] as String,
      bond: fields[2] as int,
      isAlive: fields[4] as bool,
      initial: fields[5] as String,
      age: fields[3] as int,
      isRival: fields[6] as bool,
      rivalCareer: fields[7] as String,
      rivalIntensity: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Relationship obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.bond)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.isAlive)
      ..writeByte(5)
      ..write(obj.initial)
      ..writeByte(6)
      ..write(obj.isRival)
      ..writeByte(7)
      ..write(obj.rivalCareer)
      ..writeByte(8)
      ..write(obj.rivalIntensity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelationshipAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
