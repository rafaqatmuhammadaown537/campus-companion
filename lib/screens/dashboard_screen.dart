import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    final weekday = DateTime.now().weekday;
    final today = data.slotsForWeekday(weekday);
    final overall = data.attendance.values.isEmpty
        ? 0.0
        : data.attendance.values.map((s) => s.percent).reduce((a, b) => a + b) /
            data.attendance.values.length;

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hi, ${user?.fullName.split(' ').first ?? ''}',
              style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.today_outlined),
                      SizedBox(width: 8),
                      Text("Today's classes"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (data.loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (today.isEmpty)
                    const Text('No classes scheduled today.')
                  else
                    ...today.map(
                      (s) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.menu_book_outlined),
                        title: Text('${s.courseCode} - ${s.courseName}'),
                        subtitle: Text('${s.instructor}, ${s.room}'),
                        trailing: Text('${s.startTime} - ${s.endTime}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.fact_check_outlined,
                  label: 'Attendance',
                  value: '${overall.toStringAsFixed(0)}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.campaign_outlined,
                  label: 'Announcements',
                  value: '${data.announcements.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (data.announcements.isNotEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.push_pin_outlined),
                title: Text(
                  data.announcements.first.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('d MMM').format(
                    DateTime.tryParse(data.announcements.first.publishedAt) ??
                        DateTime.now(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
