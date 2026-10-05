import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/split_percentages.dart';
import '../theme/app_theme.dart';

class SplitPieChart extends StatelessWidget {
  const SplitPieChart({
    super.key,
    required this.split,
    this.size = 160,
    this.showLegend = true,
  });

  final SplitPercentages split;
  final double size;
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    final eff = split.effectivePercentages;

    // Build the entry list dynamically so the Sadaqah slice only appears
    // when it's actually enabled, instead of always reserving a slot for it.
    final entries = <(String, Color, double)>[
      if (split.charityEnabled && eff['charity']! > 0)
        ('Sadaqah', AppColors.sadaqah, eff['charity']!),
      ('Use', AppColors.use, eff['use']!),
      ('Invest', AppColors.invest, eff['invest']!),
      ('Lifestyle', AppColors.lifestyle, eff['lifestyle']!),
      ('Emergency Fund', AppColors.emergency, eff['emergencyFund']!),
    ];

    return Column(
      children: [
        SizedBox(
          height: size,
          width: size,
          child: PieChart(
            swapAnimationDuration: const Duration(milliseconds: 450),
            swapAnimationCurve: Curves.easeOutCubic,
            PieChartData(
              sections: entries.map((e) {
                final (_, color, value) = e;
                return PieChartSectionData(
                  value: value <= 0 ? 0.0001 : value,
                  color: color,
                  radius: size * 0.22,
                  showTitle: false,
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: size * 0.18,
            ),
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: entries.map((e) {
              final (label, color, value) = e;
              final pctLabel = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$label $pctLabel%',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF4A4A45)),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
