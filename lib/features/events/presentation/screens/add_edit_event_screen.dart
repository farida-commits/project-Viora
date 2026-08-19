import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';
import 'package:viora/core/widgets/event_image.dart';
import 'package:viora/features/events/domain/entities/event.dart';
import 'package:viora/features/events/domain/entities/event_task.dart';
import 'package:viora/features/events/domain/entities/expense.dart';
import 'package:viora/features/events/presentation/widgets/select_organizers_sheet.dart';
import 'package:viora/providers/event_provider.dart';
import 'package:viora/providers/organizer_provider.dart';
import 'package:intl/intl.dart';
import 'package:viora/features/organizers/domain/entities/organizer.dart';
import 'package:viora/features/organizers/presentation/widgets/organizer_avatar.dart';
import 'package:viora/features/organizers/domain/utils/organizer_events.dart';

// добавь в начало файла
class _CapitalizeFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final capitalized = newValue.text[0].toUpperCase() + newValue.text.substring(1);
    return newValue.copyWith(
      text: capitalized,
      selection: newValue.selection,
    );
  }
}

// добавь в начало файла, рядом с _CapitalizeFirstLetterFormatter
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');
    final number = int.parse(digitsOnly);
    final formatted = _formatWithCommas(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatWithCommas(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

String _formatMoney(double value) =>
    _ThousandsSeparatorInputFormatter._formatWithCommas(value.round());

Future<T?> _showCenteredPicker<T>(BuildContext context, Widget child) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, secondaryAnim, _) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: FadeTransition(
          opacity: anim,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

class AddEditEventScreen extends StatefulWidget {
  const AddEditEventScreen({super.key, this.initial, this.initialTabIndex = 0});

  final Event? initial;
  final int initialTabIndex;

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _TaskDraft {
  _TaskDraft({required this.id, String? title, this.date, this.status = EventTaskStatus.inProgress})
      : titleCtrl = TextEditingController(text: title);

  final String id;
  final TextEditingController titleCtrl;
  DateTime? date;
  EventTaskStatus status;

  factory _TaskDraft.fromEntity(EventTask t) =>
      _TaskDraft(id: t.id, title: t.title, date: t.date, status: t.status);

  EventTask toEntity() => EventTask(id: id, title: titleCtrl.text.trim(), date: date, status: status);
}

class _ExpenseDraft {
  _ExpenseDraft({required this.id, String? title, String? price, this.date})
      : titleCtrl = TextEditingController(text: title),
        priceCtrl = TextEditingController(text: price);

  final String id;
  final TextEditingController titleCtrl;
  final TextEditingController priceCtrl;
  DateTime? date;

  factory _ExpenseDraft.fromEntity(Expense e) => _ExpenseDraft(
        id: e.id,
        title: e.title,
        price: e.price == 0 ? '' : e.price.toStringAsFixed(0),
        date: e.date,
      );

  Expense toEntity() => Expense(
        id: id,
        title: titleCtrl.text.trim(),
        price: double.tryParse(priceCtrl.text.replaceAll(',', '').trim()) ?? 0,
        date: date,
      );
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _noteInputCtrl;

  String? _photoPath;
  DateTime? _date;
  String? _startTime;
  String? _endTime;

  final List<String> _clientNotes = [];
  final List<_TaskDraft> _tasks = [];
  final List<_ExpenseDraft> _expenses = [];
  final List<String> _organizerIds = [];

  
  int _tabIndex = 0;  
  bool _dirty = false;
  int _idCounter = 0;

  bool get _isEdit => widget.initial != null;

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty && _date != null && _startTime != null && _endTime != null;

  String _newId() => '${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex; 
    
    final e = widget.initial;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _budgetCtrl = TextEditingController(text: e != null && e.budget > 0 ? e.budget.toStringAsFixed(0) : '');
    _noteInputCtrl = TextEditingController();

    _photoPath = e?.photoAsset;
    _date = e?.date;
    _startTime = e?.startTime;
    _endTime = e?.endTime;

    if (e != null) {
      _clientNotes.addAll(e.clientNotes);
      _tasks.addAll(e.tasks.map(_TaskDraft.fromEntity));
      _expenses.addAll(e.expenses.map(_ExpenseDraft.fromEntity));
      _organizerIds.addAll(e.organizerIds);
    } 

    for (final c in [_titleCtrl, _locationCtrl, _descCtrl, _budgetCtrl]) {
      c.addListener(_markDirty);
    }

    _budgetCtrl.addListener(_refreshBudget);

    for (final ex in _expenses) {
      ex.priceCtrl.addListener(_refreshBudget);
    }
  }

  void _refreshBudget() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _budgetCtrl.dispose();
    _noteInputCtrl.dispose();
    for (final t in _tasks) t.titleCtrl.dispose();
    for (final ex in _expenses) {
      ex.titleCtrl.dispose();
      ex.priceCtrl.dispose();
    }
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _pickPhoto() async {
    if (kIsWeb) {
      await _showWebPhotoAccessDialog();
      return;
    }

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, 
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _photoPath = picked.path;
          _dirty = true;
        });
      }
    } catch (_) {
      if (!mounted) return;
      _showDeniedDialog();
    }
  }

  Future<void> _pickImageFromWeb() async {
  try {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _photoPath = picked.path;
        _dirty = true;
      });
    }
  } catch (_) {
    if (!mounted) return;
    _showDeniedDialog();
  }
}

  String _getNextEventText(Organizer organizer) {
  if (organizer.nextEventDate == null) return '';
  final dateStr = DateFormat('d MMM').format(organizer.nextEventDate!);
  final nextEventId = organizer.currentEventIds.isNotEmpty
      ? organizer.currentEventIds.first
      : null;
  String eventTitle = '';
  if (nextEventId != null) {
    final eventProvider = context.read<EventProvider>();
    final event = eventProvider.events.where((e) => e.id == nextEventId).firstOrNull;
    if (event != null) eventTitle = event.title;
  }
  return eventTitle.isNotEmpty ? '$dateStr — $eventTitle' : dateStr;
}

