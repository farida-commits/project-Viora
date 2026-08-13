// lib/features/organizers/domain/repositories/organizer_repository.dart

import '../entities/organizer.dart';

abstract class OrganizerRepository {
  List<Organizer> getAll();
  Organizer? getById(String id);
  Future<void> add(Organizer organizer);
  Future<void> update(Organizer organizer);
  Future<void> delete(String id);
}