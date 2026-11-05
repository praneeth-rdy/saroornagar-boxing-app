import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee_input.dart';
import 'package:saroornagar_boxing/features/trainees/presentation/trainee_form_screen.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/trainees.dart';
import '../../../support/mocks/mock_trainee_repository.dart';
import '../../../support/scenario.dart';

class _RejectingRepository extends MockTraineeRepository {
  @override
  Future<Trainee> create(TraineeInput input) =>
      Future.error(const ValidationException('Enter a valid date of birth'));
}

Future<void> _pump(
  WidgetTester tester,
  MockTraineeRepository repository, {
  String? traineeId,
}) {
  tester.view.physicalSize = const Size(1600, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  return pumpApp(
    tester,
    overrides: [
      traineeRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 5, 7)),
    ],
    home: TraineeFormScreen(traineeId: traineeId),
  );
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.byType(PrimaryButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'submitting an empty form shows the name error and saves nothing',
    (tester) async {
      final repository = MockTraineeRepository();
      await _pump(tester, repository);
      expect(
        find.text('Enter a name between 2 and 80 characters'),
        findsNothing,
      );

      await _submit(tester);

      expect(
        find.text('Enter a name between 2 and 80 characters'),
        findsOneWidget,
      );
      expect(repository.traineeFor('trainee-new-1'), isNull);
    },
  );

  testWidgets('a short phone number shows the phone error', (tester) async {
    await _pump(tester, MockTraineeRepository());
    await tester.enterText(find.byType(TextField).at(1), 'Asha Rao');
    await tester.enterText(find.byType(TextField).at(2), '12345');
    await _submit(tester);
    expect(find.text('Enter a 10-digit mobile number'), findsOneWidget);
  });

  testWidgets('add prefills the suggested roll number, gaps first', (
    tester,
  ) async {
    await _pump(
      tester,
      MockTraineeRepository(
        trainees: [
          detailTrainee.copyWith(id: 'one', rollNo: 1),
          detailTrainee,
        ],
      ),
    );
    expect(find.text('Roll number *'), findsOneWidget);
    expect(find.widgetWithText(TextField, '2'), findsOneWidget);
  });

  testWidgets('a roll number in use shows the server message in a banner', (
    tester,
  ) async {
    final repository = MockTraineeRepository(trainees: [detailTrainee]);
    await _pump(tester, repository);
    await tester.enterText(find.byType(TextField).at(0), '12');
    await tester.enterText(find.byType(TextField).at(1), 'Asha Rao');
    await _submit(tester);
    expect(find.text('Roll number 12 is already in use'), findsOneWidget);
    expect(repository.traineeFor('trainee-new-1'), isNull);
  });

  testWidgets('a roll number of 0 shows the field error', (tester) async {
    await _pump(tester, MockTraineeRepository());
    await tester.enterText(find.byType(TextField).at(0), '0');
    await tester.enterText(find.byType(TextField).at(1), 'Asha Rao');
    await _submit(tester);
    expect(find.text('Enter a roll number above 0'), findsOneWidget);
  });

  testWidgets('a failed suggestion leaves the field empty with a banner', (
    tester,
  ) async {
    await _pump(tester, MockTraineeRepository(scenario: MockScenario.offline));
    expect(find.text(OfflineException.defaultMessage), findsOneWidget);
    expect(find.widgetWithText(TextField, '1'), findsNothing);
  });

  testWidgets('a server validation message shows in a banner', (tester) async {
    await _pump(tester, _RejectingRepository());
    await tester.enterText(find.byType(TextField).at(1), 'Asha Rao');
    await _submit(tester);
    expect(find.text('Enter a valid date of birth'), findsOneWidget);
  });

  testWidgets('edit prefills the fields with the phone as ten digits', (
    tester,
  ) async {
    await _pump(
      tester,
      MockTraineeRepository(trainees: [detailTrainee]),
      traineeId: detailTrainee.id,
    );
    expect(find.text('Edit student'), findsOneWidget);
    expect(find.text('Arjun Reddy'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
    expect(find.text('14 Mar 2012'), findsOneWidget);
    expect(find.text('Junior, 500 per month'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('a senior date of birth shows the senior tier', (tester) async {
    final senior = detailTrainee.copyWith(dateOfBirth: DateTime(2000, 1, 1));
    await _pump(
      tester,
      MockTraineeRepository(trainees: [senior]),
      traineeId: senior.id,
    );
    expect(find.text('Senior, 800 per month'), findsOneWidget);
  });
  testWidgets('add shows name and phone with the details collapsed', (
    tester,
  ) async {
    await _pump(tester, MockTraineeRepository());

    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Add more details'), findsOneWidget);
    expect(find.text('Date of birth'), findsNothing);
    expect(find.text('Joined on'), findsNothing);
    expect(find.text('Notes'), findsNothing);
  });

  testWidgets('add more details reveals date of birth, joined on and notes', (
    tester,
  ) async {
    await _pump(tester, MockTraineeRepository());

    await tester.tap(find.text('Add more details'));
    await tester.pumpAndSettle();

    expect(find.text('Date of birth'), findsOneWidget);
    expect(find.text('Joined on'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Add more details'), findsNothing);
  });

  testWidgets(
    'edit opens with the details expanded when a date of birth is set',
    (tester) async {
      await _pump(
        tester,
        MockTraineeRepository(trainees: [detailTrainee]),
        traineeId: detailTrainee.id,
      );

      expect(find.text('Date of birth'), findsOneWidget);
      expect(find.text('Add more details'), findsNothing);
    },
  );

  testWidgets('edit of a student with no details keeps them collapsed', (
    tester,
  ) async {
    await _pump(
      tester,
      MockTraineeRepository(trainees: [bareTrainee]),
      traineeId: bareTrainee.id,
    );

    expect(find.text('Add more details'), findsOneWidget);
    expect(find.text('Date of birth'), findsNothing);
  });
}
