import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/theme/app_theme.dart';
import 'package:saroornagar_boxing/features/today/domain/roster_entry.dart';
import 'package:saroornagar_boxing/features/today/presentation/roster_row.dart';

const _narrowWidth = 360.0;
const _largeTextScale = 2.0;

Future<void> _pump(WidgetTester tester, RosterEntry entry) async {
  tester.view.physicalSize = const Size(_narrowWidth, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(_narrowWidth, 800),
          textScaler: TextScaler.linear(_largeTextScale),
        ),
        child: Scaffold(
          body: RosterRow(entry: entry, onMark: (_) {}),
        ),
      ),
    ),
  );
}

void main() {
  for (final status in [
    null,
    AttendanceStatus.present,
    AttendanceStatus.absent,
  ]) {
    testWidgets(
      'a long name and status ellipsize at 360 px (${status?.wire ?? 'not marked'})',
      (tester) async {
        await _pump(
          tester,
          RosterEntry(
            traineeId: 't1',
            fullName: 'Venkata Subrahmanya Lakshmi Narasimha Reddy',
            status: status,
            markedAt: status == null ? null : DateTime.utc(2026, 11, 5, 1, 2),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(RosterRow), findsOneWidget);
      },
    );
  }
}
