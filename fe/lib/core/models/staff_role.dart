/// A staff member's role; mirrors `public.staff_role`.
enum StaffRole {
  admin('admin'),
  coach('coach'),
  unknown('unknown');

  const StaffRole(this.wire);

  /// The value Postgres stores.
  final String wire;

  static StaffRole fromWire(String? value) => values.firstWhere(
    (item) => item != unknown && item.wire == value,
    orElse: () => unknown,
  );
}
