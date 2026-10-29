import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:study_shared/api.dart';
import 'package:web/web.dart' as web;

import 'package:study_shared/theme.dart';
import 'admin_data.dart';
import 'pages/accounts_page.dart';
import 'pages/decks_page.dart';
import 'pages/overview_page.dart';
import 'pages/students_page.dart';
import 'pages/vocab_page.dart';

/// Admin website (separate Netlify site). Build: flutter build web --release
void main() => runApp(const AdminApp());

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Study For You · Quản trị',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: const _Gate(),
  );
}

const _tokenKey = 'sfy_admin_token';

/// The API client for the whole admin site; the token survives page reloads.
final api = ApiClient(token: web.window.localStorage.getItem(_tokenKey));

/// Id of the signed-in admin (an admin can't change their own role).
String? currentAdminId;

void _saveToken(String? token) {
  api.token = token;
  token == null
      ? web.window.localStorage.removeItem(_tokenKey)
      : web.window.localStorage.setItem(_tokenKey, token);
}

/// Returns true when the stored token belongs to an admin.
Future<bool> _isAdmin() async {
  if (api.token == null) return false;
  try {
    final me = await api.get('/me') as Map<String, dynamic>;
    currentAdminId = me['id'] as String;
    return me['role'] == 'admin';
  } on ApiException catch (e) {
    if (e.status == 401) _saveToken(null);
    if (e.offline) rethrow;
    return false;
  }
}

class _Gate extends StatefulWidget {
  const _Gate();

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  bool? _admin;
  String? _error;

  @override
  void initState() {
    super.initState();
    api.onUnauthorized = _expired;
    _check();
  }

  /// The login ran out (or the account was removed): back to the login form.
  void _expired() {
    _saveToken(null);
    if (!mounted || _admin != true) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    setState(() => _admin = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phiên đăng nhập đã hết hạn, đăng nhập lại nhé')));
  }

  Future<void> _check() async {
    try {
      final ok = await _isAdmin();
      if (!ok) _saveToken(null);
      if (mounted) setState(() => _admin = ok);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_error!),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() => _error = null);
                _check();
              },
              child: const Text('Thử lại'),
            ),
          ]),
        ),
      );
    }
    if (_admin == null) {
      return const Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: AppColors.pink),
            SizedBox(height: 12),
            Text('Đang kết nối máy chủ (lần đầu có thể mất ~1 phút)...'),
          ]),
        ),
      );
    }
    if (_admin!) {
      return AdminShell(
        onSignOut: () {
          _saveToken(null);
          setState(() => _admin = false);
        },
      );
    }
    return _LoginPage(onSignedIn: () => setState(() => _admin = true));
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage({required this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final _user = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await api.post('/auth/login', {
        'username': _user.text.trim().toLowerCase(),
        'password': _password.text,
      }) as Map<String, dynamic>;
      _saveToken(res['token'] as String);
      if (!await _isAdmin()) {
        _saveToken(null);
        throw ApiException(403, 'Tài khoản này chưa có quyền quản trị.');
      }
      widget.onSignedIn();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: HeartBackdrop(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SoftCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Mascot(size: 96),
                  const SizedBox(height: 8),
                  Text('Study For You', style: brandTitle(28)),
                  const Text(
                    'Trang quản trị',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _user,
                    decoration: const InputDecoration(
                      hintText: 'Tên đăng nhập',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    onSubmitted: (_) => _login(),
                    decoration: const InputDecoration(
                      hintText: 'Mật khẩu',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.red),
                    ),
                  ],
                  const SizedBox(height: 20),
                  GradientButton(
                    label: _busy ? 'Đang đăng nhập...' : 'Đăng nhập',
                    onPressed: _busy ? null : _login,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _data = AdminData(api);
  int _tab = 0;

  static const _items = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Tổng quan'),
    (Icons.people_outline, Icons.people, 'Học viên'),
    (Icons.library_books_outlined, Icons.library_books, 'Bộ đề'),
    (Icons.translate_outlined, Icons.translate, 'Từ vựng'),
    (Icons.manage_accounts_outlined, Icons.manage_accounts, 'Tài khoản'),
  ];

  @override
  void initState() {
    super.initState();
    _data.load();
  }

  Widget _page() => switch (_tab) {
    0 => OverviewPage(data: _data),
    1 => StudentsPage(data: _data),
    2 => DecksPage(data: _data),
    3 => VocabPage(data: _data),
    _ => AccountsPage(data: _data),
  };

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    final body = ListenableBuilder(
      listenable: _data,
      builder: (context, _) {
        if (_data.loading && _data.learners.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.pink),
          );
        }
        if (_data.error != null && _data.learners.isEmpty) {
          return Center(child: Text('Không tải được dữ liệu: ${_data.error}'));
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _page(),
          ),
        );
      },
    );
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              backgroundColor: Colors.white,
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              indicatorColor: AppColors.blush,
              selectedIconTheme: const IconThemeData(color: AppColors.pink),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.pink,
                fontWeight: FontWeight.w800,
              ),
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
                child: Row(
                  children: [
                    const MascotAvatar(size: 40),
                    const SizedBox(width: 10),
                    Text('Quản trị', style: brandTitle(22)),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextButton.icon(
                      onPressed: widget.onSignOut,
                      icon: const Icon(Icons.logout, color: AppColors.muted),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ),
                ),
              ),
              destinations: [
                for (final (icon, selected, label) in _items)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selected),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.border),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản trị', style: brandTitle(22)),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.blush,
        destinations: [
          for (final (icon, selected, label) in _items)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selected, color: AppColors.pink),
              label: label,
            ),
        ],
      ),
    );
  }
}
