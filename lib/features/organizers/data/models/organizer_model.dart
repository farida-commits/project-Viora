// lib/features/organizers/data/models/organizer_model.dart

import 'package:hive/hive.dart';
import '../../domain/entities/organizer.dart';

part 'organizer_model.g.dart';

@HiveType(typeId: 3)
class OrganizerModel extends HiveObject {
  OrganizerModel({
    required this.id,
    required this.name,
    required this.position,
    required this.phone,
    required this.specialization,
    required this.currentEventIds,
    required this.pastEventIds,
    this.photoPath,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String position;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String specialization;

  @HiveField(5)
  final List<String> currentEventIds;

  @HiveField(6)
  final List<String> pastEventIds;

  @HiveField(7)
  final String? photoPath;

  Organizer toEntity() => Organizer(
        id: id,
        name: name,
        position: position,
        phone: phone,
        specialization: specialization,
        currentEventIds: currentEventIds,
        pastEventIds: pastEventIds,
        photoPath: photoPath,
      );

  factory OrganizerModel.fromEntity(Organizer o) => OrganizerModel(
        id: o.id,
        name: o.name,
        position: o.position,
        phone: o.phone,
        specialization: o.specialization,
        currentEventIds: o.currentEventIds,
        pastEventIds: o.pastEventIds,
        photoPath: o.photoPath,
      );
}