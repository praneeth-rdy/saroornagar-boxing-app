import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/fees/presentation/attendance_summary_screen.dart';
import '../../features/fees/presentation/fee_status_screen.dart';
import '../../features/fees/presentation/record_payment_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/shell/presentation/shell_screen.dart';
import '../../features/staff/presentation/staff_detail_screen.dart';
import '../../features/staff/presentation/staff_form_screen.dart';
import '../../features/staff/presentation/staff_list_screen.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/trainees/presentation/attendance_history_screen.dart';
import '../../features/trainees/presentation/trainee_detail_screen.dart';
import '../../features/trainees/presentation/trainee_form_screen.dart';
import '../../features/trainees/presentation/trainees_screen.dart';
import '../../features/trials/domain/trial_booking.dart';
import '../../features/trials/presentation/book_trial_screen.dart';
import '../../features/trials/presentation/trial_booked_screen.dart';
import '../../features/trials/presentation/trials_screen.dart';
import '../di/repository_providers.dart';
import 'route_guards.dart';
import 'routes.dart';

/// The app's router; built once and re-run through the guard on every session change.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<bool>(
    ref.read(authRepositoryProvider).hasSession,
  );
  ref.listen<AsyncValue<bool>>(sessionProvider, (_, next) {
    final hasSession = next.value;
    if (hasSession != null) session.value = hasSession;
  });

  final router = GoRouter(
    initialLocation: Routes.today,
    refreshListenable: session,
    redirect: (_, state) =>
        redirectFor(hasSession: session.value, location: state.uri.path),
    routes: [
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      _trialRoute,
      _recordPaymentRoute,
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
        branches: [
          _branch(Routes.today, const TodayScreen()),
          _traineesBranch,
          _branch(Routes.trials, const TrialsScreen()),
          _moreBranch,
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, _) => screen)],
);

// Nested so a detail, form or history screen keeps the list beneath it; the full paths
// are Routes.traineeNew, traineeDetail, traineeEdit and traineeHistory.
final _traineesBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.trainees,
      builder: (_, _) => const TraineesScreen(),
      routes: [
        // Before ':id' so "new" is never read as a trainee id.
        GoRoute(path: 'new', builder: (_, _) => const TraineeFormScreen()),
        GoRoute(
          path: ':id',
          builder: (_, state) =>
              TraineeDetailScreen(traineeId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (_, state) =>
                  TraineeFormScreen(traineeId: state.pathParameters['id']),
            ),
            GoRoute(
              path: 'history',
              builder: (_, state) => AttendanceHistoryScreen(
                traineeId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

// Full paths Routes.feeStatus, attendanceSummary and the staff routes; each keeps More
// beneath it.
final _moreBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.more,
      builder: (_, _) => const MoreScreen(),
      routes: [
        GoRoute(path: 'fees', builder: (_, _) => const FeeStatusScreen()),
        GoRoute(
          path: 'attendance',
          builder: (_, _) => const AttendanceSummaryScreen(),
        ),
        GoRoute(
          path: 'staff',
          builder: (_, _) => const StaffListScreen(),
          routes: [
            // Before ':id' so "new" is never read as a staff id.
            GoRoute(path: 'new', builder: (_, _) => const StaffFormScreen()),
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  StaffDetailScreen(userId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, state) =>
                      StaffFormScreen(userId: state.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

// Outside the shell and before it, so a push from the trainee detail (Trainees tab) and
// from the fee status (More tab) both land on top of the screen that pushed it.
final _recordPaymentRoute = GoRoute(
  path: Routes.recordPayment,
  builder: (_, state) => RecordPaymentScreen(
    traineeId: state.pathParameters['id']!,
    month: _monthParameter(state.uri.queryParameters['month']),
  ),
);

DateTime? _monthParameter(String? value) {
  final date = value == null ? null : DateTime.tryParse(value);
  return date == null ? null : DateTime(date.year, date.month);
}

// Public, outside the shell; the full path of 'booked' is Routes.trialBooked.
final _trialRoute = GoRoute(
  path: Routes.trial,
  builder: (_, _) => const BookTrialScreen(),
  routes: [
    GoRoute(
      path: 'booked',
      // The booking travels as `extra`, which a cold start or deep link does not carry.
      redirect: (_, state) => state.extra is TrialBooking ? null : Routes.trial,
      builder: (_, state) =>
          TrialBookedScreen(booking: state.extra! as TrialBooking),
    ),
  ],
);
