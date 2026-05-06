import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// 로컬 알림 초기화/예약을 담당하는 서비스입니다.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const int _dailyReminderId = 1001;
  static const int _visitDayBeforeId = 1002;
  static const int _visitSameDayId = 1003;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: '열기');
    const WindowsInitializationSettings windowsSettings =
        WindowsInitializationSettings(
          appName: 'My Project',
          appUserModelId: 'com.chsop.my_project.app',
          guid: '6f4f8d8d-6b1d-4fcb-a8c7-95f2e8d64a13',
        );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    await _plugin.initialize(settings: settings);
    await _requestPermissionIfNeeded();
    _isInitialized = true;
  }

  // 매일 같은 시간에 "아직 기록 안 함" 알림을 반복 예약합니다.
  Future<void> scheduleDailyRecordReminder(TimeOfDay timeOfDay) async {
    if (!_supportsSchedulingPlatform()) {
      return;
    }
    await initialize();
    await _plugin.cancel(id: _dailyReminderId);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: '오늘 천식 기록 알림',
      // 매일 기록 알림은 부담이 적고 친근한 문장으로 안내합니다.
      body: '오늘 숨은 괜찮으셨나요? 기록하러 가볼까요? 😊',
      scheduledDate: scheduled,
      notificationDetails: _notificationDetails(),
      androidScheduleMode: await _androidScheduleMode(),
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_record',
    );
  }

  // 진료일 전날/당일 알림을 다시 계산해서 예약합니다.
  Future<void> scheduleVisitDateNotifications(DateTime visitDate) async {
    if (!_supportsSchedulingPlatform()) {
      return;
    }
    await initialize();
    await _plugin.cancel(id: _visitDayBeforeId);
    await _plugin.cancel(id: _visitSameDayId);

    final DateTime dateOnly = DateTime(
      visitDate.year,
      visitDate.month,
      visitDate.day,
    );
    await _scheduleIfFuture(
      id: _visitDayBeforeId,
      title: '진료일 알림',
      // 진료 전날에는 준비를 도와주는 톤으로 알림 문구를 보냅니다.
      body: '내일 병원 가는 날이에요! 기록 한번 확인해볼까요? 📋',
      scheduled: dateOnly.subtract(const Duration(days: 1)),
      payload: 'visit_day_before',
    );
    await _scheduleIfFuture(
      id: _visitSameDayId,
      title: '진료일 알림',
      // 진료 당일에는 응원 메시지를 포함해 부드럽게 안내합니다.
      body: '오늘 병원 가는 날! 건강한 하루 되세요 🏥',
      scheduled: dateOnly,
      payload: 'visit_same_day',
    );
  }

  Future<void> _scheduleIfFuture({
    required int id,
    required String title,
    required String body,
    required DateTime scheduled,
    required String payload,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime target = tz.TZDateTime(
      tz.local,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      9,
    );
    if (target.isBefore(now)) {
      return;
    }
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: target,
      notificationDetails: _notificationDetails(),
      androidScheduleMode: await _androidScheduleMode(),
      payload: payload,
    );
  }

  NotificationDetails _notificationDetails() {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'asthma_record_channel',
          '천식 기록 알림',
          channelDescription: '천식 기록 및 진료일 안내 알림 채널',
          importance: Importance.max,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();
    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );
  }

  Future<void> _requestPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
      // Android 12+에서 exact 알림 권한이 없더라도 동작하도록 아래에서 모드 fallback 처리합니다.
      await androidPlugin?.requestExactAlarmsPermission();
      return;
    }
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  bool _supportsSchedulingPlatform() =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isLinux ||
      Platform.isWindows;

  Future<AndroidScheduleMode> _androidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final bool canExact =
        await androidPlugin?.canScheduleExactNotifications() ?? false;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }
}
