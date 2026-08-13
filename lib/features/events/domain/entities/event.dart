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
    this.imageAsset,
    this.tasksDone = 0,
    this.tasksTotal = 0,
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

  /// путь к ассету картинки карточки, если нет — карточка без фото
  final String? imageAsset;

  final int tasksDone;
  final int tasksTotal;

  double get budgetLeft => budgetTotal - budgetSpent;
}