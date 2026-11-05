import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/list_row.dart';
import '../domain/attendance_day.dart';

/// One attended date and the batches the student was present in.
class AttendanceDayRow extends StatelessWidget {
  const AttendanceDayRow({super.key, required this.day});

  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    return ListRow(
      title: DateFormat('EEE d MMM').format(day.date),
      subtitle: day.label,
    );
  }
}
