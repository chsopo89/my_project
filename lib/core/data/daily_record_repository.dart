import 'dart:async';

import 'package:sqflite/sqflite.dart';

// 하루 기록 여부를 SQLite에 저장/조회하는 저장소입니다.
class DailyRecordRepository {
  DailyRecordRepository._();

  static final DailyRecordRepository instance = DailyRecordRepository._();
  static Database? _database;
  static Future<Database>? _openingDatabase;
  static const Duration _dbTimeout = Duration(seconds: 5);

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    // 동시에 여러 곳에서 DB를 열려고 해도 한 번만 열도록 Future를 공유합니다.
    if (_openingDatabase != null) {
      return _withTimeout(_openingDatabase!, '기록 DB 열기');
    }
    _openingDatabase = _openDatabase();
    try {
      _database = await _withTimeout(_openingDatabase!, '기록 DB 열기');
      return _database!;
    } finally {
      // DB 열기에 실패/타임아웃이 나도 잠금 상태가 남지 않게 초기화합니다.
      _openingDatabase = null;
    }
  }

  // 오늘 날짜 키(yyyy-mm-dd)로 기록 완료 상태를 저장합니다.
  Future<void> markCompleted(DateTime dateTime) async {
    final Database db = await database;
    await _withTimeout(
      db.insert('daily_records', <String, Object?>{
        'date_key': _dateKey(dateTime),
        'is_completed': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace),
      '기록 저장',
    );
  }

  // 특정 날짜에 기록한 적이 있으면 true를 반환합니다.
  Future<bool> hasRecord(DateTime dateTime) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await _withTimeout(
      db.query(
        'daily_records',
        where: 'date_key = ? AND is_completed = 1',
        whereArgs: <Object?>[_dateKey(dateTime)],
        limit: 1,
      ),
      '기록 조회',
    );
    return rows.isNotEmpty;
  }

  Future<Database> _openDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = '$databasesPath/act_daily_records.db';
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // 날짜별 1건만 저장되도록 date_key를 기본 키로 둡니다.
        await db.execute('''
          CREATE TABLE daily_records (
            date_key TEXT PRIMARY KEY,
            is_completed INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<T> _withTimeout<T>(Future<T> future, String actionName) async {
    try {
      return await future.timeout(_dbTimeout);
    } on TimeoutException {
      // 대기가 너무 길어지면 즉시 에러로 전환해 화면이 무한 로딩에 빠지지 않게 합니다.
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
