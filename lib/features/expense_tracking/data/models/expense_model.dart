import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.amount,
    required super.category,
    required super.date,
    super.description,
    super.type = 'expense',
    super.isFixed = false,
  });

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      amount: entity.amount,
      category: entity.category,
      date: entity.date,
      description: entity.description,
      type: entity.type,
      isFixed: entity.isFixed,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ExpenseModel(
      id: documentId,
      userId: json['userId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: (json['date'] as Timestamp).toDate(),
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'expense',
      isFixed: json['isFixed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'description': description,
      'type': type,
      'isFixed': isFixed,
    };
  }
}
