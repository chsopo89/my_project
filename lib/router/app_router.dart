import 'package:go_router/go_router.dart';
import 'package:my_project/features/act/presentation/screens/act_question_screen.dart';
import 'package:my_project/features/act/presentation/screens/act_result_screen.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/report_screen.dart';
import 'package:my_project/screens/settings_screen.dart';
import 'package:my_project/screens/splash_screen.dart';

// 앱의 이동 경로(라우트)를 한 곳에서 관리합니다.
final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/', redirect: (context, state) => '/splash'),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/report', builder: (context, state) => const ReportScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/act/result',
      builder: (context, state) => const ActResultScreen(),
    ),
    GoRoute(
      path: '/act/:page',
      builder: (context, state) {
        // URL 파라미터를 정수 페이지로 변환합니다. 실패하면 1페이지로 처리합니다.
        final int page = int.tryParse(state.pathParameters['page'] ?? '1') ?? 1;
        return ActQuestionScreen(page: page);
      },
    ),
  ],
);
