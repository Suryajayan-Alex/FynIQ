import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../domain/providers/database_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> { // Fixed double underscore
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name 👤")),
      );
      return;
    }

    final settingsRepo = ref.read(settingsRepositoryProvider);
    await settingsRepo.setUserName(name);

    final incomeText = _incomeController.text.trim();
    if (incomeText.isNotEmpty) {
      await settingsRepo.setMonthlyIncomeGoal(double.tryParse(incomeText) ?? 0);
    }

    await settingsRepo.setIsFirstLaunch(false);

    final catRepo = ref.read(categoryRepositoryProvider);
    await catRepo.seedDefaultCategories();

    if (mounted) {
      context.go('/home/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FyniqScaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _buildPage0(),
                _buildPage1(),
                _buildPage2(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _PageDots(count: 3, index: _currentPage),
                const SizedBox(height: 16),
                GradientButton(
                  text: _currentPage == 2 ? "Let's get smart 🚀" : "Continue",
                  onPressed: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage0() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40, left: 24, right: 24),
      child: Center(
        child: Column(
          children: [
            const _IllustrationCircle(emoji: '💸', color: FyniqColors.primaryAccent),
            const SizedBox(height: 32),
            Text(
              'Outsmart Your\nSpending 💸',
              style: FyniqTextStyles.headingXL,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Track every rupee, know every pattern,\nand never lose control of your cash.',
              style: FyniqTextStyles.body.copyWith(color: FyniqColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40, left: 24, right: 24),
      child: Center(
        child: Column(
          children: [
            const _IllustrationCircle(emoji: '🎯', color: FyniqColors.highlightCTA),
            const SizedBox(height: 32),
            Text(
              'Budget Like\nYou Mean It 🎯',
              style: FyniqTextStyles.headingXL,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Set limits per category. Fyniq alerts\nyou before you blow past them.',
              style: FyniqTextStyles.body.copyWith(color: FyniqColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40, left: 24, right: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Quick Setup ⚡',
              style: FyniqTextStyles.headingXL,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("What should we call you? 👤", style: FyniqTextStyles.caption),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: FyniqTextStyles.body,
              decoration: const InputDecoration(
                hintText: "Your name...",
                prefixIcon: Icon(Iconsax.user, color: FyniqColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Monthly income? (optional) 💰", style: FyniqTextStyles.caption),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              style: FyniqTextStyles.body,
              decoration: const InputDecoration(
                hintText: "₹ 0.00",
                prefixIcon: Icon(Iconsax.wallet, color: FyniqColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationCircle extends StatelessWidget {
  final String emoji;
  final Color color;
  const _IllustrationCircle({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.4), Colors.transparent],
        ),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 56)),
      ),
    )
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 2000.ms, curve: Curves.easeInOut);
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int index;
  const _PageDots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isSelected = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
