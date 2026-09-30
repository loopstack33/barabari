import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/split_percentages.dart';

/// Colors match the app's icon/logo mark for visual consistency.
const kUseColor = Color(0xFFC1666B);
const kInvestColor = Color(0xFF2E7D6B);
const kLifestyleColor = Color(0xFFB07D3D);
const kEmergencyColor = Color(0xFF3A3A86);

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

  static const _entries = [
    ('Use', kUseColor),
    ('Invest', kInvestColor),
    ('Lifestyle', kLifestyleColor),
    ('Emergency Fund', kEmergencyColor),
  ];

  @override
  Widget build(BuildContext context) {
    final values = [split.use, split.invest, split.lifestyle, split.emergencyFund];

    return Column(
      children: [
        SizedBox(
          height: size,
          width: size,
          child: PieChart(
            PieChartData(
              sections: List.generate(_entries.length, (i) {
                final (_, color) = _entries[i];
                final value = values[i];
                return PieChartSectionData(
                  value: value <= 0 ? 0.0001 : value,
                  color: color,
                  radius: size * 0.22,
                  showTitle: false,
                );
              }),
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
            children: List.generate(_entries.length, (i) {
              final (label, color) = _entries[i];
              final value = values[i];
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
            }),
          ),
        ],
      ],
    );
  }
}
