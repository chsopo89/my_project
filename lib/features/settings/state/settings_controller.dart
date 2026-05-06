import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/core/data/app_settings_repository.dart';
import 'package:my_project/core/services/notification_service.dart';
import 'package:my_project/features/home/state/home_record_controller.dart';

final AsyncNotifierProvider<SettingsController, SettingsState>
settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(
      SettingsController.new,
    );

class SettingsController extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async => _load();

  // 진료일을 저장하고 관련 알림(전날/당일)을 다시 예약합니다.
  Future<void> setVisitDate(DateTime visitDate) async {
    await AppSettingsRepository.instance.saveVisitDate(visitDate);
    await NotificationService.instance.scheduleVisitDateNotifications(
      visitDate,
    );
    state = await AsyncValue.guard(_load);
    ref.invalidate(homeRecordControllerProvider);
  }

  // 매일 기록 알림 시간을 저장하고 반복 알림을 다시 예약합니다.
  Future<void> setReminderTime(TimeOfDay timeOfDay) async {
    await AppSettingsRepository.instance.saveReminderTime(timeOfDay);
    await NotificationService.instance.scheduleDailyRecordReminder(timeOfDay);
    state = await AsyncValue.guard(_load);
  }

  Future<SettingsState> _load() async {
    final DateTime? visitDate = await AppSettingsRepository.instance
        .getVisitDate();
    final TimeOfDay? reminderTime = await AppSettingsRepository.instance
        .getReminderTime();
    return SettingsState(visitDate: visitDate, reminderTime: reminderTime);
  }
}

class SettingsState {
  const SettingsState({required this.visitDate, required this.reminderTime});

  final DateTime? visitDate;
  final TimeOfDay? reminderTime;
}
