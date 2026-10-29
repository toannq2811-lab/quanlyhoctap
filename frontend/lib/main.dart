import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/splash_page.dart';
import 'package:study_shared/theme.dart';

/// Lets [Auth] send the user back to the login page when the session expires.
final appNavigator = GlobalKey<NavigatorState>();

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study For You',
      navigatorKey: appNavigator,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const SplashPage(),
    );
  }
}
