// lib/features/events/domain/entities/event_task.dart

enum EventTaskStatus { inProgress, done, notStarted }

class EventTask {
  const EventTask({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
  });

  final String id;
  final String title;
  final DateTime? date;
  final EventTaskStatus status;

  EventTask copyWith({String? title, DateTime? date, EventTaskStatus? status}) {
    return EventTask(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}