// lib/providers/organizer_provider.dart

import 'package:flutter/foundation.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';
import 'package:viora/features/organizers/domain/repositories/organizer_repository.dart';

class OrganizerProvider extends ChangeNotifier {
  OrganizerProvider(this._repository) {
    _organizers.addAll(_repository.getAll());
  }

  final OrganizerRepository _repository;
  final List<Organizer> _organizers = [];

  List<Organizer> get organizers => List.unmodifiable(_organizers);

  Organizer? getById(String id) {
    for (final o in _organizers) {
      if (o.id == id) return o;
    }
    return null;
  }

  Future<void> add(Organizer organizer) async {
    await _repository.add(organizer);
    _organizers.add(organizer);
    notifyListeners();
  }

  Future<void> update(Organizer organizer) async {
    await _repository.update(organizer);
    final index = _organizers.indexWhere((o) => o.id == organizer.id);
    if (index == -1) return;
    _organizers[index] = organizer;
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    _organizers.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}