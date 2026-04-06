import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'domain/providers/database_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar transparency
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialize notifications
  final notificationService = NotificationService.instance;
  await notificationService.initialize();
  await notificationService.requestPermission();

  // Initialize timezones
  tz.initializeTimeZones();
  // Using Asia/Kolkata as default per prompt
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  // Use ProviderContainer to check recurring transactions before UI starts
  final container = ProviderContainer();
  try {
    final recurringService = container.read(recurringServiceProvider);
    final count = await recurringService.checkAndAutoLog();

    if (count > 0) {
      await notificationService.plugin.show(
        99,
        '🔁 Auto-logged!',
        '$count recurring expense(s) auto-logged. Stay sharp.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fyniq_budget_alerts',
            'Budget Alerts',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFFEC4899),
          ),
        ),
      );
    }
  } catch (e) {
    debugPrint("Failed to log recurring: $e");
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FyniqApp(),
    ),
  );
}

class FyniqApp extends ConsumerWidget {
  const FyniqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Fyniq',
      debugShowCheckedModeBanner: false,
      theme: FyniqTheme.darkTheme(),
      routerConfig: router,
    );
  }
}
