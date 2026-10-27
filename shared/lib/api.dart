import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'config.dart';

/// An error answered by the API (or a network failure, status 0).
class ApiException implements Exception {
  ApiException(this.status, this.message);

  final int status;
  final String message;

  bool get offline => status == 0;

  @override
  String toString() => message;
}

/// Small JSON client for the FastAPI backend, with a bearer token.
class ApiClient {
  ApiClient({this.baseUrl = apiBaseUrl, this.token});

  final String baseUrl;
  String? token;

  // Free Render instances sleep; the first request can take ~a minute.
  static const _timeout = Duration(seconds: 75);

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> _headers([String type = 'application/json']) => {
        'Content-Type': type,
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send(() => http.get(_uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, [Object? body]) =>
      _send(() => http.post(_uri(path), headers: _headers(), body: jsonEncode(body ?? {})));

  Future<dynamic> put(String path, Object? body) =>
      _send(() => http.put(_uri(path), headers: _headers(), body: jsonEncode(body)));

  Future<dynamic> patch(String path, Object? body) =>
      _send(() => http.patch(_uri(path), headers: _headers(), body: jsonEncode(body)));

  Future<dynamic> delete(String path) => _send(() => http.delete(_uri(path), headers: _headers()));

  Future<dynamic> putBytes(String path, Uint8List bytes, String contentType) =>
      _send(() => http.put(_uri(path), headers: _headers(contentType), body: bytes));

  Future<Uint8List> getBytes(String path) async {
    final res = await _raw(() => http.get(_uri(path), headers: _headers()));
    return res.bodyBytes;
  }

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    final res = await _raw(call);
    if (res.body.isEmpty) return null;
    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  Future<http.Response> _raw(Future<http.Response> Function() call) async {
    http.Response res;
    try {
      res = await call().timeout(_timeout);
    } on TimeoutException {
      throw ApiException(0, 'Máy chủ phản hồi quá lâu, thử lại nhé');
    } catch (_) {
      throw ApiException(0, 'Không kết nối được máy chủ, kiểm tra mạng nhé');
    }
    if (res.statusCode >= 400) throw ApiException(res.statusCode, _detail(res));
    return res;
  }

  String _detail(http.Response res) {
    try {
      final detail = (jsonDecode(utf8.decode(res.bodyBytes)) as Map)['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) return 'Dữ liệu không hợp lệ (${detail.first['msg']})';
    } catch (_) {}
    return 'Lỗi máy chủ (${res.statusCode})';
  }
}