// для разрешения фото
  Future<bool?> _showWebPhotoAccessDialog() {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: Color(0xBF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
      actionsPadding: EdgeInsets.zero,
      title: const Text(
        '"Viora" Would Like to Access \nYour Photos',
        textAlign: TextAlign.center,
        style: AppTextStyles.body,
      ),
      content: const Text(
        'Allow access to your gallery to upload \npictures of your events.',
        textAlign: TextAlign.center,
        style: AppTextStyles.footnote,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(height: 16,),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: AppColors.bgLevel2, height: 1, thickness: 1,),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff007AFF),
                overlayColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                minimumSize: Size(double.infinity, 48), 
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromWeb();
              },
              child: const Text(
                'Select Photos...',
                style: TextStyle(
                  color: Color(0xff0A84FF),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Divider(color: AppColors.bgLevel2, height: 1, thickness: 1,),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff0A84FF),
                overlayColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                minimumSize: const Size(double.infinity, 48),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromWeb();
              },
              child: const Text(
                'Allow Access to all Photos',
                style: TextStyle(
                  color: Color(0xff0A84FF),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Divider(color: AppColors.bgLevel2, height: 1, thickness: 1,),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff0A84FF),
                overlayColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                minimumSize: const Size(double.infinity, 48),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _showDeniedDialog();
              },
              child: const Text(
                "Don't Allow",
                style: TextStyle(
                  color: Color(0xff0A84FF),
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  void _showDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xBF1E1E1E),
        title: const Text(
          textAlign: TextAlign.center,
          'Access to photos has been \ndenied', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
        content: const Text(
          textAlign: TextAlign.center,
          'Allow in the settings to upload pictures \nof your events.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.zero,
        actions: [
          Column(
            children: [
              const Divider(color: AppColors.bgLevel2, height: 1),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: Colors.transparent,
                      ),
                      onPressed: () => Navigator.pop(context), 
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppTextStyles.fontFamily,
                          color: Color(0xff007AFF)
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
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: Colors.transparent
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        if (kIsWeb) {
                          _pickImageFromWeb();
                        } else {
                          openAppSettings();
                        }
                      },
                      child: const Text(
                        'Settings',
                        style: TextStyle(
                          color: Color(0xff007AFF),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppTextStyles.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- дата / время ----------

  Future<void> _pickDate() async {
    DateTime temp = _date ?? DateTime.now();
    final result = await _showCenteredPicker<DateTime>(
      context,
      _PickerSheet(
        height: 250, 
        picker: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: temp,
          onDateTimeChanged: (d) => temp = d,
        ), 
        onCancel: () => Navigator.pop(context), 
        onSave:() => Navigator.pop(context, temp),
      ),
    );
    if (result != null) {
      setState(() {
        _date = result;
        _dirty = true;
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final now = DateTime.now();
    DateTime temp = now;
    final result = await _showCenteredPicker<DateTime>(
      context,
      _PickerSheet(
        height: 220, 
        picker: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          initialDateTime: temp,
          onDateTimeChanged: (d) => temp = d,
        ), 
        onCancel: () => Navigator.pop(context),
        onSave: () => Navigator.pop(context, temp),
      ),
    //   context: context,
    //   backgroundColor: const Color(0xFF241729),
    //   shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    //   builder: (ctx) => _PickerSheet(
    //     height: 220,
    //     picker: CupertinoDatePicker(
    //       mode: CupertinoDatePickerMode.time,
    //       use24hFormat: true,
    //       initialDateTime: temp,
    //       onDateTimeChanged: (d) => temp = d,
    //     ),
    //     onCancel: () => Navigator.pop(ctx),
    //     onSave: () => Navigator.pop(ctx, temp),
    //   ),
    );
    if (result != null) {
      final formatted =
          '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _startTime = formatted;
        } else {
          _endTime = formatted;
        }
        _dirty = true;
      });
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ---------- выход / сохранение / удаление ----------

Future<bool> _confirmExit() async {
  if (!_dirty) return true;
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            width: 270,
            padding: const EdgeInsets.only(top: 20,),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unsaved Changes Detected',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 4),
                const Text(
                  'You have unsaved changes. Are you \nsure you want to exit without saving?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.footnote,
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.bgLevel2, height: 1),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: Colors.transparent,
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'Stay',
                          style: TextStyle(
                            color: Color(0xff0A84FF),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 44, color: AppColors.bgLevel2),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          overlayColor: Colors.transparent,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Exit',
                          style: TextStyle(
                            color: Color(0xff0A84FF),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTextStyles.fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}

  void _save() {
    if (!_canSave) return;
    final event = Event(
      id: widget.initial?.id ?? _newId(),
      title: _titleCtrl.text.trim(),
      photoAsset: _photoPath,
      date: _date!,
      startTime: _startTime,
      endTime: _endTime,
      location: _locationCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      clientNotes: List.of(_clientNotes),
      tasks: _tasks.map((t) => t.toEntity()).toList(),
      budget: double.tryParse(_budgetCtrl.text.replaceAll(',', '').trim()) ?? 0,
      expenses: _expenses.map((e) => e.toEntity()).toList(),
      organizerIds: List.of(_organizerIds),
    );

    final provider = context.read<EventProvider>();
    if (_isEdit) {
      provider.update(event);
    } else {
      provider.add(event);
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
        content: const Text(
          "Once deleted, this can't be restored. Proceed?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (result == true && widget.initial != null) {
      context.read<EventProvider>().remove(widget.initial!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit()) {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgLevel1,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/fon.png', fit: BoxFit.cover),
            Column(
            children: [
              _buildPhotoHeader(),
              const SizedBox(height: 16,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TabsBar(index: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      _buildInformationTab(),
                      _buildTasksTab(),
                      _buildBudgetTab(),
                      _buildOrganizersTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoHeader() {
    final hasPhoto = _photoPath != null;

    return Container(
      height: hasPhoto ? 250 : 176,
      decoration: BoxDecoration(
        color: hasPhoto ? null : AppColors.bgLevel2,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasPhoto)
            EventImage(path: _photoPath!),
          if (hasPhoto)       
            Container(color: const Color(0xFF000000).withValues(alpha: 0.3)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                    if (await _confirmExit()) {
                      if (mounted) Navigator.of(context).pop();
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/back.png',
                        width: 24, 
                        height: 24, 
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(_isEdit ? 'Edit Event' : 'Add Event', style: AppTextStyles.title),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _canSave ? _save : null,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bgLevel2,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/save.png',
                        width: 20,
                        height: 20,
                        color: _canSave ? Colors.white : AppColors.txtLevel3,                    
                      ),
                    ),
                  ),
                )
                ],
              ),
              // SizedBox(height: hasPhoto ? 90 : 38,),
              if (!hasPhoto)
            GestureDetector(
              onTap: _pickPhoto,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/photo.png',
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text('Upload Photo', style: AppTextStyles.title.copyWith(color: Colors.white)),
                ],
              ),
            )
            else
            GestureDetector(
              onTap: () => setState(() {
                _photoPath = null;
                _dirty = true;
              }),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/delete.png',
                    width: 20,
                    height: 20,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Delete Photo', 
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ]
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildInformationTab() {
    return ListView(
      children: [
        TextField(
          controller: _titleCtrl,
          style: AppTextStyles.body,
          cursorColor: Colors.white,
          cursorHeight: 19,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [_CapitalizeFirstLetterFormatter()],
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter Title',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.txtLevel3,
            ),
          ),
        ),
        const Divider(color: AppColors.bgLevel2),
        _RowField(
          label: _date != null ? _formatDate(_date!) : 'Date',
          isPlaceholder: _date == null,
          iconAsset: 'assets/images/calendar.png',
          onTap: _pickDate,
        ),
        const Divider(color: AppColors.bgLevel2),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _RowField(
                  label: _startTime ?? 'Start Time',
                  isPlaceholder: _startTime == null,
                  iconAsset: 'assets/images/clock.png',
                  onTap: () => _pickTime(isStart: true),
                ),
              ),
              Container(
                width: 1, 
                color: AppColors.bgLevel2,
                margin: EdgeInsets.only(right: 10, left: 10),
              ),
              Expanded(
                child: _RowField(
                  label: _endTime ?? 'End Time',
                  isPlaceholder: _endTime == null,
                  iconAsset: 'assets/images/clock.png',
                  onTap: () => _pickTime(isStart: false),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.bgLevel2),
        TextField(
          controller: _locationCtrl,
          style: AppTextStyles.body,
          cursorColor: Colors.white,
          cursorHeight: 19,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [_CapitalizeFirstLetterFormatter()],
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter Location',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.txtLevel3,
            ),
          ),
        ),
        const Divider(color: AppColors.bgLevel2),
        TextField(
          controller: _descCtrl,
          minLines: 1,
          maxLines: 4,
          style: AppTextStyles.body,
          cursorColor: Colors.white,
          cursorHeight: 19,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [_CapitalizeFirstLetterFormatter()],
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter Description',
            hintStyle: AppTextStyles.body.copyWith(
              color: AppColors.txtLevel3,
            ),
          ),
        ),
        const Divider(color: AppColors.bgLevel2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Client Notes', 
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _clientNotes.add('');
                _dirty = true;
              }),
              child: Image.asset(
                'assets/images/plus.png', 
                color: Colors.white,
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        for (int i = 0; i < _clientNotes.length; i++) _buildNoteRow(i),
        if (_isEdit) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),              
              label: Text(
                'Delete Event', 
                style: AppTextStyles.body.copyWith(
                color: Colors.white
                ),
              ),
              onPressed: _confirmDelete,
              icon: Image.asset(
                'assets/images/delete.png',
                width: 20,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNoteRow(int i) {
    final controller = TextEditingController(text: _clientNotes[i]);
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    final showDelete = i != 0 || _clientNotes[i].trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.body,
                  cursorColor: Colors.white,
                  cursorHeight: 19,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [_CapitalizeFirstLetterFormatter()],
                  onChanged: (v) {
                    setState(() {
                      _clientNotes[i] = v;
                      _dirty = true;
                    });
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter Note',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.txtLevel3
                    ),
                  ),
                ),
              ),
              if (showDelete)
              GestureDetector(
                onTap: () => setState(() {
                  _clientNotes.removeAt(i);
                  _dirty = true;
                }),
                child: Image.asset(
                  'assets/images/delete.png',
                  width: 20,
                  height: 20,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.bgLevel2,),
        ],
      ),
    );
  }

  // ---------- Tasks ----------

  Widget _buildTasksTab() {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Task', 
              style: AppTextStyles.body,
            ),
            GestureDetector(
              onTap: () => setState(() {
                _tasks.add(_TaskDraft(id: _newId()));
                _dirty = true;
              }),
              child: Image.asset(
                'assets/images/plus.png',
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _tasks.length; i++) _buildTaskCard(i),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTaskCard(int i) {
    final t = _tasks[i];
    final dateCtrl = TextEditingController(
      text: t.date != null ? _formatDate(t.date!) : '',
    );
    final deleteCtrl = TextEditingController(text: 'Delete Task');

    Widget wrap(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: child,
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12,),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLevel2,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          TextField(
            controller: t.titleCtrl,
            minLines: 1,
            maxLines: 4,
            style: AppTextStyles.body,
            cursorColor: Colors.white,
            cursorHeight: 19,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [_CapitalizeFirstLetterFormatter()],
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: 'Enter Task',
                hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.txtLevel3,
              ),
            ),
          ),
          const Divider(color: AppColors.bgLevel2),
          GestureDetector(
            onTap: () async {
              DateTime temp = t.date ?? DateTime.now();
              final result = await _showCenteredPicker<DateTime>(
                context,
                _PickerSheet(
                  height: 250,
                  picker: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: temp,
                    onDateTimeChanged: (d) => temp = d,
                  ),
                  onCancel: () => Navigator.pop(context),
                  onSave: () => Navigator.pop(context, temp),
                ),
              );
              if (result != null) {
                setState(() {
                  t.date = result;
                  _dirty = true;
                });
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: dateCtrl,
                readOnly: true,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: 'Select Date',
                  hintStyle: AppTextStyles.body.copyWith(color: Colors.white),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Image.asset(
                      'assets/images/calendar.png',
                      color: Colors.white, 
                      width: 20, 
                      height: 20
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                ),
              ),
            ),
          ),
          const Divider(color: AppColors.bgLevel2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusChip(
                  label: 'In Progress',
                  color: const Color(0xFF007AFF),
                  active: t.status == EventTaskStatus.inProgress,
                  onTap: () => setState(() {
                    t.status = EventTaskStatus.inProgress;
                    _dirty = true;
                  }),
                ),
                _StatusChip(
                  label: 'Done',
                  color: AppColors.success,
                  active: t.status == EventTaskStatus.done,
                  onTap: () => setState(() {
                    t.status = EventTaskStatus.done;
                    _dirty = true;
                  }),
                ),
                _StatusChip(
                  label: 'Not Started',
                  color: AppColors.warning,
                  active: t.status == EventTaskStatus.notStarted,
                  onTap: () => setState(() {
                    t.status = EventTaskStatus.notStarted;
                    _dirty = true;
                  }),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.bgLevel2),
          GestureDetector(
            onTap: () => setState(() {
              _tasks.removeAt(i);
              _dirty = true;
            }),
            child: AbsorbPointer(
              child: TextField(
                controller: deleteCtrl,
                readOnly: true,
                style: AppTextStyles.body.copyWith(color: AppColors.warning),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Image.asset(
                      'assets/images/delete.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Budget ----------

  Widget _buildBudgetTab() {
    final expensesSum = _expenses.fold<double>(
      0,
      (s, e) => s + (double.tryParse(e.priceCtrl.text.replaceAll(',', '').trim()) ?? 0),
    );
    final budget = double.tryParse(_budgetCtrl.text.replaceAll(',', '').trim()) ?? 0;
    final fundBalance = budget - expensesSum;

    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _budgetCtrl,
                keyboardType: TextInputType.number,
                style: AppTextStyles.body,
                cursorColor: Colors.white,
                cursorHeight: 19,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [_ThousandsSeparatorInputFormatter()],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter Budget',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.txtLevel3),
                ),
              ),
            ),
             Image.asset(
              'assets/images/dollar.png',
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ],
        ),
        const Divider(color: AppColors.bgLevel2),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Fund balance - ', style: AppTextStyles.body),
            Image.asset(
              'assets/images/dollar.png',
              width: 15,
              height: 15,
              color: Colors.white,
            ),
            Text(_formatMoney(fundBalance), style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.bgLevel2),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Expense', 
              style: AppTextStyles.body,
            ),
            GestureDetector(
              onTap: () => setState(() {
                final expense = _ExpenseDraft(id: _newId());
                expense.priceCtrl.addListener(_refreshBudget);
                _expenses.add(expense);
                _dirty = true;
              }),
              child: Image.asset(
                'assets/images/plus.png',
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _expenses.length; i++) _buildExpenseCard(i),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildExpenseCard(int i) {
    final ex = _expenses[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLevel2,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: ex.titleCtrl,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.body,
                  cursorColor: Colors.white,
                  cursorHeight: 19,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [_CapitalizeFirstLetterFormatter()],
                  onChanged: (_) => setState(_markDirty),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: 'Title',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.txtLevel3),
                    
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 1, 
                  height: 23,
                  color: AppColors.bgLevel2,
                  // margin: EdgeInsets.only(left: 208),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ex.priceCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.start,
                        style: AppTextStyles.body,
                        cursorColor: Colors.white,
                        cursorHeight: 19,
                        textCapitalization: TextCapitalization.sentences,
                        inputFormatters: [_ThousandsSeparatorInputFormatter()],
                        onChanged: (_) => setState(_markDirty),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: 'Price',
                          hintStyle: AppTextStyles.body.copyWith(color: AppColors.txtLevel3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Image.asset(
                      'assets/images/dollar.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12,),
          _RowField(
            label: ex.date != null ? _formatDate(ex.date!) : 'Select Date',
            isPlaceholder: ex.date == null,
            iconAsset: 'assets/images/calendar.png',
            dense: true,
            onTap: () async {
              DateTime temp = ex.date ?? DateTime.now();
              final result = await _showCenteredPicker<DateTime>(
                context,
                 _PickerSheet(
                  height: 250,
                  picker: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: temp,
                    onDateTimeChanged: (d) => temp = d,
                  ),
                  onCancel: () => Navigator.pop(context),
                  onSave: () => Navigator.pop(context, temp),
                ),
              );
              if (result != null) {
                setState(() {
                  ex.date = result;
                  _dirty = true;
                });
              }
            },
          ),
          const Divider(color: Colors.white12,),
          GestureDetector(
            onTap: () => setState(() {
              _expenses.removeAt(i);
              _dirty = true;
            }),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delete Expense', 
                  style: AppTextStyles.body.copyWith(color: AppColors.warning)
                ),
                Image.asset(
                  'assets/images/delete.png',
                  width: 20,
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Organizers ----------

  Widget _buildOrganizersTab() {
    final allOrganizers = context.watch<OrganizerProvider>().organizers;
    final selected = allOrganizers.where((o) => _organizerIds.contains(o.id)).toList();

    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Organizer', 
              style: AppTextStyles.body
            ),
            GestureDetector(
              onTap: () async {
                final result = await showSelectOrganizersSheet(context, initialSelected: _organizerIds);
                if (result != null) {
                  setState(() {
                    _organizerIds
                      ..clear()
                      ..addAll(result);
                    _dirty = true;
                  });
                }
              },
              child: Image.asset(
                'assets/images/plus.png',
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        const Divider(color: Colors.white12,),
        const SizedBox(height: 12),
        for (final o in selected)
          Builder(
            builder: (context) {
              final eventProvider = context.watch<EventProvider>();
              final nextEventText = organizerNextEventText(eventProvider, o.id);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgLevel2,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OrganizerAvatar(
                    photoPath: o.photoPath,
                    size: 64,
                    borderRadius: 24,
                    placeholderIconSize: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.position, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text(o.name, style: AppTextStyles.body),
                        if (nextEventText.isNotEmpty) ...[
                          const SizedBox(height: 4,),
                          Text(
                            'Next Event:',
                          style: AppTextStyles.caption.copyWith(color: AppColors.txtLevel2),
                          ),
                          const SizedBox(height: 2,),
                          Text(
                            nextEventText,
                            style: AppTextStyles.caption.copyWith(color: AppColors.txtLevel1),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _organizerIds.remove(o.id);
                      _dirty = true;
                    }),
                    child: Image.asset(
                      'assets/images/delete.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TabsBar extends StatelessWidget {
  const _TabsBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const _labels = ['Information', 'Tasks', 'Budget', 'Organizers'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgLevel2,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Container(
              width: 1,
              height: 24,
              color: Color(0x0DFFFFFF),
            );
          }
          final index0 = i ~/ 2;
          final active = index0 == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  _labels[index0],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.footnote.copyWith(
                    color: active ? AppColors.primary : Colors.white,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RowField extends StatelessWidget {
  const _RowField({
    required this.label,
    required this.isPlaceholder,
    required this.iconAsset,
    required this.onTap,
    this.dense = false,
  });

  final String label;
  final bool isPlaceholder;
  final String iconAsset;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 4 : 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
            Image.asset(
              iconAsset, 
              color: Colors.white, 
              width: 20,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color, required this.active, required this.onTap});

  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: active ? color : AppColors.txtLevel2,
        ),
      ),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.height,
    required this.picker,
    required this.onCancel,
    required this.onSave,
  });

  final double height;
  final Widget picker;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  static const Color _sheetFill = Color(0xFF2A202D);
  static const double _itemExtent = 32.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SafeArea(
        child: SizedBox(
          width: 343,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container (
                margin: const EdgeInsets.only(top: 20), 
                height: _itemExtent * 7,
                decoration: BoxDecoration(
                  color: _sheetFill,
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(brightness: Brightness.dark),
                  child: Container(
                    color: _sheetFill,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 12,
                          right: 12,
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        picker,
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _sheetFill,        
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: onCancel,
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: onSave,
                          child:  Text(
                            'Save',
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.white,
                            ),
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
  }
}