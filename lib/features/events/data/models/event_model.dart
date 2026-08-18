// lib/features/events/data/models/event_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/event.dart';
import 'event_task_model.dart';
import 'expense_model.dart';

part 'event_model.g.dart';

@HiveType(typeId: 4)
class EventModel extends HiveObject {
  EventModel({
    required this.id,
    required this.title,
    this.photoAsset,
    required this.date,
    this.startTime,
    this.endTime,
    this.location = '',
    this.description = '',
    this.clientNotes = const [],
    this.tasks = const [],
    this.budget = 0,
    this.expenses = const [],
    this.organizerIds = const [],
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? photoAsset;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? startTime;

  @HiveField(5)
  final String? endTime;

  @HiveField(6)
  final String location;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final List<String> clientNotes;

  @HiveField(9)
  final List<EventTaskModel> tasks;

  @HiveField(10)
  final double budget;

  @HiveField(11)
  final List<ExpenseModel> expenses;

  @HiveField(12)
  final List<String> organizerIds;

  Event toEntity() => Event(
        id: id,
        title: title,
        photoAsset: photoAsset,
        date: date,
        startTime: startTime,
        endTime: endTime,
        location: location,
        description: description,
        clientNotes: clientNotes,
        tasks: tasks.map((t) => t.toEntity()).toList(),
        budget: budget,
        expenses: expenses.map((e) => e.toEntity()).toList(),
        organizerIds: organizerIds,
      );

  factory EventModel.fromEntity(Event e) => EventModel(
        id: e.id,
        title: e.title,
        photoAsset: e.photoAsset,
        date: e.date,
        startTime: e.startTime,
        endTime: e.endTime,
        location: e.location,
        description: e.description,
        clientNotes: e.clientNotes,
        tasks: e.tasks.map((t) => EventTaskModel.fromEntity(t)).toList(),
        budget: e.budget,
        expenses: e.expenses.map((ex) => ExpenseModel.fromEntity(ex)).toList(),
        organizerIds: e.organizerIds,
      );
}