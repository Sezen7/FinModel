import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../expense_tracking/presentation/bloc/expense_bloc.dart';
import '../../../expense_tracking/presentation/bloc/expense_state.dart';
import '../../../saving_goals/presentation/bloc/goal_bloc.dart';
import '../../../saving_goals/presentation/bloc/goal_state.dart';
import '../../data/datasources/robo_advisor_datasource.dart';

class RoboAdvisorChatPage extends StatefulWidget {
  const RoboAdvisorChatPage({super.key});

  @override
  State<RoboAdvisorChatPage> createState() => _RoboAdvisorChatPageState();
}

class _RoboAdvisorChatPageState extends State<RoboAdvisorChatPage> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final RoboAdvisorDataSource _advisorDataSource = RoboAdvisorDataSourceImpl();

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final List<String> _suggestedPrompts = [
    '💡 Bu ay nasıl tasarruf edebilirim?',
    '📊 Gelirime göre 50/30/20 bütçesi çıkar',
    '💳 Borçlarımı en hızlı nasıl kapatırım?',
    '🎯 Birikim hedeflerime ulaşmak için tavsiye ver',
  ];

  @override
  void initState() {
    super.initState();
    // Add initial greeting message
    _messages.add({
      'role': 'ai',
      'text': 'Merhaba! Ben **FinModel AI Finansal Danışmanın** 🧠\n\nGelirlerinizi, harcamalarınızı ve hedeflerinizi analiz ederek size özel tasarruf ve bütçe stratejileri sunabilirim. Bugün bütçenizle ilgili neyi iyileştirmek istersiniz?',
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? customPrompt]) async {
    final prompt = customPrompt ?? _textCtrl.text.trim();
    if (prompt.isEmpty || _isLoading) return;

    _textCtrl.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': prompt});
      _isLoading = true;
    });
    _scrollToBottom();

    // Get current financial context
    final authState = context.read<AuthBloc>().state;
    final uid = authState is Authenticated ? authState.user.uid : '';

    // Read BLoC states synchronously before async calls
    final expenseState = context.read<ExpenseBloc>().state;
    final goalState = context.read<GoalBloc>().state;

    double monthlyIncome = 0.0;
    double totalExpense = 0.0;
    double totalDebt = 0.0;
    int activeGoalsCount = 0;

    if (expenseState is ExpensesLoaded) {
      final now = DateTime.now();
      for (var e in expenseState.expenses) {
        if (e.date.year == now.year && e.date.month == now.month) {
          totalExpense += e.amount;
        }
      }
    }

    if (goalState is GoalsLoaded) {
      activeGoalsCount = goalState.goals.where((g) => !g.isCompleted).length;
    }

    try {
      if (uid.isNotEmpty) {
        final incomeDoc = await FirebaseFirestore.instance.collection('incomes').doc(uid).get();
        if (incomeDoc.exists && incomeDoc.data() != null) {
          monthlyIncome = (incomeDoc.data()!['amount'] as num?)?.toDouble() ?? 0.0;
        }

        final debtSnap = await FirebaseFirestore.instance
            .collection('debts')
            .where('userId', isEqualTo: uid)
            .get();
        for (var doc in debtSnap.docs) {
          final isPaid = doc.data()['isPaid'] as bool? ?? false;
          if (!isPaid) {
            totalDebt += (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      final aiResponse = await _advisorDataSource.askFinancialAdvisor(
        userMessage: prompt,
        chatHistory: _messages,
        monthlyIncome: monthlyIncome,
        totalExpense: totalExpense,
        totalDebt: totalDebt,
        activeGoalsCount: activeGoalsCount,
      );

      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': aiResponse});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text': '⚠️ Bir hata oluştu: ${e.toString().replaceAll("Exception: ", "")}',
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [kPurple, kTeal]),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Robo-Advisor AI',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Kişisel Finans Koçunuz',
                  style: TextStyle(color: kTeal, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: kBgCard,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Sohbeti Sıfırla',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add({
                  'role': 'ai',
                  'text': 'Sohbet sıfırlandı. Finansal durumunuz veya hedefleriniz hakkında ne sormak istersiniz?',
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _buildMessageBubble(msg['text'] ?? '', isUser);
              },
            ),
          ),
          if (_messages.length <= 2 && !_isLoading) _buildSuggestedChips(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildSuggestedChips() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestedPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final prompt = _suggestedPrompts[i];
          return ActionChip(
            backgroundColor: kBgCard,
            side: BorderSide(color: kPurple.withOpacity(0.4)),
            label: Text(
              prompt,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            onPressed: () => _sendMessage(prompt),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [kPurple, kTeal]),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? kPurple : kBgCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser ? Colors.transparent : Colors.white.withOpacity(0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  if (!isUser && text.length > 50) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cevap panoya kopyalandı!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Icon(Icons.copy_rounded, size: 14, color: Colors.white.withOpacity(0.4)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [kPurple, kTeal]),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: kTeal),
                ),
                const SizedBox(width: 10),
                Text(
                  'Finansal analiz yapılıyor...',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: kBgCard,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Bir finansal soru sorun...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                filled: true,
                fillColor: kBgDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [kPurple, kTeal]),
            ),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _isLoading ? null : () => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }
}
