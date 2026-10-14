import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/budget_controller.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import '../widgets/animated_amount.dart';
import '../widgets/animated_progress_bar.dart';
import '../widgets/fade_slide_in.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.invest,
        onPressed: () => _showAddGoalSheet(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('New goal'),
      ),
      body: Obx(() {
        if (controller.goals.isEmpty) {
          return _emptyState(context, controller);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.invest.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL SAVED',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.invest),
                  ),
                  AnimatedAmount(
                    value: controller.totalSaved,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(controller.goals.length, (i) {
              final g = controller.goals[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FadeSlideIn(
                  delay: Duration(milliseconds: 60 * i),
                  child: _GoalCard(goal: g, controller: controller),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _emptyState(BuildContext context, BudgetController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.savings_outlined, size: 48, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(
              'No goals yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a goal to start tracking savings toward it, e.g. an emergency fund top-up or a big purchase.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context, BudgetController controller) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Goal name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Target amount',
                  prefixText: 'PKR ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.invest),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final target = double.tryParse(targetCtrl.text) ?? 0;
                    if (name.isEmpty || target <= 0) return;
                    controller.addGoal(name, target);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add goal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.controller});

  final Goal goal;
  final BudgetController controller;

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Text(
                  goal.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20, color: AppColors.muted),
                onSelected: (v) {
                  if (v == 'delete') controller.deleteGoal(goal.id);
                  if (v == 'history') _showHistorySheet(context);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'history', child: Text('View history')),
                  PopupMenuItem(value: 'delete', child: Text('Delete goal')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedProgressBar(
            value: goal.progress,
            color: goal.isComplete ? AppColors.invest : AppColors.lifestyle,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedAmount(
                    value: goal.saved,
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                  Text(' of ', style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                  AnimatedAmount(
                    value: goal.target,
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                ],
              ),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showContributeDialog(context, add: true),
                  child: const Text('Add funds'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showContributeDialog(context, add: false),
                  child: const Text('Withdraw'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showHistorySheet(context),
              icon: const Icon(Icons.history, size: 16),
              label: Text('History (${goal.transactions.length})'),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.35,
          builder: (_, scroll) {
            return Obx(() {
              final g = controller.goals.firstWhereOrNull((x) => x.id == goal.id);
              final txs = g?.transactions ?? <GoalTransaction>[];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Text(
                      '${goal.name} · history',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                  ),
                  Expanded(
                    child: txs.isEmpty
                        ? Center(
                            child: Text(
                              'No add-fund or withdraw actions yet',
                              style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                            ),
                          )
                        : ListView.separated(
                            controller: scroll,
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            itemCount: txs.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border),
                            itemBuilder: (_, i) {
                              final t = txs[i];
                              final color = t.isDeposit ? AppColors.invest : AppColors.sadaqah;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.12),
                                  child: Icon(
                                    t.isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: color,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  '${t.isDeposit ? '+' : '-'} ${formatPkr(t.amount)}',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: color),
                                ),
                                subtitle: Text(
                                  '${DateFormat('d MMM yyyy, h:mm a').format(t.date)}'
                                  '${t.note != null ? '\n${t.note}' : ''}',
                                  style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                                ),
                                isThreeLine: t.note != null,
                                trailing: Text(
                                  'Bal ${formatPkr(t.balanceAfter)}',
                                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            });
          },
        );
      },
    );
  }

  void _showContributeDialog(BuildContext context, {required bool add}) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(add ? 'Add funds to "${goal.name}"' : 'Withdraw from "${goal.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(prefixText: 'PKR ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (add) {
                controller.contributeToGoal(goal.id, amount, note: noteCtrl.text);
              } else {
                controller.withdrawFromGoal(goal.id, amount, note: noteCtrl.text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
