/// A savings goal the user is contributing towards over time.
class Goal {
  final String id;
  final String name;
  final double target;
  double saved;

  Goal({
    required this.id,
    required this.name,
    required this.target,
    this.saved = 0,
  });

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
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        name: json['name'] as String,
        target: (json['target'] as num).toDouble(),
        saved: (json['saved'] as num).toDouble(),
      );
}
