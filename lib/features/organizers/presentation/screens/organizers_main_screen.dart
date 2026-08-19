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
import 'add_edit_organizer_screen.dart';
import 'organizer_info_screen.dart';
import 'package:viora/core/utils/slide_route.dart';

class OrganizersMainScreen extends StatefulWidget {
  const OrganizersMainScreen({super.key});

  @override
  State<OrganizersMainScreen> createState() => _OrganizersMainScreenState();
}

class _OrganizersMainScreenState extends State<OrganizersMainScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTap(BuildContext context, AppTab tab) {
  switch (tab) {
    case AppTab.events:
      Navigator.of(context).pushReplacement(
        slideRoute(const EventsMainScreen(), fromRight: false),
      );
      break;
    case AppTab.organizers:
      break;
    case AppTab.settings:
      Navigator.of(context).pushReplacement(
        slideRoute(const SettingsScreen(), fromRight: true),
      );
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    final allOrganizers = context.watch<OrganizerProvider>().organizers;
    final showSearch = allOrganizers.length > 5;

    final organizers = _query.isEmpty
        ? allOrganizers
        : allOrganizers
            .where((o) => o.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.bgLevel1,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/fon.png', fit: BoxFit.cover),

          if (allOrganizers.isEmpty)
            Center(
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.1919, 0.853, 1.0],
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

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: showSearch
                      ? Row(
                          children: [
                            Expanded(
                              child: _SearchField(
                                controller: _searchController,
                                onChanged: (v) => setState(() => _query = v),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _AddButton(
                              onTap: () => showAddEditOrganizerDialog(context),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ORGANIZERS', style: AppTextStyles.headline),
                            _AddButton(
                              onTap: () => showAddEditOrganizerDialog(context),
                            ),
                          ],
                        ),
                ),
                if (showSearch)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 300, 8),
                    child: Text('ORGANIZERS', style: AppTextStyles.headline),
                  ),
                if (allOrganizers.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: organizers.length,
                      separatorBuilder: (_, __) => Divider(
                        color: Colors.white.withValues(alpha: 0.03),
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      itemBuilder: (context, index) {
                        final organizer = organizers[index];
                        return OrganizerCard(
                          organizer: organizer,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrganizerInfoScreen(
                                  organizerId: organizer.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgLevel2,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.body.copyWith(color: AppColors.txtLevel1),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.txtLevel3),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const Icon(Icons.search, color: AppColors.txtLevel3, size: 20),
        ],
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