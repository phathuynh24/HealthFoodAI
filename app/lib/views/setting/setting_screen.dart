import 'package:app/core/theme/app_theme.dart';
import 'package:app/views/auth/login_screen.dart';
import 'package:app/views/setting/edit_goal_screen.dart';
import 'package:app/widgets/activity_level_picker_bottom_sheet.dart';
import 'package:app/widgets/custom_picker_bottom_sheet.dart';
import 'package:app/widgets/weight_picker_bottom_sheet';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isLoading = true;
  Map<String, dynamic>? userData;
  String appVersion = "";

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "Version ${packageInfo.version}";
    });
  }

  Future<void> _getUserData() async {
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
      print('Lỗi khi tải dữ liệu người dùng: $e');
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

        // Cập nhật trực tiếp giá trị và làm mới UI
        setState(() {
          userData?[key] = value;
        });
      }
    } catch (e) {
      print('Lỗi khi cập nhật dữ liệu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent.withOpacity(0.1),
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAccountDetails(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Tài khoản', style: TextStyle(fontSize: 20)),
      centerTitle: true,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
    );
  }

  Widget _buildAccountDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildFeatureSection(
            items: [
              _buildFeatureItem(
                icon: CupertinoIcons.person_fill,
                color: Colors.blue,
                title: "Giới tính",
                subtitle: userData?['gender'] == "Male" ? "Nam" : "Nữ",
                onTap: () {
                  _showPicker(
                    context: context,
                    title: "Chọn Giới Tính",
                    options: ["Male", "Female"],
                    currentValue: userData?['gender'] ?? "Male",
                    onSelected: (value) => _updateUserData('gender', value),
                    displayValue: (value) => value == "Male" ? "Nam" : "Nữ",
                  );
                },
              ),
              _buildFeatureItem(
                icon: Icons.height,
                color: Colors.red,
                title: "Chiều cao",
                subtitle: "${userData?['height'] ?? '--'} cm",
                onTap: () {
                  _showPicker(
                    context: context,
                    title: "Chọn Chiều Cao",
                    options: List.generate(
                        100, (index) => index + 100), // 100-200 cm
                    currentValue: userData?['height'] ?? 170,
                    onSelected: (value) => _updateUserData('height', value),
                    displayValue: (value) => "$value cm",
                  );
                },
              ),
              _buildFeatureItem(
                icon: Icons.cake,
                color: Colors.indigo,
                title: "Tuổi",
                subtitle: "${userData?['age'] ?? '--'}",
                onTap: () {
                  _showPicker(
                    context: context,
                    title: "Chọn Tuổi",
                    options: List.generate(100, (index) => index + 1),
                    currentValue: userData?['age'] ?? 25,
                    onSelected: (value) => _updateUserData('age', value),
                  );
                },
              ),
              _buildFeatureItem(
                icon: Icons.monitor_weight,
                color: Colors.orange,
                title: "Cân nặng",
                subtitle: "${userData?['weight'] ?? '--'} kg",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) {
                      return WeightPickerBottomSheet(
                        initialWeight: (userData?['weight'] ?? 60).toDouble(),
                        onSelected: (newWeight) {
                          setState(() {
                            userData?['weight'] = newWeight;
                          });
                          _updateUserData('weight', newWeight);
                        },
                      );
                    },
                  );
                },
              ),
              _buildFeatureItem(
                icon: Icons.directions_run,
                color: Colors.green,
                title: "Hoạt động",
                subtitle: userData?['activityLevel'] ?? "Không rõ",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return ActivityLevelPickerBottomSheet(
                        selectedActivityLevel: userData?['activityLevel'] ??
                            "Không vận động nhiều",
                        onSelected: (value) {
                          _updateUserData('activityLevel', value);
                        },
                      );
                    },
                  );
                },
              ),
              _buildFeatureItem(
                icon: Icons.flag,
                color: Colors.purple,
                title: "Mục tiêu",
                subtitle: userData?['goal'] ?? "Không rõ",
                showDivider: false,
                onTap: () async {
                  final updatedData =
                      await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const EditGoalScreen(),
                    ),
                  );

                  // Nếu có dữ liệu trả về thì cập nhật lại giao diện
                  if (updatedData != null && mounted) {
                    setState(() {
                      userData = updatedData;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildFeatureSection(
            items: [
              _buildFeatureItem(
                icon: Icons.info_outline,
                color: Colors.grey,
                title: "Phiên bản",
                subtitle: appVersion.isNotEmpty ? appVersion : "Đang tải...",
                onTap: () {},
              ),
              _buildFeatureItem(
                icon: Icons.logout,
                color: Colors.redAccent,
                title: "Đăng xuất",
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  void _showPicker<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required T currentValue,
    required ValueChanged<T> onSelected,
    String Function(T)? displayValue,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return CustomPickerBottomSheet<T>(
          title: title,
          options: options,
          selectedValue: currentValue,
          onSelected: onSelected,
          displayValue: displayValue,
        );
      },
    );
  }

  Widget _buildFeatureSection({required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    String subtitle = "",
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color, size: 30),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 4,
            indent: 15,
            endIndent: 15,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}
