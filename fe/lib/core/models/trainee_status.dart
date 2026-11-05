/// Whether a trainee is on the active roster; mirrors `public.trainee_status`.
enum TraineeStatus {
  active('active'),
  inactive('inactive'),
  unknown('unknown');

  const TraineeStatus(this.wire);

  /// The value Postgres stores.
  final String wire;

  static TraineeStatus fromWire(String? value) => values.firstWhere(
    (item) => item != unknown && item.wire == value,
    orElse: () => unknown,
  );
}
