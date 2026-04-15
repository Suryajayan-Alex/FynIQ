import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/gradient_button.dart';

class BiometricGateScreen extends ConsumerStatefulWidget {
  const BiometricGateScreen({super.key});

  @override
  ConsumerState<BiometricGateScreen> createState() => _BiometricGateScreenState();
}

class _BiometricGateScreenState extends ConsumerState<BiometricGateScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _delayedAuth();
  }

  Future<void> _delayedAuth() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        if (mounted) context.go('/home/dashboard');
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Unlock Fyniq to access your finances 💸',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (didAuthenticate && mounted) {
        context.go('/home/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Authentication error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FyniqScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'assets/images/fyniq_logo.png',
                width: 120,
                height: 120,
              ),
            ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text("Unlock Fyniq 🔐", style: FyniqTextStyles.headingL, textAlign: TextAlign.center)
                .animate()
                .fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text(
              "Use your fingerprint or face to continue.",
              style: FyniqTextStyles.body.copyWith(color: FyniqColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: GradientButton(text: "Unlock Now", onPressed: _authenticate),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }
}
