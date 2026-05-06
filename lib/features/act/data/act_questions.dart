import 'package:my_project/features/act/models/act_question.dart';

// 앱에서 사용하는 ACT 5개 문항의 정적 데이터입니다.
const List<ActQuestion> kActQuestions = <ActQuestion>[
  ActQuestion(
    id: 1,
    text:
        '당신은 오늘 천식으로 인해 얼마나 많은 시간을 직장이나 학교나 집에서 '
        '평소 했던 만큼 일하고 공부하고 활동하는데 지장을 받았습니까?',
    choices: <ActChoice>[
      ActChoice(score: 5, label: '전혀 없었어요'),
      ActChoice(score: 4, label: '조금 있었어요'),
      ActChoice(score: 3, label: '보통이었어요'),
      ActChoice(score: 2, label: '자주 있었어요'),
      ActChoice(score: 1, label: '매우 자주 있었어요'),
    ],
  ),
  ActQuestion(
    id: 2,
    text: '당신은 오늘 얼마나 자주 숨을 헐떡였거나 숨을 쉬기가 어려웠습니까?',
    choices: <ActChoice>[
      ActChoice(score: 5, label: '전혀 없었어요'),
      ActChoice(score: 4, label: '가끔 있었어요'),
      ActChoice(score: 3, label: '주 1~2회 정도였어요'),
      ActChoice(score: 2, label: '거의 매일 있었어요'),
      ActChoice(score: 1, label: '하루에도 여러 번 있었어요'),
    ],
  ),
  ActQuestion(
    id: 3,
    text:
        '당신은 오늘 천식 증상(쌕쌕거리는 소리, 기침, 숨가쁨, 가슴 조임이나 통증) '
        '으로 인해 얼마나 자주 밤에 잠을 깨거나 아침에 평소보다 일찍 일어났습니까?',
    choices: <ActChoice>[
      ActChoice(score: 5, label: '전혀 없었어요'),
      ActChoice(score: 4, label: '한두 번 있었어요'),
      ActChoice(score: 3, label: '주 1회 정도였어요'),
      ActChoice(score: 2, label: '주 2~3회였어요'),
      ActChoice(score: 1, label: '거의 매일 있었어요'),
    ],
  ),
  ActQuestion(
    id: 4,
    text: '당신은 오늘 응급약(예를 들면 실부타몰, 패노테롤, 베로텍 등)을 얼마나 자주 사용했습니까?',
    choices: <ActChoice>[
      ActChoice(score: 5, label: '사용하지 않았어요'),
      ActChoice(score: 4, label: '주 1회 이하였어요'),
      ActChoice(score: 3, label: '주 2~3회였어요'),
      ActChoice(score: 2, label: '하루 1회 이상이었어요'),
      ActChoice(score: 1, label: '하루 여러 번 사용했어요'),
    ],
  ),
  ActQuestion(
    id: 5,
    text: '당신은 오늘 천식을 얼마나 잘 조절했다고 평가하겠습니까?',
    choices: <ActChoice>[
      ActChoice(score: 5, label: '매우 잘 조절되었어요'),
      ActChoice(score: 4, label: '잘 조절되었어요'),
      ActChoice(score: 3, label: '보통이었어요'),
      ActChoice(score: 2, label: '잘 조절되지 않았어요'),
      ActChoice(score: 1, label: '전혀 조절되지 않았어요'),
    ],
  ),
];
