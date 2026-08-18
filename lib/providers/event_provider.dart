// lib/providers/event_provider.dart

import 'package:flutter/foundation.dart';
import 'package:viora/features/events/domain/entities/event.dart';
import 'package:viora/features/events/domain/repositories/event_repository.dart';

class EventProvider extends ChangeNotifier {
  EventProvider(this._repository) {
    _events.addAll(_repository.getAll());
  }

  final EventRepository _repository;
  final List<Event> _events = [];
  String _query = '';

  List<Event> get events => List.unmodifiable(_events);
  String get query => _query;

  bool get showSearch => _events.length > 5;

  List<Event> get _filtered {
    if (_query.trim().isEmpty) return _events;
    final q = _query.toLowerCase();
    return _events.where((e) => e.title.toLowerCase().contains(q)).toList();
  }

  List<Event> get upcomingThisWeek {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));
    final list = _filtered
        .where((e) => !e.date.isBefore(today) && e.date.isBefore(weekEnd))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<Event> get others {
    final upcomingIds = upcomingThisWeek.map((e) => e.id).toSet();
    final list = _filtered.where((e) => !upcomingIds.contains(e.id)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  bool get hasResults => upcomingThisWeek.isNotEmpty || others.isNotEmpty;

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  Future<void> add(Event event) async {
    await _repository.add(event);
    _events.add(event);
    notifyListeners();
  }

  Future<void> update(Event event) async {
    await _repository.update(event);
    final i = _events.indexWhere((e) => e.id == event.id);
    if (i != -1) _events[i] = event;
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}