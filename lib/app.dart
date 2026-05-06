import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_project/core/state/text_scale_controller.dart';
import 'package:my_project/router/app_router.dart';

// 앱 전체 테마와 라우터를 설정하는 루트 위젯입니다.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자가 조절한 글자 배율 상태를 구독합니다.
    final double textScale = ref.watch(textScaleControllerProvider);

    return MaterialApp.router(
      title: 'ACT Survey',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        textTheme: GoogleFonts.juaTextTheme(
          ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          ).textTheme,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      builder: (context, child) {
        // MediaQuery를 덮어써 앱 전체 글자 크기를 한 번에 반영합니다.
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(textScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: appRouter,
    );
  }
}
