import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/models/trainee_status.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/trainees/presentation/trainee_detail_screen.dart';
import 'package:saroornagar_boxing/features/trainees/presentation/trainee_providers.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/trainees.dart';
import '../../../support/mocks/mock_trainee_repository.dart';

final _clock = DateTime.utc(2026, 11, 5, 7);

Future<void> _pump(
  WidgetTester tester,
  MockTraineeRepository repository,
  String id, {
  List<ImageSource>? pickedFrom,
}) {
  tester.view.physicalSize = const Size(1600, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  return pumpApp(
    tester,
    overrides: [
      traineeRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(() => _clock),
      photoPickerProvider.overrideWithValue((source) async {
        pickedFrom?.add(source);
        return (bytes: Uint8List.fromList([1, 2, 3]), fileName: 'pick.jpg');
      }),
    ],
    home: TraineeDetailScreen(traineeId: id),
  );
}

void main() {
  testWidgets('shows the profile line, joining date and notes', (tester) async {
    await _pump(
      tester,
      MockTraineeRepository(trainees: [detailTrainee]),
      detailTrainee.id,
    );
    expect(find.text('Arjun Reddy'), findsOneWidget);
    expect(find.text('+91 98765 43210 · Age 14 · Junior'), findsOneWidget);
    expect(find.text('Joined 3 Mar 2026'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('NOTES'), findsOneWidget);
    expect(find.text('No sessions marked yet'), findsOneWidget);
  });

  testWidgets('a bare trainee omits the missing parts', (tester) async {
    await _pump(
      tester,
      MockTraineeRepository(trainees: [bareTrainee]),
      bareTrainee.id,
    );
    expect(find.text('Kiran Rao'), findsOneWidget);
    expect(find.textContaining('Joined'), findsNothing);
    expect(find.textContaining('Age'), findsNothing);
    expect(find.text('NOTES'), findsNothing);
  });

  testWidgets('set inactive asks first, and cancel changes nothing', (
    tester,
  ) async {
    final repository = MockTraineeRepository(trainees: [detailTrainee]);
    await _pump(tester, repository, detailTrainee.id);

    await tester.tap(find.text('Set inactive'));
    await tester.pumpAndSettle();
    expect(find.text('Set Arjun Reddy inactive?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      repository.traineeFor(detailTrainee.id)!.status,
      TraineeStatus.active,
    );
  });

  testWidgets('confirming set inactive updates the trainee and the button', (
    tester,
  ) async {
    final repository = MockTraineeRepository(trainees: [detailTrainee]);
    await _pump(tester, repository, detailTrainee.id);

    await tester.tap(find.text('Set inactive'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set inactive').last);
    await tester.pumpAndSettle();

    expect(
      repository.traineeFor(detailTrainee.id)!.status,
      TraineeStatus.inactive,
    );
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('Set active'), findsOneWidget);
  });

  testWidgets('the photo sheet calls the repository for each action', (
    tester,
  ) async {
    final repository = MockTraineeRepository(trainees: [detailTrainee]);
    final pickedFrom = <ImageSource>[];
    await _pump(tester, repository, detailTrainee.id, pickedFrom: pickedFrom);

    await tester.tap(find.text('AR'));
    await tester.pumpAndSettle();
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
    expect(find.text('Remove'), findsNothing);

    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();
    expect(pickedFrom, [ImageSource.gallery]);
    expect(repository.uploads.single.fileName, 'pick.jpg');
    expect(repository.traineeFor(detailTrainee.id)!.photoPath, isNotNull);

    await tester.tap(find.text('AR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    expect(pickedFrom, [ImageSource.gallery, ImageSource.camera]);

    await tester.tap(find.text('AR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(repository.traineeFor(detailTrainee.id)!.photoPath, isNull);
  });
}
