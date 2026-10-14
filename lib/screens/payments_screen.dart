import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/budget_controller.dart';
import '../models/payment.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import '../widgets/animated_amount.dart';
import '../widgets/fade_slide_in.dart';

enum _PayFilter { all, pending, paid }

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  _PayFilter _filter = _PayFilter.all;
  final _dateFmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BudgetController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.use,
        onPressed: () => _showEditSheet(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add payment'),
      ),
      body: Obx(() {
        final all = controller.payments.toList();
        final list = all.where((p) {
          switch (_filter) {
            case _PayFilter.pending:
              return !p.isPaid;
            case _PayFilter.paid:
              return p.isPaid;
            case _PayFilter.all:
              return true;
          }
        }).toList();
        // Pending first (earliest due date first), then paid (latest first).
        list.sort((a, b) {
          if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
          if (!a.isPaid) {
            final ad = a.dueDate ?? DateTime(9999);
            final bd = b.dueDate ?? DateTime(9999);
            return ad.compareTo(bd);
          }
          return (b.paidDate ?? b.createdAt).compareTo(a.paidDate ?? a.createdAt);
        });

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Row(
              children: [
                Expanded(
                  child: _totalCard('PENDING', controller.pendingTotal, AppColors.lifestyle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _totalCard('PAID', controller.paidTotal, AppColors.invest),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SegmentedButton<_PayFilter>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: _PayFilter.all, label: Text('All')),
                ButtonSegment(value: _PayFilter.pending, label: Text('Pending')),
                ButtonSegment(value: _PayFilter.paid, label: Text('Paid')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
            const SizedBox(height: 14),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.muted),
                    const SizedBox(height: 12),
                    Text(
                      'No payments here',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Track bills, loans or money owed — pending or paid — with details.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(list.length, (i) {
                final p = list[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FadeSlideIn(
                    key: ValueKey(p.id),
                    delay: Duration(milliseconds: 40 * i),
                    child: _paymentCard(context, controller, p),
                  ),
                );
              }),
          ],
        );
      }),
    );
  }

  Widget _totalCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          AnimatedAmount(
            value: value,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(BuildContext context, BudgetController controller, Payment p) {
    final statusColor = p.isPaid
        ? AppColors.invest
        : (p.isOverdue ? AppColors.sadaqah : AppColors.lifestyle);
    final statusText = p.isPaid ? 'Paid' : (p.isOverdue ? 'Overdue' : 'Pending');

    final meta = <String>[];
    if (p.party != null) meta.add(p.party!);
    if (p.isPaid && p.paidDate != null) {
      meta.add('Paid ${_dateFmt.format(p.paidDate!)}');
    } else if (p.dueDate != null) {
      meta.add('Due ${_dateFmt.format(p.dueDate!)}');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
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
              Expanded(
                child: Text(
                  p.title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20, color: AppColors.muted),
                onSelected: (v) {
                  if (v == 'edit') _showEditSheet(context, controller, existing: p);
                  if (v == 'delete') controller.deletePayment(p.id);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatPkr(p.amount),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(meta.join(' · '), style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                ],
                if (p.details != null) ...[
                  const SizedBox(height: 6),
                  Text(p.details!, style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => controller.setPaymentPaid(p.id, !p.isPaid),
                    icon: Icon(p.isPaid ? Icons.undo : Icons.check_circle_outline, size: 18),
                    label: Text(p.isPaid ? 'Mark as pending' : 'Mark as paid'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, BudgetController controller, {Payment? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final amountCtrl = TextEditingController(
      text: existing == null
          ? ''
          : (existing.amount % 1 == 0
              ? existing.amount.toStringAsFixed(0)
              : existing.amount.toString()),
    );
    final partyCtrl = TextEditingController(text: existing?.party ?? '');
    final detailsCtrl = TextEditingController(text: existing?.details ?? '');
    DateTime? dueDate = existing?.dueDate;
    bool isPaid = existing?.isPaid ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'New payment' : 'Edit payment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'PKR ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: partyCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'To / from (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: detailsCtrl,
                    maxLines: 3,
                    minLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Details (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.event, size: 18),
                          label: Text(
                            dueDate == null ? 'Due date' : DateFormat('d MMM yyyy').format(dueDate!),
                          ),
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: dueDate ?? now,
                              firstDate: DateTime(now.year - 2),
                              lastDate: DateTime(now.year + 5),
                            );
                            if (picked != null) setSheet(() => dueDate = picked);
                          },
                        ),
                      ),
                      if (dueDate != null)
                        IconButton(
                          tooltip: 'Clear due date',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setSheet(() => dueDate = null),
                        ),
                    ],
                  ),
                  if (existing == null)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Already paid'),
                      value: isPaid,
                      onChanged: (v) => setSheet(() => isPaid = v),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.use),
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                        if (title.isEmpty || amount <= 0) return;
                        if (existing == null) {
                          controller.addPayment(
                            title: title,
                            amount: amount,
                            party: partyCtrl.text,
                            details: detailsCtrl.text,
                            dueDate: dueDate,
                            isPaid: isPaid,
                          );
                        } else {
                          controller.updatePayment(
                            existing.id,
                            title: title,
                            amount: amount,
                            party: partyCtrl.text,
                            details: detailsCtrl.text,
                            dueDate: dueDate,
                          );
                        }
                        Navigator.pop(ctx);
                      },
                      child: Text(existing == null ? 'Add payment' : 'Save changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
