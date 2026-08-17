// lib/features/events/presentation/widgets/select_organizers_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/providers/organizer_provider.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';

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

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1A0F1D),
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
                    onTap: () => Navigator.of(context).pop(_selected.toList()),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bgLevel2),
                      child: Center(
                        child: Image.asset(
                          'assets/images/save.png', 
                          color: Colors.white,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          style: AppTextStyles.body,
                          cursorColor: AppColors.primary,
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
                          child: Text('Nothing was found...', style: AppTextStyles.footnote),
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
  const _OrganizerRow({required this.organizer, required this.checked, required this.onTap});

  final Organizer organizer;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              color: checked ? AppColors.primary : Colors.transparent,
            ),
            child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(organizer.position, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                Text(organizer.name, style: AppTextStyles.body),
                if (organizer.nextEventDate != null)
                  Text(
                    'Next Event: ${organizer.nextEventDate}',
                    style: AppTextStyles.caption,
                  ),
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