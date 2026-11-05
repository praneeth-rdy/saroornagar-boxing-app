import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/models/trainee_status.dart';
import 'package:saroornagar_boxing/core/widgets/link_button.dart';
import 'package:saroornagar_boxing/core/widgets/list_row.dart';
import 'package:saroornagar_boxing/features/fees/domain/fee_status.dart';
import 'package:saroornagar_boxing/features/fees/presentation/fee_status_screen.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/fees.dart';
import '../../../support/mocks/mock_fee_repository.dart';
import '../../../support/scenario.dart';

final _clock = DateTime.utc(2026, 11, 5, 7);
final _created = DateTime.utc(2026, 1, 10, 4, 30);

Trainee _trainee(String id, String name, DateTime? dob) => Trainee(
  id: id,
  fullName: name,
  dateOfBirth: dob,
  status: TraineeStatus.active,
  createdAt: _created,
  updatedAt: _created,
);

Future<void> _pump(WidgetTester tester, MockFeeRepository repository) {
  tester.view.physicalSize = const Size(1600, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  return pumpApp(
    tester,
    overrides: [
      feeRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(() => _clock),
    ],
    home: const FeeStatusScreen(),
  );
}

void main() {
  group('feeStatusSubtitle', () {
    test('covers every variant', () {
      FeeStatus status({int? tier, int paid = 0, DateTime? on}) => FeeStatus(
        traineeId: 't',
        fullName: 'n',
        tierAmount: tier,
        paidAmount: paid,
        lastPaidOn: on,
      );
      expect(
        feeStatusSubtitle(
          status(tier: 800, paid: 800, on: DateTime(2026, 11, 3)),
        ),
        'Paid 800 on 3 Nov',
      );
      expect(
        feeStatusSubtitle(status(tier: 800, paid: 500)),
        'Partly paid 500 of 800',
      );
      expect(feeStatusSubtitle(status(tier: 800)), 'Unpaid · 800 due');
      expect(feeStatusSubtitle(status()), 'No date of birth, tier unknown');
      expect(feeStatusSubtitle(status(paid: 700)), 'Paid 700');
    });
  });

  testWidgets(
    'lists the variants, unpaid first, with counts and Record links',
    (tester) async {
      final repository = MockFeeRepository(
        trainees: [
          _trainee('a', 'Asha Paid', DateTime(1998, 1, 1)),
          _trainee('b', 'Bala Partly', DateTime(1998, 1, 1)),
          _trainee('c', 'Chitra Unpaid', DateTime(1998, 1, 1)),
          _trainee('d', 'Dev Unknown', null),
        ],
        payments: [
          fixturePayment(
            id: 'p1',
            traineeId: 'a',
            amount: 800,
            paidOn: DateTime(2026, 11, 3),
          ),
          fixturePayment(id: 'p2', traineeId: 'b', amount: 500),
        ],
        clock: () => _clock,
      );
      await _pump(tester, repository);

      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('2 unpaid · 2 paid'), findsOneWidget);
      expect(find.text('Paid 800 on 3 Nov'), findsOneWidget);
      expect(find.text('Partly paid 500 of 800'), findsOneWidget);
      expect(find.text('Unpaid · 800 due'), findsOneWidget);
      expect(find.text('No date of birth, tier unknown'), findsOneWidget);
      // Everyone but the fully paid row still owes, so offers Record.
      expect(find.widgetWithText(LinkButton, 'Record'), findsNWidgets(3));
      // Unpaid first.
      expect(
        tester.getTopLeft(find.text('Chitra Unpaid')).dy,
        lessThan(tester.getTopLeft(find.text('Asha Paid')).dy),
      );
    },
  );

  testWidgets('Record shows while something is owed, partly paid included', (
    tester,
  ) async {
    final repository = MockFeeRepository(
      trainees: [
        _trainee('a', 'Asha Paid', DateTime(1998, 1, 1)),
        _trainee('b', 'Bala Partly', DateTime(1998, 1, 1)),
        _trainee('c', 'Chitra Unpaid', DateTime(1998, 1, 1)),
        _trainee('d', 'Dev Tierless Paid', null),
        _trainee('e', 'Esha Tierless Unpaid', null),
      ],
      payments: [
        fixturePayment(id: 'p1', traineeId: 'a', amount: 800),
        fixturePayment(id: 'p2', traineeId: 'b', amount: 500),
        fixturePayment(id: 'p3', traineeId: 'd', amount: 700),
      ],
      clock: () => _clock,
    );
    await _pump(tester, repository);

    Finder recordIn(String name) => find.descendant(
      of: find.ancestor(of: find.text(name), matching: find.byType(ListRow)),
      matching: find.widgetWithText(LinkButton, 'Record'),
    );
    expect(recordIn('Asha Paid'), findsNothing);
    expect(recordIn('Bala Partly'), findsOneWidget);
    expect(recordIn('Chitra Unpaid'), findsOneWidget);
    expect(recordIn('Dev Tierless Paid'), findsNothing);
    expect(recordIn('Esha Tierless Unpaid'), findsOneWidget);
    // The caption still counts any payment as paid.
    expect(find.text('2 unpaid · 3 paid'), findsOneWidget);
  });

  testWidgets('next month is disabled and previous shows the earlier month', (
    tester,
  ) async {
    await _pump(
      tester,
      MockFeeRepository(
        trainees: [_trainee('a', 'Asha Paid', DateTime(1998, 1, 1))],
        clock: () => _clock,
      ),
    );
    final next = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Next month'),
        matching: find.byType(IconButton),
      ),
    );
    expect(next.onPressed, isNull);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('1 unpaid · 0 paid'), findsOneWidget);
  });

  testWidgets('shows the empty state with a next action', (tester) async {
    await _pump(
      tester,
      MockFeeRepository(scenario: MockScenario.empty, clock: () => _clock),
    );
    expect(find.text('No active students'), findsOneWidget);
    expect(find.text('Fee status lists active students.'), findsOneWidget);
    expect(find.text('Go to Students'), findsOneWidget);
  });

  testWidgets('a failed load shows a retry', (tester) async {
    await _pump(
      tester,
      MockFeeRepository(scenario: MockScenario.offline, clock: () => _clock),
    );
    expect(find.text('Try again'), findsOneWidget);
  });
}
