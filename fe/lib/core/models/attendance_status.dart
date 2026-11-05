/// A trainee's mark for one session; mirrors `public.attendance_status`.
enum AttendanceStatus {
  present('present'),
  absent('absent'),
  unknown('unknown');

  const AttendanceStatus(this.wire);

  /// The value Postgres stores.
  final String wire;

  static AttendanceStatus fromWire(String? value) => values.firstWhere(
    (item) => item != unknown && item.wire == value,
    orElse: () => unknown,
  );
}
