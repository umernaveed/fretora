import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ApiListScreen(
      title: 'Packages',
      path: '/packages',
      primaryField: 'tracking_number',
      secondaryField: 'supplier_tracking',
    );
  }
}

class _ApiListScreen extends StatelessWidget {
  const _ApiListScreen({
    required this.title,
    required this.path,
    required this.primaryField,
    required this.secondaryField,
  });

  final String title;
  final String path;
  final String primaryField;
  final String secondaryField;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<ApiClient>().list(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(child: Text('No $title found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text('${item[primaryField] ?? '-'}'),
                subtitle: Text('${item[secondaryField] ?? ''}'),
                trailing: Text('${item['status'] ?? ''}'),
              ),
            );
          },
        );
      },
    );
  }
}
