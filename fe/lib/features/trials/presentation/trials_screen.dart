import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/state_views.dart';
import '../../today/presentation/today_providers.dart';
import '../domain/trial_booking.dart';
import 'trial_providers.dart';

/// Staff tab: every trial visitor booked for the next 30 days, by day.
class TrialsScreen extends ConsumerWidget {
  const TrialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = dateOnly(ref.watch(clockProvider)());
    // Pushed so the staff member returns to this tab from the public form.
    void bookForSomeone() => context.push(Routes.trial).ignore();
    Future<void> refresh() => ref.refresh(upcomingTrialsProvider.future);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trials'),
        actions: [
          LinkButton(label: 'Book for someone', onPressed: bookForSomeone),
        ],
      ),
      body: AsyncValueView<List<TrialBooking>>(
        value: ref.watch(upcomingTrialsProvider),
        onRetry: () => ref.invalidate(upcomingTrialsProvider),
        isEmpty: (bookings) => bookings.isEmpty,
        empty: _Refreshable(
          onRefresh: refresh,
          child: EmptyView(
            title: 'No trials booked',
            message:
                'Bookings made in the app appear here for the next 30 days.',
            actionLabel: 'Book for someone',
            onAction: bookForSomeone,
          ),
        ),
        data: (bookings) => RefreshIndicator(
          onRefresh: refresh,
          child: _TrialDays(days: trialsByDay(bookings), today: today),
        ),
      ),
    );
  }
}

class _TrialDays extends StatelessWidget {
  const _TrialDays({required this.days, required this.today});

  final Map<DateTime, List<TrialBooking>> days;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final dates = days.keys.toList();
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      itemCount: dates.length,
      itemBuilder: (_, index) => _TrialDay(
        date: dates[index],
        bookings: days[dates[index]]!,
        isToday: dates[index] == today,
        isFirst: index == 0,
      ),
    );
  }
}

class _TrialDay extends StatelessWidget {
  const _TrialDay({
    required this.date,
    required this.bookings,
    required this.isToday,
    required this.isFirst,
  });

  final DateTime date;
  final List<TrialBooking> bookings;
  final bool isToday;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Eyebrow(isToday ? 'TODAY' : DateFormat('EEEE d MMMM').format(date)),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: ListRow.divide([
                for (final booking in bookings)
                  ListRow(
                    title: booking.fullName,
                    subtitle: _detailsOf(booking),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lets a view that does not scroll, such as the empty state, take a pull to refresh.
class _Refreshable extends StatelessWidget {
  const _Refreshable({required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (_, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// `Morning · +91 98765 43210`, then the age or birth date and the note on a second line.
String _detailsOf(TrialBooking booking) {
  final summary = '${booking.slot.label} · ${formatPhone(booking.phone)}';
  final dateOfBirth = booking.dateOfBirth;
  final age = booking.age;
  final note = booking.note;
  final extras = [
    if (age != null)
      'Age $age'
    else if (dateOfBirth != null)
      'Born ${DateFormat('d MMM yyyy').format(dateOfBirth)}',
    ?note,
  ];
  return extras.isEmpty ? summary : '$summary\n${extras.join(' · ')}';
}
