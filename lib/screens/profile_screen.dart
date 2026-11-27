import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 40),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(user?.fullName ?? '',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          Center(child: Text(user?.email ?? '')),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Student ID'),
            subtitle: Text(user?.studentId ?? '-'),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Role'),
            subtitle: Text(user?.role ?? '-'),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.read<DataProvider>().reset();
                Navigator.of(context).popUntil((r) => r.isFirst);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
