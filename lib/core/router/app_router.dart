import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/analytics/analytics_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/budgets/budgets_screen.dart';
import '../../presentation/screens/budgets/add_budget_screen.dart';
import '../../presentation/screens/transactions/add_transaction_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/auth/biometric_gate_screen.dart';
import '../../presentation/screens/settings/manage_categories_screen.dart';
import '../../presentation/screens/transactions/transaction_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => 
            FadeTransition(opacity: animation, child: child),
          transitionDuration: 300.ms,
        ),
      ),
      GoRoute(
        path: '/biometric-gate',
        builder: (context, state) => const BiometricGateScreen(),
      ),
      
      // Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/dashboard',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const DashboardScreen(),
                  transitionsBuilder: (ctx, anim, _, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: 300.ms,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/analytics',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const AnalyticsScreen(),
                  transitionsBuilder: (ctx, anim, _, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: 300.ms,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/budgets',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const BudgetsScreen(),
                  transitionsBuilder: (ctx, anim, _, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: 300.ms,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/settings',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                  transitionsBuilder: (ctx, anim, _, child) => FadeTransition(opacity: anim, child: child),
                  transitionDuration: 300.ms,
                ),
              ),
            ],
          ),
        ],
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Transaction flows
      GoRoute(
        path: '/add-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddTransactionScreen(),
          transitionsBuilder: (ctx, anim, _, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: 400.ms,
        ),
      ),
      GoRoute(
        path: '/edit-transaction/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddTransactionScreen(id: id),
            transitionsBuilder: (ctx, anim, _, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
            transitionDuration: 400.ms,
          );
        },
      ),
      GoRoute(
        path: '/transaction-detail/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: TransactionDetailScreen(id: id!),
            transitionsBuilder: (ctx, anim, _, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: 300.ms,
          );
        },
      ),

      // Budget flows
      GoRoute(
        path: '/add-budget',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddBudgetScreen(),
          transitionsBuilder: (ctx, anim, _, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: 400.ms,
        ),
      ),
      
      // Category flows
      GoRoute(
        path: '/manage-categories',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ManageCategoriesScreen(),
          transitionsBuilder: (ctx, anim, _, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: 300.ms,
        ),
      ),
    ],
    
    redirect: (context, state) async {
       // Optional: Add global auth redirect or splash logic here if needed
       return null;
    },
  );
});
