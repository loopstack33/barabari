import 'split_percentages.dart';

/// A computed 4-way split of an amount using a given [SplitPercentages].
class Breakdown {
  final double use;
  final double invest;
  final double lifestyle;
  final double emergencyFund;
  final double total;

  const Breakdown({
    required this.use,
    required this.invest,
    required this.lifestyle,
    required this.emergencyFund,
    required this.total,
  });

  factory Breakdown.fromAmount(double amount, [SplitPercentages? split]) {
    final s = split ?? SplitPercentages.defaultSplit;
    return Breakdown(
      use: amount * (s.use / 100),
      invest: amount * (s.invest / 100),
      lifestyle: amount * (s.lifestyle / 100),
      emergencyFund: amount * (s.emergencyFund / 100),
      total: amount,
    );
  }

  static const zero = Breakdown(use: 0, invest: 0, lifestyle: 0, emergencyFund: 0, total: 0);

  Breakdown operator +(Breakdown other) {
    return Breakdown(
      use: use + other.use,
      invest: invest + other.invest,
      lifestyle: lifestyle + other.lifestyle,
      emergencyFund: emergencyFund + other.emergencyFund,
      total: total + other.total,
    );
  }
}
