import 'package:flutter/material.dart';
import '../../domain/entities/goal_entity.dart';
import '../../../../core/constants/app_colors.dart';

class AddProgressDialog extends StatefulWidget {
  final GoalEntity goal;
  const AddProgressDialog({super.key, required this.goal});

  @override
  State<AddProgressDialog> createState() => _AddProgressDialogState();
}

class _AddProgressDialogState extends State<AddProgressDialog> {
  final _amountCtrl = TextEditingController();
  
  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
    
    return AlertDialog(
      backgroundColor: kBgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Para Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Kumbara: ${widget.goal.title}', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: '₺0.0',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kalan: ₺${remaining.toStringAsFixed(2)}',
            style: TextStyle(color: kRed.withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: kTextMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
            if (val > 0) {
              Navigator.pop(context, val);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: kPurple),
          child: const Text('Kumbara\'ya At'),
        ),
      ],
    );
  }
}
