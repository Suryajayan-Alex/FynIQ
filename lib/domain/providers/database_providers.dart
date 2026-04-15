import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/recurring_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final categoryDaoProvider = Provider((ref) =>
  ref.watch(appDatabaseProvider).categoriesDao);

final transactionDaoProvider = Provider((ref) =>
  ref.watch(appDatabaseProvider).transactionsDao);

final budgetDaoProvider = Provider((ref) =>
  ref.watch(appDatabaseProvider).budgetsDao);

final settingsDaoProvider = Provider((ref) =>
  ref.watch(appDatabaseProvider).settingsDao);

final notificationsDaoProvider = Provider((ref) =>
  ref.watch(appDatabaseProvider).notificationsDao);

final notificationServiceProvider = Provider((ref) => NotificationService.instance);

final categoryRepositoryProvider = Provider((ref) =>
  CategoryRepository(ref.watch(categoryDaoProvider)));

final transactionRepositoryProvider = Provider((ref) =>
  TransactionRepository(
    ref.watch(transactionDaoProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(budgetRepositoryProvider),
    ref.watch(categoryRepositoryProvider),
    ref.watch(notificationRepositoryProvider),
  ));

final budgetRepositoryProvider = Provider((ref) =>
  BudgetRepository(ref.watch(budgetDaoProvider)));

final settingsRepositoryProvider = Provider((ref) =>
  SettingsRepository(ref.watch(settingsDaoProvider)));

final notificationRepositoryProvider = Provider((ref) =>
  NotificationRepository(ref.watch(notificationsDaoProvider)));

final recurringServiceProvider = Provider((ref) =>
  RecurringService(ref.watch(transactionRepositoryProvider)));
