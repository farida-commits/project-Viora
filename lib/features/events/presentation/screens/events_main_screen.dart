// lib/features/events/presentation/screens/events_main_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/core/widgets/app_bottom_nav.dart';
import 'package:viora/features/organizers/presentation/screens/organizers_main_screen.dart';
import 'package:viora/features/settings/settings_screen.dart';
import 'package:viora/features/events/presentation/widgets/rate_app_dialog.dart';

class EventsMainScreen extends StatefulWidget {
  const EventsMainScreen({super.key});

  @override
  State<EventsMainScreen> createState() => _EventsMainScreenState();
}

class _EventsMainScreenState extends State<EventsMainScreen> {
  Timer? _rateTimer;

  @override
  void initState() {
    super.initState();
    _rateTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) showRateAppDialog(context);
    });
  }

  @override
  void dispose() {
    _rateTimer?.cancel();
    super.dispose();
  }

  void _onTabTap(AppTab tab) {
    switch (tab) {
      case AppTab.events:
        break;
      case AppTab.organizers:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OrganizersMainScreen()),
        );
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
    return Scaffold(
      backgroundColor: AppColors.bgLevel1,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Фон
          Image.asset('assets/images/fon.png', fit: BoxFit.cover),

          // 2. Сама картинка (внизу слоя)
          Center(
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, // верх фото исчезает
                      Colors.black,
                      Colors.black,
                      Colors.transparent, // низ фото исчезает
                    ],
                    stops: [0.0, 0.1181, 0.853, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/events_photo.png',
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
                    Text('EVENTS', style: AppTextStyles.headline),
                    _AddButton(onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(current: AppTab.events, onTap: _onTabTap),
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