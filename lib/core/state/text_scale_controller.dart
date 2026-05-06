import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<TextScaleController, double>
textScaleControllerProvider = NotifierProvider<TextScaleController, double>(
  TextScaleController.new,
);

// 글자 크기 배율(예: 1.0, 1.2)을 관리하는 상태 컨트롤러입니다.
class TextScaleController extends Notifier<double> {
  static const double minScale = 0.9;
  static const double maxScale = 1.6;
  static const double defaultScale = 1.0;
  static const double _step = 0.1;

  @override
  // 앱 최초 실행 시 기본 배율입니다.
  double build() => defaultScale;

  // 배율을 0.1씩 키우되, 최대값을 넘지 않도록 제한합니다.
  void increase() => state = (state + _step).clamp(minScale, maxScale);

  // 배율을 0.1씩 줄이되, 최소값 아래로 내려가지 않게 제한합니다.
  void decrease() => state = (state - _step).clamp(minScale, maxScale);

  // 슬라이더 등에서 받은 값을 범위 안으로 보정해 저장합니다.
  void setScale(double scale) => state = scale.clamp(minScale, maxScale);

  // 기본 배율(100%)로 되돌립니다.
  void reset() => state = defaultScale;
}
