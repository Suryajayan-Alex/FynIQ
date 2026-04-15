import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/providers/database_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(2.seconds);
    if (!mounted) return;

    final settings = ref.read(settingsRepositoryProvider);
    final isFirstLaunch = await settings.getIsFirstLaunch();
    final isBiometricEnabled = await settings.getIsBiometricEnabled();

    if (isFirstLaunch) {
      context.go('/onboarding');
    } else if (isBiometricEnabled) {
      context.go('/biometric-gate');
    } else {
      context.go('/home/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FyniqColors.backgroundAlt,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: FyniqColors.primaryAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/images/fyniq_logo.png',
                    width: 160,
                    height: 160,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: -8, end: 8, duration: 1500.ms, curve: Curves.easeInOut)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
