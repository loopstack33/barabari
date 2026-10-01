import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/budget_controller.dart';
import '../models/expense.dart';
import '../utils/currency.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final BudgetController controller = Get.find<BudgetController>();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E7D6B),
        onPressed: () => _showAddExpenseSheet(context),
        icon: const Icon(Icons.add, color: Colors.white,),
        label: const Text('Add Spend',style: TextStyle(color: Colors.white),),
      ),
      body: Obx(() {
        final dayExpenses = controller.expensesForDay(_selectedDay);
        final monthTotal = controller.totalForMonth(_focusedDay);
        final dayTotal = controller.totalForDay(_selectedDay);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E4DC)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TableCalendar<Expense>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2035, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => _isSameDay(day, _selectedDay),
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) => setState(() => _calendarFormat = format),
                onPageChanged: (day) => setState(() => _focusedDay = day),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                eventLoader: (day) => controller.expensesForDay(day),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Color(0xFFB07D3D), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Color(0xFF2E7D6B), shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: Color(0xFFC1666B), shape: BoxShape.circle),
                  outsideDaysVisible: false,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    color: Color(0xFFEFEDE7),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  formatButtonTextStyle: TextStyle(fontSize: 12, color: Color(0xFF4A4A45)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _totalCard(
                    label: DateFormat('MMM d').format(_selectedDay),
                    amount: dayTotal,
                    color: const Color(0xFF2E7D6B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _totalCard(
                    label: DateFormat('MMMM').format(_focusedDay),
                    amount: monthTotal,
                    color: const Color(0xFF3A3A86),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('EEEE, MMM d').format(_selectedDay),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2A2A26)),
            ),
            const SizedBox(height: 10),
            if (dayExpenses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No spending logged for this day',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B6A63)),
                  ),
                ),
              )
            else
              ...dayExpenses.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: ValueKey(e.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC1666B),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (_) => controller.deleteExpense(e.id),
                      child: _expenseTile(e),
                    ),
                  )),
          ],
        );
      }),
    );
  }

  Widget _totalCard({required String label, required double amount, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(
            formatPkr(amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2A2A26)),
          ),
        ],
      ),
    );
  }

  Widget _expenseTile(Expense e) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E4DC)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEDE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(e.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              e.note?.isNotEmpty == true ? e.note! : '—',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B6A63)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formatPkr(e.amount),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2A2A26)),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    String category = kExpenseCategories.first;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime pickedDate = _selectedDay;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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
                  const Text('Add spending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: kExpenseCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setSheetState(() => category = v ?? category),
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
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: pickedDate,
                        firstDate: DateTime.utc(2020, 1, 1),
                        lastDate: DateTime.utc(2035, 12, 31),
                      );
                      if (picked != null) setSheetState(() => pickedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFBDBAB2)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('EEE, MMM d, yyyy').format(pickedDate)),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E7D6B)),
                      onPressed: () {
                        final amount = double.tryParse(amountCtrl.text) ?? 0;
                        if (amount <= 0) return;
                        controller.addExpense(
                          date: pickedDate,
                          category: category,
                          amount: amount,
                          note: noteCtrl.text,
                        );
                        setState(() {
                          _selectedDay = pickedDate;
                          _focusedDay = pickedDate;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
