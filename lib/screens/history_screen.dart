import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/budget_controller.dart';
import '../models/breakdown.dart';
import '../models/budget_entry.dart';
import '../utils/currency.dart';
import '../widgets/breakdown_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
              children: const [
                Icon(Icons.history, size: 48, color: Color(0xFFB7B4AB)),
                SizedBox(height: 12),
                Text(
                  'No saved months yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2A2A26)),
                ),
                SizedBox(height: 6),
                Text(
                  'Save a month from the Dashboard tab to start building your history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B6A63)),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: controller.history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entry = controller.history[index];
          final breakdown = Breakdown.fromAmount(entry.gross) + Breakdown.fromAmount(entry.perks);
          return Dismissible(
            key: ValueKey(entry.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFC65D4A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            onDismissed: (_) => controller.deleteHistoryEntry(entry.id),
            child: _HistoryTile(entry: entry, breakdown: breakdown, dateLabel: dateFmt.format(entry.date)),
          );
        },
      );
    });
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.breakdown, required this.dateLabel});

  final BudgetEntry entry;
  final Breakdown breakdown;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E4DC)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateLabel, style: const TextStyle(fontSize: 12, color: Color(0xFF6B6A63))),
                  const SizedBox(height: 4),
                  Text(
                    'Gross ${formatPkr(entry.gross)} · Perks ${formatPkr(entry.perks)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2A2A26)),
                  ),
                ],
              ),
            ),
            Text(
              formatPkr(entry.total),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2E7D6B)),
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
            color: const Color(0xFFF6F5F1),
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
