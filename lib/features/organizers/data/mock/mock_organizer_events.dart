// lib/features/organizers/data/mock/mock_organizer_events.dart


// TODO: временные мок-данные для карточек, календаря и истории организатора.
// Удалить/заменить, когда появится реальный EventProvider у коллеги.

class OrganizerMockEvent {
  const OrganizerMockEvent({
    required this.title,
    required this.date,
    this.timeRange,
  });

  final String title;
  final DateTime date;
  final String? timeRange;
}

/// текущие/предстоящие ивенты — для карточки в списке и календаря
final Map<String, OrganizerMockEvent> mockEvents = {
  'evt-1': OrganizerMockEvent(
    title: 'Alice & Tom Wedding',
    date: DateTime(2025, 6, 12),
    timeRange: '14:00–22:00',
  ),
  'evt-1b': OrganizerMockEvent(
    title: 'Anniversary Dinner',
    date: DateTime(2025, 6, 20),
    timeRange: '18:00–21:00',
  ),
  'evt-1c': OrganizerMockEvent(
    title: 'Vendor Meeting',
    date: DateTime(2025, 6, 24),
    timeRange: '10:00–11:00',
  ),
  'evt-1d': OrganizerMockEvent(
    title: 'Venue Walkthrough',
    date: DateTime(2025, 6, 28),
    timeRange: '09:00–10:00',
  ),
  'evt-2': OrganizerMockEvent(
    title: "Summer '25 Fashion Show",
    date: DateTime(2025, 6, 20),
    timeRange: '19:00–23:00',
  ),
  'evt-3': OrganizerMockEvent(
    title: "James' 40th Birthday",
    date: DateTime(2025, 7, 1),
    timeRange: '16:00–22:00',
  ),
  'evt-4': OrganizerMockEvent(
    title: 'Kids Party: Dino World',
    date: DateTime(2025, 6, 7),
    timeRange: '12:00–15:00',
  ),
  'evt-5': OrganizerMockEvent(
    title: 'Open Air Yoga Event',
    date: DateTime(2025, 6, 10),
    timeRange: '07:00–09:00',
  ),
};

/// прошедшие ивенты — для вкладки "Events History"
final Map<String, OrganizerMockEvent> mockPastEvents = {
  'evt-hist-1': OrganizerMockEvent(
    title: 'Product Launch: Nova Phone',
    date: DateTime(2025, 5, 5),
  ),
  'evt-hist-2': OrganizerMockEvent(
    title: 'Product Launch: Nova Phone',
    date: DateTime(2025, 4, 23),
  ),
  'evt-hist-3': OrganizerMockEvent(
    title: 'Product Launch: Nova Phone',
    date: DateTime(2025, 3, 15),
  ),
};