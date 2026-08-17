import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import 'add_expense_page.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.uid : 'demo_user_123';
    context.read<ExpenseBloc>().add(LoadExpensesEvent(userId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Market':
        return kTeal;
      case 'Yeme-İçme':
        return kYellow;
      case 'Ulaşım':
        return kGreen;
      case 'Alışveriş':
        return kPurple;
      case 'Eğlence':
        return kRed;
      case 'Fatura':
        return Colors.amber;
      case 'Eğitim':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Market':
        return Icons.shopping_basket_rounded;
      case 'Yeme-İçme':
        return Icons.restaurant_rounded;
      case 'Ulaşım':
        return Icons.directions_car_rounded;
      case 'Alışveriş':
        return Icons.local_mall_rounded;
      case 'Eğlence':
        return Icons.sports_esports_rounded;
      case 'Fatura':
        return Icons.bolt_rounded;
      case 'Eğitim':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        title: const Text(AppStrings.expenseTracking, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kPurple,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.4),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt_rounded, size: 20), text: 'Harcama Listesi'),
            Tab(icon: Icon(Icons.pie_chart_rounded, size: 20), text: 'Kategori Dağılımı'),
          ],
        ),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator(color: kPurple));
          } else if (state is ExpensesLoaded) {
            if (state.expenses.isEmpty) {
              return _buildEmptyState(context);
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildExpenseList(state.expenses),
                _buildExpenseAnalytics(state.expenses),
              ],
            );
          } else if (state is ExpenseError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: kRed, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: kRed)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      final uid = authState is Authenticated ? authState.user.uid : '';
                      context.read<ExpenseBloc>().add(LoadExpensesEvent(uid));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: kPurple),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator(color: kPurple));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_rounded, size: 64, color: Colors.white.withOpacity(0.3)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Henüz Harcama Kaydı Yok',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Manuel ekleme yapabilir veya fişinizin fotoğrafını çekerek yapay zekanın otomatik okumasını sağlayabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpensePage()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('İlk Harcamanı Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPurple,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList(List<dynamic> expenses) {
    double total = 0.0;
    for (var e in expenses) {
      total += e.amount;
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: kBgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Toplam Harcama', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('₺${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${expenses.length} Kayıt', style: const TextStyle(color: kPurple, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final catColor = _getCategoryColor(expense.category);
              final catIcon = _getCategoryIcon(expense.category);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: kBgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(catIcon, color: catColor, size: 22),
                  ),
                  title: Text(
                    expense.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    '${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                  trailing: Text(
                    '₺${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(color: kRed, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseAnalytics(List<dynamic> expenses) {
    final Map<String, double> categoryTotals = {};
    double totalSpending = 0.0;

    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0.0) + e.amount;
      totalSpending += e.amount;
    }

    if (totalSpending <= 0) {
      return const Center(child: Text('Veri bulunamadı.', style: TextStyle(color: Colors.white)));
    }

    final categories = categoryTotals.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                const Text(
                  'Harcama Dağılımı',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                      centerSpaceRadius: 44,
                      sections: List.generate(categories.length, (i) {
                        final cat = categories[i];
                        final amount = categoryTotals[cat]!;
                        final isTouched = i == _touchedIndex;
                        final fontSize = isTouched ? 16.0 : 12.0;
                        final radius = isTouched ? 58.0 : 48.0;
                        final color = _getCategoryColor(cat);
                        final percentage = (amount / totalSpending) * 100;

                        return PieChartSectionData(
                          color: color,
                          value: amount,
                          title: '%${percentage.toStringAsFixed(0)}',
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...categories.map((cat) {
            final amount = categoryTotals[cat]!;
            final percentage = (amount / totalSpending) * 100;
            final color = _getCategoryColor(cat);
            final icon = _getCategoryIcon(cat);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('%${percentage.toStringAsFixed(1)} pay', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                    '₺${amount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
