import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../expense_tracking/presentation/bloc/expense_bloc.dart';
import '../../../expense_tracking/presentation/bloc/expense_state.dart';
import '../../data/models/budget_model.dart';
import '../widgets/set_budget_dialog.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Market', 'icon': Icons.shopping_basket_rounded, 'color': kTeal},
    {'name': 'Yeme-İçme', 'icon': Icons.restaurant_rounded, 'color': kYellow},
    {'name': 'Ulaşım', 'icon': Icons.directions_car_rounded, 'color': kGreen},
    {'name': 'Alışveriş', 'icon': Icons.local_mall_rounded, 'color': kPurple},
    {'name': 'Eğlence', 'icon': Icons.sports_esports_rounded, 'color': kRed},
    {'name': 'Fatura', 'icon': Icons.bolt_rounded, 'color': Colors.amber},
    {'name': 'Eğitim', 'icon': Icons.school_rounded, 'color': Colors.blueAccent},
    {'name': 'Diğer', 'icon': Icons.category_rounded, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final uid = authState is Authenticated ? authState.user.uid : '';

    if (uid.isEmpty) {
      return const Scaffold(
        backgroundColor: kBgDark,
        body: Center(
          child: Text('Giriş yapmanız gerekmektedir.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        title: const Text('Aylık Bütçe Yönetimi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('budgets')
            .snapshots(),
        builder: (context, budgetSnapshot) {
          final Map<String, double> budgetLimits = {};
          if (budgetSnapshot.hasData) {
            for (var doc in budgetSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final budget = CategoryBudget.fromFirestore(data);
              budgetLimits[budget.category] = budget.limitAmount;
            }
          }

          return BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, expenseState) {
              // Calculate spending per category for this month
              final Map<String, double> categorySpendings = {};
              final now = DateTime.now();
              double totalSpentThisMonth = 0.0;

              if (expenseState is ExpensesLoaded) {
                for (var expense in expenseState.expenses) {
                  if (expense.date.year == now.year && expense.date.month == now.month) {
                    categorySpendings[expense.category] =
                        (categorySpendings[expense.category] ?? 0.0) + expense.amount;
                    totalSpentThisMonth += expense.amount;
                  }
                }
              }

              // Calculate overall budget
              double totalBudgetLimit = 0.0;
              for (var limit in budgetLimits.values) {
                totalBudgetLimit += limit;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallBudgetCard(totalSpentThisMonth, totalBudgetLimit),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kategori Limitleri',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Bu Ay (${_getMonthName(now.month)})',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ..._categories.map((cat) {
                      final catName = cat['name'] as String;
                      final catIcon = cat['icon'] as IconData;
                      final catColor = cat['color'] as Color;
                      final limit = budgetLimits[catName] ?? 0.0;
                      final spent = categorySpendings[catName] ?? 0.0;

                      return _buildCategoryBudgetCard(
                        uid: uid,
                        name: catName,
                        icon: catIcon,
                        color: catColor,
                        limit: limit,
                        spent: spent,
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  Widget _buildOverallBudgetCard(double totalSpent, double totalLimit) {
    final hasLimit = totalLimit > 0;
    final ratio = hasLimit ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;
    final percentage = hasLimit ? (totalSpent / totalLimit) * 100 : 0.0;
    final isExceeded = hasLimit && totalSpent > totalLimit;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExceeded
              ? [const Color(0xFF5B1A24), const Color(0xFF2C1217)]
              : [const Color(0xFF1E2640), const Color(0xFF141A29)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isExceeded ? kRed.withOpacity(0.5) : kPurple.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: isExceeded ? kRed.withOpacity(0.2) : kPurple.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isExceeded ? kRed : kTeal).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExceeded ? Icons.warning_amber_rounded : Icons.pie_chart_rounded,
                      color: isExceeded ? kRed : kTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Toplam Bütçe Durumu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (hasLimit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isExceeded ? kRed : kTeal).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '%${percentage.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isExceeded ? kRed : kTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harcanan',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₺${totalSpent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Toplam Limit',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasLimit ? '₺${totalLimit.toStringAsFixed(0)}' : 'Belirlenmedi',
                    style: TextStyle(
                      color: hasLimit ? Colors.white70 : kTextSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                isExceeded
                    ? kRed
                    : (ratio > 0.8 ? kYellow : kTeal),
              ),
            ),
          ),
          if (isExceeded) ...[
            const SizedBox(height: 10),
            Text(
              '⚠️ Dikkat: Toplam bütçe limitinizi ₺${(totalSpent - totalLimit).toStringAsFixed(2)} aştınız!',
              style: const TextStyle(color: kRed, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ] else if (!hasLimit) ...[
            const SizedBox(height: 10),
            Text(
              '💡 Aşağıdaki kategorilere limit belirleyerek aylık harcamalarınızı kontrol altına alın.',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetCard({
    required String uid,
    required String name,
    required IconData icon,
    required Color color,
    required double limit,
    required double spent,
  }) {
    final hasLimit = limit > 0;
    final ratio = hasLimit ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final percentage = hasLimit ? (spent / limit) * 100 : 0.0;
    final isExceeded = hasLimit && spent > limit;
    final isNearLimit = hasLimit && !isExceeded && ratio >= 0.8;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExceeded
              ? kRed.withOpacity(0.6)
              : (isNearLimit ? kYellow.withOpacity(0.5) : Colors.white.withOpacity(0.06)),
          width: isExceeded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isExceeded) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Aşıldı!', style: TextStyle(color: kRed, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasLimit
                          ? '₺${spent.toStringAsFixed(0)} / ₺${limit.toStringAsFixed(0)} (%${percentage.toStringAsFixed(0)})'
                          : '₺${spent.toStringAsFixed(0)} harcandı (Limit yok)',
                      style: TextStyle(
                        color: isExceeded ? kRed : Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: isExceeded ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  hasLimit ? Icons.edit_rounded : Icons.add_circle_outline_rounded,
                  color: hasLimit ? kTextSecondary : kTeal,
                  size: 22,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => SetBudgetDialog(
                      userId: uid,
                      category: name,
                      currentLimit: limit,
                      categoryIcon: icon,
                      categoryColor: color,
                    ),
                  );
                },
              ),
            ],
          ),
          if (hasLimit) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isExceeded
                      ? kRed
                      : (isNearLimit ? kYellow : color),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
