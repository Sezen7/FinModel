import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryBudget {
  final String category;
  final double limitAmount;
  final DateTime updatedAt;

  const CategoryBudget({
    required this.category,
    required this.limitAmount,
    required this.updatedAt,
  });

  factory CategoryBudget.fromFirestore(Map<String, dynamic> data) {
    return CategoryBudget(
      category: data['category'] as String? ?? 'Diğer',
      limitAmount: (data['limitAmount'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limitAmount': limitAmount,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
