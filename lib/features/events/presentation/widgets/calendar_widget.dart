import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.eventDates,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  final DateTime displayedMonth; // любой день внутри нужного месяца
  final DateTime? selectedDate;
  final Set<DateTime> eventDates; // нормализованные (y,m,d) даты с ивентами
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<int> onMonthChanged; // -1 назад, +1 вперёд

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final leadingBlanks = firstDayOfMonth.weekday - 1; // Monday = 1
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => onMonthChanged(-1),
              icon: const Icon(Icons.chevron_left, color: AppColors.txtLevel1),
            ),
            Text(
              DateFormat('MMMM, y').format(displayedMonth),
              style: AppTextStyles.title,
            ),
            IconButton(
              onPressed: () => onMonthChanged(1),
              icon: const Icon(Icons.chevron_right, color: AppColors.txtLevel1),
            ),
          ],
        ),
        Row(
          children: _weekdayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: AppTextStyles.caption.copyWith(color: AppColors.txtLevel3),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        for (int row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNumber = cellIndex - leadingBlanks + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                final date = DateTime(displayedMonth.year, displayedMonth.month, dayNumber);
                final isSelected = selectedDate != null && _isSameDay(date, selectedDate!);
                final hasEvent = eventDates.any((d) => _isSameDay(d, date));

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: Center(
                      child: _DayCell(
                        day: dayNumber,
                        isSelected: isSelected,
                        hasEvent: hasEvent && !isSelected,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.isSelected, required this.hasEvent});

  final int day;
  final bool isSelected;
  final bool hasEvent;

  @override
  Widget build(BuildContext context) {
    final size = 36.0;
    Widget content = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
      ),
      child: Text(
        '$day',
        style: AppTextStyles.footnote.copyWith(
          color: isSelected ? AppColors.txtLevel1 : AppColors.txtLevel1,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );

    if (hasEvent) {
      content = CustomPaint(
        painter: _DashedCirclePainter(color: AppColors.primary),
        child: content,
      );
    }

    return content;
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    const dashCount = 16;
    const gapFraction = 0.5; // половина сегмента — линия, половина — пробел

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (2 * 3.141592653589793 / dashCount) * i;
      final sweep = (2 * 3.141592653589793 / dashCount) * gapFraction;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) => false;
}