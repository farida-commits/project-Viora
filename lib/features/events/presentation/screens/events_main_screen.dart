import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/core/widgets/app_bottom_nav.dart';
import 'package:viora/features/organizers/presentation/screens/organizers_main_screen.dart';
import 'package:viora/features/settings/settings_screen.dart';
import 'package:viora/features/events/presentation/widgets/rate_app_dialog.dart';
import 'package:viora/features/events/presentation/widgets/event_card.dart';
import 'package:viora/features/events/presentation/widgets/upcoming_event_card.dart';
import 'package:viora/features/events/presentation/screens/add_edit_event_screen.dart';
import 'package:viora/providers/event_provider.dart';
import 'package:viora/features/events/presentation/screens/event_details_screen.dart';
import 'package:viora/core/utils/slide_route.dart';

class EventsMainScreen extends StatefulWidget {
  const EventsMainScreen({super.key});

  @override
  State<EventsMainScreen> createState() => _EventsMainScreenState();
}

class _EventsMainScreenState extends State<EventsMainScreen> {
  Timer? _rateTimer;
  final _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTap(AppTab tab) {
  switch (tab) {
    case AppTab.events:
      break;
    case AppTab.organizers:
      Navigator.of(context).pushReplacement(
        slideRoute(const OrganizersMainScreen(), fromRight: true),
      );
      break;
    case AppTab.settings:
      Navigator.of(context).pushReplacement(
        slideRoute(const SettingsScreen(), fromRight: true),
      );
      break;
  }
}

  void _onAddTap() {
    // TODO: переход на Add / Edit Event
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventProvider>();
    final isEmpty = provider.events.isEmpty;

    return Scaffold(
      extendBody: true,
      body: isEmpty ? _buildEmptyState() : _buildListState(provider),
      bottomNavigationBar: AppBottomNav(current: AppTab.events, onTap: _onTabTap),
    );
  }
      Widget _buildEmptyState() {
        return Stack(
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
                      _AddButton(onTap: () {
                        Navigator.of(context).push(
                          slideRoute(const AddEditEventScreen()),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }

      Widget _buildListState(EventProvider provider) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/fon.png', fit: BoxFit.cover),
            SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8,),
                  if (provider.showSearch) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _SearchField(
                            controller: _searchController,
                            onChanged: provider.setQuery,
                          ),
                        ),
                        const SizedBox(width: 12,),
                        _AddButton(onTap: () {
                          Navigator.of(context).push(
                            slideRoute(const AddEditEventScreen()),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('EVENTS', style: AppTextStyles.headline),
                  ] else 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EVENTS',
                          style: AppTextStyles.headline),
                          _AddButton(onTap: () {
                            Navigator.of(context).push(
                              slideRoute(const AddEditEventScreen()),
                            );
                          }),
                      ],
                    ),
                    const SizedBox(height: 16,),
                    Expanded(
                      child: !provider.hasResults
                        ? Center(
                          child: Text(
                            'Nothing was found...',
                            style: AppTextStyles.body,
                          ),
                        )
                        : ListView(
                          children: [
                            if (provider.upcomingThisWeek.isNotEmpty) ...[
                              Text('Upcoming This Week', style: AppTextStyles.body,),
                              const SizedBox(height: 12,),
                              SizedBox(
                                height: 123,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: provider.upcomingThisWeek.length,
                                  itemBuilder: (_, i) => UpcomingEventCard(
                                    event: provider.upcomingThisWeek[i],
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EventDetailsScreen(eventId: provider.upcomingThisWeek[i].id),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20,),
                            ],
                            if (provider.others.isNotEmpty) ...[
                              Text('Others', style: AppTextStyles.body,),
                              const SizedBox(height: 12,),
                              ...provider.others.map(
                                (e) => EventCard(
                                  event: e,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EventDetailsScreen(eventId: e.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 20,),
                          ],
                        ),
                  ),
                ],
              ),
            ),
          ),
          ],
        );
      }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
    final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
   
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14,),
        decoration: BoxDecoration(
          color: AppColors.bgLevel2,
          borderRadius: BorderRadius.circular(24),
          border: _isFocused
              ? Border.all(color: AppColors.txtLevel1, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                style: AppTextStyles.body,
                cursorColor: Colors.white,
                cursorHeight: 19,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'Search',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.txtLevel3),
                ),
              ),
            ),
            Image.asset(
              'assets/images/search.png',
              width: 20,
              height: 20,
              color: AppColors.txtLevel2,
            ),
          ],
        ),
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