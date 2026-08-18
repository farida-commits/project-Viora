// lib/features/events/domain/repositories/event_repository.dart

import '../entities/event.dart';

abstract class EventRepository {
  List<Event> getAll();
  Event? getById(String id);
  Future<void> add(Event event);
  Future<void> update(Event event);
  Future<void> delete(String id);
}