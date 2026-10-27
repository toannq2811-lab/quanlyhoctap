import 'package:flutter/material.dart';

import '../auth.dart';
import '../storage.dart';
import 'package:study_shared/theme.dart';
import 'home_tab.dart';
import 'practice_tab.dart';
import 'results_tab.dart';
import 'settings_tab.dart';
import 'chinese/chinese_tab.dart';

/// Bottom navigation: Trang chủ · Luyện tập · Tiếng Trung · Kết quả · Cài đặt.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.auth, required this.store});

  final Auth auth;
  final Store store;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  void _goTo(int tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeartBackdrop(
        child: SafeArea(
          bottom: false,
          // Tabs are created inside the builder so they rebuild on store changes.
          child: ListenableBuilder(
            listenable: Listenable.merge([widget.store, widget.store.chinese]),
            builder: (_, _) => IndexedStack(
              index: _tab,
              children: [
                HomeTab(
                  store: widget.store,
                  onOpenSettings: () => _goTo(4),
                  onOpenChinese: () => _goTo(2),
                ),
                PracticeTab(store: widget.store),
                ChineseTab(zh: widget.store.chinese),
                ResultsTab(store: widget.store),
                SettingsTab(auth: widget.auth, store: widget.store),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.blush,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (s) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: s.contains(WidgetState.selected)
                  ? AppColors.pink
                  : AppColors.muted,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (s) => IconThemeData(
              color: s.contains(WidgetState.selected)
                  ? AppColors.pink
                  : AppColors.muted,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _goTo,
          height: 68,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Luyện tập',
            ),
            NavigationDestination(
              icon: Text(
                '中',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.muted,
                ),
              ),
              selectedIcon: Text(
                '中',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.pink,
                ),
              ),
              label: 'Tiếng Trung',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Kết quả',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_rounded),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }
}
