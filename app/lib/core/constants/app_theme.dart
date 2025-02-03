import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Define gradient
  static const Gradient primaryGradient = LinearGradient(
    colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryGreen,
    scaffoldBackgroundColor: AppColors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: TextStyle(
          color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreen),
      headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.darkGray),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.mediumGray),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryGreen,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.darkGreen,
    scaffoldBackgroundColor: AppColors.darkGray,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkGreen,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: TextStyle(
          color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.white),
      headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.lightGreen),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.lightGray),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.mediumGray),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.secondaryGreen,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryGreen,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
  );
}
