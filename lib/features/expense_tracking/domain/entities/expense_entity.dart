import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final String type; // 'expense' veya 'income'
  final bool isFixed; // Sabit gider/gelir mi?

  const ExpenseEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.type = 'expense',
    this.isFixed = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        amount,
        category,
        date,
        description,
        type,
        isFixed,
      ];
}
