import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/loading_indicator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty) {
      CustomSnackbar.show(context, 'Vui lòng nhập email', isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());

      if (!mounted) return;
      CustomSnackbar.show(context, 'Link đặt lại mật khẩu đã được gửi!',
          isSuccess: true);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'Có lỗi xảy ra!';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email này chưa đăng ký tài khoản!';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ!';
          break;
        case 'network-request-failed':
          errorMessage = 'Lỗi kết nối mạng, kiểm tra Internet!';
          break;
        default:
          errorMessage = e.message ?? 'Không thể gửi yêu cầu!';
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
    _emailController.dispose();
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
                          child: Image.asset('assets/forgot_password.png',
                              fit: BoxFit.cover)),
                      const SizedBox(height: 20),

                      const Text(
                        'Quên Mật Khẩu',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Input Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Nhập email của bạn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Button Reset Password
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text(
                            'Gửi Yêu Cầu',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Back to Login
                      TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
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
