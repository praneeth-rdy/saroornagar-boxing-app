import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/trainees/domain/attendance_record.dart';
import 'package:saroornagar_boxing/features/trainees/presentation/attendance_history_screen.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/trainees.dart';
import '../../../support/mocks/mock_trainee_repository.dart';

AttendanceRecord _record(
  DateTime date,
  SessionSlot slot, {
  AttendanceStatus status = AttendanceStatus.present,
}) => AttendanceRecord(
  sessionId: '${date.month}-${date.day}-${slot.wire}',
  sessionDate: date,
  slot: slot,
  status: status,
  markedAt: DateTime.utc(date.year, date.month, date.day, 1),
);

final _history = {
  detailTrainee.id: [
    _record(DateTime(2026, 11, 4), SessionSlot.morning),
    _record(DateTime(2026, 10, 15), SessionSlot.evening),
    _record(DateTime(2026, 10, 15), SessionSlot.morning),
    _record(DateTime(2026, 10, 14), SessionSlot.morning),
    _record(
      DateTime(2026, 10, 13),
      SessionSlot.morning,
      status: AttendanceStatus.absent,
    ),
  ],
};

Future<void> _pump(WidgetTester tester, {DateTime? month}) {
  tester.view.physicalSize = const Size(1600, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  return pumpApp(
    tester,
    overrides: [
      traineeRepositoryProvider.overrideWithValue(
        MockTraineeRepository(trainees: [detailTrainee], history: _history),
      ),
      clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 5, 7)),
    ],
    home: AttendanceHistoryScreen(traineeId: detailTrainee.id, month: month),
  );
}

void main() {
  testWidgets('opens on the month it is given, one row per attended date', (
    tester,
  ) async {
    await _pump(tester, month: DateTime(2026, 10));

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('3 classes attended'), findsOneWidget);
    expect(find.text('Thu 15 Oct'), findsOneWidget);
    expect(find.text('Morning and evening'), findsOneWidget);
    expect(find.text('Wed 14 Oct'), findsOneWidget);
    expect(find.text('Tue 13 Oct'), findsNothing);
  });

  testWidgets('without a month it opens on the current month', (tester) async {
    await _pump(tester);

    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('1 class attended'), findsOneWidget);
  });

  testWidgets('a future month opens on the current month', (tester) async {
    await _pump(tester, month: DateTime(2027, 1));

    expect(find.text('November 2026'), findsOneWidget);
  });
}
