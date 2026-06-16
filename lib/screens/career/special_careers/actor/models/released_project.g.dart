// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'released_project.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReleasedProjectAdapter extends TypeAdapter<ReleasedProject> {
  @override
  final int typeId = 23;

  @override
  ReleasedProject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReleasedProject(
      title: fields[0] as String,
      type: fields[1] as String,
      year: fields[2] as int,
      releaseScore: fields[3] as int,
      criticScore: fields[4] as int,
      audienceScore: fields[5] as int,
      outcome: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReleasedProject obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.releaseScore)
      ..writeByte(4)
      ..write(obj.criticScore)
      ..writeByte(5)
      ..write(obj.audienceScore)
      ..writeByte(6)
      ..write(obj.outcome);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReleasedProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
