import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:viora/core/theme/app_colors.dart';

class EventImage extends StatelessWidget {
  const EventImage({super.key, required this.path, this.fit = BoxFit.cover});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('base64:')) {
      try {
        final bytes = base64Decode(path.substring(7));
        return Image.memory(bytes, fit: fit);
      } catch (_) {
        return _errorPlaceholder();
      }
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: fit);
    }
    if (kIsWeb) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorPlaceholder(),
      );
    }
    return Image.file(File(path), fit: fit);
  }

  Widget _errorPlaceholder() {
    return Container(color: AppColors.bgLevel2);
  }
}