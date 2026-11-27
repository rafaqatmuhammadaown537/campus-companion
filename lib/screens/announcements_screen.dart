import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final theme = Theme.of(context);

    if (data.announcements.isEmpty) {
      return ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No announcements yet.')),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => data.loadAll(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: data.announcements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final a = data.announcements[i];
          final date = DateTime.tryParse(a.publishedAt) ?? DateTime.now();
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${a.author} - ${DateFormat('d MMM yyyy').format(date)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(a.body),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
