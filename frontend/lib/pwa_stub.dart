/// Non-web fallback: the app is never "installable" outside the browser.
class Pwa {
  static bool get isStandalone => true;
  static bool get canPrompt => false;
  static String get platform => 'desktop';
  static Future<String> prompt() async => 'unavailable';
}

void openAdminSite() {}
