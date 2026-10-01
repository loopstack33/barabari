import 'split_percentages.dart';

/// A computed split of an amount using a given [SplitPercentages]. If
/// charity is enabled on the split, [charity] is taken off the top first,
/// and use/invest/lifestyle/emergencyFund are computed from what's left —
/// so those four automatically shrink to fit the smaller remainder.
class Breakdown {
  final double use;
  final double invest;
  final double lifestyle;
  final double emergencyFund;
  final double charity;
  final double total;

  const Breakdown({
    required this.use,
    required this.invest,
    required this.lifestyle,
    required this.emergencyFund,
    this.charity = 0,
    required this.total,
  });

  factory Breakdown.fromAmount(double amount, [SplitPercentages? split]) {
    final s = split ?? SplitPercentages.defaultSplit;
    final charityAmount = s.charityEnabled ? amount * (s.charityPercent / 100) : 0.0;
    final remainder = amount - charityAmount;
    return Breakdown(
      use: remainder * (s.use / 100),
      invest: remainder * (s.invest / 100),
      lifestyle: remainder * (s.lifestyle / 100),
      emergencyFund: remainder * (s.emergencyFund / 100),
      charity: charityAmount,
      total: amount,
    );
  }

  static const zero = Breakdown(use: 0, invest: 0, lifestyle: 0, emergencyFund: 0, charity: 0, total: 0);

  Breakdown operator +(Breakdown other) {
    return Breakdown(
      use: use + other.use,
      invest: invest + other.invest,
      lifestyle: lifestyle + other.lifestyle,
      emergencyFund: emergencyFund + other.emergencyFund,
      charity: charity + other.charity,
      total: total + other.total,
    );
  }
}