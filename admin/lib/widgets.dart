import 'dart:math';

import 'package:flutter/material.dart';

import 'package:study_shared/theme.dart';
import 'admin_data.dart';

/// Page title row used at the top of every admin page.
class AdminHeader extends StatelessWidget {
  const AdminHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
            if (subtitle != null)
              Text(subtitle!, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
        Wrap(spacing: 10, runSpacing: 10, children: actions),
      ],
    ),
  );
}

/// A headline number with a label (stat tile).
class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.icon,
  });

  final String label;
  final String value;
  final String? hint;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.all(18),
    child: Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.pink),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (hint != null)
                Text(
                  hint!,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Lays children out in as many columns as fit (min width each).
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minWidth = 220,
    this.spacing = 14,
  });

  final List<Widget> children;
  final double minWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final cols = max(
        1,
        ((c.maxWidth + spacing) / (minWidth + spacing)).floor(),
      );
      final w = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final child in children) SizedBox(width: w, child: child),
        ],
      );
    },
  );
}

/// Titled white card for a page section.
class AdminSection extends StatelessWidget {
  const AdminSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

/// Single-series daily bar chart with a hover/tap tooltip on every bar.
class ActivityBars extends StatelessWidget {
  const ActivityBars({
    super.key,
    required this.activity,
    this.days = 30,
    this.unit = 'lượt',
  });

  final Map<String, int> activity;
  final int days;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = [
      for (var i = days - 1; i >= 0; i--) now.subtract(Duration(days: i)),
    ];
    final counts = [for (final d in dates) activity[dayKey(d)] ?? 0];
    final peak = max(1, counts.reduce(max));
    final total = counts.reduce((a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          total == 0
              ? 'Chưa có hoạt động trong $days ngày'
              : '$total $unit trong $days ngày · cao nhất $peak/ngày',
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, d) in dates.indexed)
                Expanded(
                  child: Tooltip(
                    message: '${d.day}/${d.month}: ${counts[i]} $unit',
                    waitDuration: Duration.zero,
                    child: Container(
                      // Taller hit target than the bar itself.
                      color: Colors.transparent,
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        height: counts[i] == 0 ? 2 : 4 + 140 * counts[i] / peak,
                        decoration: BoxDecoration(
                          color: counts[i] == 0
                              ? AppColors.border
                              : AppColors.pink,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${dates.first.day}/${dates.first.month}',
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
            const Spacer(),
            const Text(
              'Hôm nay',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

/// "Chương 1 ······ 32/50 · đúng 80%" with a thin progress bar.
class ProgressRow extends StatelessWidget {
  const ProgressRow({
    super.key,
    required this.label,
    required this.done,
    required this.total,
    this.detail,
  });

  final String label;
  final int done;
  final int total;
  final String? detail;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '$done/$total${detail == null ? '' : ' · $detail'}',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : done / total,
            minHeight: 7,
            color: AppColors.pink,
            backgroundColor: AppColors.blush,
          ),
        ),
      ],
    ),
  );
}

class LearnerAvatar extends StatelessWidget {
  const LearnerAvatar({super.key, required this.learner, this.size = 44});

  final Learner learner;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = learner.avatar;
    if (image == null) return MascotAvatar(size: size);
    return CircleAvatar(radius: size / 2, backgroundImage: image);
  }
}

String agoText(DateTime? t) {
  if (t == null) return 'chưa vào app';
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 2) return 'đang online';
  if (d.inMinutes < 60) return '${d.inMinutes} phút trước';
  if (d.inHours < 24) return '${d.inHours} giờ trước';
  if (d.inDays < 30) return '${d.inDays} ngày trước';
  return '${t.day}/${t.month}/${t.year}';
}

String dateText(DateTime t) =>
    '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}';

void showError(BuildContext context, Object e) {
  final msg = e.toString().replaceFirst('Exception: ', '');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.red,
      content: Text(msg.length > 200 ? '${msg.substring(0, 200)}…' : msg),
    ),
  );
}

void showDone(BuildContext context, String msg) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(backgroundColor: AppColors.pink, content: Text(msg)));
