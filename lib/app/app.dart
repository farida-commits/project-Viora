import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/splash/presentation/screens/splash_onboarding_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashOnboardingScreen(),
    );
  }
}