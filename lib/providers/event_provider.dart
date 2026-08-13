import 'package:flutter/foundation.dart';
import 'package:viora/features/events/domain/entities/event.dart';

class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];
  String _query = '';

  List<Event> get events => List.unmodifiable(_events);
  String get query => _query;

  bool get showSearchc => _events.length > 5;

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

  void add(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void remove(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}