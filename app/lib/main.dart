import 'package:app/information_screen/gender_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/product_scan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: GenderSelectionScreen(),
      home: ProductScanScreen(),
    );
  }
}