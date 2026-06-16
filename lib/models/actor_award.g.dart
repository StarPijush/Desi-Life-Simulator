// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_award.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActorAwardAdapter extends TypeAdapter<ActorAward> {
  @override
  final int typeId = 24;

  @override
  ActorAward read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActorAward(
      awardName: fields[0] as String,
      projectTitle: fields[1] as String,
      year: fields[2] as int,
      category: fields[3] as String,
      won: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ActorAward obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.awardName)
      ..writeByte(1)
      ..write(obj.projectTitle)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.won);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActorAwardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
