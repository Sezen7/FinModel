import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/expense_entity.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Diğer';
  bool _isFixed = false;

  final List<String> _categories = [
    'Market',
    'Yeme-İçme',
    'Ulaşım',
    'Alışveriş',
    'Eğlence',
    'Eğitim',
    'Fatura',
    'Sağlık',
    'Diğer'
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);

    if (pickedFile != null && context.mounted) {
      final bytes = await pickedFile.readAsBytes();
      final mimeType = pickedFile.mimeType ?? 'image/jpeg';
      context.read<ExpenseBloc>().add(AnalyzeReceiptImageEvent(bytes, mimeType));
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      final userId = authState is Authenticated ? authState.user.uid : 'demo_user_123';
      
      final expense = ExpenseEntity(
        id: const Uuid().v4(),
        userId: userId,
        title: _titleCtrl.text.trim(),
        amount: double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0.0,
        category: _selectedCategory,
        date: DateTime.now(),
        description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
        type: 'expense',
        isFixed: _isFixed,
      );

      context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harcama kaydedildi.'), backgroundColor: kGreen));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcama Ekle'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is AiAnalysisSuccess) {
            _titleCtrl.text = state.analyzedData.title;
            _amountCtrl.text = state.analyzedData.amount.toString();
            if (_categories.contains(state.analyzedData.category)) {
              setState(() {
                _selectedCategory = state.analyzedData.category;
              });
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Fiş başarıyla analiz edildi ve form dolduruldu!'),
                  backgroundColor: kGreen),
            );
          } else if (state is ExpenseActionSuccess) {
            Navigator.pop(context, true); // Go back after success
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: kRed),
            );
          }
        },
        builder: (context, state) {
          final isAiLoading = state is AiAnalysisLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // AI Button Area
                      _buildScanCard(isAiLoading),
                      const SizedBox(height: 32),
                      
                      // Manual Form Area
                      const Text('VEYA', textAlign: TextAlign.center, style: TextStyle(color: kTextMuted, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),

                      _buildTextField(
                        controller: _titleCtrl,
                        label: 'Firma / Başlık',
                        icon: Icons.store_rounded,
                        validator: (v) => v!.isEmpty ? 'Gereklidir' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildTextField(
                        controller: _amountCtrl,
                        label: 'Tutar (₺)',
                        icon: Icons.attach_money_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Gereklidir';
                          if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Geçerli bir sayı girin';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _descCtrl,
                        label: 'Açıklama (İsteğe Bağlı)',
                        icon: Icons.notes_rounded,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Bu Sabit Bir Harcamadır', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Kira, fatura, abonelik gibi düzenli giderler', style: TextStyle(color: kTextMuted, fontSize: 12)),
                        value: _isFixed,
                        activeColor: kPurple,
                        onChanged: (val) => setState(() => _isFixed = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: isAiLoading ? null : _saveExpense,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        child: const Text('Harcamayı Kaydet', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              if (isAiLoading)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: kTeal),
                        const SizedBox(height: 16),
                        Text('Yapay Zeka Fişi Analiz Ediyor...', 
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: kGradientCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Fiş / Fatura Tarat Saniyeler İçinde Doldurulsun (AI)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: isLoading ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                label: const Text('Kamera', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: isLoading ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 18),
                label: const Text('Galeri', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: kTextMuted, size: 20),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      dropdownColor: kBgSurface,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Kategori',
        prefixIcon: Icon(Icons.category_rounded, color: kTextMuted, size: 20),
      ),
      items: _categories.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(cat),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedCategory = val;
          });
        }
      },
      validator: (v) => v == null ? 'Gereklidir' : null,
    );
  }
}
