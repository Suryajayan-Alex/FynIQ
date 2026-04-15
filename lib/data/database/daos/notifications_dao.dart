import 'package:drift/drift.dart';
import '../app_database.dart';

part 'notifications_dao.g.dart';

@DriftAccessor(tables: [InAppNotifications])
class NotificationsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  Stream<List<InAppNotification>> watchAllNotifications() =>
    (select(inAppNotifications)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<void> insertNotification(InAppNotificationsCompanion entry) =>
    into(inAppNotifications).insert(entry);

  Future<void> markAsRead(String id) =>
    (update(inAppNotifications)..where((t) => t.id.equals(id)))
      .write(const InAppNotificationsCompanion(isRead: Value(true)));

  Future<void> clearAll() => delete(inAppNotifications).go();
}
