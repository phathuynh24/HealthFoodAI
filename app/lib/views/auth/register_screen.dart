import 'package:app/core/firebase/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/loading_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _saveUserToFirestore(User user) async {
    await FirebaseFirestore.instance.collection(FirebaseConstants.usersCollection)
    .doc(user.uid)
    .set({
      UserFields.uid: user.uid,
      UserFields.email: user.email,
      // UserFields.fullName: _fullNameController.text.trim(),
      UserFields.createdAt: FieldValue.serverTimestamp(),
      UserFields.status: "active",
      UserFields.isFirstLogin: true,
      UserFields.gender: "",
      UserFields.age: 0,
      UserFields.height: 0,
      UserFields.weight: 0,
      UserFields.targetWeight: 0,
      UserFields.activityLevel: "",
      UserFields.goal: "",
      UserFields.calories: 0,
      UserFields.weightChangeRate: 0,
      UserFields.surveyHistory: [],
    });
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (
        // _fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      CustomSnackbar.show(context, 'Vui lòng nhập đầy đủ thông tin!',
          isSuccess: false);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      CustomSnackbar.show(context, 'Mật khẩu nhập lại không khớp!',
          isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      if (!mounted) return;
      CustomSnackbar.show(context, 'Đăng ký thành công!', isSuccess: true);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'Đăng ký thất bại!';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email này đã được sử dụng!';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ!';
          break;
        case 'weak-password':
          errorMessage = 'Mật khẩu quá yếu! Hãy thử mật khẩu mạnh hơn.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Tính năng đăng ký chưa được bật!';
          break;
        case 'network-request-failed':
          errorMessage = 'Lỗi kết nối mạng, kiểm tra Internet!';
          break;
        default:
          errorMessage = e.message ?? 'Đăng ký thất bại!';
      }

      CustomSnackbar.show(context, errorMessage, isSuccess: false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image
                      SizedBox(
                          width: 300,
                          height: 300,
                          child: Image.asset('assets/register.png',
                              fit: BoxFit.cover)),
                      const SizedBox(height: 50),

                      // Name
                      // TextFormField(
                      //   controller: _fullNameController,
                      //   decoration: InputDecoration(
                      //     labelText: 'Họ và Tên',
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12.0),
                      //     ),
                      //     filled: true,
                      //     fillColor: Colors.white,
                      //   ),
                      // ),
                      // const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Nhập lại mật khẩu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Button Register
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text(
                            'Đăng Ký',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Back to Login
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Quay lại Đăng nhập',
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: LoadingIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
