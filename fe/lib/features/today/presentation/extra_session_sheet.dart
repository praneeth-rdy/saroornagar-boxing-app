import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/primary_button.dart';
import 'today_providers.dart';

// Extra sessions are usually afternoon top-ups, so the pickers open there.
const _suggestedStart = TimeOfDay(hour: 16, minute: 0);
const _suggestedEnd = TimeOfDay(hour: 17, minute: 30);

/// Opens [ExtraSessionSheet] for [date].
Future<void> showExtraSessionSheet(BuildContext context, DateTime date) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.ground,
      builder: (_) => ExtraSessionSheet(date: date),
    );

/// Start and end pickers for a new extra session on [date].
class ExtraSessionSheet extends ConsumerStatefulWidget {
  const ExtraSessionSheet({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<ExtraSessionSheet> createState() => _ExtraSessionSheetState();
}

class _ExtraSessionSheetState extends ConsumerState<ExtraSessionSheet> {
  TimeOfDay? start;
  TimeOfDay? end;

  Future<void> pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ?? _suggestedStart,
    );
    if (picked != null && mounted) setState(() => start = picked);
  }

  Future<void> pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: end ?? _suggestedEnd,
    );
    if (picked != null && mounted) setState(() => end = picked);
  }

  Future<void> submit() async {
    final isAdded = await ref
        .read(addExtraSessionControllerProvider.notifier)
        .submit(widget.date, start, end);
    if (isAdded && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(addExtraSessionControllerProvider);
    final failure = submission.isLoading ? null : submission.error;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.xl,
          AppSpacing.gutter,
          AppSpacing.gutter + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add an extra session', style: AppTypography.heading),
            const SizedBox(height: AppSpacing.xs),
            Text(
              DateFormat('EEEE d MMMM').format(widget.date),
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: ListRow.divide([
                  _TimeRow(label: 'Starts', time: start, onTap: pickStart),
                  _TimeRow(label: 'Ends', time: end, onTap: pickEnd),
                ]),
              ),
            ),
            if (failure != null) ...[
              const SizedBox(height: AppSpacing.md),
              InlineBanner(
                message: failure is AppException
                    ? failure.message
                    : UnknownException.defaultMessage,
                tone: InlineBannerTone.error,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Add',
              onPressed: submit,
              isBusy: submission.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chosen = time;
    return ListRow(
      title: label,
      subtitle: chosen == null
          ? 'Choose a time'
          : formatClockTime(
              DateTime.utc(2000, 1, 1, chosen.hour, chosen.minute),
            ),
      trailing: const Icon(Icons.schedule, color: AppColors.muted),
      onTap: onTap,
    );
  }
}
