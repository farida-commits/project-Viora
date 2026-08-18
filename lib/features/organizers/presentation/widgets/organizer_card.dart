// lib/features/organizers/presentation/widgets/organizer_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';
import 'package:viora/features/organizers/data/mock/mock_organizer_events.dart';
import 'package:viora/features/organizers/presentation/widgets/organizer_avatar.dart';

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
    final dateStr = organizer.nextEventDate != null
        ? DateFormat('d MMM').format(organizer.nextEventDate!)
        : null;

    final nextEventId = organizer.currentEventIds.isNotEmpty
        ? organizer.currentEventIds.first
        : null;
    final eventTitle = nextEventId != null
        ? mockEvents[nextEventId]?.title
        : null;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                  if (dateStr != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Next Event:',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.txtLevel3,
                      ),
                    ),
                    Text(
                      eventTitle != null ? '$dateStr — $eventTitle' : dateStr,
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