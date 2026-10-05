import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/budget_controller.dart';
import '../models/breakdown.dart';
import '../models/budget_entry.dart';
import '../utils/currency.dart';
import '../widgets/breakdown_card.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _confirmClearAll(BuildContext context, BudgetController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This removes every saved month. This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.use),
            onPressed: () {
              controller.clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();
    final dateFmt = DateFormat('MMM d, yyyy');

    return Obx(() {
      if (controller.history.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 48, color: AppColors.muted),
                const SizedBox(height: 12),
                Text(
                  'No saved months yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  'Save a month from the Dashboard tab to start building your history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _confirmClearAll(context, controller),
              icon: Icon(Icons.delete_sweep_outlined, size: 18, color: AppColors.use),
              label: Text('Clear all', style: TextStyle(color: AppColors.use, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 4),
          ...List.generate(controller.history.length, (index) {
            final entry = controller.history[index];
            final breakdown = Breakdown.fromAmount(entry.gross, entry.split) +
                Breakdown.fromAmount(entry.perks, entry.split);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Dismissible(
                key: ValueKey(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.use,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => controller.deleteHistoryEntry(entry.id),
                child: _HistoryTile(
                  entry: entry,
                  breakdown: breakdown,
                  dateLabel: dateFmt.format(entry.date),
                  onDelete: () => controller.deleteHistoryEntry(entry.id),
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.breakdown,
    required this.dateLabel,
    required this.onDelete,
  });

  final BudgetEntry entry;
  final Breakdown breakdown;
  final String dateLabel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateLabel, style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                  const SizedBox(height: 4),
                  Text(
                    'Gross ${formatPkr(entry.gross)} · Perks ${formatPkr(entry.perks)}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            Text(
              formatPkr(entry.total),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.invest),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: AppColors.muted),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                BreakdownCard(title: 'COMBINED TOTAL', breakdown: breakdown),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
