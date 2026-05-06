import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

// 진료일/알림 시간 같은 앱 설정을 SQLite에 저장하는 저장소입니다.
class AppSettingsRepository {
  AppSettingsRepository._();

  static final AppSettingsRepository instance = AppSettingsRepository._();
  static Database? _database;
  static Future<Database>? _openingDatabase;
  static const Duration _dbTimeout = Duration(seconds: 5);

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    // 동시에 열기 요청이 들어와도 한 번만 열도록 공유 Future를 사용합니다.
    if (_openingDatabase != null) {
      return _withTimeout(_openingDatabase!, '설정 DB 열기');
    }
    _openingDatabase = _openDatabase();
    try {
      _database = await _withTimeout(_openingDatabase!, '설정 DB 열기');
      return _database!;
    } finally {
      // 실패 시에도 다음 시도에서 다시 열 수 있도록 잠금 상태를 정리합니다.
      _openingDatabase = null;
    }
  }

  Future<DateTime?> getVisitDate() async {
    final String? dateText = await _getValue(_visitDateKey);
    if (dateText == null) {
      return null;
    }
    return DateTime.tryParse(dateText);
  }

  Future<void> saveVisitDate(DateTime visitDate) async {
    final DateTime dateOnly = DateTime(
      visitDate.year,
      visitDate.month,
      visitDate.day,
    );
    await _setValue(_visitDateKey, _dateKey(dateOnly));
  }

  Future<TimeOfDay?> getReminderTime() async {
    final String? timeText = await _getValue(_dailyReminderTimeKey);
    if (timeText == null || !timeText.contains(':')) {
      return null;
    }
    final List<String> parts = timeText.split(':');
    final int? hour = int.tryParse(parts.first);
    final int? minute = int.tryParse(parts.last);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> saveReminderTime(TimeOfDay timeOfDay) async {
    final String hour = timeOfDay.hour.toString().padLeft(2, '0');
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    await _setValue(_dailyReminderTimeKey, '$hour:$minute');
  }

  Future<String?> _getValue(String key) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await _withTimeout(
      db.query(
        'app_settings',
        where: 'setting_key = ?',
        whereArgs: <Object?>[key],
        limit: 1,
      ),
      '설정 조회',
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['setting_value'] as String?;
  }

  Future<void> _setValue(String key, String value) async {
    final Database db = await database;
    await _withTimeout(
      db.insert('app_settings', <String, Object?>{
        'setting_key': key,
        'setting_value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace),
      '설정 저장',
    );
  }

  Future<Database> _openDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = '$databasesPath/app_settings.db';
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // key-value 구조로 간단한 설정값을 저장합니다.
        await db.execute('''
          CREATE TABLE app_settings (
            setting_key TEXT PRIMARY KEY,
            setting_value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<T> _withTimeout<T>(Future<T> future, String actionName) async {
    try {
      return await future.timeout(_dbTimeout);
    } on TimeoutException {
      // 무한 로딩처럼 보이는 상태를 피하기 위해 일정 시간 후 에러로 전환합니다.
      throw Exception('$actionName 시간이 너무 오래 걸려 중단되었어요.');
    }
  }

  String _dateKey(DateTime dateTime) {
    final String year = dateTime.year.toString();
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

const String _visitDateKey = 'visit_date';
const String _dailyReminderTimeKey = 'daily_reminder_time';
