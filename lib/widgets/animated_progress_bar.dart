import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatefulWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.backgroundColor = const Color(0xFFEFEDE7),
    this.minHeight = 8,
  });

  final double value; // 0..1
  final Color color;
  final Color backgroundColor;
  final double minHeight;

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar> {
  double _previousValue = 0;
  bool _first = true;

  @override
  void didUpdateWidget(covariant AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousValue = oldWidget.value;
  }

  @override
  Widget build(BuildContext context) {
    final begin = _first ? 0.0 : _previousValue;
    _first = false;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: begin, end: widget.value),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: widget.minHeight,
          backgroundColor: widget.backgroundColor,
          color: widget.color,
        ),
      ),
    );
  }
}
