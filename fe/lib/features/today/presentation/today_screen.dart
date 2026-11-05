import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/session_slot.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/state_views.dart';
import '../../trials/domain/trial_booking.dart';
import '../domain/club_session.dart';
import '../domain/roster_entry.dart';
import 'extra_session_sheet.dart';
import 'progress_card.dart';
import 'roster_row.dart';
import 'session_segment.dart';
import 'today_providers.dart';
import 'trial_visitors_card.dart';

const _pickerDaysBack = 60;
const _pickerDaysAhead = 7;

// The bulk-absent bar: its padding plus one button.
const _barTopPadding = AppSpacing.sm;
const _barBottomPadding = AppSpacing.md;
const _barHeight = _barTopPadding + AppSizes.controlHeight + _barBottomPadding;

/// The day's sessions and attendance marking.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final sessions = ref.watch(daySessionsProvider(date));
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TodayHeader(date: date),
            Expanded(
              child: AsyncValueView<List<ClubSession>>(
                value: sessions,
                onRetry: () => ref.invalidate(daySessionsProvider(date)),
                isEmpty: (loaded) => loaded.isEmpty,
                empty: _NoSessionsView(date: date),
                data: (loaded) => _SessionDay(date: date, sessions: loaded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayHeader extends ConsumerWidget {
  const _TodayHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = dateOnly(ref.watch(clockProvider)());
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.lg,
        AppSpacing.gutter,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(DateFormat('EEEE d MMMM').format(date)),
          Row(
            children: [
              Expanded(
                child: Text(
                  date == today ? 'Today' : DateFormat('EEEE').format(date),
                  style: AppTypography.title,
                ),
              ),
              IconButton(
                tooltip: 'Choose a date',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.ink,
                  fixedSize: const Size.square(AppSizes.minTapTarget),
                ),
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () => _pickDate(context, ref, today),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    DateTime today,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(today.year, today.month, today.day - _pickerDaysBack),
      lastDate: DateTime(today.year, today.month, today.day + _pickerDaysAhead),
    );
    if (picked != null) ref.read(selectedDateProvider.notifier).select(picked);
  }
}

class _NoSessionsView extends StatelessWidget {
  const _NoSessionsView({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final isSunday = date.weekday == DateTime.sunday;
    return EmptyView(
      title: isSunday ? 'Closed today' : 'No sessions',
      message: isSunday
          ? 'The club does not train on Sundays.'
          : 'There are no sessions on this day.',
      actionLabel: 'Add an extra session',
      onAction: () => showExtraSessionSheet(context, date),
    );
  }
}

class _SessionDay extends ConsumerWidget {
  const _SessionDay({required this.date, required this.sessions});

  final DateTime date;
  final List<ClubSession> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedSessionIdProvider);
    SessionSlot? slot;
    for (final session in sessions) {
      if (session.id == selectedId) slot = session.slot;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: SessionSegment(
            date: date,
            sessions: sessions,
            selectedId: selectedId,
          ),
        ),
        Expanded(
          child: selectedId == null
              ? const LoadingView()
              : _RosterSection(sessionId: selectedId, date: date, slot: slot),
        ),
      ],
    );
  }
}

class _RosterSection extends ConsumerWidget {
  const _RosterSection({
    required this.sessionId,
    required this.date,
    required this.slot,
  });

  final String sessionId;
  final DateTime date;
  final SessionSlot? slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView<List<RosterEntry>>(
      value: ref.watch(rosterProvider(sessionId)),
      onRetry: () => ref.invalidate(rosterProvider(sessionId)),
      isEmpty: (entries) => entries.isEmpty,
      empty: EmptyView(
        title: 'No active trainees',
        message: 'Add trainees to start marking attendance.',
        actionLabel: 'Go to Trainees',
        onAction: () => context.go(Routes.trainees),
      ),
      data: (entries) => _RosterBody(
        sessionId: sessionId,
        date: date,
        slot: slot,
        entries: entries,
      ),
    );
  }
}

class _RosterBody extends ConsumerWidget {
  const _RosterBody({
    required this.sessionId,
    required this.date,
    required this.slot,
    required this.entries,
  });

  final String sessionId;
  final DateTime date;
  final SessionSlot? slot;
  final List<RosterEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marking = ref.watch(markControllerProvider(sessionId));
    final controller = ref.read(markControllerProvider(sessionId).notifier);
    final failure = marking.isLoading ? null : marking.error;
    final remaining = entries.where((entry) => entry.status == null).length;
    final hasBar = remaining > 0;
    return Stack(
      children: [
        Positioned.fill(
          child: ListView(
            // The bar floats over the list, so the last row needs room to clear it.
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              hasBar ? _barHeight + AppSpacing.lg : AppSpacing.lg,
            ),
            children: [
              ProgressCard(
                marked: entries.length - remaining,
                total: entries.length,
              ),
              if (failure != null) ...[
                const SizedBox(height: AppSpacing.md),
                InlineBanner(
                  message: failure is AppException
                      ? failure.message
                      : UnknownException.defaultMessage,
                  tone: InlineBannerTone.error,
                  onRetry: controller.retry,
                ),
              ],
              _TrialVisitors(date: date, slot: slot),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: ListRow.divide([
                    for (final entry in entries)
                      RosterRow(
                        key: ValueKey(entry.traineeId),
                        entry: entry,
                        onMark: (status) =>
                            controller.mark(entry.traineeId, status),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        if (hasBar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ColoredBox(
              color: AppColors.ground,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  _barTopPadding,
                  AppSpacing.gutter,
                  _barBottomPadding,
                ),
                child: PrimaryButton(
                  label: 'Mark the remaining $remaining absent',
                  isBusy: marking.isLoading,
                  onPressed: () => _markRemaining(context, ref, remaining),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _markRemaining(
    BuildContext context,
    WidgetRef ref,
    int remaining,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          remaining == 1
              ? 'Mark 1 trainee absent?'
              : 'Mark $remaining trainees absent?',
        ),
        content: const Text('Everyone not marked yet is marked absent.'),
        actions: [
          LinkButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          LinkButton(
            label: 'Mark absent',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final count = await ref
        .read(markControllerProvider(sessionId).notifier)
        .markRemainingAbsent();
    if (count == null || !context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$count marked absent')));
  }
}

/// The trial visitors booked into this batch; extra sessions take no bookings.
class _TrialVisitors extends ConsumerWidget {
  const _TrialVisitors({required this.date, required this.slot});

  final DateTime date;
  final SessionSlot? slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trials = ref.watch(dayTrialsProvider(date));
    if (trials.hasError && !trials.isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: InlineBanner(
          message: 'Could not load trial visitors.',
          tone: InlineBannerTone.error,
          onRetry: () => ref.invalidate(dayTrialsProvider(date)),
        ),
      );
    }
    final bookings = [
      for (final booking in trials.value ?? const <TrialBooking>[])
        if (booking.slot == slot) booking,
    ];
    if (bookings.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: TrialVisitorsCard(bookings: bookings),
    );
  }
}
