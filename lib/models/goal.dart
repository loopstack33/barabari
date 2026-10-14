/// A single add-funds / withdraw action on a goal.
class GoalTransaction {
  final String id;
  final DateTime date;
  final double amount;
  final bool isDeposit;
  final String? note;

  /// Goal balance right after this action.
  final double balanceAfter;

  GoalTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.isDeposit,
    required this.balanceAfter,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'isDeposit': isDeposit,
        'balanceAfter': balanceAfter,
        'note': note,
      };

  factory GoalTransaction.fromJson(Map<String, dynamic> json) => GoalTransaction(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
        isDeposit: json['isDeposit'] as bool? ?? true,
        balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0,
        note: json['note'] as String?,
      );
}

/// A savings goal the user is contributing towards over time.
class Goal {
  final String id;
  final String name;
  final double target;
  double saved;
  final List<GoalTransaction> transactions;

  Goal({
    required this.id,
    required this.name,
    required this.target,
    this.saved = 0,
    List<GoalTransaction>? transactions,
  }) : transactions = transactions ?? [];

  double get progress {
    if (target <= 0) return 0;
    final p = saved / target;
    return p.clamp(0, 1).toDouble();
  }

  bool get isComplete => saved >= target && target > 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'target': target,
        'saved': saved,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        name: json['name'] as String,
        target: (json['target'] as num).toDouble(),
        saved: (json['saved'] as num).toDouble(),
        transactions: ((json['transactions'] as List?) ?? const [])
            .map((e) => GoalTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
