import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/breakdown.dart';
import '../models/budget_entry.dart';
import '../models/expense.dart';
import '../models/goal.dart';
import '../models/payment.dart';
import '../models/split_percentages.dart';
import '../theme/app_theme_presets.dart';

class BudgetController extends GetxController {
  static const _historyKey = 'budget_history_v1';
  static const _goalsKey = 'budget_goals_v1';
  static const _currentKey = 'budget_current_v1';
  static const _splitKey = 'budget_split_v1';
  static const _expensesKey = 'budget_expenses_v1';
  static const _themeKey = 'budget_theme_v1';
  static const _paymentsKey = 'budget_payments_v1';

  /// Current (unsaved) month inputs.
  final grossInput = 0.0.obs;
  final perksInput = 0.0.obs;

  /// The currently active split percentages (adjustable in Settings).
  final splitPercentages = SplitPercentages.defaultSplit.obs;

  /// The currently active app-wide color theme.
  final activeTheme = kThemeBarabri.obs;

  /// Saved months, most recent first.
  final history = <BudgetEntry>[].obs;

  /// Savings goals.
  final goals = <Goal>[].obs;

  /// Logged spending history entries.
  final expenses = <Expense>[].obs;

  /// Pending / paid payments with details.
  final payments = <Payment>[].obs;

  final isLoading = true.obs;

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  // ---------------------------------------------------------------- getters

  Breakdown get grossBreakdown =>
      Breakdown.fromAmount(grossInput.value, splitPercentages.value);
  Breakdown get perksBreakdown =>
      Breakdown.fromAmount(perksInput.value, splitPercentages.value);
  Breakdown get combinedBreakdown => grossBreakdown + perksBreakdown;

  double get totalSaved => goals.fold(0.0, (sum, g) => sum + g.saved);
  double get totalGoalTargets => goals.fold(0.0, (sum, g) => sum + g.target);

  // ------------------------------------------------------------ persistence

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();

    final currentRaw = _prefs?.getString(_currentKey);
    if (currentRaw != null) {
      final map = jsonDecode(currentRaw) as Map<String, dynamic>;
      grossInput.value = (map['gross'] as num?)?.toDouble() ?? 0;
      perksInput.value = (map['perks'] as num?)?.toDouble() ?? 0;
    }

    final historyRaw = _prefs?.getStringList(_historyKey) ?? <String>[];
    history.assignAll(
      historyRaw.map(
        (e) => BudgetEntry.fromJson(jsonDecode(e) as Map<String, dynamic>),
      ),
    );

    final goalsRaw = _prefs?.getStringList(_goalsKey) ?? <String>[];
    goals.assignAll(
      goalsRaw.map((e) => Goal.fromJson(jsonDecode(e) as Map<String, dynamic>)),
    );

    final expensesRaw = _prefs?.getStringList(_expensesKey) ?? <String>[];
    expenses.assignAll(
      expensesRaw.map((e) => Expense.fromJson(jsonDecode(e) as Map<String, dynamic>)),
    );

    final paymentsRaw = _prefs?.getStringList(_paymentsKey) ?? <String>[];
    payments.assignAll(
      paymentsRaw.map((e) => Payment.fromJson(jsonDecode(e) as Map<String, dynamic>)),
    );

    final splitRaw = _prefs?.getString(_splitKey);
    if (splitRaw != null) {
      splitPercentages.value =
          SplitPercentages.fromJson(jsonDecode(splitRaw) as Map<String, dynamic>);
    }

    final themeId = _prefs?.getString(_themeKey);
    if (themeId != null) {
      activeTheme.value = themeById(themeId);
    }

