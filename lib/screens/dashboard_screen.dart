import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/budget_controller.dart';
import '../models/split_percentages.dart';
import '../utils/currency.dart';
import '../widgets/breakdown_card.dart';
import '../widgets/split_pie_chart.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BudgetController controller = Get.find<BudgetController>();
  late final TextEditingController _grossCtrl;
  late final TextEditingController _perksCtrl;

  @override
  void initState() {
    super.initState();
    _grossCtrl = TextEditingController(
      text: controller.grossInput.value == 0 ? '' : controller.grossInput.value.toStringAsFixed(0),
    );
    _perksCtrl = TextEditingController(
      text: controller.perksInput.value == 0 ? '' : controller.perksInput.value.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _grossCtrl.dispose();
    _perksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const Text(
            'Monthly income',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2A2A26)),
          ),
          const SizedBox(height: 12),
          _SplitSummaryChip(controller: controller),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _amountField(
                  label: 'Gross Salary',
                  ctrl: _grossCtrl,
                  onChanged: (v) => controller.setGross(double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _amountField(
                  label: 'Perks',
                  ctrl: _perksCtrl,
                  onChanged: (v) => controller.setPerks(double.tryParse(v) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          BreakdownCard(
            title: 'GROSS SALARY BREAKDOWN',
            breakdown: controller.grossBreakdown,
            split: controller.splitPercentages.value,
            accentColor: const Color(0xFF2E7D6B),
          ),
          const SizedBox(height: 14),
          BreakdownCard(
            title: 'PERKS BREAKDOWN',
            breakdown: controller.perksBreakdown,
            split: controller.splitPercentages.value,
            accentColor: const Color(0xFFB07D3D),
          ),
          const SizedBox(height: 14),
          BreakdownCard(
            title: 'COMBINED TOTAL',
            breakdown: controller.combinedBreakdown,
            split: controller.splitPercentages.value,
            accentColor: const Color(0xFF3A3A86),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7E4DC)),
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'YOUR SPLIT',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A4A45)),
                  ),
                ),
                const SizedBox(height: 12),
                SplitPieChart(split: controller.splitPercentages.value),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D6B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                controller.saveCurrentToHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Saved ${formatPkr(controller.combinedBreakdown.total)} to history',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save this month to history'),
            ),
          ),
        ],
      );
    });
  }

  Widget _amountField({
    required String label,
    required TextEditingController ctrl,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B6A63))),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixText: 'PKR ',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE7E4DC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE7E4DC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D6B), width: 1.5),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Small tappable chip on the Dashboard showing the current split, with a
/// warning if it doesn't sum to 100%. Tapping it opens Settings to adjust.
class _SplitSummaryChip extends StatelessWidget {
  const _SplitSummaryChip({required this.controller});

  final BudgetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final SplitPercentages s = controller.splitPercentages.value;
      final ok = s.sumsToWhole;
      final color = ok ? const Color(0xFF2E7D6B) : const Color(0xFFC1666B);
      final fmt = (double v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(ok ? Icons.pie_chart_outline : Icons.error_outline, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ok
                      ? 'Split: ${fmt(s.use)} / ${fmt(s.invest)} / ${fmt(s.lifestyle)} / ${fmt(s.emergencyFund)}'
                      : 'Split adds up to ${fmt(s.total)}%, not 100% — tap to fix',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                ),
              ),
              Icon(Icons.chevron_right, color: color, size: 18),
            ],
          ),
        ),
      );
    });
  }
}
