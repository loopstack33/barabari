import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/budget_controller.dart';
import '../models/split_percentages.dart';
import '../theme/app_theme.dart';
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
  late bool _charityEnabled;
  late double _charityPercent;

  @override
  void initState() {
    super.initState();
    final s = controller.splitPercentages.value;
    _use = s.use;
    _invest = s.invest;
    _lifestyle = s.lifestyle;
    _emergency = s.emergencyFund;
    _charityEnabled = s.charityEnabled;
    _charityPercent = s.charityPercent;
  }

  SplitPercentages get _currentDraft => SplitPercentages(
    use: _use,
    invest: _invest,
    lifestyle: _lifestyle,
    emergencyFund: _emergency,
    charityEnabled: _charityEnabled,
    charityPercent: _charityPercent,
  );

  double get _total => _use + _invest + _lifestyle + _emergency;
  bool get _sumsToWhole => (_total - 100).abs() < 0.01;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Adjust split')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Center(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: SplitPieChart(split: _currentDraft, size: 180),
            ),
          ),
          const SizedBox(height: 20),
          _charityCard(),
          const SizedBox(height: 16),
          _sumBanner(),
          const SizedBox(height: 20),
          _slider('Use', AppColors.use, _use, (v) => setState(() => _use = v)),
          _slider('Invest', AppColors.invest, _invest, (v) => setState(() => _invest = v)),
          _slider('Lifestyle', AppColors.lifestyle, _lifestyle, (v) => setState(() => _lifestyle = v)),
          _slider('Emergency Fund', AppColors.emergency, _emergency, (v) => setState(() => _emergency = v)),
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
                  style: FilledButton.styleFrom(backgroundColor: AppColors.invest),
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
            style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }

  Widget _charityCard() {
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
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: AppColors.sadaqah, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Give in the way of Allah (Sadaqah)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
              ),
              Switch(
                value: _charityEnabled,
                onChanged: (v) => setState(() => _charityEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Taken off the top before the rest is split — Use, Invest, '
                'Lifestyle and Emergency Fund automatically shrink to fit what\'s left.',
            style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
          if (_charityEnabled) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Percentage', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  '${_charityPercent.toStringAsFixed(_charityPercent % 1 == 0 ? 0 : 1)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.sadaqah),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.sadaqah,
                thumbColor: AppColors.sadaqah,
                overlayColor: AppColors.sadaqah.withValues(alpha: 0.15),
                inactiveTrackColor: AppColors.border,
              ),
              child: Slider(
                value: _charityPercent,
                min: 0,
                max: 50,
                divisions: 100,
                onChanged: (v) => setState(() => _charityPercent = v),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sumBanner() {
    final color = _sumsToWhole ? AppColors.invest : AppColors.use;
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
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              inactiveTrackColor: AppColors.border,
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