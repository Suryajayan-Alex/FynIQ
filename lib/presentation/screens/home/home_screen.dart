import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: FyniqColors.background,
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
            alignment: const Alignment(0, 0.88),
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
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: FyniqColors.primaryAccent.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
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
                  label: "Report",
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                const SizedBox(width: 48), // Space for FAB
                _NavItem(
                  icon: Iconsax.wallet_2,
                  label: "Plan",
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
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? FyniqColors.primaryAccent : FyniqColors.textSecondary,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: FyniqColors.primaryAccent,
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FyniqColors.primaryAccent, FyniqColors.highlightCTA],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: FyniqColors.primaryAccent.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Iconsax.add, color: Colors.white, size: 28),
      )
      .animate(onPlay: (c) => c.repeat(reverse: true))
      .scaleXY(begin: 1.0, end: 1.05, duration: 1500.ms, curve: Curves.easeInOutCubic),
    );
  }
}
