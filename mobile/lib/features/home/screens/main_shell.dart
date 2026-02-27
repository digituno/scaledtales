import 'package:flutter/material.dart';

import 'home_screen.dart';
import '../../animal/screens/animal_list_screen.dart';
import '../../announcements/screens/announcement_screen.dart';
import '../../care_log/screens/care_log_list_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/app_drawer.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onNavigate: _navigateTo,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onOpenDrawer: _openDrawer),
          AnnouncementScreen(onOpenDrawer: _openDrawer),
          AnimalListScreen(onOpenDrawer: _openDrawer),
          CareLogListScreen(onOpenDrawer: _openDrawer),
          SettingsScreen(onOpenDrawer: _openDrawer),
        ],
      ),
    );
  }
}
