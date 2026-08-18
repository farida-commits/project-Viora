// lib/features/organizers/presentation/widgets/organizer_avatar.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:viora/core/theme/app_colors.dart';

/// Отображает фото организатора по photoPath.
/// photoPath может быть:
/// - null → плейсхолдер
/// - 'base64:xxxxx' → декодируем и показываем через Image.memory
/// - обычный путь → Image.asset (на случай будущих реальных ассетов)
class OrganizerAvatar extends StatelessWidget {
  const OrganizerAvatar({
    super.key,
    required this.photoPath,
    required this.size,
    this.borderRadius = 12,
    this.placeholderIconSize = 24,
  });

  final String? photoPath;
  final double size;
  final double borderRadius;
  final double placeholderIconSize;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (photoPath == null) {
      child = Center(
        child: Image.asset(
          'assets/images/photo.png',
          width: placeholderIconSize,
          height: placeholderIconSize,
        ),
      );
    } else if (photoPath!.startsWith('base64:')) {
      final bytes = base64Decode(photoPath!.substring(7));
      child = Image.memory(bytes, fit: BoxFit.cover, width: size, height: size);
    } else {
      child = Image.asset(photoPath!, fit: BoxFit.cover, width: size, height: size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: AppColors.bgLevel2,
        child: child,
      ),
    );
  }
}