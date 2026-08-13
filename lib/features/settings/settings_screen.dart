// lib/features/settings/presentation/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/core/widgets/app_bottom_nav.dart';
import 'package:viora/features/events/presentation/screens/events_main_screen.dart';
import 'package:viora/features/organizers/presentation/screens/organizers_main_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _onTabTap(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.events:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EventsMainScreen()),
        );
        break;
      case AppTab.organizers:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrganizersMainScreen()),
        );
        break;
      case AppTab.settings:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLevel1,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/set_phon.png', fit: BoxFit.cover,),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text('SETTINGS', style: AppTextStyles.headline),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppTab.settings,
        onTap: (tab) => _onTabTap(context, tab),
      ),
    );
  }
}