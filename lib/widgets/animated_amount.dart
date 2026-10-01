import 'package:flutter/material.dart';

import '../utils/currency.dart';

/// Animates a PKR amount smoothly from whatever it last showed to [value],
/// instead of jumping instantly — used anywhere a computed total changes
/// live (typing an amount, dragging a split slider, contributing to a goal).
class AnimatedAmount extends StatefulWidget {
  const AnimatedAmount({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 350),
  });

  final double value;
  final TextStyle? style;
  final Duration duration;

  @override
  State<AnimatedAmount> createState() => _AnimatedAmountState();
}

class _AnimatedAmountState extends State<AnimatedAmount> {
  double _previousValue = 0;
  bool _first = true;

  @override
  void didUpdateWidget(covariant AnimatedAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousValue = oldWidget.value;
  }

  @override
  Widget build(BuildContext context) {
    final begin = _first ? widget.value : _previousValue;
    _first = false;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: widget.value),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(formatPkr(v), style: widget.style),
    );
  }
}