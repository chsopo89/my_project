import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_project/features/home/state/home_record_controller.dart';
import 'package:table_calendar/table_calendar.dart';

// 홈 화면입니다. 오늘 기록 상태와 최근 기록 흐름을 보여줍니다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeRecordState> homeRecordState = ref.watch(
      homeRecordControllerProvider,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(homeRecordControllerProvider.notifier).refresh(),
          child: homeRecordState.when(
            data: (HomeRecordState state) {
              final DateTime? nextVisitDate = state.visitDate;
              final int? dDay = nextVisitDate == null
                  ? null
                  : _calculateDday(state.today, nextVisitDate);
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _HomeTopHeader(
                    todayLabel: _formatKoreanDate(state.today),
                    hasTodayRecord: state.hasTodayRecord,
                    onSettingsTap: () => context.go('/settings'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: _DdayBanner(
                      nextVisitDate: nextVisitDate,
                      dDay: dDay,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SizedBox(
                      height: 68,
                      child: ElevatedButton(
                        // Flutter에서 onPressed가 null이면 버튼이 자동으로 비활성화됩니다.
                        // 즉, 오늘 기록(state.hasTodayRecord)이 true면 버튼을 누를 수 없습니다.
                        onPressed: state.hasTodayRecord
                            ? null
                            : () => context.go('/act/1'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF378ADD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          // 버튼 문구도 상태에 맞게 바꿔 사용자가 현재 상태를 바로 알 수 있게 합니다.
                          state.hasTodayRecord ? '오늘 기록 완료' : '오늘 기록하기',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text(
                      '최근 7일 기록',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    child: _Last7DaysRow(records: state.last7Days),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _MiniRecordCalendar(
                      focusedDay: state.today,
                      recordsByDate: state.thisMonthRecords,
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(
                    '홈 데이터를 불러오는 중이에요...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            error: (Object error, StackTrace stackTrace) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SelectableText.rich(
                        TextSpan(
                          text: '기록 정보를 불러오지 못했어요.\n$error',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // 사용자가 바로 복구할 수 있도록 재시도 버튼을 제공합니다.
                      ElevatedButton(
                        onPressed: () => ref
                            .read(homeRecordControllerProvider.notifier)
                            .refresh(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatKoreanDate(DateTime dateTime) {
    const List<String> weekdays = <String>['월', '화', '수', '목', '금', '토', '일'];
    final String weekday = weekdays[dateTime.weekday - 1];
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ($weekday)';
  }

  int _calculateDday(DateTime baseDate, DateTime targetDate) =>
      targetDate.difference(baseDate).inDays;
}

class _HomeTopHeader extends StatelessWidget {
  const _HomeTopHeader({
    required this.todayLabel,
    required this.hasTodayRecord,
    required this.onSettingsTap,
  });

  final String todayLabel;
  final bool hasTodayRecord;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = hasTodayRecord
        ? const Color(0xFF2E7D32)
        : const Color(0xFFD32F2F);
    final String statusText = hasTodayRecord ? '오늘 기록 완료!' : '오늘 아직 기록 안 했어요';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFB8DDF7), Color(0xFFDAEFFE)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            todayLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF0E3F62),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1A4F75),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(Icons.settings),
                color: const Color(0xFF1A4F75),
                tooltip: '설정',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DdayBanner extends StatelessWidget {
  const _DdayBanner({required this.nextVisitDate, required this.dDay});

  final DateTime? nextVisitDate;
  final int? dDay;

  @override
  Widget build(BuildContext context) {
    if (nextVisitDate == null || dDay == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F6FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB3DFFD)),
        ),
        child: Text(
          '진료일을 아직 등록하지 않았어요. 설정에서 등록해 주세요.',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFF1B4E77),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    final String visitDateText =
        '${nextVisitDate!.year}.${nextVisitDate!.month.toString().padLeft(2, '0')}.${nextVisitDate!.day.toString().padLeft(2, '0')}';
    final String dDayText = dDay! >= 0 ? 'D-$dDay' : 'D+${dDay!.abs()}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB3DFFD)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.local_hospital_outlined, color: Color(0xFF2F6FA1)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '다음 진료일 $visitDateText  •  $dDayText',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF1B4E77),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Last7DaysRow extends StatelessWidget {
  const _Last7DaysRow({required this.records});

  final List<DailyRecordStatus> records;

  @override
  Widget build(BuildContext context) {
    // 화면 표시 순서를 일요일부터 토요일까지로 고정합니다.
    const List<int> weekdayOrder = <int>[7, 1, 2, 3, 4, 5, 6];
    const Map<int, String> weekdayLabelByNumber = <int, String>{
      7: '일',
      1: '월',
      2: '화',
      3: '수',
      4: '목',
      5: '금',
      6: '토',
    };

    // 최근 7일 데이터를 "요일 번호(1~7)" 기준으로 빠르게 찾기 위한 맵입니다.
    final Map<int, DailyRecordStatus> recordByWeekday =
        <int, DailyRecordStatus>{
          for (final DailyRecordStatus record in records)
            record.date.weekday: record,
        };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekdayOrder.map((int weekdayNumber) {
          // 해당 요일 데이터가 없으면 "미기록(false)"으로 간주해 빨간 점으로 표시합니다.
          final DailyRecordStatus? record = recordByWeekday[weekdayNumber];
          final bool hasRecord = record?.hasRecord ?? false;
          final String weekday = weekdayLabelByNumber[weekdayNumber] ?? '';
          final Color dotColor = hasRecord
              ? const Color(0xFF2E7D32)
              : const Color(0xFFD32F2F);
          return Column(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                weekday,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4A657A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MiniRecordCalendar extends StatefulWidget {
  const _MiniRecordCalendar({
    required this.focusedDay,
    required this.recordsByDate,
  });

  final DateTime focusedDay;
  // 키: 날짜, 값: 그날 기록했는지 여부(true/false)
  final Map<DateTime, bool> recordsByDate;

  @override
  State<_MiniRecordCalendar> createState() => _MiniRecordCalendarState();
}

class _MiniRecordCalendarState extends State<_MiniRecordCalendar> {
  late DateTime _focusedCalendarDay;

  @override
  void initState() {
    super.initState();
    _focusedCalendarDay = widget.focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    // 비교 시 시/분/초를 제거한 "실제 오늘 날짜" 기준값입니다.
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    // table_calendar는 "무한대 날짜"를 직접 받지 못하므로,
    // 실사용에서 충분히 긴 범위(예: 오늘 기준 100년 뒤)로 만년처럼 처리합니다.
    final DateTime farFutureLastDay = DateTime(DateTime.now().year + 100, 12, 31);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '이번 달 기록 캘린더',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          // 날짜 셀 아래에 점(marker)을 찍어 기록 여부를 한눈에 보여줍니다.
          TableCalendar<void>(
            // 조회 가능한 달 범위를 2026.01.01 ~ 2027.12.31로 고정합니다.
            firstDay: DateTime(2026, 1, 1),
            lastDay: farFutureLastDay,
            focusedDay: _focusedCalendarDay,
            // 로케일을 한국어로 지정하면 요일/월 표기가 한글 기준으로 맞춰집니다.
            locale: 'ko_KR',
            headerVisible: true,
            // table_calendar 3.2.0에서는 헤더 버튼 설정을 headerStyle에서 제어합니다.
            // 따라서 "2 weeks" 버튼을 숨기려면 아래처럼 formatButtonVisible을 false로 둡니다.
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            // 좌우 스와이프/화살표로 이전 달, 다음 달 이동이 가능하도록 허용합니다.
            availableGestures: AvailableGestures.horizontalSwipe,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarFormat: CalendarFormat.month,
            // 요일 표기를 영어 대신 한글(일월화수목금토)로 고정합니다.
            daysOfWeekStyle: DaysOfWeekStyle(
              // table_calendar 3.2.0에서는 두 번째 파라미터 타입이 dynamic이므로
              // String으로 고정하지 않고 dynamic으로 받아야 타입 오류가 나지 않습니다.
              dowTextFormatter: (DateTime date, dynamic locale) {
                const List<String> labels = <String>[
                  '일',
                  '월',
                  '화',
                  '수',
                  '목',
                  '금',
                  '토',
                ];
                return labels[date.weekday % 7];
              },
            ),
            daysOfWeekHeight: 20,
            rowHeight: 38,
            selectedDayPredicate: (DateTime day) =>
                isSameDay(day, widget.focusedDay),
            // 사용자가 월을 넘기면 현재 보고 있는 달 기준일을 상태로 저장합니다.
            onPageChanged: (DateTime focusedDay) {
              setState(() {
                _focusedCalendarDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF378ADD),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: const Color(0xFF378ADD).withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
              markerDecoration: const BoxDecoration(color: Colors.transparent),
            ),
            calendarBuilders: CalendarBuilders<void>(
              markerBuilder: (BuildContext context, DateTime day, _) {
                // 캘린더가 넘겨주는 날짜에서 시/분/초를 제거해 DB 키 형식과 맞춥니다.
                final DateTime normalizedDay = DateTime(
                  day.year,
                  day.month,
                  day.day,
                );
                // State 클래스 안에서 부모 위젯의 값을 쓸 때는 `widget.`으로 접근해야 합니다.
                // 그래서 recordsByDate도 widget.recordsByDate로 읽어야 컴파일 오류가 나지 않습니다.
                final bool? hasRecord = widget.recordsByDate[normalizedDay];
                if (hasRecord == null) {
                  // 이번 달 범위를 벗어나거나 데이터가 없으면 점을 표시하지 않습니다.
                  return null;
                }
                // 오늘 이후의 미래 날짜는 기록 대상이 아니므로 흰색 점으로 표시합니다.
                // 오늘/과거 날짜만 기록 여부에 따라 초록(완료), 빨강(미완료)으로 표시합니다.
                final bool isFutureDate = normalizedDay.isAfter(today);
                final Color markerColor = isFutureDate
                    ? Colors.white
                    : hasRecord
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFD32F2F);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
