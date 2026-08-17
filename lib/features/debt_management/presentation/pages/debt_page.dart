import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({super.key});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedFilterIndex = 0; // 0: Tümü, 1: Bekleyen, 2: Ödenen

  void _showAddDebtDialog(BuildContext context, String uid) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kBgSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Yeni Borç Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Borç / Alacaklı Adı',
                      labelStyle: TextStyle(color: kTextSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kPurple)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kTeal)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Tutar (₺)',
                      labelStyle: TextStyle(color: kTextSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kPurple)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: kTeal)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Son Ödeme Tarihi:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today_rounded, color: kTeal, size: 16),
                        label: Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(color: kTeal, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) {
                            setDialogState(() {
                              selectedDate = date;
                            });
                          }
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
                    final title = titleCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                    if (title.isEmpty || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen geçerli bir başlık ve tutar girin.'), backgroundColor: kRed),
                      );
                      return;
                    }

                    final debtId = const Uuid().v4();
                    await _firestore.collection('debts').doc(debtId).set({
                      'id': debtId,
                      'userId': uid,
                      'title': title,
                      'amount': amount,
                      'dueDate': selectedDate.toIso8601String(),
                      'isPaid': false,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Borç başarıyla eklendi!'), backgroundColor: kGreen),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kPurple),
                  child: const Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteDebt(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Borcu Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('"$title" kaydını silmek istediğinize emin misiniz?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç', style: TextStyle(color: kTextSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('debts').doc(id).delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Borç kaydı silindi.'), backgroundColor: kYellow),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _togglePaidStatus(String id, bool currentStatus) async {
    await _firestore.collection('debts').doc(id).update({
      'isPaid': !currentStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final uid = authState is Authenticated ? authState.user.uid : '';

    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        title: const Text('Borç & Alacak Yönetimi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context, uid),
        backgroundColor: kRed,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('debts')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kRed));
          }

          final docs = snapshot.data?.docs ?? [];
          double totalDebt = 0.0;
          double remainingDebt = 0.0;
          double paidDebt = 0.0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
            final isPaid = data['isPaid'] as bool? ?? false;

            totalDebt += amount;
            if (isPaid) {
              paidDebt += amount;
            } else {
              remainingDebt += amount;
            }
          }

          // Filter
          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isPaid = data['isPaid'] as bool? ?? false;
            if (_selectedFilterIndex == 1) return !isPaid;
            if (_selectedFilterIndex == 2) return isPaid;
            return true;
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: Column(
                    children: [
                      _buildSummaryRow(totalDebt, remainingDebt, paidDebt),
                      const SizedBox(height: 20),
                      _buildFilterTabs(),
                    ],
                  ),
                ),
              ),
              if (filteredDocs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_score_rounded, size: 64, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilterIndex == 2 ? 'Henüz ödenmiş borç yok' : 'Kayıtlı borç bulunamadı',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final id = doc.id;
                        final title = data['title'] as String? ?? 'Borç';
                        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
                        final isPaid = data['isPaid'] as bool? ?? false;
                        final dueDateStr = data['dueDate'] as String?;
                        final dueDate = dueDateStr != null ? DateTime.tryParse(dueDateStr) : null;

                        return _buildDebtCard(
                          id: id,
                          title: title,
                          amount: amount,
                          isPaid: isPaid,
                          dueDate: dueDate,
                        );
                      },
                      childCount: filteredDocs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(double total, double remaining, double paid) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Kalan Borç',
            amount: remaining,
            color: kRed,
            icon: Icons.pending_actions_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Ödenen',
            amount: paid,
            color: kGreen,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₺${amount.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['Tümü', 'Bekleyen', 'Ödenen'];
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = _selectedFilterIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? kPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  filters[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDebtCard({
    required String id,
    required String title,
    required double amount,
    required bool isPaid,
    required DateTime? dueDate,
  }) {
    final isOverdue = dueDate != null && !isPaid && dueDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPaid
              ? kGreen.withOpacity(0.3)
              : (isOverdue ? kRed.withOpacity(0.5) : Colors.white.withOpacity(0.06)),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: () => _togglePaidStatus(id, isPaid),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPaid ? kGreen.withOpacity(0.2) : Colors.white.withOpacity(0.05),
              border: Border.all(color: isPaid ? kGreen : Colors.white.withOpacity(0.3)),
            ),
            child: Icon(
              isPaid ? Icons.check_rounded : Icons.circle_outlined,
              color: isPaid ? kGreen : Colors.white54,
              size: 20,
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: isPaid ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: dueDate != null
            ? Text(
                'Son Ödeme: ${DateFormat('dd MMM yyyy').format(dueDate)}${isOverdue ? ' (Günü Geçti!)' : ''}',
                style: TextStyle(
                  color: isOverdue ? kRed : Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₺${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isPaid ? kGreen : kRed,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: isPaid ? TextDecoration.lineThrough : null,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.white.withOpacity(0.3), size: 20),
              onPressed: () => _confirmDeleteDebt(context, id, title),
            ),
          ],
        ),
      ),
    );
  }
}
