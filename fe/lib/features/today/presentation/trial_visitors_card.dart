import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/list_row.dart';
import '../../trials/domain/trial_booking.dart';

/// The trial visitors booked into the session on screen.
class TrialVisitorsCard extends StatelessWidget {
  const TrialVisitorsCard({super.key, required this.bookings});

  final List<TrialBooking> bookings;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Eyebrow('Trial visitors'),
          ),
          ...ListRow.divide([
            for (final booking in bookings)
              ListRow(
                leading: AvatarInitials(name: booking.fullName),
                title: booking.fullName,
                subtitle: _detailsOf(booking),
              ),
          ]),
        ],
      ),
    );
  }
}

String _detailsOf(TrialBooking booking) {
  final dateOfBirth = booking.dateOfBirth;
  final age = booking.age;
  final details = [
    formatPhone(booking.phone),
    if (age != null)
      'Age $age'
    else if (dateOfBirth != null)
      'DOB ${DateFormat('d MMM yyyy').format(dateOfBirth)}',
  ].join(', ');
  final note = booking.note;
  return note == null ? details : '$details\n$note';
}
