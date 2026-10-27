import 'package:flutter/material.dart';

import '../auth.dart';
import '../avatar.dart';
import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'add_document_page.dart';
import 'install_page.dart';
import 'profile_setup_page.dart';
import 'splash_page.dart';
import '../pwa.dart' show openAdminSite;

/// 9. Cài đặt.
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key, required this.auth, required this.store});

  final Auth auth;
  final Store store;

  @override
  Widget build(BuildContext context) {
    return PageBody(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Center(
            child: Text('Cài đặt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 16),
          SoftCard(
            color: AppColors.blush,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _changeAvatar(context),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UserAvatar(image: store.avatar, size: 64),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            gradient: AppColors.gradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.photo_camera, size: 13, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cùng nhau học nhé 💕',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      Text(
                          [
                            store.name ?? store.user,
                            if (store.birthday != null) '🎂 ${formatDate(store.birthday!)}',
                          ].join(' · '),
                          style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                      const Text('Bạn luôn cố gắng rất tốt!',
                          style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _Item(
                  icon: Icons.account_circle_outlined,
                  title: 'Đổi ảnh đại diện',
                  onTap: () => _changeAvatar(context),
                ),
                _Item(
                  icon: Icons.person_outline,
                  title: 'Tài khoản',
                  onTap: () => _account(context),
                ),
                _Item(
                  icon: Icons.install_mobile,
                  title: 'Cài app vào điện thoại',
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const InstallPage())),
                ),
                _Item(
                  icon: Icons.flag_outlined,
                  title: 'Mục tiêu mỗi ngày',
                  value: '${store.dailyGoal} lượt',
                  onTap: () => _pickGoal(context),
                ),
                if (store.profile.isAdmin)
                  _Item(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Trang quản trị',
                    onTap: openAdminSite,
                  ),
                const _Item(icon: Icons.palette_outlined, title: 'Giao diện', value: 'Hồng pastel'),
                const _Item(icon: Icons.language, title: 'Ngôn ngữ', value: 'Tiếng Việt'),
                _Item(
                  icon: Icons.restart_alt,
                  title: 'Xóa kết quả đã làm',
                  onTap: () => _resetProgress(context),
                ),
                _Item(
                  icon: Icons.help_outline,
                  title: 'Hướng dẫn sử dụng',
                  onTap: () => _info(context, 'Hướng dẫn sử dụng', usageGuide),
                ),
                _Item(
                  icon: Icons.info_outline,
                  title: 'Giới thiệu',
                  onTap: () => _info(context, 'Study For You',
                      'Học tốt hơn, cùng nhau tiến bộ 💕\n\nỨng dụng ôn tập trắc nghiệm: thêm tài liệu có đáp án, '
                      'làm bài và biết ngay đúng hay sai.\n\nKết quả được đồng bộ lên máy chủ, đăng nhập máy nào cũng thấy.'),
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Cố lên em nhé!\nAnh luôn ở đây cùng em ♡',
              textAlign: TextAlign.center, style: handwriting(26)),
        ],
      ),
    );
  }

  Future<void> _changeAvatar(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(image: store.avatar, size: 96),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.pink),
              title: const Text('Chọn ảnh từ máy', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () => Navigator.pop(ctx, 'pick'),
            ),
            if (store.hasCustomAvatar)
              ListTile(
                leading: const Icon(Icons.restart_alt, color: AppColors.pink),
                title: const Text('Bỏ ảnh đại diện',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, 'reset'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (action == 'reset') {
        await store.setAvatar(null);
      } else {
        final png = await pickAvatarPhoto();
        if (png == null) return;
        messenger.showSnackBar(const SnackBar(content: Text('Đang tải ảnh lên...')));
        await store.setAvatar(png);
        messenger.showSnackBar(const SnackBar(content: Text('Đã đổi ảnh đại diện 💕')));
      }
    } catch (e) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Không đổi được ảnh, kiểm tra mạng hoặc thử ảnh khác nhé')));
    }
  }

  Future<void> _pickGoal(BuildContext context) async {
    final goal = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Mục tiêu mỗi ngày'),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text('Tính cả câu trắc nghiệm, flashcard, tập viết và phát âm.',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
          for (final n in const [10, 20, 30, 50, 100])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, n),
              child: Text('$n lượt',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: n == store.dailyGoal ? FontWeight.w900 : FontWeight.w500,
                      color: n == store.dailyGoal ? AppColors.pink : null)),
            ),
        ],
      ),
    );
    if (goal != null) store.dailyGoal = goal;
  }

  Future<void> _account(BuildContext context) async {
    final logout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tài khoản'),
        content: Text('Đang đăng nhập: ${store.user}\n\n'
            'Kết quả được đồng bộ lên máy chủ — đăng nhập máy nào cũng thấy.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Đóng')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (logout != true || !context.mounted) return;
    await auth.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashPage()), (_) => false);
  }

  Future<void> _resetProgress(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Xóa toàn bộ kết quả đã làm để ôn lại từ đầu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await store.resetProgress(store.allQuestions);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không xóa được, kiểm tra mạng nhé')));
      }
    }
  }

  void _info(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng'))],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.title, this.value, this.onTap, this.last = false});

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.pink),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Text(value!, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              if (onTap != null) const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
          onTap: onTap,
        ),
        if (!last) const Divider(height: 1, indent: 56, color: AppColors.border),
      ],
    );
  }
}
