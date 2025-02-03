import 'package:app/core/constants/firebase_constants.dart';
import 'package:app/models/user_model.dart';
import 'package:app/views/auth/forgot_password_screen.dart';
import 'package:app/views/home/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/views/auth/register_screen.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/loading_indicator.dart';
import 'package:app/views/user_info_survey/gender_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      CustomSnackbar.show(context, 'Vui lòng nhập đầy đủ email và mật khẩu',
          isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
            code: 'unknown-error', message: 'Đăng nhập thất bại!');
      }

      // Get user data
      DocumentSnapshot userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(
            code: 'user-not-found', message: 'Tài khoản không tồn tại!');
      }

      UserModel currentUser =
          UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

      if (!mounted) return;
      CustomSnackbar.show(context, 'Đăng nhập thành công!', isSuccess: true);

      // Check if user is first login
      if (currentUser.isFirstLogin) {
        // Survey data when first login
        Map<String, dynamic> surveyData = {
          UserFields.uid: currentUser.uid,
          UserFields.email: currentUser.email,
          UserFields.isFirstLogin: currentUser.isFirstLogin,
        };
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GenderSelectionScreen(surveyData: surveyData),
          ),
        );
      }
      // If user is not first login
      else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'Đăng nhập thất bại!';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Tài khoản không tồn tại!';
          break;
        case 'wrong-password':
          errorMessage = 'Sai mật khẩu, vui lòng thử lại!';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ!';
          break;
        case 'network-request-failed':
          errorMessage = 'Lỗi kết nối mạng, kiểm tra Internet!';
          break;
        case 'too-many-requests':
          errorMessage = 'Bạn đã nhập sai quá nhiều lần, thử lại sau!';
          break;
        case 'invalid-credential':
          errorMessage = 'Lỗi xác thực tài khoản, vui lòng thử lại!';
          break;
        case 'internal-error':
          errorMessage = 'Lỗi hệ thống, thử lại sau!';
          break;
        case 'session-cookie-expired':
          errorMessage = 'Phiên đăng nhập đã hết hạn!';
          break;
        case 'recaptcha-check-failed':
          errorMessage = 'Lỗi bảo mật, thử lại sau!';
          break;
        case 'auth/invalid-login-credentials':
          errorMessage = 'Email hoặc mật khẩu không chính xác!';
          break;
        default:
          errorMessage = e.message ?? 'Đăng nhập thất bại!';
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
    _passwordController.dispose();
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
                      // Logo
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset('assets/app_icon.png',
                              fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 65),

                      // Email Input Field
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

                      // Password Input Field
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
                      const SizedBox(height: 24),

                      // Button Login
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            minimumSize: const Size.fromHeight(55),
                          ),
                          child: const Text(
                            'Đăng Nhập',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Chưa có tài khoản?",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16)),
                          TextButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen()),
                              );
                            },
                            child: const Text(
                              'Đăng ký ngay!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),

                      // Forgot Password
                      TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(color: Colors.red, fontSize: 16),
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
