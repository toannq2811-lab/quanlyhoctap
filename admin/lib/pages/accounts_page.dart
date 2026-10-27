import 'package:flutter/material.dart';

import 'package:study_shared/theme.dart';
import '../admin_data.dart';
import '../main.dart' show currentAdminId;
import '../widgets.dart';

/// Tài khoản: every account, create learners, edit profiles, grant admin.
class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key, required this.data});

  final AdminData data;

  @override
  Widget build(BuildContext context) {
    final me = currentAdminId;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AdminHeader(
          title: 'Tài khoản',
          subtitle: '${data.learners.length} tài khoản',
          actions: [
            GradientButton(
              label: 'Tạo tài khoản',
              icon: Icons.person_add_alt_1,
              expand: false,
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _CreateDialog(data: data),
              ),
            ),
          ],
        ),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              for (final l in data.learners)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      LearnerAvatar(learner: l, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    l.displayName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                if (l.profile.isAdmin) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.blush,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'admin',
                                      style: TextStyle(
                                        color: AppColors.pink,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              [
                                '@${l.profile.username}',
                                if (l.profile.birthday != null)
                                  '🎂 ${dateText(l.profile.birthday!)}',
                                agoText(l.lastSeen),
                              ].join(' · '),
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Sửa tên / ngày sinh',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) =>
                              _ProfileDialog(data: data, learner: l),
                        ),
                      ),
                      if (l.profile.id != me)
                        TextButton(
                          onPressed: () async {
                            try {
                              await data.setRole(
                                l,
                                l.profile.isAdmin ? 'student' : 'admin',
                              );
                            } catch (e) {
                              if (context.mounted) showError(context, e);
                            }
                          },
                          child: Text(
                            l.profile.isAdmin
                                ? 'Bỏ quyền admin'
                                : 'Cấp quyền admin',
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Mật khẩu được mã hóa trên máy chủ; muốn đặt lại mật khẩu thì tạo tài khoản mới hoặc nhờ người quản lý máy chủ.',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      ],
    );
  }
}

class _CreateDialog extends StatefulWidget {
  const _CreateDialog({required this.data});

  final AdminData data;

  @override
  State<_CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<_CreateDialog> {
  final _user = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  String? _error;
  bool _saving = false;

  Future<void> _create() async {
    final user = _user.text.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9._-]{3,30}$').hasMatch(user)) {
      setState(
        () => _error = 'Tên đăng nhập: chữ không dấu, số, . _ - (3–30 ký tự)',
      );
      return;
    }
    if (_password.text.length < 6) {
      setState(() => _error = 'Mật khẩu cần ít nhất 6 ký tự');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.data.createAccount(user, _password.text, _name.text);
      if (mounted) {
        Navigator.pop(context);
        showDone(context, 'Đã tạo tài khoản $user');
      }
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString().contains('already')
            ? 'Tên này đã có người dùng'
            : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Tạo tài khoản học viên'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _user,
            decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Mật khẩu'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Tên hiển thị (không bắt buộc)',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppColors.red)),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: _saving ? null : _create,
        child: Text(_saving ? 'Đang tạo...' : 'Tạo'),
      ),
    ],
  );
}

class _ProfileDialog extends StatefulWidget {
  const _ProfileDialog({required this.data, required this.learner});

  final AdminData data;
  final Learner learner;

  @override
  State<_ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<_ProfileDialog> {
  late final _name = TextEditingController(
    text: widget.learner.profile.name ?? '',
  );
  late DateTime? _birthday = widget.learner.profile.birthday;
  bool _saving = false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('@${widget.learner.profile.username}'),
    content: SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Tên'),
          ),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cake_outlined, color: AppColors.pink),
            title: Text(
              _birthday == null ? 'Chưa có ngày sinh' : dateText(_birthday!),
            ),
            trailing: TextButton(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _birthday ?? DateTime(2004),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _birthday = d);
              },
              child: const Text('Chọn'),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: _saving
            ? null
            : () async {
                setState(() => _saving = true);
                try {
                  await widget.data.updateProfile(
                    widget.learner,
                    _name.text,
                    _birthday,
                  );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  setState(() => _saving = false);
                  if (context.mounted) showError(context, e);
                }
              },
        child: const Text('Lưu'),
      ),
    ],
  );
}