    isLoading.value = false;
  }

  Future<void> _persistCurrent() async {
    await _prefs?.setString(
      _currentKey,
      jsonEncode({'gross': grossInput.value, 'perks': perksInput.value}),
    );
  }

  Future<void> _persistHistory() async {
    await _prefs?.setStringList(
      _historyKey,
      history.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> _persistGoals() async {
    await _prefs?.setStringList(
      _goalsKey,
      goals.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> _persistExpenses() async {
    await _prefs?.setStringList(
      _expensesKey,
      expenses.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> _persistPayments() async {
    await _prefs?.setStringList(
      _paymentsKey,
      payments.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> _persistSplit() async {
    await _prefs?.setString(_splitKey, jsonEncode(splitPercentages.value.toJson()));
  }

  /// Updates the active split percentages. Does not touch history — past
  /// entries keep whatever split was active when they were saved.
  void setSplit(SplitPercentages newSplit) {
    splitPercentages.value = newSplit;
    _persistSplit();
  }

  void resetSplitToDefault() => setSplit(SplitPercentages.defaultSplit);

  Future<void> setTheme(AppThemeOption theme) async {
    activeTheme.value = theme;
    await _prefs?.setString(_themeKey, theme.id);
  }

  // ------------------------------------------------------------- mutations

  void setGross(double value) {
    grossInput.value = value < 0 ? 0 : value;
    _persistCurrent();
  }

  void setPerks(double value) {
    perksInput.value = value < 0 ? 0 : value;
    _persistCurrent();
  }

  /// Saves the current gross/perks as a new history entry (does not clear
  /// the current inputs, so the dashboard keeps showing them).
  void saveCurrentToHistory() {
    if (grossInput.value <= 0 && perksInput.value <= 0) return;
    final entry = BudgetEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      gross: grossInput.value,
      perks: perksInput.value,
      split: splitPercentages.value,
    );
    history.insert(0, entry);
    _persistHistory();
  }

  void deleteHistoryEntry(String id) {
    history.removeWhere((e) => e.id == id);
    _persistHistory();
  }

  void clearHistory() {
    history.clear();
    _persistHistory();
  }

  void addGoal(String name, double target) {
    goals.add(
      Goal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        target: target,
      ),
    );
    _persistGoals();
  }

  void contributeToGoal(String id, double amount, {String? note}) {
    final goal = _findGoal(id);
    if (goal == null || amount <= 0) return;
    goal.saved += amount;
    _logGoalTx(goal, amount, true, note);
    goals.refresh();
    _persistGoals();
  }

  void withdrawFromGoal(String id, double amount, {String? note}) {
    final goal = _findGoal(id);
    if (goal == null || amount <= 0) return;
    // Never withdraw more than what is saved; log the actual amount taken out.
    final actual = amount > goal.saved ? goal.saved : amount;
    if (actual <= 0) return;
    goal.saved -= actual;
    _logGoalTx(goal, actual, false, note);
    goals.refresh();
    _persistGoals();
  }

  void _logGoalTx(Goal goal, double amount, bool isDeposit, String? note) {
    goal.transactions.insert(
      0,
      GoalTransaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: amount,
        isDeposit: isDeposit,
        balanceAfter: goal.saved,
        note: (note != null && note.trim().isNotEmpty) ? note.trim() : null,
      ),
    );
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    _persistGoals();
  }

  Goal? _findGoal(String id) {
    for (final g in goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  // ------------------------------------------------------------- expenses

  void addExpense({
    required DateTime date,
    required String category,
    required double amount,
    String? note,
  }) {
    if (amount <= 0) return;
    expenses.add(
      Expense(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: date,
        category: category,
        amount: amount,
        note: (note != null && note.trim().isNotEmpty) ? note.trim() : null,
      ),
    );
    _persistExpenses();
  }

  void deleteExpense(String id) {
    expenses.removeWhere((e) => e.id == id);
    _persistExpenses();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Expense> expensesForDay(DateTime day) {
    final list = expenses.where((e) => _isSameDay(e.date, day)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Expense> expensesForMonth(DateTime month) {
    final list = expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double totalForDay(DateTime day) =>
      expensesForDay(day).fold(0.0, (sum, e) => sum + e.amount);

  double totalForMonth(DateTime month) =>
      expensesForMonth(month).fold(0.0, (sum, e) => sum + e.amount);

  /// Category → total spent, for a given month (used for a per-category summary).
  Map<String, double> categoryTotalsForMonth(DateTime month) {
    final totals = <String, double>{};
    for (final e in expensesForMonth(month)) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  // ------------------------------------------------------------- payments

  String? _clean(String? v) => (v != null && v.trim().isNotEmpty) ? v.trim() : null;

  void addPayment({
    required String title,
    required double amount,
    String? party,
    String? details,
    DateTime? dueDate,
    bool isPaid = false,
  }) {
    if (title.trim().isEmpty || amount <= 0) return;
    payments.insert(
      0,
      Payment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.trim(),
        amount: amount,
        party: _clean(party),
        details: _clean(details),
        dueDate: dueDate,
        isPaid: isPaid,
        paidDate: isPaid ? DateTime.now() : null,
        createdAt: DateTime.now(),
      ),
    );
    _persistPayments();
  }

  void updatePayment(
    String id, {
    required String title,
    required double amount,
    String? party,
    String? details,
    DateTime? dueDate,
  }) {
    final i = payments.indexWhere((p) => p.id == id);
    if (i < 0 || title.trim().isEmpty || amount <= 0) return;
    final old = payments[i];
    payments[i] = Payment(
      id: old.id,
      title: title.trim(),
      amount: amount,
      party: _clean(party),
      details: _clean(details),
      dueDate: dueDate,
      isPaid: old.isPaid,
      paidDate: old.paidDate,
      createdAt: old.createdAt,
    );
    _persistPayments();
  }

  void setPaymentPaid(String id, bool paid) {
    final i = payments.indexWhere((p) => p.id == id);
    if (i < 0) return;
    final old = payments[i];
    payments[i] = Payment(
      id: old.id,
      title: old.title,
      amount: old.amount,
      party: old.party,
      details: old.details,
      dueDate: old.dueDate,
      isPaid: paid,
      paidDate: paid ? DateTime.now() : null,
      createdAt: old.createdAt,
    );
    _persistPayments();
  }

  void deletePayment(String id) {
    payments.removeWhere((p) => p.id == id);
    _persistPayments();
  }

  double get pendingTotal =>
      payments.where((p) => !p.isPaid).fold(0.0, (s, p) => s + p.amount);
  double get paidTotal =>
      payments.where((p) => p.isPaid).fold(0.0, (s, p) => s + p.amount);
}
