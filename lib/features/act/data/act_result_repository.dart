import 'package:sqflite/sqflite.dart';

// ACT 결과(총점/문항별 점수)를 날짜별로 저장/조회하는 저장소입니다.
class ActResultRepository {
  ActResultRepository._();

  static final ActResultRepository instance = ActResultRepository._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    final String databasesPath = await getDatabasesPath();
    final String path = '$databasesPath/act_results.db';
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // 같은 날짜에는 1건만 저장되도록 date_key를 기본 키로 둡니다.
        await db.execute('''
          CREATE TABLE act_results (
            date_key TEXT PRIMARY KEY,
            total_score INTEGER NOT NULL,
            q1_score INTEGER NOT NULL,
            q2_score INTEGER NOT NULL,
            q3_score INTEGER NOT NULL,
            q4_score INTEGER NOT NULL,
            q5_score INTEGER NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  // 오늘 설문 결과를 저장합니다. 같은 날짜는 최신 값으로 덮어씁니다.
  Future<void> saveTodayResult({
    required int totalScore,
    required List<int> questionScores,
  }) async {
    if (questionScores.length != 5) {
      throw ArgumentError('문항 점수는 5개여야 합니다.');
    }
    final Database db = await database;
    final DateTime now = DateTime.now();
    await db.insert('act_results', <String, Object?>{
      'date_key': _dateKey(now),
      'total_score': totalScore,
      'q1_score': questionScores[0],
      'q2_score': questionScores[1],
      'q3_score': questionScores[2],
      'q4_score': questionScores[3],
      'q5_score': questionScores[4],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 최근 N일 데이터를 오래된 날짜부터 반환합니다.
  Future<List<ActDailyResult>> fetchRecentDays(int days) async {
    final Database db = await database;
    final DateTime startDate = DateTime.now().subtract(
      Duration(days: days - 1),
    );
    final List<Map<String, Object?>> rows = await db.query(
      'act_results',
      where: 'date_key >= ?',
      whereArgs: <Object?>[_dateKey(startDate)],
      orderBy: 'date_key ASC',
    );
    return rows.map(_fromRow).toList();
  }

  ActDailyResult _fromRow(Map<String, Object?> row) {
    return ActDailyResult(
      dateKey: row['date_key'] as String,
      totalScore: row['total_score'] as int,
      questionScores: <int>[
        row['q1_score'] as int,
        row['q2_score'] as int,
        row['q3_score'] as int,
        row['q4_score'] as int,
        row['q5_score'] as int,
      ],
    );
  }

  String _dateKey(DateTime dateTime) {
    final String year = dateTime.year.toString();
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class ActDailyResult {
  const ActDailyResult({
    required this.dateKey,
    required this.totalScore,
    required this.questionScores,
  });

  final String dateKey;
  final int totalScore;
  final List<int> questionScores;
}
