// lib/features/settings/settings_screen.dart

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
          Image.asset('assets/images/set_phon.png', fit: BoxFit.cover),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const horizontalPadding = 20.0;
                const maxCardWidth = 343.0;
                final availableWidth = constraints.maxWidth - horizontalPadding * 2;
                final cardWidth = availableWidth < maxCardWidth ? availableWidth : maxCardWidth;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text('SETTINGS', style: AppTextStyles.headline),
                      const SizedBox(height: 32),
                      _SettingsCard(width: cardWidth),
                    ],
                  ),
                );
              },
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

class _SettingsCard extends StatelessWidget {
  final double width;

  const _SettingsCard({required this.width});

  static const _items = [
    'Privacy Policy',
    'Terms of Use',
    'Support',
    'Share',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: AppColors.bgLevel2,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < _items.length; i++) ...[
                _SettingsItem(
                  title: _items[i],
                  onTap: () {
                    // TODO: подключить переходы/логику
                  },
                ),
                if (i != _items.length - 1)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.08),
                    height: 1,
                    thickness: 1,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.footnote.copyWith(color: AppColors.txtLevel2),
        ),
      ),
    );
  }
}