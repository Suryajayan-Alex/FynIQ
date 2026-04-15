import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/utils/csv_exporter.dart';
import '../../../domain/providers/dashboard_providers.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../core/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FyniqScaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _ProfileHeader(ref)),
            const SliverToBoxAdapter(child: _SecurityGroup()),
            const SliverToBoxAdapter(child: _NotificationsGroup()),
            const SliverToBoxAdapter(child: _DataGroup()),
            const SliverToBoxAdapter(child: _AboutGroup()),
            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final WidgetRef ref;
  const _ProfileHeader(this.ref);

  @override
  Widget build(BuildContext context) {
    final nameAsync = ref.watch(userNameProvider);
    final imageAsync = ref.watch(profileImageProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _pickImage(context, ref),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [FyniqColors.primaryAccent, FyniqColors.highlightCTA]),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: imageAsync.when(
                    data: (path) => path != null && File(path).existsSync()
                        ? Image.file(File(path), fit: BoxFit.cover, width: 56, height: 56)
                        : Center(
                            child: nameAsync.when(
                              data: (name) => Text(
                                (name?.isNotEmpty == true) ? name![0].toUpperCase() : 'F',
                                style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: FyniqColors.textPrimary),
                              ),
                              loading: () => const SizedBox(),
                              error: (_, __) => const Text('F', style: TextStyle(color: FyniqColors.textPrimary)),
                            ),
                          ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  nameAsync.when(
                    data: (name) => Text(name ?? "Fyniq User", style: FyniqTextStyles.headingM),
                    loading: () => const ShimmerBox(width: 120, height: 24, borderRadius: 8),
                    error: (_, __) => Text("Fyniq User", style: FyniqTextStyles.headingM),
                  ),
                  const SizedBox(height: 2),
                  Text("outsmart your spending.", style: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.edit_2, color: FyniqColors.primaryAccent, size: 24),
              onPressed: () => _editName(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      await ref.read(settingsRepositoryProvider).setProfileImage(image.path);
      ref.invalidate(profileImageProvider);
    }
  }

  void _editName(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(userNameProvider).value ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Your Name"),
        content: TextField(
          controller: controller,
          style: FyniqTextStyles.body,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter your name..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await ref.read(settingsRepositoryProvider).setUserName(controller.text.trim());
              ref.invalidate(userNameProvider);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text("Save ✓"),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(color: FyniqColors.divider.withOpacity(0.5), height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? FyniqColors.textSecondary, size: 22),
      title: Text(title, style: FyniqTextStyles.body.copyWith(color: titleColor, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle!, style: FyniqTextStyles.caption.copyWith(fontSize: 10)) : null,
      trailing: trailing,
    );
  }
}

class _SecurityGroup extends ConsumerWidget {
  const _SecurityGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricAsync = ref.watch(biometricEnabledProvider);

    return _SettingsGroup(
      title: "Security 🔐",
      children: [
        _SettingsRow(
          icon: Iconsax.finger_scan,
          title: "Biometric Lock",
          subtitle: "Lock Fyniq with fingerprint or face",
          trailing: Switch(
            value: biometricAsync.value ?? false,
            activeThumbColor: FyniqColors.primaryAccent,
            onChanged: (val) => _toggleBiometric(context, val, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleBiometric(BuildContext context, bool enable, WidgetRef ref) async {
    if (enable) {
      final auth = LocalAuthentication();
      final canAuth = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canAuth) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Biometrics not available")));
        return;
      }
      final didAuth = await auth.authenticate(
        localizedReason: 'Confirm to enable biometric lock',
        options: const AuthenticationOptions(biometricOnly: false),
      );
      if (didAuth) {
        await ref.read(settingsRepositoryProvider).setIsBiometricEnabled(true);
        ref.invalidate(biometricEnabledProvider);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Biometric lock enabled 🔐")));
      }
    } else {
      await ref.read(settingsRepositoryProvider).setIsBiometricEnabled(false);
      ref.invalidate(biometricEnabledProvider);
    }
  }
}

final biometricEnabledProvider = FutureProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).getIsBiometricEnabled();
});

final reminderEnabledProvider = FutureProvider<bool>((ref) {
  return ref.watch(settingsRepositoryProvider).getIsReminderEnabled();
});

final reminderTimeProvider = FutureProvider<TimeOfDay?>((ref) {
  return ref.watch(settingsRepositoryProvider).getReminderTime();
});

class _NotificationsGroup extends ConsumerWidget {
  const _NotificationsGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderAsync = ref.watch(reminderEnabledProvider);
    final timeAsync = ref.watch(reminderTimeProvider);

    return _SettingsGroup(
      title: "Notifications 🔔",
      children: [
        _SettingsRow(
          icon: Iconsax.notification,
          title: "Daily Reminder",
          subtitle: "Remind me to log my spends",
          trailing: Switch(
            value: reminderAsync.value ?? false,
            activeThumbColor: FyniqColors.primaryAccent,
            onChanged: (val) => _toggleReminder(context, val, ref),
          ),
        ),
        if (reminderAsync.value == true)
          _SettingsRow(
            icon: Iconsax.clock,
            title: "Reminder Time",
            subtitle: timeAsync.when(
              data: (t) => t != null ? "${t.hourOfPeriod}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}" : "Set time",
              loading: () => "...",
              error: (_, __) => "Set time",
            ),
            trailing: const Icon(Iconsax.edit, size: 18, color: FyniqColors.primaryAccent),
            onTap: () => _pickTime(context, ref),
          ),
      ],
    );
  }

  Future<void> _toggleReminder(BuildContext context, bool enable, WidgetRef ref) async {
    if (enable) {
      await _pickTime(context, ref);
    } else {
      await ref.read(settingsRepositoryProvider).setIsReminderEnabled(false);
      await NotificationService.instance.cancelDailyReminder();
      ref.invalidate(reminderEnabledProvider);
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final curTime = ref.read(reminderTimeProvider).value ?? const TimeOfDay(hour: 20, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: curTime,
    );

    if (picked != null) {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setReminderTime(picked);
      await repo.setIsReminderEnabled(true);
      
      final name = await repo.getUserName() ?? "";
      await NotificationService.instance.scheduleDailyReminder(picked, name);
      
      ref.invalidate(reminderEnabledProvider);
      ref.invalidate(reminderTimeProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reminder scheduled! 🔔")));
      }
    }
  }
}

class _DataGroup extends ConsumerWidget {
  const _DataGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsGroup(
      title: "Data 💾",
      children: [
        _SettingsRow(
          icon: Iconsax.document,
          title: "Manage Categories",
          trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: FyniqColors.textSecondary),
          onTap: () => context.push('/manage-categories'),
        ),
        _SettingsRow(
          icon: Iconsax.export,
          title: "Export Data",
          subtitle: "Save all transactions as CSV",
          trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: FyniqColors.textSecondary),
          onTap: () async {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exporting data... ⏳")));
            await CsvExporter.export(ref);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data exported to Downloads! ✓ 💾")));
          },
        ),
        _SettingsRow(
          icon: Iconsax.trash,
          iconColor: FyniqColors.highlightCTA,
          title: "Clear All Data",
          subtitle: "Delete everything and start fresh",
          titleColor: FyniqColors.highlightCTA,
          onTap: () => _confirmClearAll(context, ref),
        ),
      ],
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: FyniqColors.cardSurface,
            title: const Text("Delete EVERYTHING?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("This action is permanent. All transactions and budgets will be lost."),
                const SizedBox(height: 16),
                const Text("Type 'DELETE' to confirm:"),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: "DELETE"),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              TextButton(
                onPressed: controller.text == "DELETE"
                    ? () async {
                         // Implement full reset in repo if needed, but for now we just clear relevant tables
                         // Or simply delete the db file if we want total reset.
                         // For now, let's just clear the main tables.
                         final db = ref.read(appDatabaseProvider);
                         await db.customStatement('DELETE FROM transactions');
                         await db.customStatement('DELETE FROM budgets');
                         await ref.read(settingsRepositoryProvider).setIsFirstLaunch(true);
                         if (context.mounted) {
                           context.go('/onboarding');
                         }
                      }
                    : null,
                child: Text("RESET ALL", style: TextStyle(color: controller.text == "DELETE" ? FyniqColors.highlightCTA : FyniqColors.textSecondary)),
              ),
            ],
          );
        });
      },
    );
  }
}

class _AboutGroup extends StatelessWidget {
  const _AboutGroup();

  @override
  Widget build(BuildContext context) {
    return _SettingsGroup(
      title: "About ℹ️",
      children: [
        const _SettingsRow(
          icon: Iconsax.info_circle,
          title: "Version",
          trailing: Text("1.0.0", style: TextStyle(color: FyniqColors.textSecondary, fontSize: 12)),
        ),
        _SettingsRow(
          icon: Iconsax.heart,
          title: "Open Source",
          subtitle: "Built with ❤️ for everyone",
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: "Fyniq",
              applicationIcon: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/images/fyniq_logo.png', width: 48, height: 48)),
              applicationVersion: "1.0.0",
              applicationLegalese: "MIT License",
              children: [
                const Text("Fyniq is a powerful, local-first finance tracker helping you outsmart your spending."),
              ],
            );
          },
        ),
      ],
    );
  }
}
