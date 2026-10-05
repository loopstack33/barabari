import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/budget_controller.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  final BudgetController _controller = Get.find<BudgetController>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
    _navigateWhenReady();
  }

  Future<void> _navigateWhenReady() async {
    final minDelay = Future.delayed(const Duration(milliseconds: 1400));
    // Wait until the controller has finished loading persisted data, so the
    // dashboard doesn't flash a loading spinner right after the splash.
    while (_controller.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    await minDelay;
    if (!mounted) return;
    Get.offAll(() => const HomeScreen());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icon/spLogo.png',
                ),
                Text(
                  'Balance your income, on purpose',
                  style: TextStyle(fontSize: 14, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
