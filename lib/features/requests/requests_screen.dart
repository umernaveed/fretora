import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(text: 'Pre-Alerts'),
            Tab(text: 'Purchase Requests'),
          ]),
          Expanded(
            child: TabBarView(
              children: [
                _RequestList(
                  path: '/pre-alerts',
                  numberField: 'pre_alert_number',
                  emptyText: 'No pre-alerts found.',
                ),
                _RequestList(
                  path: '/purchase-requests',
                  numberField: 'purchase_request_number',
                  emptyText: 'No purchase requests found.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({
    required this.path,
    required this.numberField,
    required this.emptyText,
  });

  final String path;
  final String numberField;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<ApiClient>().list(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) return Center(child: Text(emptyText));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text('${item[numberField] ?? '-'}'),
                subtitle: Text('${item['merchant'] ?? item['courier'] ?? ''}\n${item['description'] ?? ''}'),
                isThreeLine: true,
                trailing: Text('${item['status_label'] ?? item['status'] ?? ''}'),
              ),
            );
          },
        );
      },
    );
  }
}
