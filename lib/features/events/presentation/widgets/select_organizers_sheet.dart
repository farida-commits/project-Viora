// lib/features/events/presentation/widgets/select_organizers_sheet.dart
import 'package:intl/intl.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/providers/organizer_provider.dart';
import 'package:viora/providers/event_provider.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';
import 'package:viora/features/organizers/presentation/widgets/organizer_avatar.dart';
import 'package:viora/features/organizers/domain/utils/organizer_events.dart';

/// Возвращает обновлённый список выбранных id организаторов,
/// либо null если пользователь закрыл без сохранения.
Future<List<String>?> showSelectOrganizersSheet(
  BuildContext context, {
  required List<String> initialSelected,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SelectOrganizersSheet(initialSelected: initialSelected),
  );
}

class _SelectOrganizersSheet extends StatefulWidget {
  const _SelectOrganizersSheet({required this.initialSelected});

  final List<String> initialSelected;

  @override
  State<_SelectOrganizersSheet> createState() => _SelectOrganizersSheetState();
}

class _SelectOrganizersSheetState extends State<_SelectOrganizersSheet> {
  late Set<String> _selected = {...widget.initialSelected};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final organizers = context.watch<OrganizerProvider>().organizers;
    final filtered = _query.trim().isEmpty
        ? organizers
        : organizers
            .where((o) => o.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    
    final hasOrganizers = organizers.isNotEmpty;
    final hasSelected = _selected.isNotEmpty; 

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      
      decoration: const BoxDecoration(
        image: DecorationImage(     
          image: const AssetImage('assets/images/fon.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 5, decoration: BoxDecoration(
              color: AppColors.txtLevel3,
              borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 12),
            Text(
              'Click on the card to select an organizer', 
              style: AppTextStyles.caption.copyWith(color: AppColors.txtLevel2)
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(null),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bgLevel2),
                      child: const Icon(Icons.close, size: 20, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Select Organizers', 
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: hasSelected
                    ? () => Navigator.of(context).pop(_selected.toList())
                    : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bgLevel2),
                      child: Center(
                        child: Image.asset(
                          'assets/images/save.png', 
                          color:  hasSelected ? Colors.white : AppColors.txtLevel3,
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (organizers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bgLevel2,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          style: AppTextStyles.body,
                          cursorColor: Colors.white,
                          cursorHeight: 19,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            hintText: 'Search Contact Name',
                            hintStyle: AppTextStyles.body.copyWith(color: AppColors.txtLevel3),
                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/images/search.png',
                        color: AppColors.txtLevel3,
                        width: 16,
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: organizers.isEmpty
                  ? _EmptyOrganizers(
                      onAddNew: () {
                        Navigator.of(context).pop(null);
                        // TODO: переход на Add / Edit Organizer
                      },
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Nothing was found...', 
                            style: AppTextStyles.body.copyWith(color: Colors.white)                            
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(color: AppColors.bgLevel2, height: 24),
                          itemBuilder: (_, i) {
                            final o = filtered[i];
                            final checked = _selected.contains(o.id);
                            return _OrganizerRow(
                              organizer: o,
                              checked: checked,
                              onTap: () => setState(() {
                                checked ? _selected.remove(o.id) : _selected.add(o.id);
                              }),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganizerRow extends StatelessWidget {
  const _OrganizerRow({
    required this.organizer, 
    required this.checked, 
    required this.onTap
  });  

  final Organizer organizer;
  final bool checked;
  final VoidCallback onTap;

  // String _getNextEventText(BuildContext context, Organizer organizer) {
  //   if (organizer.nextEventDate == null) return '';

  //   final dateStr = DateFormat('d MMM').format(organizer.nextEventDate!);

  //   final nextEventId = organizer.currentEventIds.isNotEmpty
  //       ? organizer.currentEventIds.first
  //       : null;

  //   String eventTitle = '';
  //   if (nextEventId != null) {
  //     final eventProvider = context.watch<EventProvider>();
  //     final event =
  //         eventProvider.events.where((e) => e.id == nextEventId).firstOrNull;
  //     if (event != null) {
  //       eventTitle = event.title;
  //     }
  //   }

  //   return eventTitle.isNotEmpty
  //       ? '$dateStr — $eventTitle'  // "12 Jun — Alice & Tom Wedding"
  //       : dateStr;                   // "12 Jun"
  // }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final nextEventText = organizerNextEventText(eventProvider, organizer.id);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.primary, width: 2),
              color: checked ? AppColors.primary : Colors.transparent,
            ),
            child: checked ? const Icon(
              Icons.check, 
              size: 14, 
              color: Colors.white,
            ) : null,
          ),
          const SizedBox(width: 12),
          OrganizerAvatar(
            photoPath: organizer.photoPath, 
            size: 64,
            borderRadius: 24,
            placeholderIconSize: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organizer.position, 
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4,),
                Text(
                  organizer.name, 
                  style: AppTextStyles.body,
                ),
                SizedBox(height: 4,),
                if (nextEventText.isNotEmpty) ...[
                  Text(
                    'Next Event:',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.txtLevel2,
                    ),
                  ),
                  SizedBox(height: 4,),
                  Text(
                    nextEventText,
                    style: AppTextStyles.caption.copyWith(color: AppColors.txtLevel1),
                  )
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrganizers extends StatelessWidget {
  const _EmptyOrganizers({required this.onAddNew});

  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
              'assets/images/organizers_photo.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1F1422),
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xFF1C1320),
                  ],
                  stops: [0.0, 0.15, 0.7, 1.0]
                ),
              ),
            )
            ],
          ),
        ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                onPressed: onAddNew,
                child: Text(
                  'Add New Organizer', 
                  style: AppTextStyles.buttonText.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}