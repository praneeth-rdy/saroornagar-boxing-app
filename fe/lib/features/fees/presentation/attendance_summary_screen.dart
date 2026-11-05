import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/state_views.dart';
import '../../today/presentation/today_providers.dart';
import '../../trainees/presentation/trainee_providers.dart';
import '../domain/attendance_summary_row.dart';
import 'fee_providers.dart';
import 'month_navigator.dart';

/// Every active student's attended classes for a month; a row opens their log.
class AttendanceSummaryScreen extends ConsumerStatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  ConsumerState<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState
    extends ConsumerState<AttendanceSummaryScreen> {
  late final DateTime currentMonth;
  late DateTime month;

  @override
  void initState() {
    super.initState();
    currentMonth = monthOf(ref.read(clockProvider)());
    month = currentMonth;
  }

  void showPrevious() =>
      setState(() => month = DateTime(month.year, month.month - 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly attendance')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              AppSpacing.md,
            ),
            child: MonthNavigator(
              month: month,
              latest: currentMonth,
              onChanged: (next) => setState(() => month = next),
            ),
          ),
          Expanded(
            child: AsyncValueView<List<AttendanceSummaryRow>>(
              value: ref.watch(attendanceSummaryProvider(month)),
              onRetry: () => ref.invalidate(attendanceSummaryProvider(month)),
              isEmpty: (rows) => rows.isEmpty,
              empty: EmptyView(
                title: 'No active students',
                message: 'Monthly attendance lists active students.',
                actionLabel: 'Go to Students',
                onAction: () => context.go(Routes.trainees),
              ),
              data: (rows) => rows.first.sessionCount == 0
                  ? EmptyView(
                      title: 'No sessions this month',
                      message:
                          'No sessions were held in '
                          '${DateFormat('MMMM yyyy').format(month)}.',
                      actionLabel: 'Previous month',
                      onAction: showPrevious,
                    )
                  : _SummaryList(rows: rows, month: month),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryList extends StatelessWidget {
  const _SummaryList({required this.rows, required this.month});

  final List<AttendanceSummaryRow> rows;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: ListRow.divide([
              for (final row in rows) _SummaryRow(row: row, month: month),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({required this.row, required this.month});

  final AttendanceSummaryRow row;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoPath = row.photoPath;
    final photoUrl = photoPath == null
        ? null
        : ref.watch(traineePhotoUrlProvider(photoPath)).value;
    return ListRow(
      leading: AvatarInitials(name: row.fullName, photoUrl: photoUrl),
      title: row.fullName,
      subtitle: row.presentCount == 1
          ? '1 class attended'
          : '${row.presentCount} classes attended',
      trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      onTap: () => context.push(
        Routes.traineeHistoryOf(row.traineeId, month: month),
      ),
    );
  }
}
