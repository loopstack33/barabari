/// A pending or paid amount (bill, loan, money owed, etc.) with details.
class Payment {
  final String id;
  final String title;
  final double amount;
  final String? party; // who it is to / from
  final String? details;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final bool isPaid;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
    this.party,
    this.details,
    this.dueDate,
    this.paidDate,
    this.isPaid = false,
  });

  bool get isOverdue {
    if (isPaid || dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate!.isBefore(today);
  }

  Payment copyWith({
    String? title,
    double? amount,
    String? party,
    String? details,
    DateTime? dueDate,
    DateTime? paidDate,
    bool? isPaid,
    bool clearDueDate = false,
    bool clearPaidDate = false,
  }) =>
      Payment(
        id: id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        createdAt: createdAt,
        party: party ?? this.party,
        details: details ?? this.details,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        paidDate: clearPaidDate ? null : (paidDate ?? this.paidDate),
        isPaid: isPaid ?? this.isPaid,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'party': party,
        'details': details,
        'dueDate': dueDate?.toIso8601String(),
        'paidDate': paidDate?.toIso8601String(),
        'isPaid': isPaid,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        party: json['party'] as String?,
        details: json['details'] as String?,
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
        paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate'] as String) : null,
        isPaid: json['isPaid'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
