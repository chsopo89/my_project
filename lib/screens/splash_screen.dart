import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_project/features/act/state/act_survey_controller.dart';

// 앱 첫 진입 화면입니다. 간단한 소개와 시작 버튼을 제공합니다.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFB8DDF7), Color(0xFFEEF8FF)],
          ),
        ),
        child: SafeArea(
          // 화면이 열릴 때 페이드 인 + 위로 떠오르는 느낌을 함께 적용합니다.
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 24),
                  child: child,
                ),
              );
            },
            child: Stack(
              children: <Widget>[
                // 하늘 배경 위에 구름 4개를 배치해 부드러운 분위기를 만듭니다.
                const Positioned(
                  top: 70,
                  left: 24,
                  child: _CloudShape(width: 120, height: 52),
                ),
                const Positioned(
                  top: 120,
                  right: 28,
                  child: _CloudShape(width: 100, height: 44),
                ),
                const Positioned(
                  top: 190,
                  left: 72,
                  child: _CloudShape(width: 92, height: 40),
                ),
                const Positioned(
                  top: 240,
                  right: 68,
                  child: _CloudShape(width: 116, height: 50),
                ),
                // 바람 물결 라인 3개를 그려 화면에 가벼운 움직임 느낌을 줍니다.
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 315,
                  child: _WindLines(),
                ),
                Column(
                  children: <Widget>[
                    const Spacer(),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          color: Color(0xFF1B4B73),
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                        ),
                        children: <TextSpan>[
                          TextSpan(text: '나의 천식은'),
                          TextSpan(
                            text: '?',
                            style: TextStyle(color: Color(0xFF378ADD)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '매일 1분 내천식 상태를\n간편하게 기록해요',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF2D5D88),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            // 새 설문 시작 전, 이전 답변 상태를 초기화합니다.
                            ref
                                .read(actSurveyControllerProvider.notifier)
                                .reset();
                          context.go('/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF378ADD),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '시작하기',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloudShape extends StatelessWidget {
  const _CloudShape({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          _buildCircle(
            diameter: height * 0.7,
            left: width * 0.08,
            top: height * 0.2,
          ),
          _buildCircle(diameter: height * 0.95, left: width * 0.3, top: 0),
          _buildCircle(
            diameter: height * 0.62,
            left: width * 0.58,
            top: height * 0.26,
          ),
          Positioned(
            left: width * 0.16,
            right: width * 0.14,
            bottom: 0,
            child: Container(
              height: height * 0.48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(height * 0.32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle({
    required double diameter,
    required double left,
    required double top,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _WindLines extends StatelessWidget {
  const _WindLines();

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 90, child: CustomPaint(painter: _WindPainter()));
  }
}

class _WindPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    _drawLine(
      canvas: canvas,
      paint: paint,
      size: size,
      yOffset: 16,
      amplitude: 6,
    );
    _drawLine(
      canvas: canvas,
      paint: paint,
      size: size,
      yOffset: 41,
      amplitude: 8,
    );
    _drawLine(
      canvas: canvas,
      paint: paint,
      size: size,
      yOffset: 67,
      amplitude: 7,
    );
  }

  // 부드러운 곡선 2개를 이어서 하나의 바람 라인을 만듭니다.
  void _drawLine({
    required Canvas canvas,
    required Paint paint,
    required Size size,
    required double yOffset,
    required double amplitude,
  }) {
    final Path path = Path()
      ..moveTo(size.width * 0.1, yOffset)
      ..quadraticBezierTo(
        size.width * 0.28,
        yOffset - amplitude,
        size.width * 0.46,
        yOffset,
      )
      ..quadraticBezierTo(
        size.width * 0.64,
        yOffset + amplitude,
        size.width * 0.86,
        yOffset - 1,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
