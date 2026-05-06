import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_project/features/act/models/act_question.dart';

// 문항의 한 선택지를 카드 형태로 보여주는 재사용 위젯입니다.
class ActChoiceTile extends StatelessWidget {
  const ActChoiceTile({
    required this.choice,
    required this.faceAssetPath,
    required this.isSelected,
    required this.fillColor,
    required this.onTap,
    super.key,
  });

  final ActChoice choice;
  final String faceAssetPath;
  final bool isSelected;
  final Color fillColor;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      // 탭하면 부모로 선택 점수를 전달합니다.
      onTap: () => onTap(choice.score),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? fillColor.withValues(alpha: 0.85) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? fillColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: fillColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Center(
          child: SvgPicture.asset(faceAssetPath, width: 56, height: 56),
        ),
      ),
    );
  }
}
