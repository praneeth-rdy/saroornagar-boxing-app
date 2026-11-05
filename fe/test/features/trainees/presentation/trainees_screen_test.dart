import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/features/trainees/presentation/trainees_screen.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/trainees.dart';
import '../../../support/mocks/mock_trainee_repository.dart';
import '../../../support/scenario.dart';

Future<void> _pump(WidgetTester tester, MockTraineeRepository repository) {
  tester.view.physicalSize = const Size(1600, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  return pumpApp(
    tester,
    overrides: [traineeRepositoryProvider.overrideWithValue(repository)],
    home: const TraineesScreen(),
  );
}

void main() {
  testWidgets('search filters by name and by phone digits', (tester) async {
    await _pump(
      tester,
      MockTraineeRepository(trainees: [detailTrainee, bareTrainee]),
    );
    expect(find.text('Arjun Reddy'), findsOneWidget);
    expect(find.text('Kiran Rao'), findsOneWidget);
    expect(find.text('No phone'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'arj');
    await tester.pumpAndSettle();
    expect(find.text('Arjun Reddy'), findsOneWidget);
    expect(find.text('Kiran Rao'), findsNothing);

    await tester.enterText(find.byType(TextField), '98765 43210');
    await tester.pumpAndSettle();
    expect(find.text('Arjun Reddy'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No one matches'), findsOneWidget);

    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Kiran Rao'), findsOneWidget);
  });

  testWidgets('the Inactive filter lists only inactive trainees', (
    tester,
  ) async {
    await _pump(
      tester,
      MockTraineeRepository(trainees: [detailTrainee, inactiveTraineeRow]),
    );
    expect(find.text('Arjun Reddy'), findsOneWidget);
    expect(find.text('Kiran Rao'), findsNothing);

    await tester.tap(find.text('Inactive'));
    await tester.pumpAndSettle();
    expect(find.text('Kiran Rao'), findsOneWidget);
    expect(find.text('Arjun Reddy'), findsNothing);
  });

  testWidgets('an empty roster offers to add the first trainee', (
    tester,
  ) async {
    await _pump(tester, MockTraineeRepository());
    expect(find.text('No students yet'), findsOneWidget);
    expect(
      find.text('Add the first student to start marking attendance.'),
      findsOneWidget,
    );
    expect(find.text('Add student'), findsOneWidget);
  });

  testWidgets('permission denied shows the denied view', (tester) async {
    await _pump(
      tester,
      MockTraineeRepository(scenario: MockScenario.permissionDenied),
    );
    expect(find.text('Students'), findsOneWidget);
    expect(find.text('Arjun Reddy'), findsNothing);
  });
}
