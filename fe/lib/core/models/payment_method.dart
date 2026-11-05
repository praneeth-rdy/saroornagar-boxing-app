/// How a fee was paid; mirrors `public.payment_method`.
enum PaymentMethod {
  cash('cash'),
  upi('upi'),
  unknown('unknown');

  const PaymentMethod(this.wire);

  /// The value Postgres stores.
  final String wire;

  static PaymentMethod fromWire(String? value) => values.firstWhere(
    (item) => item != unknown && item.wire == value,
    orElse: () => unknown,
  );
}
