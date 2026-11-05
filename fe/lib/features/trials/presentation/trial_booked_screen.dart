import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/trial_booking.dart';
import 'book_trial_screen.dart';

/// Tells the visitor when to come; the booking only informs the coach, nothing to confirm.
class TrialBookedScreen extends ConsumerWidget {
  const TrialBookedScreen({super.key, required this.booking});

  final TrialBooking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Staff who booked for someone return to their Trials tab; a visitor gets a fresh form.
    final isSignedIn = ref.watch(sessionProvider).value ?? false;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.xxl,
          ),
          children: [
            const Text("You're booked", style: AppTypography.title),
            const SizedBox(height: AppSpacing.md),
            Text(_instructions(booking), style: AppTypography.body),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Done',
              onPressed: () =>
                  context.go(isSignedIn ? Routes.trials : Routes.trial),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: LinkButton(
                label: 'Book another day',
                // Back to the form, which keeps the visitor's details.
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go(Routes.trial),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _instructions(TrialBooking booking) {
  final date = DateFormat('EEEE d MMMM').format(booking.sessionDate);
  final hours = batchHours(booking.slot);
  final batch = hours == null
      ? 'the ${booking.slot.label} batch'
      : 'the ${booking.slot.label} batch ($hours)';
  return 'Come to the club on $date for $batch. Ask for the coach when you arrive.';
}
