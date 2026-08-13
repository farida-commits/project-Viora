// lib/features/organizers/presentation/screens/organizers_main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/core/widgets/app_bottom_nav.dart';
import 'package:viora/features/events/presentation/screens/events_main_screen.dart';
import 'package:viora/features/settings/settings_screen.dart';
import 'package:viora/providers/organizer_provider.dart';
import '../widgets/organizer_card.dart';

class OrganizersMainScreen extends StatelessWidget {
  const OrganizersMainScreen({super.key});

  void _onTabTap(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.events:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EventsMainScreen()),
        );
        break;
      case AppTab.organizers:
        break;
      case AppTab.settings:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final organizers = context.watch<OrganizerProvider>().organizers;

    return Scaffold(
      backgroundColor: AppColors.bgLevel1,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Фон
          Image.asset('assets/images/fon.png', fit: BoxFit.cover),

          // 2. Фото по центру с градиентным исчезновением сверху/снизу
          Center(
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, // верх фото исчезает
                      Colors.black,
                      Colors.black,
                      Colors.transparent, // низ фото исчезает
                    ],
                    stops: const [0.0, 0.1919, 0.853, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/organizers_photo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ORGANIZERS', style: AppTextStyles.headline),
                    _AddButton(onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: AppTab.organizers,
        onTap: (tab) => _onTabTap(context, tab),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: Image.asset(
          'assets/images/plus.png', 
          color: Colors.white,
          height: 20,
          width: 20,
        ),
      ),
    );
  }
}