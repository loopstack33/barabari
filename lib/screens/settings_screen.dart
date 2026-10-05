import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/budget_controller.dart';
import '../models/split_percentages.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import '../utils/route_transitions.dart';
import '../widgets/split_pie_chart.dart';
import 'theme_screen.dart';

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

  /// When true, each category is edited as a PKR amount instead of a %,
  /// with the percentage recalculated automatically as you type.
  bool _amountMode = false;

  final _useAmountCtrl = TextEditingController();
  final _investAmountCtrl = TextEditingController();
  final _lifestyleAmountCtrl = TextEditingController();
  final _emergencyAmountCtrl = TextEditingController();
  final _charityAmountCtrl = TextEditingController();

  /// The income amount amount-mode percentages are calculated against —
  /// the combined Gross + Perks currently entered on the Dashboard.
  double get _referenceTotal => controller.grossInput.value + controller.perksInput.value;

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

  @override
  void dispose() {
    _useAmountCtrl.dispose();
    _investAmountCtrl.dispose();
    _lifestyleAmountCtrl.dispose();
    _emergencyAmountCtrl.dispose();
    _charityAmountCtrl.dispose();
    super.dispose();
  }

  String _amountText(double pct) {
    final total = _referenceTotal;
    final amount = total * (pct / 100);
    return amount == 0 ? '' : amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
  }

  /// Populates the amount fields from the current percentages — called
  /// whenever switching into amount mode, so the two views always agree.
  void _syncAmountFieldsFromPercentages() {
    _useAmountCtrl.text = _amountText(_use);
    _investAmountCtrl.text = _amountText(_invest);
    _lifestyleAmountCtrl.text = _amountText(_lifestyle);
    _emergencyAmountCtrl.text = _amountText(_emergency);
    _charityAmountCtrl.text = _amountText(_charityPercent);
  }

  /// Recomputes a category's percentage from a typed PKR amount.
  void _onAmountChanged(String text, void Function(double pct) applyPct) {
    final total = _referenceTotal;
    if (total <= 0) return;
    final amount = double.tryParse(text) ?? 0;
    final pct = (amount / total * 100).clamp(0, 100).toDouble();
    setState(() => applyPct(pct));
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
      appBar: AppBar(
        title: const Text('Adjust split'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'App theme',
            onPressed: () => Navigator.of(context).push(fadeScaleRoute(const ThemeScreen())),
          ),
        ],
      ),
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
          const SizedBox(height: 16),
          _modeToggle(),
          const SizedBox(height: 16),
          if (_amountMode && _referenceTotal <= 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.use.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Enter your Gross Salary and Perks on the Dashboard first — '
                'amount mode needs a total to calculate percentages against.',
                style: TextStyle(fontSize: 12, color: AppColors.use),
              ),
            )
          else if (_amountMode) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Splitting ${formatPkr(_referenceTotal)} (Gross + Perks from Dashboard)',
                style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
              ),
            ),
            _amountField('Use', AppColors.use, _useAmountCtrl, (pct) => _use = pct),
            _amountField('Invest', AppColors.invest, _investAmountCtrl, (pct) => _invest = pct),
            _amountField('Lifestyle', AppColors.lifestyle, _lifestyleAmountCtrl, (pct) => _lifestyle = pct),
            _amountField('Emergency Fund', AppColors.emergency, _emergencyAmountCtrl, (pct) => _emergency = pct),
          ] else ...[
            _slider('Use', AppColors.use, _use, (v) => setState(() => _use = v)),
            _slider('Invest', AppColors.invest, _invest, (v) => setState(() => _invest = v)),
            _slider('Lifestyle', AppColors.lifestyle, _lifestyle, (v) => setState(() => _lifestyle = v)),
            _slider('Emergency Fund', AppColors.emergency, _emergency, (v) => setState(() => _emergency = v)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
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
              const SizedBox(width: 5),
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
          Text(
            'Note: past saved months in History keep whichever split was '
            'active when they were saved — changing this won\'t rewrite them.',
            style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }

  Widget _modeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _modeButton('By %', !_amountMode, () => setState(() => _amountMode = false))),
          Expanded(
            child: _modeButton('By Amount', _amountMode, () {
              setState(() {
                _amountMode = true;
                _syncAmountFieldsFromPercentages();
              });
            }),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.invest : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.card : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }

  Widget _amountField(
    String label,
    Color color,
    TextEditingController ctrl,
    void Function(double pct) applyPct,
  ) {
    final pct = switch (label) {
      'Use' => _use,
      'Invest' => _invest,
      'Lifestyle' => _lifestyle,
      _ => _emergency,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            width: 130,
            child: TextField(
              controller: ctrl,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                prefixText: 'PKR ',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (text) => _onAmountChanged(text, applyPct),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '${pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1)}%',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
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
                decoration: BoxDecoration(color: AppColors.sadaqah, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
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
          Text(
            'Taken off the top before the rest is split — Use, Invest, '
            'Lifestyle and Emergency Fund automatically shrink to fit what\'s left.',
            style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
          ),
          if (_charityEnabled) ...[
            const SizedBox(height: 12),
            if (_amountMode && _referenceTotal > 0)
              Row(
                children: [
                  const Expanded(
                    child: Text('Amount', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(
                    width: 130,
                    child: TextField(
                      controller: _charityAmountCtrl,
                      textAlign: TextAlign.right,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                      decoration: InputDecoration(
                        isDense: true,
                        prefixText: 'PKR ',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (text) => _onAmountChanged(text, (pct) => _charityPercent = pct),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${_charityPercent.toStringAsFixed(_charityPercent % 1 == 0 ? 0 : 1)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                ],
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Percentage', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    '${_charityPercent.toStringAsFixed(_charityPercent % 1 == 0 ? 0 : 1)}%',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.sadaqah),
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
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
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
