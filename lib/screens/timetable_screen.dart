import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var d = 1; d <= 5; d++) ...[
            Text(_days[d - 1], style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (data.slotsForWeekday(d).isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12, left: 4),
                child: Text('No classes'),
              )
            else
              ...data.slotsForWeekday(d).map(
                    (s) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(s.courseCode.split('-').last),
                        ),
                        title: Text('${s.courseCode} - ${s.courseName}'),
                        subtitle: Text('${s.instructor} - ${s.room}'),
                        trailing: Text('${s.startTime}\n${s.endTime}',
                            textAlign: TextAlign.end),
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
