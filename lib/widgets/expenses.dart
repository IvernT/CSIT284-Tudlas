import 'package:flutter/material.dart';

import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:expense_tracker/widgets/dashboard_summary.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  final List<Expense> _registeredExpenses = [
    Expense(
      title: 'Flutter Course',
      amount: 19.99,
      date: DateTime.now(),
      category: Category.work,
    ),
    Expense(
      title: 'Cinema',
      amount: 15.69,
      date: DateTime.now(),
      category: Category.leisure,
    ),
    Expense(
      title: 'Groceries',
      amount: 42.50,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: Category.food,
    ),
  ];

  double _monthlyBudget = 500;
  Category? _selectedFilter;

  List<Expense> get filteredExpenses {
    if (_selectedFilter == null) {
      return _registeredExpenses;
    }
    return _registeredExpenses
        .where((expense) => expense.category == _selectedFilter)
        .toList();
  }

  double get totalSpent {
    return _registeredExpenses.fold(
        0.0, (sum, expense) => sum + expense.amount);
  }

  double get averageExpense {
    if (_registeredExpenses.isEmpty) return 0;
    return totalSpent / _registeredExpenses.length;
  }

  int get transactionCount => _registeredExpenses.length;

  Future<void> _changeBudget() async {
    final controller = TextEditingController(
      text: _monthlyBudget.toStringAsFixed(2),
    );

    final newBudget = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set monthly budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Budget amount',
            prefixText: '₱ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value == null || value < 0) {
                Navigator.pop(ctx, null);
                return;
              }
              Navigator.pop(ctx, value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newBudget != null) {
      setState(() {
        _monthlyBudget = newBudget;
      });
    }
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: NewExpense(onAddExpense: _addExpense),
      ),
    );
  }

  void _addExpense(Expense expense) {
    setState(() {
      _registeredExpenses.add(expense);
    });
  }

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: const Text('Expense deleted.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense to start tracking your spending.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openAddExpenseOverlay,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add expense'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleExpenses = filteredExpenses;

    if (_registeredExpenses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Tracker'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddExpenseOverlay,
          icon: const Icon(Icons.add),
          label: const Text('Add expense'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildEmptyState(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpenseOverlay,
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideLayout = constraints.maxWidth >= 760;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWideLayout ? 1200 : 600,
                  ),
                  child: isWideLayout
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildSummary(),
                                  const SizedBox(height: 16),
                                  _buildMetrics(),
                                  const SizedBox(height: 16),
                                  Chart(expenses: _registeredExpenses),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildCategoryFilter(),
                                  const SizedBox(height: 14),
                                  _buildRecentExpenses(visibleExpenses),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildSummary(),
                            const SizedBox(height: 16),
                            _buildMetrics(),
                            const SizedBox(height: 16),
                            _buildCategoryFilter(),
                            const SizedBox(height: 16),
                            Chart(expenses: _registeredExpenses),
                            const SizedBox(height: 14),
                            _buildRecentExpenses(visibleExpenses),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return DashboardSummary(
      totalSpent: totalSpent,
      monthlyBudget: _monthlyBudget,
      onEditBudget: _changeBudget,
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        MetricCard(
          label: 'Count',
          value: '$transactionCount',
          icon: Icons.receipt_long_rounded,
        ),
        const SizedBox(width: 12),
        MetricCard(
          label: 'Avg',
          value: currencyFormatter.format(averageExpense),
          icon: Icons.bar_chart_rounded,
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _selectedFilter == null,
            onSelected: (_) => setState(() => _selectedFilter = null),
          ),
          const SizedBox(width: 8),
          ...Category.values.map((category) {
            final selected = _selectedFilter == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(categoryIcons[category]),
                label: Text(
                  category.name[0].toUpperCase() + category.name.substring(1),
                ),
                selected: selected,
                onSelected: (_) => setState(
                  () => _selectedFilter = selected ? null : category,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses(List<Expense> visibleExpenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _selectedFilter == null
              ? 'Recent expenses'
              : '${_selectedFilter!.name[0].toUpperCase()}${_selectedFilter!.name.substring(1)} expenses',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: visibleExpenses.isEmpty
              ? SizedBox(
                  height: 180,
                  child: Center(
                    child: Text(
                      'No expenses in this category.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              : ExpensesList(
                  key: ValueKey(
                    '${_selectedFilter ?? 'all'}-${visibleExpenses.length}',
                  ),
                  expenses: visibleExpenses,
                  onRemoveExpense: _removeExpense,
                ),
        ),
      ],
    );
  }
}
