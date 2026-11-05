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
    await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
    await tester.enterText(find.byType(TextField).at(1), '12345');
    await _submit(tester);
    expect(find.text('Enter a 10-digit mobile number'), findsOneWidget);
  });

  testWidgets('a server validation message shows in a banner', (tester) async {
    await _pump(tester, _RejectingRepository());
    await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
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
    expect(find.text('Edit trainee'), findsOneWidget);
    expect(find.text('Arjun Reddy'), findsOneWidget);
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
    expect(find.text('Senior, 1000 per month'), findsOneWidget);
  });
}
