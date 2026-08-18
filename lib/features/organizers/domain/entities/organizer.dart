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
    this.photoPath,
  });

  final String id;
  final String name;
  final String position;
  final String phone;
  final String specialization;
  final List<String> currentEventIds;
  final List<String> pastEventIds;
  final DateTime? nextEventDate;
  final String? photoPath; // локальный путь к фото (assets или файл на устройстве)

  Organizer copyWith({
    String? id,
    String? name,
    String? position,
    String? phone,
    String? specialization,
    List<String>? currentEventIds,
    List<String>? pastEventIds,
    DateTime? nextEventDate,
    String? photoPath,
  }) {
    return Organizer(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      currentEventIds: currentEventIds ?? this.currentEventIds,
      pastEventIds: pastEventIds ?? this.pastEventIds,
      nextEventDate: nextEventDate ?? this.nextEventDate,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}