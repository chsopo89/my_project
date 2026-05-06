import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_project/features/act/data/act_result_repository.dart';
import 'package:my_project/features/act/presentation/widgets/text_scale_action_button.dart';
import 'package:my_project/features/act/state/act_survey_controller.dart';
import 'package:my_project/features/home/state/home_record_controller.dart';

// 설문 응답을 합산한 ACT 총점을 보여주는 결과 화면입니다.
class ActResultScreen extends ConsumerStatefulWidget {
  const ActResultScreen({super.key});

  @override
  ConsumerState<ActResultScreen> createState() => _ActResultScreenState();
}

class _ActResultScreenState extends ConsumerState<ActResultScreen> {
  @override
  void initState() {
    super.initState();
    // 결과 화면에 처음 들어왔을 때 오늘 기록 상태/결과를 저장합니다.
    Future<void>.microtask(() async {
      await ref
          .read(homeRecordControllerProvider.notifier)
          .markTodayCompleted();

      // 현재 선택된 문항 점수를 DB에 저장해 리포트 화면에서 4주 통계로 사용합니다.
      final List<int?> answers = ref.read(actSurveyControllerProvider);
      final List<int> questionScores = answers
          .map((int? score) => score ?? 0)
          .toList();
      final int totalScore = ref.read(actTotalScoreProvider);
      await ActResultRepository.instance.saveTodayResult(
        totalScore: totalScore,
        questionScores: questionScores,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 상태에 저장된 문항 점수들을 더한 최종 점수입니다.
    final int totalScore = ref.watch(actTotalScoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACT 결과'),
        actions: const <Widget>[TextScaleActionButton()],
      ),
      // 하단에 항상 보이는 홈 이동 버튼입니다.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            // 버튼을 누르면 홈 화면으로 바로 이동합니다.
            onPressed: () => context.go('/home'),
            child: const Text(
              '홈화면 가기',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '당신의 오늘 천식 점수는',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '$totalScore',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('/ 25점', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
