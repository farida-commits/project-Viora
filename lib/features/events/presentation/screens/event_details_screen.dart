// lib/features/events/presentation/screens/event_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/core/widgets/event_image.dart';
import 'package:viora/features/events/domain/entities/event.dart';
import 'package:viora/features/events/domain/entities/event_task.dart';
import 'package:viora/features/events/presentation/screens/add_edit_event_screen.dart';
import 'package:viora/features/organizers/presentation/widgets/organizer_avatar.dart';
import 'package:viora/providers/event_provider.dart';
import 'package:viora/providers/organizer_provider.dart';
import 'package:viora/features/organizers/domain/utils/organizer_events.dart';
import 'package:viora/core/utils/slide_route.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int _tabIndex = 0;

  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatShortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _openEdit({int tab = 0}) async {
  final provider = context.read<EventProvider>();
  final event = provider.events.firstWhere((e) => e.id == widget.eventId);
  await Navigator.of(context).push(
    slideRoute(AddEditEventScreen(initial: event, initialTabIndex: tab)),
  );
}

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final event = provider.events.where((e) => e.id == widget.eventId).firstOrNull;

    if (event == null) {
      return Scaffold(
        backgroundColor: AppColors.bgLevel1,
        body: Center(child: Text('Event not found', style: AppTextStyles.body)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgLevel1,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/fon.png', fit: BoxFit.cover),
          Column(
            children: [
              _buildHeader(event),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TabsBar(index: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      _buildInformationTab(event),
                      _buildTasksTab(event),
                      _buildBudgetTab(event),
                      _buildOrganizersTab(event),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Event event) {
    final hasPhoto = event.photoAsset != null;

    String subtitle;
    switch (_tabIndex) {
      case 1:
        subtitle = '${event.tasksDone}/${event.tasksTotal} tasks done';
        break;
      case 2:
        subtitle = 'Balance \$${_formatMoney(event.fundBalance)} / \$${_formatMoney(event.budget)}';
        break;
      case 3:
        subtitle = '${event.organizerIds.length} Organizers';
        break;
      default:
        subtitle = '';
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: hasPhoto ? null : AppColors.bgLevel2,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasPhoto) EventImage(path: event.photoAsset!),
          Container(color: const Color(0xFF000000).withValues(alpha: 0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          children: [
                            Image.asset('assets/images/back.png', width: 24, height: 24, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Event Details', style: AppTextStyles.title),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openEdit(tab: _tabIndex),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bgLevel2,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/pen.png', 
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.location.isNotEmpty ? event.location : event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        _buildSubtitle(subtitle),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    if (_tabIndex == 2) {
      // "Balance $X / $Y" — $X красным
      final parts = subtitle.split(' / ');
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: AppTextStyles.footnote.copyWith(color: Colors.white),
          children: [
            const TextSpan(text: 'Balance '),
            TextSpan(
              text: parts[0].replaceFirst('Balance ', ''),
              style: const TextStyle(color: AppColors.warning),
            ),
            TextSpan(text: ' / ${parts.length > 1 ? parts[1] : ''}'),
          ],
        ),
      );
    }
    return Text(subtitle, style: AppTextStyles.footnote.copyWith(color: Colors.white));
  }

  // ---------- Information ----------

  Widget _buildInformationTab(Event event) {
    return ListView(
      children: [
        if (event.title.isNotEmpty || event.startTime != null)
          Text(
            [
              if (event.title.isNotEmpty) event.title,
              '${_formatDate(event.date)}${event.startTime != null ? '; ${event.startTime} — ${event.endTime}' : ''}',
            ].join('\n'),
            style: AppTextStyles.body,
          ),
        const SizedBox(height: 12),
        const Divider(color: AppColors.bgLevel2),
        const SizedBox(height: 12),
        if (event.description.isNotEmpty)
          Text(event.description, style: AppTextStyles.body.copyWith(color: AppColors.txtLevel2)),
        if (event.clientNotes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Client Notes', style: AppTextStyles.title),
          const SizedBox(height: 8),
          for (final note in event.clientNotes)
            if (note.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 8),
                      child: Image.asset(
                        'assets/images/tochka.png',
                        width: 16,
                        height: 16,                  
                      ),
                    ),
                    Expanded(
                      child: Text(
                        note,
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------- Tasks ----------

  Widget _buildTasksTab(Event event) {
    if (event.tasks.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Add Your First Task',
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ),
          ),
          _buildBottomButton('Add New Task', () => _openEdit(tab: 1)),
        ],
      );
    }
    final sortedTasks = List.of(event.tasks)
    ..sort((a, b) => _statusOrder(a.status).compareTo(_statusOrder(b.status)));

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: event.tasks.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.bgLevel2),
            itemBuilder: (_, i) {
              final t = sortedTasks[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _statusLabel(t.status),
                            style: AppTextStyles.footnote.copyWith(
                              color: _statusColor(t.status),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4,),
                          Text(t.title, style: AppTextStyles.body),
                        ],
                      ),
                    ),
                    if (t.date != null)
                      Text(
                        _formatShortDate(t.date!),
                        style: AppTextStyles.footnote.copyWith(color: AppColors.txtLevel3),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        _buildBottomButton('Add New Task', () => _openEdit(tab: 1)),
      ],
    );
  }

  int _statusOrder(EventTaskStatus s) {
  switch (s) {
    case EventTaskStatus.notStarted:
      return 0;
    case EventTaskStatus.inProgress:
      return 1;
    case EventTaskStatus.done:
      return 2;
  }
}

  String _statusLabel(EventTaskStatus s) {
    switch (s) {
      case EventTaskStatus.inProgress:
        return 'In Progress';
      case EventTaskStatus.done:
        return 'Done';
      case EventTaskStatus.notStarted:
        return 'Not Started';
    }
  }

  Color _statusColor(EventTaskStatus s) {
    switch (s) {
      case EventTaskStatus.inProgress:
        return const Color(0xFF007AFF);
      case EventTaskStatus.done:
        return AppColors.success;
      case EventTaskStatus.notStarted:
        return AppColors.warning;
    }
  }

  // ---------- Budget ----------

  Widget _buildBudgetTab(Event event) {
    if (event.expenses.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Add Your First Expense',
                style: AppTextStyles.body.copyWith(color: AppColors.txtLevel2),
              ),
            ),
          ),
          _buildBottomButton('Add New Expense', () => _openEdit(tab: 2)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Expenses - ',
              style: AppTextStyles.title,
            ),
            Image.asset(
          'assets/images/dollar.png',
          width: 18,
          height: 18,
        ),
        Text(
          _formatMoney(event.spent),
          maxLines: 1,
          // '${event.spent.toStringAsFixed(0)}',
          style: AppTextStyles.title,
        ),
      ],
    ),        
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: event.expenses.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.bgLevel2),
            itemBuilder: (_, i) {
              final ex = event.expenses[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ex.date != null)
                            Text(
                              _formatShortDate(ex.date!),
                              style: AppTextStyles.footnote.copyWith(color: AppColors.txtLevel3),
                            ),
                          Text(ex.title, style: AppTextStyles.body),
                        ],
                      ),
                    ),
                    Text(
                      '\$${ex.price.toStringAsFixed(0)}',
                      style: AppTextStyles.body.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _buildBottomButton('Add New Expense', () => _openEdit(tab: 2)),
      ],
    );
  }

  String _formatMoney(double value) {  
  final formatted = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  final chars = formatted.split('');
  final isNegative = chars.isNotEmpty && chars[0] == '-';
  final digits = isNegative ? chars.sublist(1) : chars;

  for (int i = 0; i < digits.length; i++) {
    if (i != 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }

  return (isNegative ? '-' : '') + buffer.toString();
}

  // ---------- Organizers ----------

  Widget _buildOrganizersTab(Event event) {
    final allOrganizers = context.watch<OrganizerProvider>().organizers;
    final eventProvider = context.watch<EventProvider>();
    final selected = allOrganizers.where((o) => event.organizerIds.contains(o.id)).toList();

    if (selected.isEmpty) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Add Your First Organizer',
                style: AppTextStyles.body.copyWith(color: AppColors.txtLevel2),
              ),
            ),
          ),
          _buildBottomButton('Add New Organizer', () => _openEdit(tab: 3)),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: selected.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.bgLevel2),
            itemBuilder: (_, i) {
              final o = selected[i];
              final nextEventText = organizerNextEventText(eventProvider, o.id);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    OrganizerAvatar(photoPath: o.photoPath, size: 48, borderRadius: 12, placeholderIconSize: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            o.position,
                            style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                          Text(o.name, style: AppTextStyles.body),
                          if (nextEventText.isNotEmpty) ...[
                            Text('Next Event:', style: AppTextStyles.caption.copyWith(color: AppColors.txtLevel2)),
                            Text(
                              nextEventText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(color: AppColors.txtLevel2),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _buildBottomButton('Add New Organizer', () => _openEdit(tab: 3)),
      ],
    );
  }

  Widget _buildBottomButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          onPressed: onTap,
          child: Text(label, style: AppTextStyles.buttonText.copyWith(color: Colors.white)),
        ),
      ),
    );
  }
}

class _TabsBar extends StatelessWidget {
  const _TabsBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _labels = ['Information', 'Tasks', 'Budget', 'Organizers'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgLevel2,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final active = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.footnote.copyWith(
                    color: active ? AppColors.primary : Colors.white,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}