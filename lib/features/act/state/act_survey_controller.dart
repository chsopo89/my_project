import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/features/act/data/act_questions.dart';

final NotifierProvider<ActSurveyController, List<int?>>
actSurveyControllerProvider = NotifierProvider<ActSurveyController, List<int?>>(
  ActSurveyController.new,
);

// 선택된 점수들을 모두 더해 총점을 계산합니다.
final Provider<int> actTotalScoreProvider = Provider<int>((ref) {
  final List<int?> answers = ref.watch(actSurveyControllerProvider);
  return answers.whereType<int>().fold(0, (sum, score) => sum + score);
});

// 문항별 답변 상태를 관리합니다. (미선택은 null)
class ActSurveyController extends Notifier<List<int?>> {
  @override
  // 처음에는 모든 문항을 미선택(null)으로 시작합니다.
  List<int?> build() => List<int?>.filled(kActQuestions.length, null);

  void selectAnswer({required int pageIndex, required int score}) {
    // 불변성 유지를 위해 복사본을 만든 뒤 해당 문항 점수만 교체합니다.
    final List<int?> nextState = List<int?>.from(state);
    nextState[pageIndex] = score;
    state = nextState;
  }

  // 새 설문을 위해 모든 답변을 초기화합니다.
  void reset() => state = List<int?>.filled(kActQuestions.length, null);
}
