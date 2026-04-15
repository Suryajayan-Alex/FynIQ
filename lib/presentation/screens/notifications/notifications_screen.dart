import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatter.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../data/database/app_database.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(_notificationsStreamProvider);

    return Scaffold(
      backgroundColor: FyniqColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Notifications",
          style: FyniqTextStyles.headingM.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(notificationRepositoryProvider).clearAll(),
            icon: const Icon(Iconsax.trash, color: FyniqColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.notification_bing, size: 64, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    "No notifications yet",
                    style: FyniqTextStyles.body.copyWith(color: FyniqColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final n = list[index];
              return _NotificationTile(notification: n);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

final _notificationsStreamProvider = StreamProvider.autoDispose<List<InAppNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).watchNotifications();
});

class _NotificationTile extends StatelessWidget {
  final InAppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();
    final color = _getColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FyniqColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.title,
                      style: FyniqTextStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      FyniqFormatter.formatDate(DateTime.fromMillisecondsSinceEpoch(notification.date)),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: FyniqColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: FyniqTextStyles.body.copyWith(
                    color: FyniqColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.1, end: 0);
  }

  IconData _getIcon() {
    switch (notification.type) {
      case 'budget': return Iconsax.warning_2;
      case 'recurring': return Iconsax.repeat;
      case 'system': return Iconsax.setting;
      default: return Iconsax.notification;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case 'budget': return Colors.pinkAccent;
      case 'recurring': return FyniqColors.primaryAccent;
      case 'system': return Colors.blueAccent;
      default: return Colors.white54;
    }
  }
}
