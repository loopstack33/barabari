/// The four adjustable percentages used to split any amount.
/// Values are stored as plain percents (e.g. 50 means 50%), not fractions.
class SplitPercentages {
  final double use;
  final double invest;
  final double lifestyle;
  final double emergencyFund;

  const SplitPercentages({
    required this.use,
    required this.invest,
    required this.lifestyle,
    required this.emergencyFund,
  });

  static const defaultSplit = SplitPercentages(
    use: 50,
    invest: 20,
    lifestyle: 20,
    emergencyFund: 10,
  );

  double get total => use + invest + lifestyle + emergencyFund;

  bool get sumsToWhole => (total - 100).abs() < 0.01;

  SplitPercentages copyWith({
    double? use,
    double? invest,
    double? lifestyle,
    double? emergencyFund,
  }) {
    return SplitPercentages(
      use: use ?? this.use,
      invest: invest ?? this.invest,
      lifestyle: lifestyle ?? this.lifestyle,
      emergencyFund: emergencyFund ?? this.emergencyFund,
    );
  }

  Map<String, dynamic> toJson() => {
    'use': use,
    'invest': invest,
    'lifestyle': lifestyle,
    'emergencyFund': emergencyFund,
  };

  factory SplitPercentages.fromJson(Map<String, dynamic> json) {
    return SplitPercentages(
      use: (json['use'] as num?)?.toDouble() ?? defaultSplit.use,
      invest: (json['invest'] as num?)?.toDouble() ?? defaultSplit.invest,
      lifestyle: (json['lifestyle'] as num?)?.toDouble() ?? defaultSplit.lifestyle,
      emergencyFund:
      (json['emergencyFund'] as num?)?.toDouble() ?? defaultSplit.emergencyFund,
    );
  }
}