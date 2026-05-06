import 'package:flutter/material.dart';

// 현재 설문 진행 정도(페이지/진행바)를 표시하는 상단 헤더입니다.
class ActProgressHeader extends StatelessWidget {
  const ActProgressHeader({
    required this.currentPage,
    required this.totalPages,
    super.key,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Text(
            '$currentPage / $totalPages',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(value: currentPage / totalPages),
          ),
        ],
      ),
    );
  }
}
