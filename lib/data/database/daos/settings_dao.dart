import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)
      ..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) =>
    into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value));

  Future<bool> getIsBiometricEnabled() async =>
    (await getSetting('biometric_enabled')) == 'true';

  Future<void> setIsBiometricEnabled(bool v) =>
    setSetting('biometric_enabled', v.toString());

  Future<bool> getIsFirstLaunch() async =>
    (await getSetting('first_launch')) != 'false';

  Future<void> setIsFirstLaunch(bool v) =>
    setSetting('first_launch', v.toString());

  Future<String?> getUserName() => getSetting('user_name');

  Future<void> setUserName(String name) =>
    setSetting('user_name', name);

  Future<double> getMonthlyIncomeGoal() async {
    final v = await getSetting('monthly_income_goal');
    return double.tryParse(v ?? '0') ?? 0.0;
  }

  Future<void> setMonthlyIncomeGoal(double amount) =>
    setSetting('monthly_income_goal', amount.toString());

  Future<TimeOfDay?> getReminderTime() async {
    final v = await getSetting('reminder_time');
    if (v == null) return null;
    final parts = v.split(':');
    return TimeOfDay(hour:int.parse(parts[0]), 
      minute:int.parse(parts[1]));
  }

  Future<void> setReminderTime(TimeOfDay time) =>
    setSetting('reminder_time', '${time.hour}:${time.minute}');

  Future<bool> getIsReminderEnabled() async =>
    (await getSetting('reminder_enabled')) == 'true';

  Future<void> setIsReminderEnabled(bool v) =>
    setSetting('reminder_enabled', v.toString());

  Future<String?> getProfileImage() => getSetting('profile_image');

  Future<void> setProfileImage(String path) => setSetting('profile_image', path);
}
