import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_project/app.dart';
import 'package:my_project/core/services/notification_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// 앱의 시작점입니다. Riverpod 상태 관리를 전역에서 사용할 수 있게 감쌉니다.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // table_calendar가 한글 월/요일 데이터를 쓰려면 intl 로케일 초기화가 먼저 필요합니다.
  // 이 줄이 없으면 LocaleDataException이 발생할 수 있습니다.
  await initializeDateFormatting('ko_KR');
  // Windows/Linux 데스크톱에서는 ffi 팩토리를 사용해야 SQLite가 동작합니다.
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // 알림 기능을 앱 시작 시 한 번 초기화합니다.
  await NotificationService.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
