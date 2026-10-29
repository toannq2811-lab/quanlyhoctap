import 'dart:convert';

import 'package:isar_plus/isar_plus.dart';
import 'package:study_shared/api.dart';
import 'package:study_shared/profile.dart';

import 'db.dart';

export 'package:study_shared/profile.dart';

/// Login against the FastAPI backend, plus "Nhớ mật khẩu" kept in the local Isar DB.
class Auth {
  Auth(this.db) : api = ApiClient(token: db.setting(_tokenKey)) {
    api.onUnauthorized = () {
      _setToken(null);
      onExpired?.call();
    };
  }

  static const _tokenKey = 'api_token';
  static const _userKey = 'api_user';
  static const _rememberKey = 'remember';
  static const _lastUserKey = 'last_user';
  static const _savedPasswordKey = 'saved_password';

  final Isar db;

  /// Shared by the whole app; carries the signed-in user's token.
  final ApiClient api;

  /// Runs once the server says the login has expired.
  void Function()? onExpired;

  /// The user name that last logged in on this device (for the greeting).
  String? get lastUser => db.setting(_lastUserKey);
  String? get savedPassword => db.setting(_savedPasswordKey);

  /// Cached name of [user], so the login page can greet without the network.
  String? nameOf(String user) => cachedProfile(user)?.name;

  Profile? cachedProfile(String user) {
    final raw = db.setting('profile:${user.trim().toLowerCase()}');
    return raw == null ? null : Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  void cacheProfile(Profile p) => db.setSetting('profile:${p.username}', jsonEncode(p.toJson()));

  void _setToken(String? token, {String? username}) {
    api.token = token;
    db.setSetting(_tokenKey, token);
    db.setSetting(_userKey, username);
  }

  /// A still-valid session from an earlier "Nhớ mật khẩu" login, if any.
  Future<Profile?> restoreSession() async {
    if (api.token == null) return null;
    if (db.setting(_rememberKey) != '1') {
      _setToken(null);
      return null;
    }
    return loadProfile();
  }

  /// Fetches the signed-in user's profile (falls back to the cache offline).
  Future<Profile?> loadProfile() async {
    if (api.token == null) return null;
    try {
      final p = Profile.fromJson(await api.get('/me') as Map<String, dynamic>);
      cacheProfile(p);
      return p;
    } on ApiException catch (e) {
      if (e.status == 401) {
        _setToken(null);
        return null;
      }
      final username = db.setting(_userKey);
      return username == null ? null : cachedProfile(username);
    }
  }

  Future<String?> _signIn(String path, String user, String password) async {
    api.token = null;
    try {
      final res = await api.post(path, {'username': user, 'password': password}) as Map<String, dynamic>;
      final profile = Profile.fromJson(res['user'] as Map<String, dynamic>);
      _setToken(res['token'] as String, username: profile.username);
      cacheProfile(profile);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  /// Signs in. Returns an error message, or null on success.
  Future<String?> login(String user, String password, {required bool remember}) async {
    user = user.trim().toLowerCase();
    if (user.isEmpty || password.isEmpty) return 'Nhập tên đăng nhập và mật khẩu nhé';
    final error = await _signIn('/auth/login', user, password);
    if (error != null) return error;
    db.setSetting(_lastUserKey, user);
    db.setSetting(_rememberKey, remember ? '1' : null);
    db.setSetting(_savedPasswordKey, remember ? password : null);
    return null;
  }

  /// Creates the account and signs in. Returns an error message, or null.
  Future<String?> register(String user, String password) async {
    user = user.trim().toLowerCase();
    if (user.isEmpty || password.isEmpty) return 'Nhập tên đăng nhập và mật khẩu nhé';
    if (!RegExp(r'^[a-z0-9._-]{3,30}$').hasMatch(user)) {
      return 'Tên đăng nhập chỉ gồm chữ không dấu, số, dấu . _ - (3–30 ký tự)';
    }
    if (password.length < 6) return 'Mật khẩu cần ít nhất 6 ký tự';
    final error = await _signIn('/auth/register', user, password);
    if (error == null) db.setSetting(_lastUserKey, user);
    return error;
  }

  /// Saves the name and birthday entered after creating the account.
  Future<void> saveProfile({required String name, required DateTime birthday}) async {
    final res = await api.patch('/me', {
      'name': name.trim(),
      'birthday': birthday.toIso8601String().substring(0, 10),
    });
    cacheProfile(Profile.fromJson(res as Map<String, dynamic>));
  }

  Future<void> logout() async {
    db.setSetting(_rememberKey, null);
    _setToken(null);
  }
}
