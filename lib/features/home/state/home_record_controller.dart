import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/core/data/app_settings_repository.dart';
import 'package:my_project/core/data/daily_record_repository.dart';

final AsyncNotifierProvider<HomeRecordController, HomeRecordState>
homeRecordControllerProvider =
    AsyncNotifierProvider<HomeRecordController, HomeRecordState>(
      HomeRecordController.new,
    );

class HomeRecordController extends AsyncNotifier<HomeRecordState> {
  static const Duration _loadTimeout = Duration(seconds: 6);

  @override
  // 홈 데이터 로딩이 오래 걸리거나 실패하면 기본값 상태를 보여줍니다.
  Future<HomeRecordState> build() async => _load().timeout(
    _loadTimeout,
    onTimeout: () => _defaultState(_dateOnly(DateTime.now())),
  );

  // 최신 기록 상태를 다시 읽고 싶을 때 호출합니다.
  Future<void> refresh() async {
    state = const AsyncLoading<HomeRecordState>();
    // 새로고침 실패 시에도 에러 화면 대신 기본값 화면으로 복구합니다.
    final HomeRecordState fallback = _defaultState(_dateOnly(DateTime.now()));
    state = await AsyncValue.guard(
      () => _load().timeout(_loadTimeout, onTimeout: () => fallback),
    );
  }

  // 오늘 기록을 완료 처리하고 즉시 화면 상태를 갱신합니다.
  Future<void> markTodayCompleted() async {
    await DailyRecordRepository.instance.markCompleted(DateTime.now());
    await refresh();
  }

  Future<HomeRecordState> _load() async {
    final DateTime today = _dateOnly(DateTime.now());
    try {
      final bool hasTodayRecord = await DailyRecordRepository.instance
          .hasRecord(today);

      // 최근 7일은 순차 조회 대신 병렬 조회해 로딩 대기를 줄입니다.
      final List<Future<DailyRecordStatus>> last7DayFutures =
          List<Future<DailyRecordStatus>>.generate(7, (int index) async {
            final int i = 6 - index;
            final DateTime date = _dateOnly(today.subtract(Duration(days: i)));
            final bool hasRecord = await DailyRecordRepository.instance
                .hasRecord(date);
            return DailyRecordStatus(date: date, hasRecord: hasRecord);
          });
      final List<DailyRecordStatus> last7Days = await Future.wait(
        last7DayFutures,
      );

      // 미니 캘린더에서 점을 찍기 위해, 이번 달 1일부터 말일까지 전부 확인합니다.
      final DateTime nextMonthStart = DateTime(today.year, today.month + 1, 1);
      final int daysInMonth = nextMonthStart
          .subtract(const Duration(days: 1))
          .day;
      final List<Future<MapEntry<DateTime, bool>>> monthRecordFutures =
          List<Future<MapEntry<DateTime, bool>>>.generate(daysInMonth, (
            int index,
          ) async {
            final int day = index + 1;
            // DateTime(년, 월, 일) 형태로 키를 만들면, 캘린더 날짜와 정확히 매칭하기 쉽습니다.
            final DateTime date = DateTime(today.year, today.month, day);
            final bool hasRecord = await DailyRecordRepository.instance
                .hasRecord(date);
            // true면 기록 완료(초록 점), false면 미기록(빨간 점)으로 화면에서 사용합니다.
            return MapEntry<DateTime, bool>(date, hasRecord);
          });
      final List<MapEntry<DateTime, bool>> monthEntries = await Future.wait(
        monthRecordFutures,
      );
      final Map<DateTime, bool> thisMonthRecords =
          Map<DateTime, bool>.fromEntries(monthEntries);

      final DateTime? visitDate = await AppSettingsRepository.instance
          .getVisitDate();

      return HomeRecordState(
        today: today,
        hasTodayRecord: hasTodayRecord,
        last7Days: last7Days,
        visitDate: visitDate,
        thisMonthRecords: thisMonthRecords,
      );
    } catch (_) {
      // DB 연결 실패/응답 지연 시에도 홈 화면이 멈추지 않게 기본값을 반환합니다.
      return _defaultState(today);
    }
  }

  DateTime _dateOnly(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  HomeRecordState _defaultState(DateTime today) {
    // 기본값: 오늘 미기록, 최근 7일 미기록, 이번 달 미기록으로 안전하게 표시합니다.
    final List<DailyRecordStatus> last7Days = List<DailyRecordStatus>.generate(
      7,
      (int index) {
        final int i = 6 - index;
        final DateTime date = _dateOnly(today.subtract(Duration(days: i)));
        return DailyRecordStatus(date: date, hasRecord: false);
      },
    );

    final DateTime nextMonthStart = DateTime(today.year, today.month + 1, 1);
    final int daysInMonth = nextMonthStart
        .subtract(const Duration(days: 1))
        .day;
    final Map<DateTime, bool> thisMonthRecords = <DateTime, bool>{
      for (int day = 1; day <= daysInMonth; day++)
        DateTime(today.year, today.month, day): false,
    };

    return HomeRecordState(
      today: today,
      hasTodayRecord: false,
      last7Days: last7Days,
      visitDate: null,
      thisMonthRecords: thisMonthRecords,
    );
  }
}

class HomeRecordState {
  const HomeRecordState({
    required this.today,
    required this.hasTodayRecord,
    required this.last7Days,
    required this.visitDate,
    required this.thisMonthRecords,
  });

  final DateTime today;
  final bool hasTodayRecord;
  final List<DailyRecordStatus> last7Days;
  final DateTime? visitDate;
  final Map<DateTime, bool> thisMonthRecords;
}

class DailyRecordStatus {
  const DailyRecordStatus({required this.date, required this.hasRecord});

  final DateTime date;
  final bool hasRecord;
}
