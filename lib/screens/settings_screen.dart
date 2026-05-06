import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_project/features/settings/state/settings_controller.dart';

// 설정 화면입니다. 진료일과 알림 시간을 관리합니다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SettingsState> settingsState = ref.watch(
      settingsControllerProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        // 설정 후 홈으로 나갈 수 있도록 닫기 아이콘을 제공합니다.
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.close),
          tooltip: '나가기',
        ),
      ),
      body: settingsState.when(
        data: (SettingsState state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _SectionCard(
                title: '진료일 등록',
                description: state.visitDate == null
                    ? '등록된 진료일이 없어요'
                    : _formatDate(state.visitDate!),
                buttonLabel: '날짜 선택',
                onPressed: () => _pickVisitDate(context, ref, state.visitDate),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: '알림 시간 설정',
                description: state.reminderTime == null
                    ? '설정된 시간이 없어요'
                    : _formatTime(state.reminderTime!),
                buttonLabel: '시간 선택',
                onPressed: () =>
                    _pickReminderTime(context, ref, state.reminderTime),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText.rich(
              TextSpan(
                text: '설정 정보를 불러오지 못했어요.\n$error',
                style: TextStyle(color: Colors.red.shade700),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // DatePicker로 고른 진료일을 DB에 저장하고 알림을 재예약합니다.
  Future<void> _pickVisitDate(
    BuildContext context,
    WidgetRef ref,
    DateTime? initialDate,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .setVisitDate(pickedDate);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      await _showErrorDialog(context, '진료일 저장에 실패했어요.\n$error');
    }
  }

  // TimePicker로 고른 시간을 DB에 저장하고 매일 알림을 재예약합니다.
  Future<void> _pickReminderTime(
    BuildContext context,
    WidgetRef ref,
    TimeOfDay? initialTime,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (pickedTime == null || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .setReminderTime(pickedTime);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      await _showErrorDialog(context, '알림 시간 저장에 실패했어요.\n$error');
    }
  }

  String _formatDate(DateTime dateTime) {
    final String year = dateTime.year.toString();
    final String month = dateTime.month.toString();
    final String day = dateTime.day.toString();
    return '$year년 $month월 $day일';
  }

  String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('오류'),
          content: SelectableText.rich(
            TextSpan(
              text: message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
