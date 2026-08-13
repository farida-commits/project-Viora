import 'package:flutter/foundation.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';

class OrganizerProvider extends ChangeNotifier {
  final List<Organizer> _organizers = [];

  List<Organizer> get organizers => List.unmodifiable(_organizers);

  void add(Organizer organizer) {
    _organizers.add(organizer);
    notifyListeners();
  }

  void remove(String id) {
    _organizers.removeWhere((o) => o.id == id);
    notifyListeners();
  }
}