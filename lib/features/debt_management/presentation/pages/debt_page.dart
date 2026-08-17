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
                    keyboardType: TextInputType.number,
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
                        label: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(color: kTeal, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 305)),
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
                    if (title.isEmpty || amount <= 0) return;

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

  void _togglePaidStatus(String id, bool currentStatus) async {
    await _firestore.collection('debts').doc(id).update({
      'isPaid': !currentStatus,
    });
  }

  void _deleteDebt(String id) async {
    await _firestore.collection('debts').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final uid = authState is Authenticated ? authState.user.uid : '';

    return Scaffold(
      backgroundColor: kBgDark,
      appBar: AppBar(
        title: const Text('Borç Yönetimi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('debts')
            .where('userId', isEqualTo: uid)
            .orderBy('dueDate', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          double totalUnpaid = 0.0;
          double totalPaid = 0.0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
            final isPaid = data['isPaid'] as bool? ?? false;
            if (isPaid) {
              totalPaid += amount;
            } else {
              totalUnpaid += amount;
            }
          }

          return Column(
            children: [
              // Top stats summary card
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kBgCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Ödenecek Borç', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text('₺${totalUnpaid.toStringAsFixed(0)}', style: const TextStyle(color: kRed, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white10),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Ödenen Borç', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text('₺${totalPaid.toStringAsFixed(0)}', style: const TextStyle(color: kGreen, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: docs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card_off_rounded, color: Colors.white.withOpacity(0.1), size: 80),
                            const SizedBox(height: 16),
                            Text('Kayıtlı borç bulunmuyor.', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final id = data['id'] as String;
                          final title = data['title'] as String;
                          final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
                          final isPaid = data['isPaid'] as bool? ?? false;
                          final dateStr = data['dueDate'] as String;
                          final dueDate = DateTime.tryParse(dateStr) ?? DateTime.now();

                          final isOverdue = !isPaid && dueDate.isBefore(DateTime.now());

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: kBgCard,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isPaid
                                    ? kGreen.withOpacity(0.2)
                                    : (isOverdue ? kRed.withOpacity(0.4) : Colors.white.withOpacity(0.06)),
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: IconButton(
                                icon: Icon(
                                  isPaid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: isPaid ? kGreen : (isOverdue ? kRed : kTextSecondary),
                                  size: 26,
                                ),
                                onPressed: () => _togglePaidStatus(id, isPaid),
                              ),
                              title: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: isPaid ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  isPaid
                                      ? 'Ödendi'
                                      : 'Vade: ${DateFormat('dd MMM yyyy').format(dueDate)}${isOverdue ? ' (Gecikti!)' : ''}',
                                  style: TextStyle(
                                    color: isPaid
                                        ? kGreen.withOpacity(0.8)
                                        : (isOverdue ? kRed : Colors.white.withOpacity(0.4)),
                                    fontSize: 11,
                                    fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '₺${amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: isPaid ? kGreen : (isOverdue ? kRed : Colors.white),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white30, size: 20),
                                    onPressed: () => _deleteDebt(id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDebtDialog(context, uid),
        backgroundColor: kPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Borç Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
