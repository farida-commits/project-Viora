// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventTaskModelAdapter extends TypeAdapter<EventTaskModel> {
  @override
  final int typeId = 1;

  @override
  EventTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventTaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime?,
      status: fields[3] as EventTaskStatusModel,
    );
  }

  @override
  void write(BinaryWriter writer, EventTaskModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EventTaskStatusModelAdapter extends TypeAdapter<EventTaskStatusModel> {
  @override
  final int typeId = 0;

  @override
  EventTaskStatusModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EventTaskStatusModel.inProgress;
      case 1:
        return EventTaskStatusModel.done;
      case 2:
        return EventTaskStatusModel.notStarted;
      default:
        return EventTaskStatusModel.inProgress;
    }
  }

  @override
  void write(BinaryWriter writer, EventTaskStatusModel obj) {
    switch (obj) {
      case EventTaskStatusModel.inProgress:
        writer.writeByte(0);
        break;
      case EventTaskStatusModel.done:
        writer.writeByte(1);
        break;
      case EventTaskStatusModel.notStarted:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTaskStatusModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
