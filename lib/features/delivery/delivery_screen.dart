import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<ApiClient>().list('/delivery-requests'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) return const Center(child: Text('No delivery requests found.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              child: ListTile(
                title: Text('${request['request_number'] ?? '-'}'),
                subtitle: Text('${request['delivery_address'] ?? request['address'] ?? ''}'),
                trailing: Text('${request['status'] ?? ''}'),
              ),
            );
          },
        );
      },
    );
  }
}
