import 'package:flutter/material.dart';

import '../auth.dart';
import '../avatar.dart';
import 'package:study_shared/theme.dart';
import 'profile_setup_page.dart';
import 'splash_page.dart';

/// 2. Đăng nhập / Đăng ký.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.auth, this.user, this.password});

  final Auth auth;

  /// Prefilled credentials, e.g. right after creating an account.
  final String? user;
  final String? password;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final _user = TextEditingController(text: widget.user ?? widget.auth.lastUser);
  late final _password =
      TextEditingController(text: widget.password ?? widget.auth.savedPassword);
  late final String? _name = widget.auth.nameOf(_user.text);
  late final _avatar = cachedAvatar(widget.auth.db, _user.text);
  bool _hidden = true;
  bool _remember = true;
  bool _busy = false;
  String? _error;

  Future<void> _login() async {
    final user = _user.text.trim(), password = _password.text;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.auth.login(user, password, remember: _remember);
    final profile = error == null ? await widget.auth.loadProfile() : null;
    if (!mounted) return;
    if (error != null || profile == null) {
      setState(() {
        _busy = false;
        _error = error ?? 'Không tải được hồ sơ, thử lại nhé';
      });
      return;
    }
    if (profile.name == null) {
      _askProfile(user, password);
      return;
    }
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => SplashPage(profile: profile)));
  }

  Future<void> _register() async {
    final user = _user.text.trim(), password = _password.text;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.auth.register(user, password);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    _askProfile(user, password);
  }

  /// Asks for name + birthday, then comes back here to greet the user.
  void _askProfile(String user, String password) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ProfileSetupPage(auth: widget.auth, user: user, password: password),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeartBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  children: [
                    UserAvatar(image: _avatar, size: 104),
                    const SizedBox(height: 20),
                    Text(_name == null ? 'Chào bạn!' : 'Chào $_name! 💕',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    const Text('Đăng nhập để tiếp tục học nhé! 💕',
                        style: TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _user,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Tên đăng nhập',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.muted),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _password,
                      obscureText: _hidden,
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                        suffixIcon: IconButton(
                          icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.muted),
                          onPressed: () => setState(() => _hidden = !_hidden),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _remember = !_remember),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _remember,
                            activeColor: AppColors.pink,
                            side: const BorderSide(color: AppColors.pinkLight, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            onChanged: (v) => setState(() => _remember = v ?? false),
                          ),
                          const Text('Nhớ mật khẩu', style: TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.red)),
                    ],
                    const SizedBox(height: 14),
                    GradientButton(
                      label: 'Đăng nhập',
                      onPressed: _busy ? null : _login,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Hoặc', style: TextStyle(color: AppColors.muted)),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ]),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _busy ? null : _register,
                        style: OutlinedButton.styleFrom(backgroundColor: AppColors.blush),
                        child: const Text('Tạo tài khoản'),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text('Cùng nhau chăm chỉ học\nmỗi ngày nhé ♡',
                        textAlign: TextAlign.center, style: handwriting(22)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
