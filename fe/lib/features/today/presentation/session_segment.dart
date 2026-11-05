import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/session_slot.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/choice_row.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../domain/club_session.dart';
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
              ref.read(selectedSessionIdProvider.notifier).select(id),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                selected?.timeLabel ?? '',
                style: AppTypography.caption,
              ),
            ),
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

/// `Morning`, `Evening`, or `Extra 4:00 pm`.
String sessionLabel(ClubSession session) => switch (session.slot) {
  SessionSlot.morning || SessionSlot.evening => session.slot.label,
  SessionSlot.extra => 'Extra ${session.startLabel}',
  SessionSlot.unknown => session.timeLabel,
};
