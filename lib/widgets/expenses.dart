import 'package:flutter/material.dart';

import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';

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
    return _registeredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get averageExpense {
    if (_registeredExpenses.isEmpty) return 0;
    return totalSpent / _registeredExpenses.length;
  }

  double get budgetProgress {
    return (totalSpent / _monthlyBudget).clamp(0.0, 1.0);
  }

  bool get isOverBudget => totalSpent > _monthlyBudget;

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

  Widget _buildSummaryCard() {
    final remaining = _monthlyBudget - totalSpent;
    final progressText = isOverBudget ? 'Over budget' : '${((budgetProgress) * 100).round()}% used';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total spent',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormatter.format(totalSpent),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wallet_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 6),
                  IconButton(
                    onPressed: _changeBudget,
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    tooltip: 'Set monthly budget',
                    splashRadius: 18,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly budget',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              Text(
                '${currencyFormatter.format(remaining)} left',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: budgetProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.amber.shade300 : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({required String label, required String value, required IconData icon}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMetricCard(
                      label: 'Count',
                      value: '$transactionCount',
                      icon: Icons.receipt_long_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildMetricCard(
                      label: 'Avg',
                      value: currencyFormatter.format(averageExpense),
                      icon: Icons.bar_chart_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedFilter == null,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...Category.values.map((category) {
                        final selected = _selectedFilter == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(categoryIcons[category]),
                            label: Text(
                              category.name[0].toUpperCase() +
                                  category.name.substring(1),
                            ),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = selected ? null : category;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Chart(expenses: visibleExpenses),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _selectedFilter == null
                        ? 'Recent expenses'
                        : '${_selectedFilter!.name[0].toUpperCase()}${_selectedFilter!.name.substring(1)} expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
            ),
          ),
        ),
      ),
    );
  }
}