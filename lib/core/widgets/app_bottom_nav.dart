// lib/core/widgets/app_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:viora/core/theme/app_colors.dart';

enum AppTab { events, organizers, settings }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current, required this.onTap});

  final AppTab current;
  final ValueChanged<AppTab> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 42),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            asset: 'assets/images/1.png',
            active: current == AppTab.events,
            onTap: () => onTap(AppTab.events),
          ),
          _NavIcon(
            asset: 'assets/images/2.png',
            active: current == AppTab.organizers,
            onTap: () => onTap(AppTab.organizers),
          ),
          _NavIcon(
            asset: 'assets/images/3.png',
            active: current == AppTab.settings,
            onTap: () => onTap(AppTab.settings),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.asset, required this.active, required this.onTap});

  final String asset;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.bgLevel2 : Colors.transparent,
        ),
        child: Image.asset(
          asset,
          width: 24,
          height: 24,
          color: active ? Color(0xFFD83DFF) : AppColors.txtLevel3,
        ),
      ),
    );
  }
}