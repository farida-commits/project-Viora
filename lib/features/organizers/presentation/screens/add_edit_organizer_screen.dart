// lib/features/organizers/presentation/screens/add_edit_organizer_screen.dart

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';
import 'package:viora/providers/organizer_provider.dart';
import '../widgets/organizer_avatar.dart';

/// organizer == null → режим добавления
/// organizer != null → режим редактирования
/// onDeleted вызывается ПОСЛЕ успешного удаления (например, чтобы закрыть
/// экран Organizer Info и вернуться к списку)
Future<void> showAddEditOrganizerDialog(
  BuildContext context, {
  Organizer? organizer,
  VoidCallback? onDeleted,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) =>
        AddEditOrganizerDialog(organizer: organizer, onDeleted: onDeleted),
  );
}

class AddEditOrganizerDialog extends StatefulWidget {
  const AddEditOrganizerDialog({super.key, this.organizer, this.onDeleted});

  final Organizer? organizer;
  final VoidCallback? onDeleted;

  @override
  State<AddEditOrganizerDialog> createState() => _AddEditOrganizerDialogState();
}

class _AddEditOrganizerDialogState extends State<AddEditOrganizerDialog> {
  late final bool _isEdit;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _specCtrl;
  String? _photoPath;

  late final String _initialName;
  late final String _initialRole;
  late final String _initialPhone;
  late final String _initialSpec;
  late final String? _initialPhoto;

  @override
  void initState() {
    super.initState();
    final o = widget.organizer;
    _isEdit = o != null;

    _nameCtrl = TextEditingController(text: o?.name ?? '');
    _roleCtrl = TextEditingController(text: o?.position ?? '');
    _phoneCtrl = TextEditingController(text: o?.phone ?? '');
    _specCtrl = TextEditingController(text: o?.specialization ?? '');
    _photoPath = o?.photoPath;

    _initialName = _nameCtrl.text;
    _initialRole = _roleCtrl.text;
    _initialPhone = _phoneCtrl.text;
    _initialSpec = _specCtrl.text;
    _initialPhoto = _photoPath;

    for (final c in [_nameCtrl, _roleCtrl, _phoneCtrl, _specCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _phoneCtrl.dispose();
    _specCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameCtrl.text.trim().isNotEmpty &&
      _roleCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().isNotEmpty &&
      _specCtrl.text.trim().isNotEmpty;

  bool get _hasChanges =>
      _nameCtrl.text != _initialName ||
      _roleCtrl.text != _initialRole ||
      _phoneCtrl.text != _initialPhone ||
      _specCtrl.text != _initialSpec ||
      _photoPath != _initialPhoto;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _photoPath = 'base64:${base64Encode(bytes)}');
  }

  void _deletePhoto() {
    setState(() => _photoPath = null);
  }

  Future<void> _handleClose() async {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final exit = await _showUnsavedChangesAlert(context);
    if (exit == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleSave() {
    if (!_isValid) return;
    final provider = context.read<OrganizerProvider>();

    if (_isEdit) {
      final updated = widget.organizer!.copyWith(
        name: _nameCtrl.text.trim(),
        position: _roleCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        specialization: _specCtrl.text.trim(),
        photoPath: _photoPath,
      );
      // copyWith у нас с ?? — для сброса photoPath на null (удаление фото)
      // copyWith не подходит, обновляем через новый Organizer напрямую:
      final result = Organizer(
        id: widget.organizer!.id,
        name: _nameCtrl.text.trim(),
        position: _roleCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        specialization: _specCtrl.text.trim(),
        currentEventIds: widget.organizer!.currentEventIds,
        pastEventIds: widget.organizer!.pastEventIds,
        nextEventDate: widget.organizer!.nextEventDate,
        photoPath: _photoPath,
      );
      provider.update(result);
    } else {
      final newOrganizer = Organizer(
        id: 'org-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameCtrl.text.trim(),
        position: _roleCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        specialization: _specCtrl.text.trim(),
        currentEventIds: const [],
        pastEventIds: const [],
        photoPath: _photoPath,
      );
      provider.add(newOrganizer);
    }

    Navigator.of(context).pop();
  }

  Future<void> _handleDelete() async {
    final confirmed = await _showConfirmDeletionAlert(context);
    if (confirmed != true || !mounted) return;

    context.read<OrganizerProvider>().remove(widget.organizer!.id);
    Navigator.of(context).pop(); // закрыть саму модалку
    widget.onDeleted?.call(); // например, вернуться на список из Organizer Info
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await _showUnsavedChangesAlert(context);
        if (exit == true && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              width: 343,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF1C1C1E), const Color.fromARGB(255, 36, 2, 43)],
                  stops: const [0.15, 1.0],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
  onTap: _handleClose,
  child: Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: 0.15),
    ),
    child: const Icon(
      Icons.close,
      color: AppColors.txtLevel1,
      size: 18,
    ),
  ),
),
Text(
  _isEdit ? 'Edit Organizer' : 'Add Organizer',
  style: AppTextStyles.title,
),
GestureDetector(
  onTap: _isValid ? _handleSave : null,
  child: Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: 0.15),
    ),
    child: Center(
      child: Image.asset(
        'assets/images/save.png',
        width: 18,
        height: 18,
        color: _isValid ? Colors.white : AppColors.txtLevel3,
      ),
    ),
  ),
),
                    ],
                  ),
                  SizedBox(height: 20,),
                  GestureDetector(onTap: _photoPath != null ? null : _pickPhoto,
                          child: Row(
                            children: [
_photoPath != null
                                    ? Row(
                                      children: [
                                        OrganizerAvatar(
                                            photoPath: _photoPath,
                                            size: 36,
                                          ),
                                          SizedBox(width: 15,)
                                      ],
                                    )
                                    :SizedBox(),
                              Text(
                                _photoPath != null
                                    ? 'Delete Photo'
                                    : 'Add Photo',
                                style: AppTextStyles.body.copyWith(
                                  color: _photoPath != null
                                      ? AppColors.warning
                                      : AppColors.txtLevel1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _photoPath != null
                                    ? _deletePhoto
                                    : _pickPhoto,
                                child:  Image.asset(
                                        'assets/images/photo.png',
                                        width: 22,
                                        height: 22,
                                      ),
                              ),
                            ],
                          ),),                  const SizedBox(height: 10),

                                            const Divider(color: AppColors.bgLevel2, height: 1),


                  const SizedBox(height: 5),
                  _FormField(controller: _nameCtrl, hint: 'Name'),
                  const Divider(color: AppColors.bgLevel2, height: 1),
                  _FormField(controller: _roleCtrl, hint: 'Role'),
                  const Divider(color: AppColors.bgLevel2, height: 1),
                  _FormField(
                    controller: _phoneCtrl,
                    hint: 'Phone',
                    keyboardType: TextInputType.phone,
                  ),
                  const Divider(color: AppColors.bgLevel2, height: 1),
                  if (_isEdit) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          'Delete Organizer',
                          style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.body.copyWith(color: AppColors.txtLevel1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.txtLevel3),
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    );
  }
}

