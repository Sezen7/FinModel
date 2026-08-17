import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/goal_entity.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  int _durationMonths = 12;
  DateTime? _selectedDate;
  
  // Example Colors Setup
  final List<String> _colors = ['FF7F5AF0', 'FF2CB67D', 'FFFF6B6B', 'FF4ECDC4', 'FFF7DC6F'];
  late String _selectedColorHex;

  @override
  void initState() {
    super.initState();
    _selectedColorHex = _colors[0];
    _updateDeadlineFromDuration();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _updateDeadlineFromDuration() {
    setState(() {
      _selectedDate = DateTime.now().add(Duration(days: _durationMonths * 30));
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPurple,
              surface: kBgCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen hedef süresi seçin.')));
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.uid : 'demo_user_123';
    final targetAmount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final monthlyContribution = _durationMonths > 0 ? targetAmount / _durationMonths : 0.0;

    final goal = GoalEntity(
      id: const Uuid().v4(),
      userId: userId,
      title: _titleCtrl.text.trim(),
      targetAmount: targetAmount,
      currentAmount: 0.0,
      deadlineDate: _selectedDate!,
      createdAt: DateTime.now(),
      colorHex: _selectedColorHex,
      monthlyContribution: monthlyContribution,
      durationMonths: _durationMonths,
      progressHistory: [0.0],
    );

    context.read<GoalBloc>().add(AddGoalSubmitEvent(goal));
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hedef kaydedildi.'), backgroundColor: kGreen));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Hedef Ekle'),
        backgroundColor: Colors.transparent,
      ),
      body: BlocListener<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalActionSuccess) {
            Navigator.pop(context, true);
          } else if (state is GoalError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: kRed));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kBgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.flag_circle_rounded, color: kPurple, size: 64),
                      const SizedBox(height: 16),
                      Text('Ne İçin Biriktiriyoruz?', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleCtrl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Örn: Yeni Araba',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: (v) => v!.isEmpty ? 'Gereklidir' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Büyük Hedef Tutarı (₺)',
                    prefixIcon: Icon(Icons.stars_rounded, color: kTextMuted),
                  ),
                  validator: (v) => v!.isEmpty ? 'Gereklidir' : null,
                ),
                const SizedBox(height: 24),

                const Text('Hedef Süresi (Ay)', style: TextStyle(color: kTextMuted, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _durationMonths.toDouble(),
                        min: 1,
                        max: 60,
                        divisions: 59,
                        activeColor: kPurple,
                        label: '$_durationMonths Ay',
                        onChanged: (val) {
                          setState(() {
                            _durationMonths = val.toInt();
                            _updateDeadlineFromDuration();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      child: Text('$_durationMonths', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: kTextMuted),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate == null 
                                  ? 'Bitiş Tarihi Seç' 
                                  : DateFormat('dd MMM yyyy').format(_selectedDate!),
                              style: TextStyle(color: _selectedDate == null ? kTextMuted : Colors.white),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: kTextMuted, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text('Kart Rengi', style: TextStyle(color: kTextMuted, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _colors.map((c) {
                    final color = Color(int.parse(c, radix: 16));
                    final isSelected = _selectedColorHex == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorHex = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent, 
                            width: 3
                          ),
                          boxShadow: [
                            if (isSelected) BoxShadow(color: color.withOpacity(0.6), blurRadius: 10)
                          ]
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                  child: const Text('Hedefi Başlat', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
