import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';
import '../../domain/entities/goal_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/add_progress_dialog.dart';
import '../widgets/ai_report_dialog.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final List<String> _quotes = [
    "Her adım seni hedefine bir adım daha yaklaştırır.",
    "Para biriktirmek, geleceğini satın almaktır.",
    "Küçük damlalar büyük gölleri oluşturur.",
    "Bugün ektiklerin, yarın seni gölgesinde serinletecek.",
    "Zenginlik, ne kadar kazandığın değil, ne kadar biriktirdiğindir."
  ];

  late String _randomQuote;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _randomQuote = (_quotes..shuffle()).first;
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<GoalBloc>().add(LoadGoalsEvent(authState.user.uid));
    }
  }

  void _showAddProgress(GoalEntity goal) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => AddProgressDialog(goal: goal),
    );
    if (amount != null && amount > 0 && mounted) {
      context.read<GoalBloc>().add(AddProgressEvent(goal, amount));
    }
  }

  void _generateReport(GoalEntity goal) {
    context.read<GoalBloc>().add(GenerateGoalReportEvent(goal));
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<GoalBloc>(),
        child: const AiReportDialog(),
      ),
    ).then((_) {
      if (mounted) {
        context.read<GoalBloc>().add(ClearGoalReportEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userName = authState is Authenticated ? (authState.user.displayName ?? 'Kullanıcı') : 'Kullanıcı';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedeflerim'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.show_chart_rounded : Icons.history_rounded, color: Colors.white70),
            onPressed: () => setState(() => _showHistory = !_showHistory),
            tooltip: _showHistory ? 'Aktif Hedefler' : 'Geçmiş Hedefler',
          ),
        ],
      ),
      body: BlocConsumer<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: kGreen));
          } else if (state is GoalError && state is! GoalReportLoading) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: kRed));
          }
        },
        buildWhen: (previous, current) {
          return current is GoalLoading || current is GoalsLoaded || current is GoalError || current is GoalInitial;
        },
        builder: (context, state) {
          if (state is GoalLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GoalsLoaded) {
            final activeGoals = state.goals.where((g) => !g.isCompleted).toList();
            final completedGoals = state.goals.where((g) => g.isCompleted).toList();
            final currentList = _showHistory ? completedGoals : activeGoals;

            if (currentList.isEmpty) {
              return _buildEmptyState(userName);
            }

            return CustomScrollView(
              slivers: [
                if (!_showHistory)
                  SliverToBoxAdapter(
                    child: _buildStaircaseHeader(),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildGoalCard(currentList[index]),
                      childCount: currentList.length,
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  Widget _buildEmptyState(String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_showHistory ? Icons.history_rounded : Icons.flag_circle_outlined, 
               color: Colors.white.withOpacity(0.1), size: 100),
          const SizedBox(height: 16),
          Text(_showHistory ? 'Henüz tamamlanmış bir hedef yok.' : 'Henüz aktif bir hedef belirlenmedi.', 
            style: TextStyle(color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildStaircaseHeader() {
    // Note: I will use a local placeholder if the image path is not ready or valid, 
    // but here I use the generated one's logic
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kPurple.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    'assets/images/saving_goal_stairs.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: kBgSurface,
                      child: const Icon(Icons.show_chart_rounded, color: kPurple, size: 64),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, kBgCard.withOpacity(0.8), kBgCard],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                const Text(
                  'Adım Adım Geleceğe',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _randomQuote,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(GoalEntity goal) {
    final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) : 0.0;
    final color = Color(int.parse(goal.colorHex, radix: 16));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(goal.isCompleted ? 0.1 : 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  Icon(goal.isCompleted ? Icons.check_circle_rounded : Icons.bolt_rounded, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(goal.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text('%${(progress * 100).toStringAsFixed(1)}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // HEARTBEAT CHART
          SizedBox(
            height: 60,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: goal.progressHistory.isEmpty 
                        ? [const FlSpot(0, 0)] 
                        : goal.progressHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biriken', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  Text('₺${goal.currentAmount.toStringAsFixed(0)}', 
                       style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Hedef', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  Text('₺${goal.targetAmount.toStringAsFixed(0)}', 
                       style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: color,
              minHeight: 10,
            ),
          ),
          if (!goal.isCompleted) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  onPressed: () => _generateReport(goal),
                  icon: const Icon(Icons.psychology_rounded, color: Colors.white70),
                  tooltip: 'AI Rapor',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddProgress(goal),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
                    label: const Text('Para Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Bu hedef ${DateFormat('dd MMM yyyy').format(goal.completionDate ?? goal.deadlineDate)} tarihinde tamamlandı! 🎉',
                style: const TextStyle(color: kGreen, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
