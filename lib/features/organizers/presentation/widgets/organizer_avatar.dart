// lib/features/organizers/presentation/widgets/organizer_avatar.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:viora/core/theme/app_colors.dart';

class OrganizerAvatar extends StatefulWidget {
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
  State<OrganizerAvatar> createState() => _OrganizerAvatarState();
}

class _OrganizerAvatarState extends State<OrganizerAvatar> {
  Uint8List? _decodedBytes;
  String? _decodedFor;

  @override
  void initState() {
    super.initState();
    _decodeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant OrganizerAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoPath != widget.photoPath) {
      _decodeIfNeeded();
    }
  }

  void _decodeIfNeeded() {
    final path = widget.photoPath;
    if (path != null && path.startsWith('base64:') && path != _decodedFor) {
      _decodedBytes = base64Decode(path.substring(7));
      _decodedFor = path;
    } else if (path == null || !path.startsWith('base64:')) {
      _decodedBytes = null;
      _decodedFor = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.photoPath;
    Widget child;

    if (path == null) {
      child = Center(
        child: Image.asset(
          'assets/images/photo.png',
          width: widget.placeholderIconSize,
          height: widget.placeholderIconSize,
        ),
      );
    } else if (path.startsWith('base64:') && _decodedBytes != null) {
      child = Image.memory(
        _decodedBytes!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        gaplessPlayback: true,
      );
    } else {
      child = Image.asset(path, fit: BoxFit.cover, width: widget.size, height: widget.size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        width: widget.size,
        height: widget.size,
        color: AppColors.bgLevel2,
        child: child,
      ),
    );
  }
}