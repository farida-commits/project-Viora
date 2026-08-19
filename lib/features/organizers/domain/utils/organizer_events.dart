// lib/features/organizers/domain/utils/organizer_events.dart

import 'package:viora/features/events/domain/entities/event.dart';
import 'package:viora/providers/event_provider.dart';

/// Организатордун катышкан бардык эвенттери, дата боюнча сортолгон.
/// [upcomingOnly] — бүгүнгүдөн кийинки/тең гана; [pastOnly] — бүгүнгүдөн мурунку гана.
List<Event> organizerEvents(
  EventProvider eventProvider,
  String organizerId, {
  bool upcomingOnly = false,
  bool pastOnly = false,
}) {
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);

  var events = eventProvider.events
      .where((e) => e.organizerIds.contains(organizerId))
      .toList();

  if (upcomingOnly) {
    events = events
        .where((e) => !DateTime(e.date.year, e.date.month, e.date.day).isBefore(todayOnly))
        .toList();
  } else if (pastOnly) {
    events = events
        .where((e) => DateTime(e.date.year, e.date.month, e.date.day).isBefore(todayOnly))
        .toList();
  }

  events.sort((a, b) => a.date.compareTo(b.date));
  return events;
}

/// Организатордун эң жакынкы алдыдагы эвенти, же null.
Event? organizerNextEvent(EventProvider eventProvider, String organizerId) {
  final upcoming = organizerEvents(eventProvider, organizerId, upcomingOnly: true);
  return upcoming.isNotEmpty ? upcoming.first : null;
}

/// "12 Jun — Alice & Tom Wedding" түрүндөгү даяр текст, эвент жок болсо бош сап.
String organizerNextEventText(EventProvider eventProvider, String organizerId) {
  final event = organizerNextEvent(eventProvider, organizerId);
  if (event == null) return '';
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final dateStr = '${event.date.day} ${months[event.date.month - 1]}';
  return '$dateStr — ${event.title}';
}