import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/attendance_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/state_views.dart';
import '../../today/presentation/today_providers.dart';
import '../domain/attendance_record.dart';
import 'attendance_record_row.dart';
import 'trainee_providers.dart';

/// One trainee's marks a month at a time, up to the current month.
class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key, required this.traineeId});

  final String traineeId;

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen> {
  late final DateTime currentMonth;
  late DateTime month;

  @override
  void initState() {
    super.initState();
    final today = ref.read(clockProvider)();
    currentMonth = DateTime(today.year, today.month);
    month = currentMonth;
  }

  void showPrevious() =>
      setState(() => month = DateTime(month.year, month.month - 1));

  void showNext() {
    if (!month.isBefore(currentMonth)) return;
    setState(() => month = DateTime(month.year, month.month + 1));
  }

  @override
  Widget build(BuildContext context) {
    final key = (traineeId: widget.traineeId, month: month);
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance history')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MonthNavigator(
            month: month,
            onPrevious: showPrevious,
            onNext: month.isBefore(currentMonth) ? showNext : null,
          ),
          Expanded(
            child: AsyncValueView<List<AttendanceRecord>>(
              value: ref.watch(monthAttendanceProvider(key)),
              onRetry: () => ref.invalidate(monthAttendanceProvider(key)),
              isEmpty: (records) => records.isEmpty,
              empty: EmptyView(
                title: 'No sessions this month',
                message:
                    'No attendance was marked for this trainee in '
                    '${DateFormat('MMMM yyyy').format(month)}.',
                actionLabel: 'Previous month',
                onAction: showPrevious,
              ),
              data: (records) => _MonthRecords(records: records),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;

  /// Null in the current month: there is nothing after it.
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      disabledBackgroundColor: AppColors.ground,
      disabledForegroundColor: AppColors.line,
      fixedSize: const Size.square(AppSizes.minTapTarget),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous month',
            style: buttonStyle,
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(month),
              style: AppTypography.heading,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            style: buttonStyle,
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _MonthRecords extends StatelessWidget {
  const _MonthRecords({required this.records});

  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final present = records
        .where((record) => record.status == AttendanceStatus.present)
        .length;
    final absent = records
        .where((record) => record.status == AttendanceStatus.absent)
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        Text('$present present, $absent absent', style: AppTypography.caption),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: ListRow.divide([
              for (final record in records) AttendanceRecordRow(record: record),
            ]),
          ),
        ),
      ],
    );
  }
}
