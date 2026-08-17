// lib/features/events/domain/entities/event.dart

import 'event_task.dart';
import 'expense.dart';

class Event {
  const Event({
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

  final String id;
  final String title;

  final String? photoAsset;

  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String location;
  final String description;
  final List<String> clientNotes;
  final List<EventTask> tasks;
  final double budget;
  final List<Expense> expenses;
  final List<String> organizerIds;

  String? get imageAsset => photoAsset;

  int get tasksDone => tasks.where((t) => t.status == EventTaskStatus.done).length;
  int get tasksTotal => tasks.length;

  double get spent => expenses.fold(0.0, (s, e) => s + e.price);
  double get fundBalance => budget - spent;
}