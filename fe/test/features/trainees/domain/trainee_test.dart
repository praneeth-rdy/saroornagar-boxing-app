import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';

import '../../../support/fixtures/trainees.dart';

Trainee _born(DateTime? dateOfBirth, {String name = 'Arjun Reddy'}) =>
    detailTrainee.copyWith(dateOfBirth: dateOfBirth, fullName: name);

void main() {
  group('ageOn and feeTierOn', () {
    final dateOfBirth = DateTime(2011, 11, 5);

    test('the day before the 15th birthday is 14 and junior', () {
      final trainee = _born(dateOfBirth);
      final eve = DateTime(2026, 11, 4);
      expect(trainee.ageOn(eve), 14);
      expect(trainee.feeTierOn(eve), 500);
    });

    test('the 15th birthday is 15 and senior', () {
      final trainee = _born(dateOfBirth);
      final birthday = DateTime(2026, 11, 5);
      expect(trainee.ageOn(birthday), 15);
      expect(trainee.feeTierOn(birthday), 800);
    });

    test('a leap-day birth has not had the birthday on 28 February', () {
      final trainee = _born(DateTime(2012, 2, 29));
      expect(trainee.ageOn(DateTime(2027, 2, 28)), 14);
      expect(trainee.ageOn(DateTime(2027, 3, 1)), 15);
    });

    test('no date of birth gives a null age and tier', () {
      final trainee = _born(null);
      expect(trainee.ageOn(DateTime(2026, 11, 5)), isNull);
      expect(trainee.feeTierOn(DateTime(2026, 11, 5)), isNull);
      expect(trainee.feeTier, isNull);
    });
  });

  test('feeTierLabel names the two tiers', () {
    expect(feeTierLabel(500), 'Junior');
    expect(feeTierLabel(800), 'Senior');
  });

  group('initials', () {
    test('first and last word, upper-cased', () {
      expect(_born(null, name: 'arjun reddy').initials, 'AR');
      expect(_born(null, name: 'Venkata Satya Narayana').initials, 'VN');
    });

    test('a single word gives one letter', () {
      expect(_born(null, name: 'Kiran').initials, 'K');
    });

    test('extra spaces are ignored', () {
      expect(_born(null, name: '  Kiran   Rao ').initials, 'KR');
    });
  });

  test('json round-trips the wire names and dates', () {
    final json = detailTrainee.toJson();
    expect(json['full_name'], 'Arjun Reddy');
    expect(json['date_of_birth'], '2012-03-14');
    expect(json['status'], 'active');
    expect(Trainee.fromJson(json), detailTrainee);
  });
}
