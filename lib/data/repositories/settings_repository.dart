import 'package:flutter/material.dart';
import '../database/daos/settings_dao.dart';

class SettingsRepository {
  final SettingsDao _dao;

  SettingsRepository(this._dao);

  Future<String?> getSetting(String key) => _dao.getSetting(key);

  Future<void> setSetting(String key, String value) => _dao.setSetting(key, value);

  Future<bool> getIsBiometricEnabled() => _dao.getIsBiometricEnabled();

  Future<void> setIsBiometricEnabled(bool v) => _dao.setIsBiometricEnabled(v);

  Future<bool> getIsFirstLaunch() => _dao.getIsFirstLaunch();

  Future<void> setIsFirstLaunch(bool v) => _dao.setIsFirstLaunch(v);

  Future<String?> getUserName() => _dao.getUserName();

  Future<void> setUserName(String name) => _dao.setUserName(name);

  Future<double> getMonthlyIncomeGoal() => _dao.getMonthlyIncomeGoal();

  Future<void> setMonthlyIncomeGoal(double amount) => _dao.setMonthlyIncomeGoal(amount);

  Future<TimeOfDay?> getReminderTime() => _dao.getReminderTime();

  Future<void> setReminderTime(TimeOfDay time) => _dao.setReminderTime(time);

  Future<bool> getIsReminderEnabled() => _dao.getIsReminderEnabled();

  Future<void> setIsReminderEnabled(bool v) => _dao.setIsReminderEnabled(v);

  Future<String?> getProfileImage() => _dao.getProfileImage();

  Future<void> setProfileImage(String path) => _dao.setProfileImage(path);
}
