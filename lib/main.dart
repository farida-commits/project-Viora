// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/event_provider.dart';
import 'providers/organizer_provider.dart';
import 'features/events/data/models/event_model.dart';
import 'features/events/data/models/event_task_model.dart';
import 'features/events/data/models/expense_model.dart';
import 'features/events/data/repositories/event_repository_impl.dart';
import 'features/organizers/data/models/organizer_model.dart';
import 'features/organizers/data/repositories/organizer_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(EventTaskStatusModelAdapter());
  Hive.registerAdapter(EventTaskModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(EventModelAdapter());
  Hive.registerAdapter(OrganizerModelAdapter());

  final eventBox = await Hive.openBox<EventModel>('events');
  final organizerBox = await Hive.openBox<OrganizerModel>('organizers');

  final eventRepository = EventRepositoryImpl(eventBox);
  final organizerRepository = OrganizerRepositoryImpl(organizerBox);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventProvider(eventRepository)),
        ChangeNotifierProvider(create: (_) => OrganizerProvider(organizerRepository)),
      ],
      child: const App(),
    ),
  );
}