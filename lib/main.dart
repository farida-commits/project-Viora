// lib/main.dart — временный минимальный вариант, без Hive

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/event_provider.dart';
import 'providers/organizer_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => OrganizerProvider()),
      ],
      child: const App(),
    ),
  );
}