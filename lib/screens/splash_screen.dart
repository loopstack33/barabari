import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/budget_controller.dart';
import 'home_screen.dart';

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
      backgroundColor: const Color(0xFFF6F5F1),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 128,
                    height: 128,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Barabri',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2A2A26)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'balance your income, on purpose',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B6A63)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
