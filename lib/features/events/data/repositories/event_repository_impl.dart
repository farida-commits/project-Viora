// lib/features/events/data/repositories/event_repository_impl.dart

import 'package:hive/hive.dart';
import 'package:viora/features/events/domain/entities/event.dart';
import 'package:viora/features/events/domain/repositories/event_repository.dart';
import 'package:viora/features/events/data/models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl(this._box);

  final Box<EventModel> _box;

  @override
  List<Event> getAll() {
    final events = _box.values.map((m) => m.toEntity()).toList();
    print('Getting all events: ${events.length}');
    return events;
  }

  @override
  Event? getById(String id) {
    final model = _box.values.where((m) => m.id == id).firstOrNull;
    return model?.toEntity();
  }

  @override
  Future<void> add(Event event) async {
    final model = EventModel.fromEntity(event);
    await _box.put(model.id, model);
    await _box.flush();
    print('Event added: ${model.id}, total in box: ${_box.length}');
  }

 @override
  Future<void> update(Event event) => add(event);

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
    await _box.flush();
    print('Event deleted: $id, total in box: ${_box.length}');
  }
}