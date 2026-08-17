import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<void> addGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String id);
  Stream<List<GoalModel>> getGoals(String userId);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final FirebaseFirestore firestore;

  GoalRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addGoal(GoalModel goal) async {
    await firestore.collection('goals').doc(goal.id).set(goal.toJson());
  }

  @override
  Future<void> deleteGoal(String id) async {
    await firestore.collection('goals').doc(id).delete();
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await firestore.collection('goals').doc(goal.id).update(goal.toJson());
  }

  @override
  Stream<List<GoalModel>> getGoals(String userId) {
    return firestore
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .orderBy('deadlineDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GoalModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
