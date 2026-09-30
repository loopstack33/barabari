import 'package:flutter/material.dart';

import '../models/breakdown.dart';
import '../models/split_percentages.dart';
import '../utils/currency.dart';

class BreakdownCard extends StatelessWidget {
  const BreakdownCard({
    super.key,
    required this.title,
    required this.breakdown,
    this.split = SplitPercentages.defaultSplit,
    this.accentColor = const Color(0xFF2E7D6B),
  });

  final String title;
  final Breakdown breakdown;
  final SplitPercentages split;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E4DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A4A45),
                ),
              ),
              Text(
                formatPkr(breakdown.total),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _row('Use', _pctLabel(split.use), breakdown.use, accentColor),
          const SizedBox(height: 10),
          _row('Invest', _pctLabel(split.invest), breakdown.invest, accentColor),
          const SizedBox(height: 10),
          _row('Lifestyle', _pctLabel(split.lifestyle), breakdown.lifestyle, accentColor),
          const SizedBox(height: 10),
          _row('Emergency Fund', _pctLabel(split.emergencyFund), breakdown.emergencyFund,
              accentColor),
        ],
      ),
    );
  }

  String _pctLabel(double value) {
    final isWhole = value % 1 == 0;
    return '${isWhole ? value.toInt() : value.toStringAsFixed(1)}%';
  }

  Widget _row(String label, String pct, double amount, Color accentColor) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            pct,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9A968C)),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF2A2A26)),
          ),
        ),
        Text(
          formatPkr(amount),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2A26),
          ),
        ),
      ],
    );
  }
}
