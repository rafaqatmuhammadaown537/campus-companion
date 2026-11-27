import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import 'announcements_screen.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'timetable_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final label = DateFormat('EEEE, d MMMM').format(DateTime.now());

    const pages = [
      DashboardScreen(),
      TimetableScreen(),
      AttendanceScreen(),
      AnnouncementsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Campus Companion'),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          if (data.offlineMode)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: Tooltip(
                  message: 'Offline: showing locally saved data',
                  child: Icon(Icons.cloud_off, size: 20),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), label: 'Timetable'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'Announcements'),
        ],
      ),
    );
  }
}
