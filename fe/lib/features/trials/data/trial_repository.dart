import '../domain/trial_booking.dart';
import '../domain/trial_request.dart';

/// Trial bookings; failures surface as `AppException`s.
abstract class TrialRepository {
  /// Books a trial for the visitor on this device (`book_trial`, open to anon).
  Future<TrialBooking> book(TrialRequest request, String deviceKey);

  /// This device's bookings from today on (`my_trial_bookings`, open to anon).
  Future<List<TrialBooking>> mine(String deviceKey);

  /// Every booking from [from] to [to] inclusive, for staff (`trial_bookings_between`).
  Future<List<TrialBooking>> between(DateTime from, DateTime to);
}
