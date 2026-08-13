// lib/features/organizers/data/repositories/organizer_repository_impl.dart

import 'package:hive/hive.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';
import 'package:viora/features/organizers/domain/repositories/organizer_repository.dart';
import 'package:viora/features/organizers/data/models/organizer_model.dart';

class OrganizerRepositoryImpl implements OrganizerRepository {
  OrganizerRepositoryImpl(this._box);

  final Box<OrganizerModel> _box;

  @override
  List<Organizer> getAll() => _box.values.map((m) => m.toEntity()).toList();

  @override
  Organizer? getById(String id) {
    final model = _box.values.where((m) => m.id == id).firstOrNull;
    return model?.toEntity();
  }

  @override
  Future<void> add(Organizer organizer) async {
    final model = OrganizerModel.fromEntity(organizer);
    await _box.put(model.id, model);
  }

  @override
  Future<void> update(Organizer organizer) => add(organizer);

  @override
  Future<void> delete(String id) => _box.delete(id);
}