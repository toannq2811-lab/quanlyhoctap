import 'package:flutter/material.dart';

import 'package:study_shared/models.dart';
import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'quiz_page.dart';

/// Ring + "Tổng số câu / Đúng / Sai" card.
class ResultSummary extends StatelessWidget {
  const ResultSummary({super.key, required this.total, required this.right, required this.wrong});

  final int total, right, wrong;

  @override
  Widget build(BuildContext context) {
    final graded = right + wrong;
    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          PercentRing(
              value: graded == 0 ? 0 : right / graded, size: 112, label: 'Tỷ lệ chính xác'),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _row('Tổng số câu', total, AppColors.text),
                const Divider(height: 18, color: AppColors.border),
                _row('Đúng', right, AppColors.green),
                const Divider(height: 18, color: AppColors.border),
                _row('Sai', wrong, AppColors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, int value, Color color) => Row(
        children: [
          Text(label, style: TextStyle(color: color == AppColors.text ? AppColors.muted : color,
              fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('$value',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        ],
      );
}

/// "Danh sách câu sai" with a "Xem tất cả" toggle.
class WrongList extends StatefulWidget {
  const WrongList({super.key, required this.store, required this.questions});

  final Store store;
  final List<Question> questions;

  @override
  State<WrongList> createState() => _WrongListState();
}

class _WrongListState extends State<WrongList> {
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final qs = widget.questions;
    final shown = _all ? qs : qs.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('Danh sách câu sai',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const Spacer(),
            if (qs.length > 5)
              TextButton(
                onPressed: () => setState(() => _all = !_all),
                child: Text(_all ? 'Thu gọn' : 'Xem tất cả',
                    style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (qs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Không có câu sai nào, giỏi quá! 🎉',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
          ),
        for (final q in shown) ...[
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            onTap: () => startQuiz(context, widget.store, widget.store.sectionOf(q), [q]),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Câu ${q.number}',
                      style: const TextStyle(
                          color: AppColors.red, fontSize: 12, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(q.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
