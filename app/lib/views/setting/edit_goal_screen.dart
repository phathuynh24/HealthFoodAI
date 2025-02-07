import 'package:app/core/firebase/firebase_constants.dart';
import 'package:app/views/user_info_survey/weight_change_selection.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/goal_item.dart';
import 'package:app/widgets/weight_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditGoalScreen extends StatefulWidget {
  const EditGoalScreen({Key? key}) : super(key: key);

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (docSnapshot.exists) {
          setState(() {
            userData = docSnapshot.data();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateUserData(String key, dynamic value) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({key: value});

        setState(() {
          userData?[key] = value;
        });
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  String _getWeightChangeSubtitle(Map<String, dynamic>? userData) {
    final goal = userData?[UserFields.goal];
    final weightChangeRate = userData?[UserFields.weightChangeRate];

    if (goal == "Duy trì cân nặng" || weightChangeRate == null) {
      return "";
    }

    final formattedRate =
        weightChangeRate.toStringAsFixed(1); // Giữ 1 chữ số thập phân

    if (goal == "Giảm cân") {
      return "Giảm $formattedRate kg mỗi tuần";
    } else if (goal == "Tăng cân") {
      return "Tăng $formattedRate kg mỗi tuần";
    } else {
      return "Mục tiêu không xác định";
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(context, userData);
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: "Mục tiêu"),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildGoalItem(
                      title: "Cân nặng hiện tại",
                      value: "${userData?['weight'] ?? '--'} kg",
                      onTap: () {
                        // showModalBottomSheet(
                        //   context: context,
                        //   shape: const RoundedRectangleBorder(
                        //     borderRadius:
                        //         BorderRadius.vertical(top: Radius.circular(20)),
                        //   ),
                        //   builder: (_) {
                        //     return WeightPickerBottomSheet(
                        //       initialWeight:
                        //           (userData?['weight'] ?? 60).toDouble(),
                        //       onSelected: (newWeight) {
                        //         setState(() {
                        //           userData?['weight'] = newWeight;
                        //         });
                        //         _updateUserData('weight', newWeight);
                        //       },
                        //     );
                        //   },
                        // );
                      },
                      valueColor: Colors.deepOrange,
                    ),
                    const SizedBox(height: 20),
                    GoalItem(
                      title: "Cân nặng mục tiêu",
                      value: userData?[UserFields.goal] ?? "Duy trì cân nặng",
                      subValue: _getWeightChangeSubtitle(userData),
                      targetWeight: userData?[UserFields.goal] ==
                              "Duy trì cân nặng"
                          ? ""
                          : "${userData?[UserFields.targetWeight] ?? '--'} kg",
                      onTap: () async {
                        final updatedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WeightChangeSelectionScreen(
                              isSetting: true,
                              surveyData: userData ?? {},
                            ),
                            settings: const RouteSettings(
                                name:
                                    'WeightChangeSelectionScreen'), // Đặt tên cho route
                          ),
                        );

                        if (updatedData != null && mounted) {
                          setState(() {
                            userData = updatedData; // Cập nhật dữ liệu mới
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGoalItem({
    required String title,
    required String value,
    required VoidCallback onTap,
    Color valueColor = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
                // const Icon(Icons.arrow_forward_ios,
                //     size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
