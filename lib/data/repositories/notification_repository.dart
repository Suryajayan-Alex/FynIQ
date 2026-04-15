import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/daos/notifications_dao.dart';

class NotificationRepository {
  final NotificationsDao _dao;
  final Uuid _uuid = const Uuid();

  NotificationRepository(this._dao);

  Stream<List<InAppNotification>> watchNotifications() => _dao.watchAllNotifications();

  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    final entry = InAppNotificationsCompanion.insert(
      id: _uuid.v4(),
      title: title,
      body: body,
      date: DateTime.now().millisecondsSinceEpoch,
      type: type,
    );
    await _dao.insertNotification(entry);
  }

  Future<void> markAsRead(String id) => _dao.markAsRead(id);
  Future<void> clearAll() => _dao.clearAll();
}
