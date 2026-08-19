// lib/features/organizers/presentation/widgets/organizer_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';
import 'package:viora/features/organizers/presentation/widgets/organizer_avatar.dart';
import 'package:viora/providers/event_provider.dart';

class OrganizerCard extends StatelessWidget {
  const OrganizerCard({
    super.key,
    required this.organizer,
    required this.onTap,
  });

  final Organizer organizer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final allEvents = context.watch<EventProvider>().events;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final upcoming = allEvents
        .where((e) => e.organizerIds.contains(organizer.id))
        .where((e) => !DateTime(e.date.year, e.date.month, e.date.day).isBefore(todayOnly))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final nextEvent = upcoming.isNotEmpty ? upcoming.first : null;
    final dateStr = nextEvent != null ? DateFormat('d MMM').format(nextEvent.date) : null;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrganizerAvatar(photoPath: organizer.photoPath, size: 48, placeholderIconSize: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organizer.position,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.footnote.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    organizer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.txtLevel1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (nextEvent != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Next Event:',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.txtLevel3,
                      ),
                    ),
                    Text(
                      '$dateStr — ${nextEvent.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.txtLevel2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}