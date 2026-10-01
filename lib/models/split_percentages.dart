/// The four adjustable percentages used to split any amount, plus an
/// optional charity ("Sadaqah" — given in the way of Allah) deduction taken
/// off the top before the four-way split is applied to the remainder.
/// Values are stored as plain percents (e.g. 50 means 50%), not fractions.
class SplitPercentages {
  final double use;
  final double invest;
  final double lifestyle;
  final double emergencyFund;
  final bool charityEnabled;
  final double charityPercent;

  const SplitPercentages({
    required this.use,
    required this.invest,
    required this.lifestyle,
    required this.emergencyFund,
    this.charityEnabled = false,
    this.charityPercent = 5,
  });

  static const defaultSplit = SplitPercentages(
    use: 50,
    invest: 20,
    lifestyle: 20,
    emergencyFund: 10,
    charityEnabled: false,
    charityPercent: 5,
  );

  /// Sum of the four budget-category percentages (these are percentages of
  /// the post-charity remainder, not of the original total, so this should
  /// be checked against 100 regardless of whether charity is enabled).
  double get total => use + invest + lifestyle + emergencyFund;

  bool get sumsToWhole => (total - 100).abs() < 0.01;

  /// The fraction of the original total left after charity is deducted.
  double get remainderFactor => charityEnabled ? (100 - charityPercent) / 100 : 1.0;

  /// Each category's share expressed as a percentage of the *original*
  /// total (not the remainder) — what actually ends up in each bucket once
  /// charity has been taken off the top. Useful for pie charts / labels
  /// that should reflect true proportions of the whole amount.
  Map<String, double> get effectivePercentages {
    final factor = remainderFactor;
    return {
      'charity': charityEnabled ? charityPercent : 0,
      'use': use * factor,
      'invest': invest * factor,
      'lifestyle': lifestyle * factor,
      'emergencyFund': emergencyFund * factor,
    };
  }

  SplitPercentages copyWith({
    double? use,
    double? invest,
    double? lifestyle,
    double? emergencyFund,
    bool? charityEnabled,
    double? charityPercent,
  }) {
    return SplitPercentages(
      use: use ?? this.use,
      invest: invest ?? this.invest,
      lifestyle: lifestyle ?? this.lifestyle,
      emergencyFund: emergencyFund ?? this.emergencyFund,
      charityEnabled: charityEnabled ?? this.charityEnabled,
      charityPercent: charityPercent ?? this.charityPercent,
    );
  }

  Map<String, dynamic> toJson() => {
    'use': use,
    'invest': invest,
    'lifestyle': lifestyle,
    'emergencyFund': emergencyFund,
    'charityEnabled': charityEnabled,
    'charityPercent': charityPercent,
  };

  factory SplitPercentages.fromJson(Map<String, dynamic> json) {
    return SplitPercentages(
      use: (json['use'] as num?)?.toDouble() ?? defaultSplit.use,
      invest: (json['invest'] as num?)?.toDouble() ?? defaultSplit.invest,
      lifestyle: (json['lifestyle'] as num?)?.toDouble() ?? defaultSplit.lifestyle,
      emergencyFund:
      (json['emergencyFund'] as num?)?.toDouble() ?? defaultSplit.emergencyFund,
      // Entries saved before this feature existed won't have these keys —
      // default to charity off, matching prior behavior exactly.
      charityEnabled: json['charityEnabled'] as bool? ?? false,
      charityPercent: (json['charityPercent'] as num?)?.toDouble() ?? 5,
    );
  }
}