Future<bool?> _showUnsavedChangesAlert(BuildContext context) {
  return showGeneralDialog<bool>(
    context: context,
    barrierLabel: 'Unsaved Changes Detected',
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: const Alignment(0, -0.15),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 270,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unsaved Changes Detected',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.txtLevel1,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have unsaved changes.\nAre you sure you want to exit without saving?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.footnote.copyWith(
                          color: AppColors.txtLevel2,
                          decoration: TextDecoration.none,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.bgLevel2, height: 1),
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 11,
                            ),
                            overlayColor: Colors.transparent,
                          ),
                          child: const Text(
                            'Stay',
                            style: TextStyle(
                              color: Color(0xFF0A84FF),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 44,
                        color: AppColors.bgLevel2,
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 11,
                            ),
                            overlayColor: Colors.transparent,
                          ),
                          child: const Text(
                            'Exit',
                            style: TextStyle(
                              color: Color(0xFF0A84FF),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

Future<bool?> _showConfirmDeletionAlert(BuildContext context) {
  return showGeneralDialog<bool>(
    context: context,
    barrierLabel: 'Confirm Deletion',
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) {
      // Сдвигаем контейнер чуть выше центра
      return Align(
        alignment: const Alignment(0, -0.15),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 270,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Confirm Deletion',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.txtLevel1,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Добавили отступ между частями текста через перенос строки с интервалом
                      Text(
                        "Once deleted, this can't be restored.\nProceed?",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.footnote.copyWith(
                          color: AppColors.txtLevel2,
                          decoration: TextDecoration.none,
                          height: 1.3, // Управляет межстрочным интервалом
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.bgLevel2, height: 1),
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 11,
                            ),
                            overlayColor: Colors.transparent,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF0A84FF),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 44,
                        color: AppColors.bgLevel2,
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 11,
                            ),
                            overlayColor: Colors.transparent,
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
