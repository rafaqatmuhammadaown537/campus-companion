import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final theme = Theme.of(context);
    final todayCourses = data.slotsForWeekday(DateTime.now().weekday);

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Mark today's attendance", style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (todayCourses.isEmpty)
            const Text('No classes scheduled today.')
          else
            ...todayCourses.map(
              (s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${s.courseCode} - ${s.courseName}'),
                            const SizedBox(height: 4),
                            Text('${s.startTime} - ${s.endTime}, ${s.room}',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () => data.markAttendance(s.courseCode, true),
                        child: const Text('Present'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => data.markAttendance(s.courseCode, false),
                        child: const Text('Absent'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text('Summary by course', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (data.attendance.isEmpty)
            const Text('Mark attendance to see your summary.')
          else
            ...data.attendance.values.map(
              (s) {
                final color = s.percent >= 80
                    ? Colors.green
                    : s.percent >= 60
                        ? Colors.orange
                        : Colors.red;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${s.courseCode} - ${s.courseName}'),
                    subtitle: LinearProgressIndicator(
                      value: s.held == 0 ? 0 : s.attended / s.held,
                      color: color,
                    ),
                    trailing: Text(
                      '${s.attended}/${s.held}\n${s.percent.toStringAsFixed(0)}%',
                      textAlign: TextAlign.end,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
