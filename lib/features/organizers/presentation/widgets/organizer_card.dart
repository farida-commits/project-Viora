import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import '../../domain/entities/organizer.dart';

class OrganizerCard extends StatelessWidget {
  const OrganizerCard({super.key, required this.organizer, this.onTap});

  final Organizer organizer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bgLevel2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.3),
              child: Text(
                organizer.name.isNotEmpty ? organizer.name[0] : '?',
                style: AppTextStyles.title,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(organizer.name, style: AppTextStyles.body),
                  const SizedBox(height: 2),
                  Text(organizer.position, style: AppTextStyles.footnote),
                ],
              ),
            ),
            if (organizer.nextEventDate != null)
              Text(
                DateFormat('dd.MM').format(organizer.nextEventDate!),
                style: AppTextStyles.caption,
              ),
          ],
        ),
      ),
    );
  }
}