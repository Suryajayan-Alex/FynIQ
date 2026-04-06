import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: FyniqColors.background,
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [FyniqColors.primaryAccent, FyniqColors.highlightCTA]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: FyniqColors.primaryAccent.withOpacity(0.4), blurRadius: 20)],
                  ),
                  child: Center(
                    child: Text("F",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: -8, end: 8, duration: 1500.ms, curve: Curves.easeInOut),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  "FYNIQ",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Text(
                  "Outsmart your spending.",
                  style: FyniqTextStyles.caption.copyWith(color: Colors.grey, letterSpacing: 1),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
