import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.uid : 'demo_user_123';
    context.read<ExpenseBloc>().add(LoadExpensesEvent(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.expenseTracking),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpensesLoaded) {
            if (state.expenses.isEmpty) {
              return Center(
                child: Text(
                  AppStrings.noTransactions,
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: state.expenses.length,
              itemBuilder: (context, index) {
                final expense = state.expenses[index];
                return _ExpenseTile(expense: expense);
              },
            );
          } else if (state is ExpenseError) {
            return Center(child: Text(state.message, style: const TextStyle(color: kRed)));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final dynamic expense; // Assume ExpenseEntity
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_long_rounded, color: kGreen, size: 22),
        ),
        title: Text(expense.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(expense.category, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        trailing: Text('₺${expense.amount.toStringAsFixed(2)}', 
            style: const TextStyle(color: kRed, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
