import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(ExpenseModel expense);
  Stream<List<ExpenseModel>> getExpenses(String userId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore firestore;

  ExpenseRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await firestore
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toJson());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await firestore.collection('expenses').doc(id).delete();
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await firestore
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toJson());
  }

  @override
  Stream<List<ExpenseModel>> getExpenses(String userId) {
    return firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
