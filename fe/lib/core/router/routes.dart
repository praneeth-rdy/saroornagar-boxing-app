import '../utils/india_date.dart';

/// Route paths; screens navigate by these names, never by string literals.
abstract final class Routes {
  static const signIn = '/sign-in';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const today = '/today';
  static const trainees = '/trainees';
  static const traineeNew = '/trainees/new';
  static const traineeDetail = '/trainees/:id';
  static const traineeEdit = '/trainees/:id/edit';
  static const traineeHistory = '/trainees/:id/history';
  static const recordPayment = '/trainees/:id/pay';
  static const trials = '/trials';
  static const more = '/more';
  static const feeStatus = '/more/fees';
  static const attendanceSummary = '/more/attendance';
  static const staff = '/more/staff';
  static const staffNew = '/more/staff/new';
  static const staffDetail = '/more/staff/:id';
  static const staffEdit = '/more/staff/:id/edit';
  static const trial = '/trial';
  static const trialBooked = '/trial/booked';

  static String traineeDetailOf(String id) => '$trainees/$id';
  static String traineeEditOf(String id) => '$trainees/$id/edit';

  /// [month] (a first of the month) travels as `?month=YYYY-MM-DD` to open on that month.
  static String traineeHistoryOf(String id, {DateTime? month}) => Uri(
    path: '$trainees/$id/history',
    queryParameters: month == null ? null : {'month': wireDate(month)},
  ).toString();

  static String staffDetailOf(String id) => '$staff/$id';
  static String staffEditOf(String id) => '$staff/$id/edit';

  /// [month] (a first of the month) travels as `?month=YYYY-MM-DD` to preselect the period.
  static String recordPaymentOf(String id, {DateTime? month}) => Uri(
    path: '$trainees/$id/pay',
    queryParameters: month == null ? null : {'month': wireDate(month)},
  ).toString();
}
