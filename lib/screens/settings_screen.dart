import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/budget_controller.dart';
import '../models/split_percentages.dart';
import '../widgets/split_pie_chart.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BudgetController controller = Get.find<BudgetController>();

  late double _use;
  late double _invest;
  late double _lifestyle;
  late double _emergency;

  @override
  void initState() {
    super.initState();
    final s = controller.splitPercentages.value;
    _use = s.use;
    _invest = s.invest;
    _lifestyle = s.lifestyle;
    _emergency = s.emergencyFund;
  }

  SplitPercentages get _currentDraft => SplitPercentages(
        use: _use,
        invest: _invest,
        lifestyle: _lifestyle,
        emergencyFund: _emergency,
      );

  double get _total => _use + _invest + _lifestyle + _emergency;
  bool get _sumsToWhole => (_total - 100).abs() < 0.01;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F1),
      appBar: AppBar(
        title: const Text('Adjust split'),
        backgroundColor: const Color(0xFFF6F5F1),
        elevation: 0,
        foregroundColor: const Color(0xFF2A2A26),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Center(child: SplitPieChart(split: _currentDraft, size: 180)),
          const SizedBox(height: 20),
          _sumBanner(),
          const SizedBox(height: 20),
          _slider('Use', kUseColor, _use, (v) => setState(() => _use = v)),
          _slider('Invest', kInvestColor, _invest, (v) => setState(() => _invest = v)),
          _slider('Lifestyle', kLifestyleColor, _lifestyle, (v) => setState(() => _lifestyle = v)),
          _slider('Emergency Fund', kEmergencyColor, _emergency, (v) => setState(() => _emergency = v)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _use = SplitPercentages.defaultSplit.use;
                      _invest = SplitPercentages.defaultSplit.invest;
                      _lifestyle = SplitPercentages.defaultSplit.lifestyle;
                      _emergency = SplitPercentages.defaultSplit.emergencyFund;
                    });
                  },
                  child: const Text('Reset to 50/20/20/10'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E7D6B)),
                  onPressed: () {
                    controller.setSplit(_currentDraft);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Split updated'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).maybePop();
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: past saved months in History keep whichever split was '
            'active when they were saved — changing this won\'t rewrite them.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B6A63)),
          ),
        ],
      ),
    );
  }

  Widget _sumBanner() {
    final color = _sumsToWhole ? const Color(0xFF2E7D6B) : const Color(0xFFC1666B);
    final label = _sumsToWhole
        ? 'Adds up to ${_total.toStringAsFixed(_total % 1 == 0 ? 0 : 1)}% ✓'
        : 'Adds up to ${_total.toStringAsFixed(_total % 1 == 0 ? 0 : 1)}% — not 100%';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_sumsToWhole ? Icons.check_circle : Icons.error_outline, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, Color color, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              Text(
                '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2A2A26)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              inactiveTrackColor: const Color(0xFFE7E4DC),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
