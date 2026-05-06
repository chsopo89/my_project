import 'package:flutter/material.dart';
import 'package:my_project/features/act/data/act_result_repository.dart';

// 의사에게 보여주기 쉬운 4주 요약 리포트 화면입니다.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4주 리포트')),
      body: FutureBuilder<ActReportSummary>(
        future: _loadSummary(),
        builder:
            (BuildContext context, AsyncSnapshot<ActReportSummary> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText.rich(
                      TextSpan(
                        text: '리포트를 불러오지 못했어요.\n${snapshot.error}',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final ActReportSummary summary = snapshot.data!;
              if (!summary.hasEnoughData) {
                // 28일 데이터가 부족하면 결과 해석 대신 안내 문구를 보여줍니다.
                return const Center(
                  child: Text(
                    '기록이 부족합니다',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _ScoreCard(
                    averageTotalScore: summary.averageTotalScore,
                    controlLabel: summary.controlLabel,
                  ),
                  const SizedBox(height: 14),
                  _QuestionAverageTable(
                    averageByQuestion: summary.averageByQuestion,
                  ),
                ],
              );
            },
      ),
    );
  }

  Future<ActReportSummary> _loadSummary() async {
    final List<ActDailyResult> rows = await ActResultRepository.instance
        .fetchRecentDays(28);
    if (rows.length < 28) {
      return const ActReportSummary.insufficient();
    }

    final double totalAverage =
        rows
            .map((ActDailyResult row) => row.totalScore)
            .reduce((a, b) => a + b) /
        rows.length;

    final List<double> questionAverages = List<double>.generate(5, (int index) {
      final int sum = rows
          .map((ActDailyResult row) => row.questionScores[index])
          .reduce((a, b) => a + b);
      return sum / rows.length;
    });

    return ActReportSummary(
      hasEnoughData: true,
      averageTotalScore: totalAverage,
      averageByQuestion: questionAverages,
      controlLabel: _controlLabel(totalAverage),
    );
  }

  String _controlLabel(double score) {
    if (score >= 25) {
      return '완전 조절';
    }
    if (score >= 20) {
      return '잘 조절';
    }
    if (score >= 16) {
      return '부분 조절';
    }
    return '미조절';
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.averageTotalScore,
    required this.controlLabel,
  });

  final double averageTotalScore;
  final String controlLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const Text(
              '최근 4주 ACT 평균 총점',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              averageTotalScore.toStringAsFixed(1),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$controlLabel (25점 기준)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionAverageTable extends StatelessWidget {
  const _QuestionAverageTable({required this.averageByQuestion});

  final List<double> averageByQuestion;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
          },
          children: <TableRow>[
            const TableRow(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '문항',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '평균 점수',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            ...List<TableRow>.generate(5, (int index) {
              return TableRow(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('문항 ${index + 1}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(averageByQuestion[index].toStringAsFixed(2)),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ActReportSummary {
  const ActReportSummary({
    required this.hasEnoughData,
    this.averageTotalScore = 0,
    this.averageByQuestion = const <double>[],
    this.controlLabel = '',
  });

  const ActReportSummary.insufficient() : this(hasEnoughData: false);

  final bool hasEnoughData;
  final double averageTotalScore;
  final List<double> averageByQuestion;
  final String controlLabel;
}
