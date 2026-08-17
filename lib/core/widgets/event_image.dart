import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class EventImage extends StatelessWidget {
  const EventImage({super.key, required this.path, this.fit = BoxFit.cover});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // веб: путь из image_picker — это blob-URL, грузим как сетевой ресурс
      return Image.network(path, fit: fit);
    }
    if (path.startsWith('assets/')) {
      // ассеты приложения — одинаково для всех платформ
      return Image.asset(path, fit: fit);
    }
    // Android/iOS: путь из галереи — это путь к файлу на диске
    return Image.file(File(path), fit: fit);
  }
}