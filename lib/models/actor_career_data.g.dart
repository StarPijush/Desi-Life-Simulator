// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_career_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActorCareerDataAdapter extends TypeAdapter<ActorCareerData> {
  @override
  final int typeId = 22;

  @override
  ActorCareerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActorCareerData(
      actingSkill: fields[0] as int,
      fame: fields[1] as int,
      reputation: fields[2] as int,
      fanbase: fields[3] as int,
      experience: fields[4] as int,
      completedMovieProjects: (fields[5] as List).cast<String>(),
      actorAwards: (fields[6] as List).cast<dynamic>(),
      activeProjects: (fields[7] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      completedTVProjects: (fields[8] as List).cast<String>(),
      releasedMovieProjects: (fields[9] as List).cast<ReleasedProject>(),
      releasedTVProjects: (fields[10] as List).cast<ReleasedProject>(),
      prestige: fields[11] as int,
      agency: fields[12] as ActorAgency?,
      stardomTier: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ActorCareerData obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.actingSkill)
      ..writeByte(1)
      ..write(obj.fame)
      ..writeByte(2)
      ..write(obj.reputation)
      ..writeByte(3)
      ..write(obj.fanbase)
      ..writeByte(4)
      ..write(obj.experience)
      ..writeByte(5)
      ..write(obj.completedMovieProjects)
      ..writeByte(6)
      ..write(obj.actorAwards)
      ..writeByte(7)
      ..write(obj.activeProjects)
      ..writeByte(8)
      ..write(obj.completedTVProjects)
      ..writeByte(9)
      ..write(obj.releasedMovieProjects)
      ..writeByte(10)
      ..write(obj.releasedTVProjects)
      ..writeByte(11)
      ..write(obj.prestige)
      ..writeByte(12)
      ..write(obj.agency)
      ..writeByte(13)
      ..write(obj.stardomTier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActorCareerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
