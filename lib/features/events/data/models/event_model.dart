// lib/features/events/domain/entities/event.dart

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.clientWishes,
    required this.status,
    required this.budgetTotal,
    required this.budgetSpent,
    required this.organizerIds,
  });

  final String id;
  final String title;
  final DateTime date;
  final String time;
  final String location;
  final String description;
  final String clientWishes;
  final String status;
  final double budgetTotal;
  final double budgetSpent;
  final List<String> organizerIds;

  double get budgetLeft => budgetTotal - budgetSpent;
}