/// A single spending entry logged against a specific date and category.
class Expense {
  final String id;
  final DateTime date;
  final String category;
  final double amount;
  final String? note;

  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    this.note,
  });

  /// Date with time stripped, used for calendar day-matching.
  DateTime get day => DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'category': category,
        'amount': amount,
        'note': note,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        category: json['category'] as String,
        amount: (json['amount'] as num).toDouble(),
        note: json['note'] as String?,
      );
}

/// Fixed category list — matches the categories the user tracks.
const List<String> kExpenseCategories = [
  'Kitchen',
  'Grocery',
  'Bills',
  'Qmaeeti',
  'Qist',
  'Donations',
  'Other',
];
