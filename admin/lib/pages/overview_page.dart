import 'package:flutter/material.dart';

import 'package:study_shared/theme.dart';
import '../admin_data.dart';
import '../widgets.dart';
import 'students_page.dart';

/// Tổng quan: headline numbers, everyone's activity, and each learner at a glance.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.data});

  final AdminData data;

  @override
  Widget build(BuildContext context) {
    final students = data.students;
    final total = data.allQuestions.length;
    final activity = <String, int>{};
    for (final s in students) {
      s.activity.forEach((day, n) => activity[day] = (activity[day] ?? 0) + n);
    }
    final today = students.fold(0, (sum, s) => sum + s.today);
    final done = students.fold(0, (sum, s) => sum + s.done);
    final right = students.fold(0, (sum, s) => sum + s.right);
    final known = students.fold(0, (sum, s) => sum + s.knownWords);
    final online = students
        .where(
          (s) =>
              s.lastSeen != null &&
              DateTime.now().difference(s.lastSeen!).inMinutes < 2,
        )
        .length;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AdminHeader(
          title: 'Tổng quan',
          subtitle: '${students.length} học viên · $online đang online',
          actions: [
            OutlinedButton.icon(
              onPressed: data.load,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            ),
          ],
        ),
        if (!data.chineseReady)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '⚠ Chưa chạy migration 002_chinese_activity.sql — chưa có số liệu hoạt động hằng ngày và tiếng Trung.',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ResponsiveGrid(
          children: [
            KpiTile(
              label: 'Hôm nay',
              value: '$today',
              hint: 'lượt học của mọi người',
              icon: Icons.today,
            ),
            KpiTile(
              label: 'Câu trắc nghiệm đã làm',
              value: '$done',
              hint: 'mỗi người có $total câu',
              icon: Icons.quiz_outlined,
            ),
            KpiTile(
              label: 'Tỷ lệ đúng',
              value: done == 0 ? '–' : '${(right * 100 / done).round()}%',
              hint: '$right câu đúng',
              icon: Icons.check_circle_outline,
            ),
            KpiTile(
              label: 'Từ tiếng Trung đã thuộc',
              value: '$known',
              icon: Icons.translate,
            ),
          ],
        ),
        const SizedBox(height: 16),
        AdminSection(
          title: 'Hoạt động 30 ngày (mọi học viên)',
          child: ActivityBars(activity: activity),
        ),
        const SizedBox(height: 16),
        AdminSection(
          title: 'Học viên',
          child: students.isEmpty
              ? const Text(
                  'Chưa có học viên nào.',
                  style: TextStyle(color: AppColors.muted),
                )
              : Column(
                  children: [
                    for (final s in students)
                      LearnerRow(
                        learner: s,
                        total: total,
                        onTap: () => openLearner(context, data, s),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
