/// The platform's marketplace take rate.
///
/// The fee is **embedded in the listed price**: the customer only ever sees the
/// final price. GoTattoo keeps this share of every sale and the artist receives
/// the rest — the breakdown is shown to the artist at registration time only.
/// Kept in one place so the artist form and any future payment integration stay
/// in sync. See ROADMAP.md.
abstract class PlatformFee {
  /// 3% — configurable.
  static const double rate = 0.03;

  /// The platform's cut taken out of a listed [price].
  static double on(double price) => price * rate;

  /// What the artist receives from a listed [price] (price minus the fee).
  static double artistPayout(double price) => price - on(price);

  /// Human-friendly percent label, e.g. "3%".
  static String get label => '${(rate * 100).toStringAsFixed(0)}%';
}
