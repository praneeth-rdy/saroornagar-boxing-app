/// A training batch; mirrors `public.session_slot`.
enum SessionSlot {
  morning('morning', 'Morning'),
  evening('evening', 'Evening'),
  extra('extra', 'Extra'),
  unknown('unknown', 'Unknown');

  const SessionSlot(this.wire, this.label);

  /// The value Postgres stores.
  final String wire;
  final String label;

  static SessionSlot fromWire(String? value) => values.firstWhere(
    (slot) => slot != unknown && slot.wire == value,
    orElse: () => unknown,
  );
}
