import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<ApiClient>().list('/notifications'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final notifications = snapshot.data ?? [];
        if (notifications.isEmpty) return const Center(child: Text('No notifications found.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              child: ListTile(
                title: Text('${notification['title'] ?? '-'}'),
                subtitle: Text('${notification['message'] ?? ''}'),
              ),
            );
          },
        );
      },
    );
  }
}
