import 'split_percentages.dart';

/// One saved month's snapshot: gross salary and perks at the time it was
/// saved, along with the split percentages that were active then — so
/// changing your split later doesn't retroactively rewrite past months.
class BudgetEntry {
  final String id;
  final DateTime date;
  final double gross;
  final double perks;
  final SplitPercentages split;

  BudgetEntry({
    required this.id,
    required this.date,
    required this.gross,
    required this.perks,
    required this.split,
  });

  double get total => gross + perks;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'gross': gross,
    'perks': perks,
    'split': split.toJson(),
  };

  factory BudgetEntry.fromJson(Map<String, dynamic> json) => BudgetEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    gross: (json['gross'] as num).toDouble(),
    perks: (json['perks'] as num).toDouble(),
    // Entries saved before this feature existed won't have a 'split' key —
    // fall back to the original fixed split so old history stays accurate.
    split: json['split'] != null
        ? SplitPercentages.fromJson(json['split'] as Map<String, dynamic>)
        : SplitPercentages.defaultSplit,
  );
}