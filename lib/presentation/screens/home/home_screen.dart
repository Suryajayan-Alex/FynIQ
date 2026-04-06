import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';

class HomeScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  
  const HomeScreen({super.key, required this.navigationShell});

  void _onTabTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return FyniqScaffold(
      body: Stack(
        children: [
          navigationShell,
          Align(
            alignment: Alignment.bottomCenter,
            child: _FyniqBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: _onTabTapped,
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.82),
            child: _FyniqFAB(
              onTap: () => context.push('/add-transaction'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FyniqBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FyniqBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 72,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Iconsax.home_2,
                  label: "Home",
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Iconsax.chart_2,
                  label: "Analytics",
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                const SizedBox(width: 48), // Space for FAB
                _NavItem(
                  icon: Iconsax.wallet_2,
                  label: "Budgets",
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Iconsax.setting_2,
                  label: "Settings",
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? FyniqColors.primaryAccent : FyniqColors.textSecondary,
            size: 24,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [FyniqColors.primaryAccent, FyniqColors.highlightCTA],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FyniqFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _FyniqFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 140,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [FyniqColors.primaryAccent, FyniqColors.highlightCTA],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: FyniqColors.primaryAccent.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.add, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              "Add",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      )
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .scaleXY(begin: 1.0, end: 1.03, duration: 1500.ms, curve: Curves.easeInOutCubic),
    );
  }
}
