import 'dart:js_interop';

import 'package:study_shared/config.dart';
import 'package:web/web.dart' as web;

@JS('pwa.canPrompt')
external bool _canPrompt();

@JS('pwa.isStandalone')
external bool _isStandalone();

@JS('pwa.platform')
external String _platform();

@JS('pwa.prompt')
external JSPromise<JSString> _prompt();

/// Bridge to the install helpers defined in web/index.html.
class Pwa {
  static bool get isStandalone => _safe(() => _isStandalone(), false);
  static bool get canPrompt => _safe(() => _canPrompt(), false);

  /// 'ios', 'android' or 'desktop'.
  static String get platform => _safe(() => _platform(), 'desktop');

  /// Shows the browser's install dialog; returns 'accepted', 'dismissed' or 'unavailable'.
  static Future<String> prompt() async {
    try {
      return (await _prompt().toDart).toDart;
    } catch (_) {
      return 'unavailable';
    }
  }

  static T _safe<T>(T Function() f, T fallback) {
    try {
      return f();
    } catch (_) {
      return fallback;
    }
  }
}

/// Opens the admin website in a new tab.
void openAdminSite() => web.window.open(adminSiteUrl, '_blank');
