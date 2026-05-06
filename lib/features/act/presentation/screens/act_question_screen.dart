import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_project/features/act/data/act_questions.dart';
import 'package:my_project/features/act/presentation/widgets/act_choice_tile.dart';
import 'package:my_project/features/act/presentation/widgets/act_progress_header.dart';
import 'package:my_project/features/act/presentation/widgets/text_scale_action_button.dart';
import 'package:my_project/features/act/state/act_survey_controller.dart';

// ACT 문항 1개를 보여주고 답변을 선택하게 하는 화면입니다.
class ActQuestionScreen extends ConsumerWidget {
  const ActQuestionScreen({required this.page, super.key});

  // 요청사항: 선택지에 사용할 얼굴 이미지를 역순으로 매핑합니다.
  // (점수 5 -> face_1, 점수 1 -> face_5)
  static const List<String> _reversedFaceAssets = <String>[
    'assets/faces/face_1_very_bad.svg',
    'assets/faces/face_2_bad.svg',
    'assets/faces/face_3_neutral.svg',
    'assets/faces/face_4_good.svg',
    'assets/faces/face_5_very_good.svg',
  ];
  static const List<Color> _reversedFaceColors = <Color>[
    Color(0xFFE57373),
    Color(0xFFFFB74D),
    Color(0xFFFFEE58),
    Color(0xFFAED581),
    Color(0xFF81C784),
  ];

  final int page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 안전한 범위로 보정해 잘못된 URL 접근도 처리합니다.
    final int safePage = page.clamp(1, kActQuestions.length);
    final int pageIndex = safePage - 1;
    final List<int?> answers = ref.watch(actSurveyControllerProvider);
    final int? selectedScore = answers[pageIndex];
    final question = kActQuestions[pageIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACT 천식 설문'),
        actions: const <Widget>[TextScaleActionButton()],
      ),
      body: Column(
        children: <Widget>[
          ActProgressHeader(
            currentPage: safePage,
            totalPages: kActQuestions.length,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: question.choices.map((choice) {
                    final int faceIndex = 5 - choice.score;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ActChoiceTile(
                          choice: choice,
                          faceAssetPath: _reversedFaceAssets[faceIndex],
                          isSelected: selectedScore == choice.score,
                          fillColor: _reversedFaceColors[faceIndex],
                          onTap: (score) {
                            // 현재 문항의 선택 점수를 상태에 저장합니다.
                            ref
                                .read(actSurveyControllerProvider.notifier)
                                .selectAnswer(
                                  pageIndex: pageIndex,
                                  score: score,
                                );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: safePage == 1
                        ? null
                        : () => context.go('/act/${safePage - 1}'),
                    child: const Text('이전'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onNextPressed(
                      context: context,
                      selectedScore: selectedScore,
                      safePage: safePage,
                    ),
                    child: Text(
                      safePage == kActQuestions.length ? '결과 보기' : '다음',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onNextPressed({
    required BuildContext context,
    required int? selectedScore,
    required int safePage,
  }) {
    // 답변 없이 다음으로 넘어가려 하면 안내 다이얼로그를 띄웁니다.
    if (selectedScore == null) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('안내'),
            content: SelectableText.rich(
              TextSpan(
                text: '답변을 먼저 선택해주세요.',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (safePage == kActQuestions.length) {
      // 마지막 문항이면 결과 화면으로 이동합니다.
      context.go('/act/result');
      return;
    }
    // 아직 문항이 남아 있으면 다음 페이지로 이동합니다.
    context.go('/act/${safePage + 1}');
  }
}
