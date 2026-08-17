import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';

class SetBudgetDialog extends StatefulWidget {
  final String userId;
  final String category;
  final double currentLimit;
  final IconData categoryIcon;
  final Color categoryColor;

  const SetBudgetDialog({
    super.key,
    required this.userId,
    required this.category,
    required this.currentLimit,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  late final TextEditingController _amountCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.currentLimit > 0 ? widget.currentLimit.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir bütçe tutarı girin.'),
          backgroundColor: kRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('budgets')
          .doc(widget.category);

      if (amount == 0) {
        await docRef.delete();
      } else {
        await docRef.set({
          'category': widget.category,
          'limitAmount': amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.category} bütçesi güncellendi!'),
            backgroundColor: kGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bütçe kaydedilemedi: $e'),
            backgroundColor: kRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kBgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.categoryIcon, color: widget.categoryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.category} Bütçesi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Aylık harcama limiti belirleyin',
                  style: TextStyle(color: kTextSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '₺ ',
              prefixStyle: const TextStyle(color: kTeal, fontSize: 20, fontWeight: FontWeight.bold),
              labelText: 'Aylık Limit Tutarı',
              labelStyle: const TextStyle(color: kTextSecondary),
              filled: true,
              fillColor: kBgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kTeal, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '💡 Limiti kaldırmak için 0 yazıp kaydedebilirsiniz.',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç', style: TextStyle(color: kTextSecondary)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBudget,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPurple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
