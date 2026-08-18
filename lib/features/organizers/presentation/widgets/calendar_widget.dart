// lib/features/organizers/presentation/widgets/calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';

/// Календарь на месяц с кружками-обводками у каждого дня.
///
/// - обычный день — тонкая полупрозрачная обводка (AppColors.txtLevel3)
/// - день с событием (есть в [eventDates]) — обводка акцентного цвета (AppColors.primary)
/// - выбранный день ([selectedDate]) — залит AppColors.primary, текст белый
class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.eventDates,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  /// Любой день месяца, который сейчас показан (день не важен, важны year/month)
  final DateTime displayedMonth;

  /// Текущий выбранный день (может быть null)
  final DateTime? selectedDate;

  /// Даты (year/month/day, время не важно), в которые есть события
  final Set<DateTime> eventDates;

  final ValueChanged<DateTime> onDateSelected;

  /// delta = -1 (назад) или +1 (вперёд)
  final ValueChanged<int> onMonthChanged;

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _hasEvent(DateTime day) => eventDates.any((e) => _isSameDay(e, day));

  @override
  Widget build(BuildContext context) {
    final year = displayedMonth.year;
    final month = displayedMonth.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // индекс дня недели первого числа: Monday = 0 ... Sunday = 6
    final firstWeekdayIndex = firstDayOfMonth.weekday - 1;

    return Column(
      children: [
        // заголовок месяца/года со стрелками
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => onMonthChanged(-1),
              child: Image.asset(
                'assets/images/back.png',
                width: 20,
                height: 20,
              ),
            ),
            Text(
              DateFormat('MMMM, y').format(displayedMonth),
              style: AppTextStyles.title,
            ),
            GestureDetector(
              onTap: () => onMonthChanged(1),
              child: Image.asset(
                'assets/images/back2.png',
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // строка дней недели
        Row(
          children: _weekDays
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: AppTextStyles.footnote.copyWith(
                        color: AppColors.txtLevel3,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),

        // сетка дней
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: firstWeekdayIndex + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 0,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            if (index < firstWeekdayIndex) {
              return const SizedBox.shrink();
            }

            final day = index - firstWeekdayIndex + 1;
            final date = DateTime(year, month, day);
            final isSelected =
                selectedDate != null && _isSameDay(date, selectedDate!);
            final hasEvent = _hasEvent(date);

            return _DayCell(
              day: day,
              isSelected: isSelected,
              hasEvent: hasEvent,
              onTap: () => onDateSelected(date),
            );
          },
        ),
      ],
    );
  }
}


class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.hasEvent,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool hasEvent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color? borderColor = hasEvent && !isSelected ? AppColors.primary : null;

    final Color fillColor = isSelected
        ? AppColors.primary
        : Colors.white.withValues(alpha: 0.08);

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fillColor,
            border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: AppTextStyles.body.copyWith(
              color: AppColors.txtLevel1,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}