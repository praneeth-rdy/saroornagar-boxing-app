import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/attendance_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/list_row.dart';
import '../domain/attendance_record.dart';

/// One session's mark: date, batch and the status.
class AttendanceRecordRow extends StatelessWidget {
  const AttendanceRecordRow({super.key, required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    return ListRow(
      title: DateFormat('EEE d MMM').format(record.sessionDate),
      subtitle: record.slot.label,
      trailing: switch (record.status) {
        AttendanceStatus.present => Text(
          'Present',
          style: AppTypography.label.copyWith(
            color: AppColors.positive,
            fontWeight: FontWeight.w600,
          ),
        ),
        AttendanceStatus.absent => const Text(
          'Absent',
          style: AppTypography.label,
        ),
        AttendanceStatus.unknown => const Text(
          'Marked',
          style: AppTypography.caption,
        ),
      },
    );
  }
}
