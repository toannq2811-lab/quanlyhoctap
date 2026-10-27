import 'package:flutter/material.dart';

import 'package:study_shared/models.dart';
import 'package:study_shared/theme.dart';
import '../admin_data.dart';
import '../widgets.dart';

void openLearner(BuildContext context, AdminData data, Learner l) =>
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearnerPage(data: data, learnerId: l.profile.id),
      ),
    );

/// Học viên: everyone with their progress, newest activity first.
class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key, required this.data});

  final AdminData data;

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final list =
        widget.data.students
            .where(
              (s) =>
                  s.displayName.toLowerCase().contains(q) ||
                  s.profile.username.contains(q),
            )
            .toList()
          ..sort(
            (a, b) => (b.lastSeen ?? DateTime(2000)).compareTo(
              a.lastSeen ?? DateTime(2000),
            ),
          );
    final total = widget.data.allQuestions.length;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AdminHeader(title: 'Học viên', subtitle: '${list.length} người'),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Tìm theo tên hoặc tên đăng nhập...',
            prefixIcon: Icon(Icons.search, color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              for (final s in list)
                LearnerRow(
                  learner: s,
                  total: total,
                  onTap: () => openLearner(context, widget.data, s),
                ),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Không có ai.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One learner in a list: avatar, name, last seen, quiz progress, streak.
class LearnerRow extends StatelessWidget {
  const LearnerRow({
    super.key,
    required this.learner,
    required this.total,
    required this.onTap,
  });

  final Learner learner;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = learner;
    final acc = l.done == 0 ? '–' : '${(l.right * 100 / l.done).round()}%';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth > 640;
            final stats = [
              _Stat('Hôm nay', '${l.today}'),
              _Stat('Chuỗi', '🔥 ${l.streak}'),
              _Stat('Đã làm', '${l.done}/$total'),
              _Stat('Đúng', acc),
              _Stat('Từ thuộc', '${l.knownWords}'),
            ];
            return Row(
              children: [
                LearnerAvatar(learner: l),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '@${l.profile.username} · ${agoText(l.lastSeen)}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      if (!wide)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Hôm nay ${l.today} · 🔥 ${l.streak} · ${l.done}/$total câu · đúng $acc',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                if (wide) ...[
                  for (final s in stats) Expanded(flex: 2, child: s),
                ],
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label, value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
    ],
  );
}

/// Everything about one learner.
class LearnerPage extends StatelessWidget {
  const LearnerPage({super.key, required this.data, required this.learnerId});

  final AdminData data;
  final String learnerId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final l = data.byId(learnerId);
        if (l == null) {
          return const Scaffold(body: Center(child: Text('Không tìm thấy')));
        }
        final total = data.allQuestions.length;
        final wrong = data.allQuestions
            .where((q) => l.answers[q.id]?.correct == false)
            .toList();
        final p = l.profile;
        return Scaffold(
          appBar: AppBar(title: Text(l.displayName)),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  SoftCard(
                    child: Row(
                      children: [
                        LearnerAvatar(learner: l, size: 72),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.displayName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                [
                                  '@${p.username}',
                                  if (p.birthday != null)
                                    '🎂 ${dateText(p.birthday!)}',
                                  'tham gia ${dateText(l.createdAt)}',
                                  agoText(l.lastSeen),
                                ].join(' · '),
                                style: const TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ResponsiveGrid(
                    minWidth: 170,
                    children: [
                      KpiTile(
                        label: 'Hôm nay',
                        value: '${l.today}',
                        hint: 'lượt',
                      ),
                      KpiTile(label: 'Chuỗi ngày học', value: '🔥 ${l.streak}'),
                      KpiTile(label: 'Câu đã làm', value: '${l.done}/$total'),
                      KpiTile(
                        label: 'Tỷ lệ đúng',
                        value: l.done == 0
                            ? '–'
                            : '${(l.right * 100 / l.done).round()}%',
                      ),
                      KpiTile(label: 'Từ đã thuộc', value: '${l.knownWords}'),
                      KpiTile(
                        label: 'Lần làm bài',
                        value: '${l.attempts.length}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AdminSection(
                    title: 'Hoạt động 30 ngày',
                    child: ActivityBars(activity: l.activity),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, c) {
                      final chapters = AdminSection(
                        title: 'Tiến độ theo chương',
                        child: Column(
                          children: [
                            for (final d in data.decks)
                              for (final s in d.sections) _chapterRow(s, l),
                          ],
                        ),
                      );
                      final chinese = AdminSection(
                        title: 'Tiếng Trung',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final list in data.vocabLists)
                              ProgressRow(
                                label: list.name,
                                done: list.words
                                    .where((w) => l.words[w.id]?.known ?? false)
                                    .length,
                                total: list.words.length,
                              ),
                            const SizedBox(height: 4),
                            const Text(
                              'Từ hay sai nhất',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            _hardWords(l),
                          ],
                        ),
                      );
                      if (c.maxWidth < 760) {
                        return Column(
                          children: [
                            chapters,
                            const SizedBox(height: 16),
                            chinese,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: chapters),
                          const SizedBox(width: 16),
                          Expanded(child: chinese),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AdminSection(
                    title: 'Câu đang làm sai (${wrong.length})',
                    child: wrong.isEmpty
                        ? const Text(
                            'Không có câu sai 🎉',
                            style: TextStyle(color: AppColors.muted),
                          )
                        : Column(
                            children: [
                              for (final q in wrong.take(50))
                                _WrongQuestion(data: data, q: q),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  AdminSection(title: 'Các lần làm bài', child: _attempts(l)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chapterRow(Section s, Learner l) {
    var done = 0, right = 0;
    for (final q in s.questions) {
      final a = l.answers[q.id];
      if (a == null) continue;
      done++;
      if (a.correct) right++;
    }
    final i = s.title.indexOf(':');
    return ProgressRow(
      label: i > 0 && i < 20 ? s.title.substring(0, i) : s.title,
      done: done,
      total: s.questions.length,
      detail: done == 0 ? null : 'đúng ${(right * 100 / done).round()}%',
    );
  }

  Widget _hardWords(Learner l) {
    final byId = {
      for (final list in data.vocabLists)
        for (final w in list.words) w.id: w,
    };
    final hard =
        l.words.entries
            .where((e) => e.value.wrong > 0 && byId[e.key] != null)
            .toList()
          ..sort((a, b) => b.value.wrong.compareTo(a.value.wrong));
    if (hard.isEmpty) {
      return const Text(
        'Chưa có dữ liệu',
        style: TextStyle(color: AppColors.muted),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in hard.take(16))
          Tooltip(
            message: '${byId[e.key]!.pinyin} · ${byId[e.key]!.meaning}',
            child: Chip(
              backgroundColor: AppColors.blush,
              side: BorderSide.none,
              label: Text('${byId[e.key]!.hanzi}  ✗${e.value.wrong}'),
            ),
          ),
      ],
    );
  }

  Widget _attempts(Learner l) {
    if (l.attempts.isEmpty) {
      return const Text(
        'Chưa làm hết bài nào',
        style: TextStyle(color: AppColors.muted),
      );
    }
    final deckName = {for (final d in data.decks) d.id: d.name};
    return Column(
      children: [
        for (final a in l.attempts.take(30))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    '${dateText(a.at)} ${a.at.hour.toString().padLeft(2, '0')}:${a.at.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(child: Text(deckName[a.deckId] ?? '—')),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${a.total} câu',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    '${a.seconds ~/ 60}:${(a.seconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                Text(
                  '${a.right}/${a.right + a.wrong}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: a.right >= a.wrong ? AppColors.green : AppColors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _WrongQuestion extends StatelessWidget {
  const _WrongQuestion({required this.data, required this.q});

  final AdminData data;
  final Question q;

  @override
  Widget build(BuildContext context) {
    final title = data.sectionOf[q.id] ?? '';
    final i = title.indexOf(':');
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 12, bottom: 8),
        title: Text(
          '${i > 0 ? title.substring(0, i) : title} · Câu ${q.number}: ${q.text}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
        children: [
          for (final (k, o) in q.options.indexed)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${String.fromCharCode(65 + k)}. $o',
                  style: TextStyle(
                    color: k == q.answer ? AppColors.green : AppColors.text,
                    fontWeight: k == q.answer
                        ? FontWeight.w800
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
