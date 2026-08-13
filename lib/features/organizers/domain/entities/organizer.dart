class Organizer {
  const Organizer({
    required this.id,
    required this.name,
    required this.position,
    required this.phone,
    required this.specialization,
    required this.currentEventIds,
    required this.pastEventIds,
    this.nextEventDate,
  });

  final String id;
  final String name;
  final String position;
  final String phone;
  final String specialization;
  final List<String> currentEventIds;
  final List<String> pastEventIds;

  /// дата ближайшего ивента — показывается в карточке
  final DateTime? nextEventDate;
}