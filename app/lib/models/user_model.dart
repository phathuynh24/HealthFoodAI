import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/core/firebase/firebase_constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String gender;
  final int age;
  final int height;
  final double weight;
  final double targetWeight;
  final String activityLevel;
  final String goal;
  final double calories;
  final double weightChangeRate;
  final bool isFirstLogin;
  final String status;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<Map<String, dynamic>> surveyHistory;
  final List<Map<String, dynamic>> weightHistory;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.targetWeight,
    required this.activityLevel,
    required this.goal,
    required this.calories,
    required this.isFirstLogin,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.surveyHistory,
    required this.weightChangeRate,
    required this.weightHistory,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data[UserFields.uid] ?? '',
      email: data[UserFields.email] ?? '',
      fullName: data[UserFields.fullName] ?? '',
      gender: data[UserFields.gender] ?? '',
      age: data[UserFields.age] ?? 0,
      height: data[UserFields.height] ?? 0,
      weight: (data[UserFields.weight] ?? 0).toDouble(),
      targetWeight: (data[UserFields.targetWeight] ?? 0).toDouble(),
      activityLevel: data[UserFields.activityLevel] ?? '',
      goal: data[UserFields.goal] ?? '',
      calories: (data[UserFields.calories] ?? 0).toDouble(),
      isFirstLogin: data[UserFields.isFirstLogin] ?? true,
      status: data[UserFields.status] ?? 'active',
      createdAt: data[UserFields.createdAt] ?? Timestamp.now(),
      updatedAt: data[UserFields.updatedAt] ?? Timestamp.now(),
      surveyHistory: (data[UserFields.surveyHistory] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      weightChangeRate: (data[UserFields.weightChangeRate] ?? 0).toDouble(),
      weightHistory: (data[UserFields.weightHistory] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserFields.uid: uid,
      UserFields.email: email,
      UserFields.fullName: fullName,
      UserFields.gender: gender,
      UserFields.age: age,
      UserFields.height: height,
      UserFields.weight: weight,
      UserFields.targetWeight: targetWeight,
      UserFields.activityLevel: activityLevel,
      UserFields.goal: goal,
      UserFields.calories: calories,
      UserFields.isFirstLogin: isFirstLogin,
      UserFields.status: status,
      UserFields.createdAt: createdAt,
      UserFields.updatedAt: updatedAt,
      UserFields.surveyHistory: surveyHistory,
      UserFields.weightChangeRate: weightChangeRate,
      UserFields.weightHistory: weightHistory,
    };
  }
}
