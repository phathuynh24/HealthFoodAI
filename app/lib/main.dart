import 'package:app/login_screen.dart';
import 'package:app/recipe_recommendation_screen';
import 'package:flutter/material.dart';
import 'package:app/product_scan.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
      apiKey: 'AIzaSyCPjSlkmJCGYyyGf8GZG-XcSzxQgXPf-Uw',
      appId: 'healthfoodai',
      messagingSenderId: 'sendid',
      projectId: 'healthfoodai',
      storageBucket: 'healthfoodai.firebasestorage.app',
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RecipeRecommendationScreen(),
    );
  }
}
