import 'package:flutter/material.dart';

import '../models/breakdown.dart';
import '../theme/app_theme.dart';
import 'animated_amount.dart';

class BreakdownCard extends StatelessWidget {
  const BreakdownCard({
    super.key,
    required this.title,
    required this.breakdown,
    this.accentColor = AppColors.invest,
  });

  final String title;
  final Breakdown breakdown;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final total = breakdown.total;
    // Percentages are derived straight from the computed amounts, so they're
    // always correct whether or not Sadaqah is enabled — no separate
    // calculation to keep in sync.
    String pctOf(double amount) {
      if (total <= 0) return '0%';
      final pct = (amount / total) * 100;
      final isWhole = pct % 1 == 0;
      return '${isWhole ? pct.toInt() : pct.toStringAsFixed(1)}%';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
              AnimatedAmount(
                value: total,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (breakdown.charity > 0) ...[
            _row('Sadaqah', pctOf(breakdown.charity), breakdown.charity, AppColors.sadaqah),
            const SizedBox(height: 10),
          ],
          _row('Use', pctOf(breakdown.use), breakdown.use, accentColor),
          const SizedBox(height: 10),
          _row('Invest', pctOf(breakdown.invest), breakdown.invest, accentColor),
          const SizedBox(height: 10),
          _row('Lifestyle', pctOf(breakdown.lifestyle), breakdown.lifestyle, accentColor),
          const SizedBox(height: 10),
          _row('Emergency Fund', pctOf(breakdown.emergencyFund), breakdown.emergencyFund, accentColor),
        ],
      ),
    );
  }

  Widget _row(String label, String pct, double amount, Color accentColor) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            pct,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.ink),
          ),
        ),
        AnimatedAmount(
          value: amount,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
        ),
      ],
    );
  }
}