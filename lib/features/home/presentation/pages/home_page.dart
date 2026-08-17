import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../expense_tracking/presentation/pages/expenses_page.dart';
import '../../../expense_tracking/presentation/pages/add_expense_page.dart';
import '../../../expense_tracking/presentation/bloc/expense_bloc.dart';
import '../../../expense_tracking/presentation/bloc/expense_event.dart';
import '../../../expense_tracking/presentation/bloc/expense_state.dart';

import '../../../saving_goals/presentation/pages/goals_page.dart';
import '../../../saving_goals/presentation/pages/add_goal_page.dart';
import '../../../saving_goals/presentation/bloc/goal_bloc.dart';
import '../../../saving_goals/presentation/bloc/goal_event.dart';
import '../../../saving_goals/presentation/bloc/goal_state.dart';

import '../../../education/presentation/pages/education_page.dart';
import '../../../debt_management/presentation/pages/debt_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimController;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Pano'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Harcamalar'),
    _NavItem(icon: Icons.leaderboard_rounded, label: 'Hedeflerim'),
    _NavItem(icon: Icons.school_rounded, label: 'Eğitim'),
    _NavItem(icon: Icons.more_horiz_rounded, label: 'Daha Fazla'),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  Widget _buildPage(int index, String userName) {
    switch (index) {
      case 0:
        return _DashboardTab(
          userName: userName,
          onTabSelect: (i) {
            setState(() => _selectedIndex = i);
          },
        );
      case 1:
        return const ExpensesPage();
      case 2:
        return const GoalsPage();
      case 3:
        return const EducationPage();
      default:
        return _MoreTab(
          onTabSelect: (i) {
            setState(() => _selectedIndex = i);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state is Authenticated
            ? (state.user.displayName ?? state.user.email.split('@').first)
            : 'Kullanıcı';

        return Scaffold(
          backgroundColor: kBgDark,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: _buildPage(_selectedIndex, userName),
            ),
          ),
          floatingActionButton: _selectedIndex == 1 || _selectedIndex == 2
              ? ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _fabAnimController,
                    curve: Curves.elasticOut,
                  ),
                  child: FloatingActionButton(
                    onPressed: () async {
                      if (_selectedIndex == 2) {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalPage()));
                        if (result == true && mounted) {
                          setState(() => _selectedIndex = 2);
                          _fabAnimController..reset()..forward();
                        }
                      } else {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpensePage()));
                        if (result == true && mounted) {
                          setState(() => _selectedIndex = 1);
                          _fabAnimController..reset()..forward();
                        }
                      }
                    },
                    backgroundColor: _selectedIndex == 2 ? kYellow : kPurple,
                    child: Icon(_selectedIndex == 2 ? Icons.flag_rounded : Icons.add_rounded,
                        color: Colors.white, size: 28),
                  ),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: _buildBottomBar(),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              return _BottomNavItem(
                item: _navItems[i],
                isSelected: _selectedIndex == i,
                onTap: () {
                  setState(() => _selectedIndex = i);
                  _fabAnimController
                    ..reset()
                    ..forward();
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Nav Item Widget ────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _BottomNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  const _BottomNavItem(
      {required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? kPurple.withOpacity(0.15)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                item.icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? kPurple
                    : Colors.white.withOpacity(0.4),
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected
                    ? kPurple
                    : Colors.white.withOpacity(0.35),
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Tab ─────────────────────────────────────────────────────────
class _DashboardTab extends StatefulWidget {
  final String userName;
  final Function(int) onTabSelect;

  const _DashboardTab({
    required this.userName,
    required this.onTabSelect,
  });

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ExpenseBloc>().add(LoadExpensesEvent(authState.user.uid));
      context.read<GoalBloc>().add(LoadGoalsEvent(authState.user.uid));
    }
  }

  void _showIncomeDialog(BuildContext context, String uid, double currentIncome, bool currentFixed) {
    final incomeCtrl = TextEditingController(text: currentIncome > 0 ? currentIncome.toStringAsFixed(0) : '');
    bool isFixed = currentFixed;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kBgSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Aylık Gelir Girişi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: incomeCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Aylık Net Geliriniz (₺)',
                      labelStyle: TextStyle(color: kTextSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kPurple)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kTeal)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bu Geliri Sabitle', style: TextStyle(color: Colors.white, fontSize: 14)),
                      Switch(
                        value: isFixed,
                        activeColor: kPurple,
                        onChanged: (val) {
                          setDialogState(() {
                            isFixed = val;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal', style: TextStyle(color: kTextSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(incomeCtrl.text) ?? 0.0;
                    await _firestore.collection('incomes').doc(uid).set({
                      'amount': amount,
                      'isFixed': isFixed,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gelir bilgisi başarıyla güncellendi!'), backgroundColor: kGreen),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kPurple),
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final uid = authState is Authenticated ? authState.user.uid : '';

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('incomes').doc(uid).snapshots(),
      builder: (context, incomeSnapshot) {
        double incomeAmount = 0.0;
        bool isFixed = false;

        if (incomeSnapshot.hasData && incomeSnapshot.data!.exists) {
          final data = incomeSnapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            incomeAmount = (data['amount'] as num?)?.toDouble() ?? 0.0;
            isFixed = data['isFixed'] as bool? ?? false;
          }
        }

        return BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, expenseState) {
            double totalExpense = 0.0;
            List<dynamic> recentExpenses = [];

            if (expenseState is ExpensesLoaded) {
              recentExpenses = expenseState.expenses;
              for (var exp in expenseState.expenses) {
                totalExpense += exp.amount;
              }
            }

            final netBalance = incomeAmount - totalExpense;

            return BlocBuilder<GoalBloc, GoalState>(
              builder: (context, goalState) {
                int activeGoalsCount = 0;
                if (goalState is GoalsLoaded) {
                  activeGoalsCount = goalState.goals.where((g) => !g.isCompleted).length;
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('debts').where('userId', isEqualTo: uid).snapshots(),
                  builder: (context, debtSnapshot) {
                    double totalDebt = 0.0;
                    if (debtSnapshot.hasData) {
                      for (var doc in debtSnapshot.data!.docs) {
                        final d = doc.data() as Map<String, dynamic>?;
                        if (d != null) {
                          totalDebt += (d['amount'] as num?)?.toDouble() ?? 0.0;
                        }
                      }
                    }

                    return CustomScrollView(
                      slivers: [
                        _buildHeader(context, widget.userName),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              const SizedBox(height: 24),
                              _buildBalanceCard(uid, netBalance, incomeAmount, totalExpense, isFixed),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Hızlı İşlemler'),
                              const SizedBox(height: 14),
                              _buildQuickActions(context),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Bu Ay'),
                              const SizedBox(height: 14),
                              _buildMonthlyStats(incomeAmount, totalExpense, activeGoalsCount, totalDebt),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Son Harcamalar'),
                              const SizedBox(height: 14),
                              _buildRecentTransactions(recentExpenses),
                            ]),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  SliverAppBar _buildHeader(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: kBgDark,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba, $name 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Finansal durumunuza göz atın',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: Colors.white.withOpacity(0.7), size: 22),
                onPressed: () {},
              ),
              GestureDetector(
                onTap: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kPurple, kGreen],
                    ),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String uid, double netBalance, double income, double expense, bool isFixed) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: kGradientCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPurple.withOpacity(0.35),
            blurRadius: 28,
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
              const Text(
                'Toplam Net Bakiye',
                style: TextStyle(
                    color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: () => _showIncomeDialog(context, uid, income, isFixed),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isFixed ? 'Sabit Gelir' : 'Mart 2026',
                          style: const TextStyle(color: Colors.white, fontSize: 11)),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₺ ${netBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat('Gelir', '₺${income.toStringAsFixed(0)}', Icons.arrow_downward_rounded,
                  kGreen),
              const SizedBox(width: 32),
              _buildMiniStat('Gider', '₺${expense.toStringAsFixed(0)}', Icons.arrow_upward_rounded,
                  kRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final uid = authState is Authenticated ? authState.user.uid : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuickActionCard(
          action: const _QuickAction(
              icon: Icons.add_circle_outline_rounded,
              label: 'Harcama\nEkle',
              color: kRed),
          onTap: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpensePage()));
            if (result == true && context.mounted) {
              widget.onTabSelect(1); // 1 = Harcamalar
            }
          },
        ),
        _QuickActionCard(
          action: const _QuickAction(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Gelir\nGir',
              color: kTeal),
          onTap: () => _showIncomeDialog(context, uid, 0, false),
        ),
        _QuickActionCard(
          action: const _QuickAction(
              icon: Icons.flag_outlined,
              label: 'Hedef\nEkle',
              color: kYellow),
          onTap: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalPage()));
            if (result == true && context.mounted) {
              widget.onTabSelect(2); // 2 = Hedefler
            }
          },
        ),
        _QuickActionCard(
          action: const _QuickAction(
              icon: Icons.school_outlined,
              label: 'Eğitim',
              color: kPurple),
          onTap: () => widget.onTabSelect(3),
        ),
      ],
    );
  }

  Widget _buildMonthlyStats(double income, double expense, int activeGoals, double totalDebt) {
    final budgetUsage = income > 0 ? (expense / income) * 100 : 0.0;

    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Bütçe Kullanımı', value: '%${budgetUsage.toStringAsFixed(0)}', icon: Icons.pie_chart_rounded, color: kTeal)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Aktif Hedef', value: '$activeGoals', icon: Icons.flag_rounded, color: kYellow)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Toplam Borç', value: '₺${totalDebt.toStringAsFixed(0)}', icon: Icons.credit_card_rounded, color: kRed)),
      ],
    );
  }

  Widget _buildRecentTransactions(List<dynamic> expenses) {
    if (expenses.isEmpty) {
      return _buildRecentTransactionPlaceholder();
    }

    final displayExpenses = expenses.length > 3 ? expenses.sublist(0, 3) : expenses;

    return Column(
      children: displayExpenses.map((exp) {
        IconData categoryIcon = Icons.receipt_long_rounded;
        Color catColor = kPurple;

        switch (exp.category) {
          case 'Market':
            categoryIcon = Icons.shopping_basket_rounded;
            catColor = kTeal;
            break;
          case 'Yeme-İçme':
            categoryIcon = Icons.restaurant_rounded;
            catColor = kYellow;
            break;
          case 'Ulaşım':
            categoryIcon = Icons.directions_car_rounded;
            catColor = kGreen;
            break;
          case 'Alışveriş':
            categoryIcon = Icons.local_mall_rounded;
            catColor = kPurple;
            break;
          case 'Eğlence':
            categoryIcon = Icons.sports_esports_rounded;
            catColor = kRed;
            break;
          case 'Fatura':
            categoryIcon = Icons.bolt_rounded;
            catColor = kYellow;
            break;
        }

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
                color: catColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(categoryIcon, color: catColor, size: 20),
            ),
            title: Text(exp.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(DateFormat('dd MMM yyyy').format(exp.date), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
            trailing: Text('₺${exp.amount.toStringAsFixed(2)}', 
                style: const TextStyle(color: kRed, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentTransactionPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded,
              color: Colors.white.withOpacity(0.2), size: 48),
          const SizedBox(height: 12),
          Text('Henüz harcama yok',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('İlk harcamanızı eklemek için + butonuna basın',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 12)),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction(
      {required this.icon, required this.label, required this.color});
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  final VoidCallback onTap;
  const _QuickActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: action.color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(action.icon, color: action.color, size: 26),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10.5,
                  height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 10)),
        ],
      ),
    );
  }
}

// ─── More Tab ─────────────────────────────────────────────────────────────
class _MoreTab extends StatelessWidget {
  final Function(int) onTabSelect;

  const _MoreTab({required this.onTabSelect});

  void _showSettingsDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final keyCtrl = TextEditingController(text: prefs.getString('USER_GEMINI_API_KEY') ?? '');

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: kBgSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Uygulama Ayarları', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Google Gemini API Anahtarı', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Uygulamada fiş okuma ve AI asistanının çalışması için özel Gemini API anahtarınızı tanımlayabilirsiniz.',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
                const SizedBox(height: 12),
                TextField(
                  controller: keyCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Gemini API Key',
                    labelStyle: TextStyle(color: kTextSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kPurple)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kTeal)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await prefs.remove('USER_GEMINI_API_KEY');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gemini API anahtarı temizlendi, varsayılan .env kullanılacak.'), backgroundColor: kYellow),
                    );
                  }
                },
                child: const Text('Sıfırla', style: TextStyle(color: kRed)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final key = keyCtrl.text.trim();
                  if (key.isNotEmpty) {
                    await prefs.setString('USER_GEMINI_API_KEY', key);
                  } else {
                    await prefs.remove('USER_GEMINI_API_KEY');
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ayarlar başarıyla kaydedildi!'), backgroundColor: kGreen),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPurple),
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showRoboAdvisorInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kBgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Robo-Advisor Aktif! 🧠', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'Finansal koçunuz projedeki kumbaralarınızda aktiftir.\n\n"Hedeflerim" sekmesine giderek dilediğiniz kumbara kartı üzerindeki 🧠 simgesine tıklayıp, yapay zekanın hedefinize giden yolda size özel hazırladığı analiz ve tasarruf önerilerini anında alabilirsiniz.',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onTabSelect(2); // Go to Goals
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPurple),
              child: const Text('Hedeflerime Git'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem(Icons.flag_rounded, 'Finansal Hedefler', kYellow),
      _MoreItem(Icons.show_chart_rounded, 'Robo-Advisor', kPurple),
      _MoreItem(Icons.school_rounded, 'Finansal Eğitim', kTeal),
      _MoreItem(Icons.credit_card_rounded, 'Borç Yönetimi', kRed),
      _MoreItem(Icons.settings_rounded, 'Ayarlar', Colors.white54),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          const Text('Daha Fazla',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...items.map((item) {
            VoidCallback tapAction = () {};
            if (item.label == 'Finansal Hedefler') {
              tapAction = () => onTabSelect(2);
            } else if (item.label == 'Robo-Advisor') {
              tapAction = () => _showRoboAdvisorInfo(context);
            } else if (item.label == 'Finansal Eğitim') {
              tapAction = () => onTabSelect(3);
            } else if (item.label == 'Borç Yönetimi') {
              tapAction = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtPage()));
            } else if (item.label == 'Ayarlar') {
              tapAction = () => _showSettingsDialog(context);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MoreItemCard(item: item, onTap: tapAction),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                context.read<AuthBloc>().add(SignOutEvent()),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            label: const Text('Çıkış Yap',
                style: TextStyle(color: Colors.redAccent)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side:
                  const BorderSide(color: Colors.redAccent, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String label;
  final Color color;
  const _MoreItem(this.icon, this.label, this.color);
}

class _MoreItemCard extends StatelessWidget {
  final _MoreItem item;
  final VoidCallback onTap;
  const _MoreItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.color, size: 22),
        ),
        title: Text(item.label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.3)),
        onTap: onTap,
      ),
    );
  }
}
