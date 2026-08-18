// lib/features/events/data/models/event_task_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/event_task.dart';

part 'event_task_model.g.dart';

@HiveType(typeId: 0)
enum EventTaskStatusModel {
  @HiveField(0)
  inProgress,
  @HiveField(1)
  done,
  @HiveField(2)
  notStarted,
}

@HiveType(typeId: 1)
class EventTaskModel extends HiveObject {
  EventTaskModel({
    required this.id,
    required this.title,
    this.date,
    required this.status,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime? date;

  @HiveField(3)
  final EventTaskStatusModel status;

  EventTask toEntity() => EventTask(
        id: id,
        title: title,
        date: date,
        status: _statusToEntity(status),
      );

  factory EventTaskModel.fromEntity(EventTask t) => EventTaskModel(
        id: t.id,
        title: t.title,
        date: t.date,
        status: _statusFromEntity(t.status),
      );

  static EventTaskStatus _statusToEntity(EventTaskStatusModel s) {
    switch (s) {
      case EventTaskStatusModel.inProgress:
        return EventTaskStatus.inProgress;
      case EventTaskStatusModel.done:
        return EventTaskStatus.done;
      case EventTaskStatusModel.notStarted:
        return EventTaskStatus.notStarted;
    }
  }

  static EventTaskStatusModel _statusFromEntity(EventTaskStatus s) {
    switch (s) {
      case EventTaskStatus.inProgress:
        return EventTaskStatusModel.inProgress;
      case EventTaskStatus.done:
        return EventTaskStatusModel.done;
      case EventTaskStatus.notStarted:
        return EventTaskStatusModel.notStarted;
    }
  }
}