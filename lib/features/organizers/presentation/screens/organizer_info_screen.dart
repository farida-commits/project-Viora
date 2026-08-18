// lib/features/organizers/presentation/screens/organizer_info_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/features/organizers/data/mock/mock_organizer_events.dart';
import 'package:viora/features/organizers/presentation/screens/add_edit_organizer_screen.dart';
import 'package:viora/features/organizers/presentation/widgets/calendar_widget.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';
import 'package:viora/features/organizers/presentation/widgets/organizer_avatar.dart';
import 'package:viora/providers/organizer_provider.dart';

enum _InfoTab { current, history }

class OrganizerInfoScreen extends StatefulWidget {
  const OrganizerInfoScreen({super.key, required this.organizerId});

  final String organizerId;

  @override
  State<OrganizerInfoScreen> createState() => _OrganizerInfoScreenState();
}

class _OrganizerInfoScreenState extends State<OrganizerInfoScreen> {
  _InfoTab _tab = _InfoTab.current;
  DateTime? _displayedMonth;
  DateTime? _selectedDate;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final organizer = context.read<OrganizerProvider>().getById(
      widget.organizerId,
    );
    final currentEvents =
        (organizer?.currentEventIds ?? const <String>[])
            .map((id) => mockEvents[id])
            .whereType<OrganizerMockEvent>()
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final initialDate = currentEvents.isNotEmpty
        ? currentEvents.first.date
        : DateTime.now();

    _displayedMonth = DateTime(initialDate.year, initialDate.month);
    _selectedDate = initialDate;
    _initialized = true;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final organizer = context.watch<OrganizerProvider>().getById(
      widget.organizerId,
    );

    if (organizer == null || _displayedMonth == null) {
      return Scaffold(
        backgroundColor: AppColors.bgLevel1,
        body: Center(
          child: Text('Organizer not found', style: AppTextStyles.body),
        ),
      );
    }

    final currentEvents = organizer.currentEventIds
        .map((id) => mockEvents[id])
        .whereType<OrganizerMockEvent>()
        .toList();

    final displayedMonth = _displayedMonth!;

    final eventDatesInMonth = currentEvents
        .where(
          (e) =>
              e.date.year == displayedMonth.year &&
              e.date.month == displayedMonth.month,
        )
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();

    final selectedDayEvent = _selectedDate == null
        ? null
        : currentEvents
              .where((e) => _isSameDay(e.date, _selectedDate!))
              .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.bgLevel1,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // фон — как на остальных экранах раздела
          Image.asset('assets/images/fon.png', fit: BoxFit.cover),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Image.asset(
                              'assets/images/back.png',
                              width: 28,
                              height: 28,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('Organizer Info', style: AppTextStyles.title),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => showAddEditOrganizerDialog(
                          context,
                          organizer: organizer,
                          onDeleted: () => Navigator.of(
                            context,
                          ).pop(), // вернуться к списку после удаления
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bgLevel2,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/pen.png',
                              width: 18,
                              height: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _OrganizerHeaderInfo(organizer: organizer),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _TabSwitcher(
                    current: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _tab == _InfoTab.current
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              CalendarWidget(
                                displayedMonth: displayedMonth,
                                selectedDate: _selectedDate,
                                eventDates: eventDatesInMonth,
                                onDateSelected: (d) =>
                                    setState(() => _selectedDate = d),
                                onMonthChanged: (delta) => setState(() {
                                  _displayedMonth = DateTime(
                                    displayedMonth.year,
                                    displayedMonth.month + delta,
                                  );
                                  _selectedDate = null;
                                }),
                              ),
                              const SizedBox(height: 24),
                              if (selectedDayEvent != null)
                                _SelectedEventCard(event: selectedDayEvent)
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Text(
                                    'No Events',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.txtLevel3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : _EventsHistoryList(organizer: organizer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrganizerHeaderInfo extends StatelessWidget {
  const _OrganizerHeaderInfo({required this.organizer});

  final Organizer organizer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                organizer.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 2),
              Text(
                organizer.position,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                organizer.phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.footnote.copyWith(
                  color: AppColors.txtLevel2,
                ),
              ),
              Text(
                organizer.specialization,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.footnote.copyWith(
                  color: AppColors.txtLevel2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OrganizerAvatar(
          photoPath: organizer.photoPath,
          size: 80,
          placeholderIconSize: 32,
        ),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.current, required this.onChanged});

  final _InfoTab current;
  final ValueChanged<_InfoTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.bgLevel2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Current Events',
            isActive: current == _InfoTab.current,
            onTap: () => onChanged(_InfoTab.current),
          ),
          Container(width: 1, height: 18, color: AppColors.txtLevel3),
          _TabButton(
            label: 'Events History',
            isActive: current == _InfoTab.history,
            onTap: () => onChanged(_InfoTab.history),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.footnote.copyWith(
              color: isActive ? AppColors.primary : AppColors.txtLevel2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedEventCard extends StatelessWidget {
  const _SelectedEventCard({required this.event});

  final OrganizerMockEvent event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('d MMMM y').format(event.date),
              style: AppTextStyles.body,
            ),
            if (event.timeRange != null)
              Text(
                event.timeRange!,
                style: AppTextStyles.footnote.copyWith(
                  color: AppColors.txtLevel2,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          event.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EventsHistoryList extends StatelessWidget {
  const _EventsHistoryList({required this.organizer});

  final Organizer organizer;

  @override
  Widget build(BuildContext context) {
    final pastEvents = organizer.pastEventIds
        .map((id) => mockPastEvents[id])
        .whereType<OrganizerMockEvent>()
        .toList();

    if (pastEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No event history yet',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Assign this organizer to any event, and it will appear here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.footnote.copyWith(
                  color: AppColors.txtLevel3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: pastEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = pastEvents[index];
        return _PastEventCard(event: event);
      },
    );
  }
}

class _PastEventCard extends StatelessWidget {
  const _PastEventCard({required this.event});

  final OrganizerMockEvent event;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        decoration: const BoxDecoration(color: AppColors.bgLevel2),
        child: Stack(
          children: [
            // TODO: заменить на Image.asset(event.imagePath) когда появятся фото ивентов
            Positioned.fill(child: Container(color: AppColors.bgLevel1)),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('dd MMM, y').format(event.date),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.txtLevel1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.txtLevel1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}