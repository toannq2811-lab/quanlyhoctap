import 'package:flutter/material.dart';

import '../auth.dart';
import '../db.dart';
import '../main.dart' show appNavigator;
import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'login_page.dart';
import 'shell.dart';

/// 1. Màn hình khởi động — loads the account and the user's data.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.profile});

  /// Set when coming from the login page, so the user is already signed in.
  final Profile? profile;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final minDelay = Future<void>.delayed(const Duration(milliseconds: 1200));
      final db = await database();
      final auth = Auth(db);
      var profile = widget.profile ?? await auth.restoreSession();
      if (profile?.name == null) profile = null; // finish the profile on the login flow
      final store = profile == null ? null : await Store.load(db, auth, profile);
      await minDelay;
      if (!mounted) return;
      auth.onExpired = _sessionExpired;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) =>
            store == null ? LoginPage(auth: auth) : MainShell(auth: auth, store: store),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ));
    } catch (e) {
      setState(() => _error = e);
    }
  }

  static var _expiring = false;

  /// Back to the login page (data already on screen stays cached in Isar).
  static void _sessionExpired() {
    final nav = appNavigator.currentState;
    if (nav == null || _expiring) return;
    _expiring = true;
    nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SplashPage()), (_) => false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _expiring = false;
      final ctx = appNavigator.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text('Phiên đăng nhập đã hết hạn, đăng nhập lại nhé 💕')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeartBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Image.asset('assets/logo.png', filterQuality: FilterQuality.medium),
                  ),
                  const SizedBox(height: 32),
                  if (_error == null)
                    SizedBox(
                      width: 200,
                      child: GradientButton(label: 'Đang tải...', onPressed: () {}),
                    )
                  else
                    Text('Có lỗi khi tải dữ liệu:\n$_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.red)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
