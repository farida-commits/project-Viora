// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 4;

  @override
  EventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventModel(
      id: fields[0] as String,
      title: fields[1] as String,
      photoAsset: fields[2] as String?,
      date: fields[3] as DateTime,
      startTime: fields[4] as String?,
      endTime: fields[5] as String?,
      location: fields[6] as String,
      description: fields[7] as String,
      clientNotes: (fields[8] as List).cast<String>(),
      tasks: (fields[9] as List).cast<EventTaskModel>(),
      budget: fields[10] as double,
      expenses: (fields[11] as List).cast<ExpenseModel>(),
      organizerIds: (fields[12] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.photoAsset)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.clientNotes)
      ..writeByte(9)
      ..write(obj.tasks)
      ..writeByte(10)
      ..write(obj.budget)
      ..writeByte(11)
      ..write(obj.expenses)
      ..writeByte(12)
      ..write(obj.organizerIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
