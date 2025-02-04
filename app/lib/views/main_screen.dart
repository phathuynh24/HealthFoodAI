import "package:app/core/theme/app_colors.dart";
import "package:app/views/home/home_screen.dart";
import "package:flutter/material.dart";
import "package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart";

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  List<PersistentTabConfig> _tabs() => [
        // Home Screen
        PersistentTabConfig(
          screen: const HomeScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.home),
            title: "Trang chủ",
            activeForegroundColor: AppColors.activeColor,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
        // Recomendation Food Screen
        PersistentTabConfig(
          screen: const SafeArea(child: Center(child: Text("Gợi ý món ăn"))),
          item: ItemConfig(
            icon: const Icon(Icons.restaurant_menu),
            title: "Gợi ý món ăn",
            activeForegroundColor: AppColors.activeColor,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
        // Regonize Screen
        PersistentTabConfig(
          screen: const SafeArea(child: Center(child: Text("➕ Chức năng giữa"))),
          item: ItemConfig(
            icon: _buildCenterButton(),
            title: "Nhận diện món ăn",
            activeForegroundColor: Colors.transparent,
            inactiveForegroundColor: Colors.transparent,
          ),
        ),
        // Excercise Screen
        PersistentTabConfig(
          screen: const SafeArea(child: Center(child: Text("🏋️ Thể dục"))),
          item: ItemConfig(
            icon: const Icon(Icons.fitness_center),
            title: "Thể dục",
            activeForegroundColor: AppColors.activeColor,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
        // Setting Screen
        PersistentTabConfig(
          screen: const SafeArea(child: Center(child: Text("⚙️ Cài đặt"))),
          item: ItemConfig(
            icon: const Icon(Icons.settings),
            title: "Cài đặt",
            activeForegroundColor: AppColors.activeColor,
            inactiveForegroundColor: Colors.grey,
          ),
        ),
      ];

  static Widget _buildCenterButton() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.activeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      backgroundColor: Colors.white,
      tabs: _tabs(),
      navBarBuilder: (navBarConfig) => Style13BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: const NavBarDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
      ),
      navBarOverlap: const NavBarOverlap.full(),
    );
  }
}
