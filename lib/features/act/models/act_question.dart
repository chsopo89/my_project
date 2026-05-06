// ACT 설문 한 문항(질문 + 선택지 목록)을 표현합니다.
class ActQuestion {
  const ActQuestion({
    required this.id,
    required this.text,
    required this.choices,
  });

  final int id;
  final String text;
  final List<ActChoice> choices;
}

// 각 선택지의 점수와 화면 표시 문구를 담습니다.
class ActChoice {
  const ActChoice({required this.score, required this.label});

  final int score;
  final String label;
}
