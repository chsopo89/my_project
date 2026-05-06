import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_project/core/state/text_scale_controller.dart';

// 앱 어디서든 글자 크기 다이얼로그를 열 수 있는 액션 버튼입니다.
class TextScaleActionButton extends ConsumerWidget {
  const TextScaleActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double textScale = ref.watch(textScaleControllerProvider);

    return IconButton(
      tooltip: '글자 크기 조절',
      onPressed: () => _showTextScaleDialog(context, ref, textScale),
      icon: const Icon(Icons.text_fields),
    );
  }

  void _showTextScaleDialog(
    BuildContext context,
    WidgetRef ref,
    double textScale,
  ) {
    // 현재 화면 위에 작은 설정 창(다이얼로그)을 띄웁니다.
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        double currentScale = textScale;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('글자 크기'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('현재 크기: ${(currentScale * 100).round()}%'),
                  const SizedBox(height: 12),
                  // 사운드 바처럼 슬라이더를 드래그해서 한 번에 조절해요.
                  Slider(
                    value: currentScale,
                    min: TextScaleController.minScale,
                    max: TextScaleController.maxScale,
                    divisions:
                        ((TextScaleController.maxScale -
                                    TextScaleController.minScale) /
                                0.1)
                            .round(),
                    label: '${(currentScale * 100).round()}%',
                    onChanged: (double value) {
                      setState(() {
                        currentScale = value;
                      });
                      // 슬라이더 값이 바뀔 때마다 즉시 앱 글자 크기를 반영합니다.
                      ref
                          .read(textScaleControllerProvider.notifier)
                          .setScale(value);
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    ref.read(textScaleControllerProvider.notifier).reset();
                    Navigator.of(context).pop();
                  },
                  child: const Text('기본값'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('닫기'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
