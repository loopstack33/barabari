import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/budget_controller.dart';
import '../models/goal.dart';
import '../utils/currency.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D6B),
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
                color: const Color(0xFF2E7D6B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL SAVED',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2E7D6B)),
                  ),
                  Text(
                    formatPkr(controller.totalSaved),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2A2A26)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...controller.goals.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GoalCard(goal: g, controller: controller),
                )),
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
            const Icon(Icons.savings_outlined, size: 48, color: Color(0xFFB7B4AB)),
            const SizedBox(height: 12),
            const Text(
              'No goals yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2A2A26)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add a goal to start tracking savings toward it, e.g. an emergency fund top-up or a big purchase.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF6B6A63)),
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
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E7D6B)),
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
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2A2A26)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF9A968C)),
                onSelected: (v) {
                  if (v == 'delete') controller.deleteGoal(goal.id);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete goal')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEFEDE7),
              color: goal.isComplete ? const Color(0xFF2E7D6B) : const Color(0xFFB07D3D),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatPkr(goal.saved)} of ${formatPkr(goal.target)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B6A63)),
              ),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2A2A26)),
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
        ],
      ),
    );
  }

  void _showContributeDialog(BuildContext context, {required bool add}) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(add ? 'Add funds to "${goal.name}"' : 'Withdraw from "${goal.name}"'),
        content: TextField(
          controller: amountCtrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: 'PKR ', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (add) {
                controller.contributeToGoal(goal.id, amount);
              } else {
                controller.withdrawFromGoal(goal.id, amount);
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
