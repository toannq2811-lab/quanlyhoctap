import 'package:flutter/material.dart';

import '../avatar.dart';
import 'package:study_shared/models.dart';
import '../pwa.dart';
import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'add_document_page.dart';
import 'chinese/chinese_tab.dart';
import 'chinese/flashcard_page.dart';
import 'chinese/writing_page.dart';
import 'deck_page.dart';
import 'install_page.dart';
import 'quiz_page.dart';
import '../pwa.dart' show openAdminSite;

/// Hidden for the rest of the session once closed.
final _installBannerClosed = ValueNotifier(false);

const _deckIcons = [
  (Icons.gavel_rounded, Color(0xFFFFE3EC), AppColors.pink),
  (Icons.storage_rounded, Color(0xFFE6EEFF), Color(0xFF5B7FE0)),
  (Icons.code_rounded, Color(0xFFEDE5FF), Color(0xFF8C62E0)),
  (Icons.menu_book_rounded, Color(0xFFE3F6EC), Color(0xFF3DBE7A)),
];

(IconData, Color, Color) deckIcon(int index) => _deckIcons[index % _deckIcons.length];

const _weekdays = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];

/// 3. Trang chủ — a dashboard of today's progress and where to continue.
class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.store,
    required this.onOpenSettings,
    required this.onOpenChinese,
  });

  final Store store;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenChinese;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return PageBody(
      child: RefreshIndicator(
        color: AppColors.pink,
        onRefresh: store.sync,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_weekdays[now.weekday - 1]}, ${now.day}/${now.month}',
                          style: const TextStyle(
                              color: AppColors.pink, fontWeight: FontWeight.w800, fontSize: 13)),
                      Text('Chào ${store.name ?? 'em'}! 💕',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                      Text(_cheer(store),
                          style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onOpenSettings,
                  child: UserAvatar(image: store.avatar, size: 52),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (store.offline) const _OfflineNote(),
            if (store.isBirthday) _BirthdayCard(name: store.name),
            if (!Pwa.isStandalone) const _InstallBanner(),
            Row(
              children: [
                Expanded(child: _StreakCard(streak: store.streak)),
                const SizedBox(width: 12),
                Expanded(child: _GoalCard(store: store)),
              ],
            ),
            const SizedBox(height: 12),
            _WeekCard(store: store),
            if (store.profile.isAdmin) ...[
              const SizedBox(height: 12),
              SoftCard(
                color: AppColors.blush,
                onTap: openAdminSite,
                child: const Row(
                  children: [
                    Icon(Icons.monitor_heart_rounded, color: AppColors.pink, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trang quản trị', style: TextStyle(fontWeight: FontWeight.w900)),
                          Text('Theo dõi tiến độ, quản lý bộ đề, từ vựng, tài khoản',
                              style: TextStyle(color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.open_in_new, color: AppColors.pink),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const _SectionTitle('Học tiếp'),
            for (final deck in store.decks) ...[
              _DeckProgressCard(store: store, deck: deck),
              const SizedBox(height: 12),
            ],
            _ChineseProgressCard(store: store, onOpenChinese: onOpenChinese),
            const SizedBox(height: 24),
            const _SectionTitle('Lối tắt'),
            _Shortcuts(store: store, onOpenChinese: onOpenChinese),
            const SizedBox(height: 24),
            const _SectionTitle('Bộ đề của bạn'),
            for (final (i, deck) in store.decks.indexed) ...[
              DeckTile(store: store, deck: deck, index: i),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            GradientButton(
              label: 'Thêm tài liệu (PDF)',
              icon: Icons.add,
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => AddDocumentPage(store: store))),
            ),
          ],
        ),
      ),
    );
  }

  String _cheer(Store s) {
    if (s.todayCount >= s.dailyGoal) return 'Hôm nay xong mục tiêu rồi, giỏi quá! 🎉';
    if (s.todayCount > 0) return 'Còn ${s.dailyGoal - s.todayCount} câu nữa là đạt mục tiêu!';
    return 'Hôm nay cố gắng thêm một chút nhé!';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      );
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) => Container(
        height: 132,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB37A), Color(0xFFF56E8F)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFF56E8F).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 26)),
            const Spacer(),
            Text('$streak ngày',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            Text(streak == 0 ? 'Bắt đầu chuỗi hôm nay!' : 'học liên tiếp',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
      );
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final done = store.todayCount, goal = store.dailyGoal;
    return SizedBox(
      height: 132,
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            PercentRing(value: (done / goal).clamp(0, 1).toDouble(), size: 66),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎯 Hôm nay', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  Text('$done/$goal',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const Text('câu & từ', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = [for (var i = 6; i >= 0; i--) now.subtract(Duration(days: i))];
    final counts = [for (final d in days) store.activity[Store.dayKey(d)] ?? 0];
    final maxCount = counts.fold(1, (m, v) => v > m ? v : m);
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('7 ngày qua', style: TextStyle(fontWeight: FontWeight.w900)),
              const Spacer(),
              Text('${counts.fold(0, (a, b) => a + b)} lượt',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (i, d) in days.indexed)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(counts[i] == 0 ? '' : '${counts[i]}',
                            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                        const SizedBox(height: 2),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: counts[i] / maxCount),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, _) => Container(
                            height: 6 + 52 * v,
                            margin: const EdgeInsets.symmetric(horizontal: 7),
                            decoration: BoxDecoration(
                              gradient: counts[i] == 0 ? null : AppColors.gradient,
                              color: counts[i] == 0 ? AppColors.blush : null,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(i == 6 ? 'Nay' : labels[d.weekday - 1],
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: i == 6 ? FontWeight.w900 : FontWeight.w500,
                                color: i == 6 ? AppColors.pink : AppColors.muted)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckProgressCard extends StatelessWidget {
  const _DeckProgressCard({required this.store, required this.deck});

  final Store store;
  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final all = deck.allQuestions;
    final stats = Stats(store, all);
    final fresh = all.where((q) => store.results[q.id] == null).toList();
    final wrong = all.where((q) => store.results[q.id] == false).toList();
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.gavel_rounded, color: AppColors.pink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deck.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('${stats.done}/${stats.total} câu · đúng ${(stats.accuracy * 100).round()}%',
                        style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.total == 0 ? 0 : stats.done / stats.total,
              minHeight: 7,
              color: AppColors.pink,
              backgroundColor: AppColors.blush,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: fresh.isEmpty ? 'Làm lại từ đầu' : 'Tiếp tục',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => startQuiz(context, store, deck.name,
                      fresh.isEmpty ? all : fresh.take(20).toList()),
                ),
              ),
              if (wrong.isNotEmpty) ...[
                const SizedBox(width: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () => startQuiz(context, store, 'Ôn câu sai', [...wrong]..shuffle()),
                  child: Text('Ôn sai (${wrong.length})'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChineseProgressCard extends StatelessWidget {
  const _ChineseProgressCard({required this.store, required this.onOpenChinese});

  final Store store;
  final VoidCallback onOpenChinese;

  @override
  Widget build(BuildContext context) {
    final zh = store.chinese;
    final list = nextList(zh);
    final total = zh.allWords.length;
    final known = zh.lists.fold(0, (s, l) => s + zh.knownIn(l));
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(12)),
                child: const Text('中',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tiếng Trung', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text('Đã thuộc $known/$total từ${list == null ? '' : ' · đang học ${list.name}'}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : known / total,
              minHeight: 7,
              color: AppColors.pink,
              backgroundColor: AppColors.blush,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Học flashcard',
                  icon: Icons.style_rounded,
                  onPressed: list == null
                      ? null
                      : () => openFlashcards(
                          context, zh, list.name, studyOrder(zh, list.words).take(20).toList()),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: onOpenChinese,
                child: const Text('Mở'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts({required this.store, required this.onOpenChinese});

  final Store store;
  final VoidCallback onOpenChinese;

  @override
  Widget build(BuildContext context) {
    final all = store.allQuestions;
    final wrong = all.where((q) => store.results[q.id] == false).toList();
    final zh = store.chinese;
    final list = nextList(zh);
    final items = [
      (Icons.shuffle_rounded, 'Thi thử', () => pickRandomQuiz(context, store, 'Pháp luật', all)),
      (
        Icons.replay_rounded,
        'Ôn câu sai',
        () => startQuiz(context, store, 'Ôn câu sai', [...wrong]..shuffle()),
      ),
      (
        Icons.draw_rounded,
        'Tập viết',
        () => list == null ? onOpenChinese() : openWriting(context, zh, studyOrder(zh, list.words)),
      ),
      (Icons.translate_rounded, 'Từ vựng', onOpenChinese),
    ];
    return Row(
      children: [
        for (final (i, (icon, label, onTap)) in items.indexed) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 14),
              onTap: onTap,
              child: Column(
                children: [
                  Icon(icon, color: AppColors.pink, size: 26),
                  const SizedBox(height: 6),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OfflineNote extends StatelessWidget {
  const _OfflineNote();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(Icons.cloud_off, size: 18, color: AppColors.muted),
          SizedBox(width: 8),
          Expanded(
            child: Text('Đang offline — bài làm vẫn được lưu và sẽ đồng bộ khi có mạng',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
        ]),
      );
}

class _BirthdayCard extends StatelessWidget {
  const _BirthdayCard({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SoftCard(
          color: AppColors.blush,
          child: Row(children: [
            const Text('🎂', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Chúc mừng sinh nhật ${name ?? 'em'}! 🎉\nChúc em thi thật tốt và luôn vui vẻ nha 💕',
                  style: const TextStyle(fontWeight: FontWeight.w800, height: 1.4)),
            ),
          ]),
        ),
      );
}

class _InstallBanner extends StatelessWidget {
  const _InstallBanner();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: _installBannerClosed,
        builder: (context, closed, _) => closed
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoftCard(
                  color: AppColors.blush,
                  padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const InstallPage())),
                  child: Row(children: [
                    const Icon(Icons.install_mobile, color: AppColors.pink),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Cài app vào điện thoại để mở nhanh hơn',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
                      onPressed: () => _installBannerClosed.value = true,
                    ),
                  ]),
                ),
              ),
      );
}

class DeckTile extends StatelessWidget {
  const DeckTile({super.key, required this.store, required this.deck, required this.index});

  final Store store;
  final Deck deck;
  final int index;

  @override
  Widget build(BuildContext context) {
    final (icon, bg, fg) = deckIcon(index);
    return SoftCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => DeckPage(store: store, deck: deck, index: index))),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: fg),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deck.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('${deck.allQuestions.length} câu · ${store.attempts[deck.id] ?? 0} lần làm',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
