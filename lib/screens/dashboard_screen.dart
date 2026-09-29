import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/budget_controller.dart';
import '../models/split_percentages.dart';
import '../utils/currency.dart';
import '../widgets/breakdown_card.dart';

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
      text: controller.grossInput.value == 0
          ? ''
          : controller.grossInput.value.toStringAsFixed(0),
    );
    _perksCtrl = TextEditingController(
      text: controller.perksInput.value == 0
          ? ''
          : controller.perksInput.value.toStringAsFixed(0),
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2A2A26),
            ),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D6B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B6A63)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixText: 'PKR ',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
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
              borderSide: const BorderSide(
                color: Color(0xFF2E7D6B),
                width: 1.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// A compact, animated summary of the active salary split. Tapping it opens
/// an animated editor that keeps all four percentages balanced at 100%.
class _SplitSummaryChip extends StatelessWidget {
  const _SplitSummaryChip({required this.controller});

  final BudgetController controller;

  static const _colors = [
    Color(0xFF2E7D6B), // Use
    Color(0xFF3A6EA5), // Invest
    Color(0xFFCE8B2C), // Lifestyle
    Color(0xFF9C4F62), // Emergency fund
  ];

  Future<void> _openEditor(BuildContext context) async {
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SplitEditorSheet(controller: controller),
    );

    if (applied == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salary split updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This read is covered by the Obx around DashboardScreen's ListView.
    final split = controller.splitPercentages.value;
    final totalLabel = '${_formatPercent(split.total)}%';
    final isValid = split.sumsToWhole;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isValid
              ? const [Color(0xFFEAF5F1), Color(0xFFF7F2E8)]
              : const [Color(0xFFFCEBEB), Color(0xFFFFF5F5)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isValid ? const Color(0xFFCBE5DC) : const Color(0xFFF1B7B7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openEditor(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isValid
                            ? const Color(0xFF2E7D6B)
                            : const Color(0xFFC94F4F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isValid ? Icons.tune_rounded : Icons.error_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Salary split',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2A2A26),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tap to adjust breakdown percentages',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B6A63),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            totalLabel,
                            key: ValueKey(totalLabel),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isValid
                                  ? const Color(0xFF2E7D6B)
                                  : const Color(0xFFC94F4F),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Color(0xFF8A877F),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AnimatedPercentageBar(
                  values: [
                    split.use,
                    split.invest,
                    split.lifestyle,
                    split.emergencyFund,
                  ],
                  colors: _colors,
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitEditorSheet extends StatefulWidget {
  const _SplitEditorSheet({required this.controller});

  final BudgetController controller;

  @override
  State<_SplitEditorSheet> createState() => _SplitEditorSheetState();
}

class _SplitEditorSheetState extends State<_SplitEditorSheet> {
  static const _colors = [
    Color(0xFF2E7D6B),
    Color(0xFF3A6EA5),
    Color(0xFFCE8B2C),
    Color(0xFF9C4F62),
  ];

  late SplitPercentages _draft = widget.controller.splitPercentages.value;
  int? _activeIndex;

  List<double> get _values => [
        _draft.use,
        _draft.invest,
        _draft.lifestyle,
        _draft.emergencyFund,
      ];

  /// Updates one slider and redistributes the remaining amount across the
  /// other three categories. The total is therefore always exactly 100%.
  void _rebalance(int changedIndex, double requestedValue) {
    final value = requestedValue.clamp(0.0, 100.0);
    final next = List<double>.from(_values);
    final otherIndexes = [0, 1, 2, 3]
        .where((index) => index != changedIndex)
        .toList(growable: false);
    final othersTotal = otherIndexes.fold<double>(
      0,
      (sum, index) => sum + next[index],
    );
    final remaining = 100.0 - value;

    next[changedIndex] = value;
    if (othersTotal <= 0.0001) {
      final share = remaining / otherIndexes.length;
      for (final index in otherIndexes) {
        next[index] = share;
      }
    } else {
      for (final index in otherIndexes) {
        next[index] = next[index] * remaining / othersTotal;
      }
    }

    setState(() {
      _activeIndex = changedIndex;
      _draft = SplitPercentages(
        use: next[0],
        invest: next[1],
        lifestyle: next[2],
        emergencyFund: next[3],
      );
    });
  }

  void _reset() {
    setState(() {
      _activeIndex = null;
      _draft = SplitPercentages.defaultSplit;
    });
  }

  void _apply() {
    widget.controller.setSplit(_draft);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    const editors = [
      _SplitEditorData(
        title: 'Use',
        subtitle: 'Bills and essentials',
        icon: Icons.shopping_bag_outlined,
      ),
      _SplitEditorData(
        title: 'Invest',
        subtitle: 'Long-term growth',
        icon: Icons.trending_up_rounded,
      ),
      _SplitEditorData(
        title: 'Lifestyle',
        subtitle: 'Everyday enjoyment',
        icon: Icons.celebration_outlined,
      ),
      _SplitEditorData(
        title: 'Emergency Fund',
        subtitle: 'Safety reserve',
        icon: Icons.shield_outlined,
      ),
    ];

    final values = _values;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          decoration: const BoxDecoration(
            color: Color(0xFFF6F5F1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8D4CA),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adjust salary split',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2A2A26),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'The four percentages always total 100%.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B6A63),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('Reset'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B6A63),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE7E4DC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live preview',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A4A45),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AnimatedPercentageBar(
                        values: values,
                        colors: _colors,
                        height: 14,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < editors.length; i++)
                            _LegendItem(
                              color: _colors[i],
                              label:
                                  '${editors[i].title} ${_formatPercent(values[i])}%',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < editors.length; i++) ...[
                  _percentageSlider(
                    data: editors[i],
                    value: values[i],
                    color: _colors[i],
                    isActive: _activeIndex == i,
                    onChanged: (value) => _rebalance(i, value),
                  ),
                  if (i != editors.length - 1) const SizedBox(height: 4),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _apply,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Apply split'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D6B),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _percentageSlider({
    required _SplitEditorData data,
    required double value,
    required Color color,
    required bool isActive,
    required ValueChanged<double> onChanged,
  }) {
    final label = _formatPercent(value);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.4) : const Color(0xFFE7E4DC),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(data.icon, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2A2A26),
                      ),
                    ),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A877F),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: Text(
                  '$label%',
                  key: ValueKey(label),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.14),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.12),
              trackHeight: 5,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
              onChangeEnd: (_) {
                setState(() => _activeIndex = null);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPercentageBar extends StatelessWidget {
  const _AnimatedPercentageBar({
    required this.values,
    required this.colors,
    this.height = 8,
  });

  final List<double> values;
  final List<Color> colors;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = values.fold<double>(0, (sum, value) => sum + value);
        final denominator = total <= 0 ? 1.0 : total;

        return ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Container(
            height: height,
            color: const Color(0xFFECE9E2),
            child: Row(
              children: [
                // Animating each segment directly gives the preview a smooth
                // transition whenever the user drags a percentage slider.
                for (var i = 0; i < values.length; i++)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: values[i]),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, _) {
                      return SizedBox(
                        width:
                            constraints.maxWidth * (animatedValue / denominator),
                        child: ColoredBox(color: colors[i]),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SplitEditorData {
  const _SplitEditorData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B6A63)),
        ),
      ],
    );
  }
}

String _formatPercent(double value) {
  final rounded = value.roundToDouble();
  final isWhole = (value - rounded).abs() < 0.05;
  if (isWhole) return rounded.toInt().toString();
  return value.toStringAsFixed(1);
}
