import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/attendance_status.dart';
import '../../../core/models/session_slot.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/choice_row.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../domain/club_session.dart';
import '../domain/roster_entry.dart';
import 'extra_session_sheet.dart';
import 'today_providers.dart';

/// The day's sessions as pills, the selected one's times, and the extra-session actions.
class SessionSegment extends ConsumerWidget {
  const SessionSegment({
    super.key,
    required this.date,
    required this.sessions,
    required this.selectedId,
  });

  final DateTime date;
  final List<ClubSession> sessions;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletion = ref.watch(deleteExtraSessionControllerProvider);
    final failure = deletion.isLoading ? null : deletion.error;
    final selected = _sessionWithId(selectedId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChoiceRow<String>(
          options: [
            for (final session in sessions)
              ChoiceOption(value: session.id, label: sessionLabel(session)),
          ],
          selected: selectedId,
          onSelected: (id) =>
              ref.read(selectedSessionIdProvider(date).notifier).select(id),
        ),
        // Wraps the actions under the times when they do not fit on one line at 360 px.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(selected?.timeLabel ?? '', style: AppTypography.caption),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (selected != null)
                  _ResetAttendanceButton(date: date, sessionId: selected.id),
                if (selected != null && selected.isExtra)
                  IconButton(
                    tooltip: 'Remove this extra session',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: deletion.isLoading
                        ? null
                        : () => _confirmDelete(context, ref, selected),
                  ),
                LinkButton(
                  label: 'Add extra session',
                  onPressed: () => showExtraSessionSheet(context, date),
                ),
              ],
            ),
          ],
        ),
        if (failure != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InlineBanner(
              message: failure is AppException
                  ? failure.message
                  : UnknownException.defaultMessage,
              tone: InlineBannerTone.error,
            ),
          ),
      ],
    );
  }

  ClubSession? _sessionWithId(String? id) {
    for (final session in sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ClubSession session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this extra session?'),
        content: Text(
          '${session.timeLabel}. A session with attendance cannot be removed.',
        ),
        actions: [
          LinkButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          LinkButton(
            label: 'Remove',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(deleteExtraSessionControllerProvider.notifier)
        .delete(session, sessions);
  }
}

/// Shown once the session has a present mark; clears every mark after a confirm.
class _ResetAttendanceButton extends ConsumerWidget {
  const _ResetAttendanceButton({required this.date, required this.sessionId});

  final DateTime date;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final present = ref.watch(
      rosterProvider(sessionId).select(
        (roster) => (roster.value ?? const <RosterEntry>[])
            .where((entry) => entry.status == AttendanceStatus.present)
            .length,
      ),
    );
    if (present == 0) return const SizedBox.shrink();
    final isResetting = ref.watch(
      markControllerProvider(date).select((marking) => marking.isLoading),
    );
    return LinkButton(
      label: 'Reset attendance',
      onPressed: isResetting
          ? null
          : () => _confirmReset(context, ref, present),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    WidgetRef ref,
    int present,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          present == 1
              ? 'Remove 1 mark for this session?'
              : 'Remove all $present marks for this session?',
        ),
        actions: [
          LinkButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          LinkButton(
            label: 'Reset',
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    // Taken before the reset: the button leaves the tree once no mark is left.
    final messenger = ScaffoldMessenger.of(context);
    final count = await ref
        .read(markControllerProvider(date).notifier)
        .resetSession(sessionId);
    if (count == null) return;
    messenger.showSnackBar(const SnackBar(content: Text('Attendance reset')));
  }
}

/// `Morning`, `Evening`, or `Extra 4:00 pm`.
String sessionLabel(ClubSession session) => switch (session.slot) {
  SessionSlot.morning || SessionSlot.evening => session.slot.label,
  SessionSlot.extra => 'Extra ${session.startLabel}',
  SessionSlot.unknown => session.timeLabel,
};
