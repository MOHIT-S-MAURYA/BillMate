import 'package:flutter/material.dart';
import 'package:billmate/features/reports/domain/entities/report.dart';

class DateRangePicker extends StatelessWidget {
  final DateRange selectedRange;
  final ValueChanged<DateRange> onRangeChanged;

  const DateRangePicker({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _DateRangeChip(
                  label: 'Today',
                  isSelected: _isToday(selectedRange),
                  onPressed: () => onRangeChanged(DateRange.today()),
                ),
                _DateRangeChip(
                  label: 'This Week',
                  isSelected: _isThisWeek(selectedRange),
                  onPressed: () => onRangeChanged(DateRange.thisWeek()),
                ),
                _DateRangeChip(
                  label: 'This Month',
                  isSelected: _isThisMonth(selectedRange),
                  onPressed: () => onRangeChanged(DateRange.thisMonth()),
                ),
                _DateRangeChip(
                  label: 'This Year',
                  isSelected: _isThisYear(selectedRange),
                  onPressed: () => onRangeChanged(DateRange.thisYear()),
                ),
                _DateRangeChip(
                  label: 'Custom',
                  isSelected: _isCustom(selectedRange),
                  onPressed: () => _showCustomDatePicker(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(selectedRange.start)} - ${_formatDate(selectedRange.end)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateRange range) {
    final today = DateRange.today();
    return _isSameDay(range.start, today.start) &&
        _isSameDay(range.end, today.end);
  }

  bool _isThisWeek(DateRange range) {
    final thisWeek = DateRange.thisWeek();
    return _isSameDay(range.start, thisWeek.start) &&
        _isSameDay(range.end, thisWeek.end);
  }

  bool _isThisMonth(DateRange range) {
    final thisMonth = DateRange.thisMonth();
    return _isSameDay(range.start, thisMonth.start) &&
        _isSameDay(range.end, thisMonth.end);
  }

  bool _isThisYear(DateRange range) {
    final thisYear = DateRange.thisYear();
    return _isSameDay(range.start, thisYear.start) &&
        _isSameDay(range.end, thisYear.end);
  }

  bool _isCustom(DateRange range) {
    return !_isToday(range) &&
        !_isThisWeek(range) &&
        !_isThisMonth(range) &&
        !_isThisYear(range);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(2020);

    // Ensure the initial range is within bounds
    var startDate = selectedRange.start;
    var endDate = selectedRange.end;

    // Clamp dates to valid range
    if (startDate.isBefore(firstDate)) {
      startDate = firstDate;
    }
    if (endDate.isAfter(now)) {
      endDate = now;
    }
    if (startDate.isAfter(now)) {
      startDate = now.subtract(const Duration(days: 7));
    }

    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: now,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (dateRange != null) {
      onRangeChanged(DateRange(start: dateRange.start, end: dateRange.end));
    }
  }
}

class _DateRangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _DateRangeChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}
