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
    statusBarBrightness: Brightness.dark,
  ));

  // Initialize notifications
  final notificationService = NotificationService.instance;
  try {
    await notificationService.initialize();
    await notificationService.requestPermission();
  } catch (e) {
    debugPrint("Notification initialization failed: $e");
  }

  // Initialize timezones
  try {
    tz.initializeTimeZones();
    // Using Asia/Kolkata as default
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  } catch (e) {
    debugPrint("Timezone initialization failed: $e");
    // Fallback or ignore if not critical for startup
  }

  final container = ProviderContainer();

  // Run startup tasks asynchronously after starting the app
  _runBackgroundTasks(container, notificationService);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FyniqApp(),
    ),
  );
}

Future<void> _runBackgroundTasks(ProviderContainer container, NotificationService notificationService) async {
  try {
    final recurringService = container.read(recurringServiceProvider);
    final count = await recurringService.checkAndAutoLog();

    if (count > 0) {
      final notifRepo = container.read(notificationRepositoryProvider);
      const title = '🔁 Auto-logged!';
      final body = '$count recurring expense(s) auto-logged. Stay sharp.';
      
      await notificationService.plugin.show(
        99,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fyniq_budget_alerts',
            'Budget Alerts',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF22D3EE),
          ),
        ),
      );

      await notifRepo.addNotification(
        title: title,
        body: body,
        type: 'recurring',
      );
    }
  } catch (e) {
    debugPrint("Failed to log recurring items: $e");
  }
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
