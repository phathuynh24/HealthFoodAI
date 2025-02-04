import 'package:app/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyCPjSlkmJCGYyyGf8GZG-XcSzxQgXPf-Uw',
    appId: 'healthfoodai',
    messagingSenderId: 'sendid',
    projectId: 'healthfoodai',
    storageBucket: 'healthfoodai.firebasestorage.app',
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
