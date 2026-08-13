// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrganizerModelAdapter extends TypeAdapter<OrganizerModel> {
  @override
  final int typeId = 3;

  @override
  OrganizerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrganizerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      position: fields[2] as String,
      phone: fields[3] as String,
      specialization: fields[4] as String,
      currentEventIds: (fields[5] as List).cast<String>(),
      pastEventIds: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, OrganizerModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.position)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.specialization)
      ..writeByte(5)
      ..write(obj.currentEventIds)
      ..writeByte(6)
      ..write(obj.pastEventIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
