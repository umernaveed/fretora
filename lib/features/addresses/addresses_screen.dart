import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: context.read<ApiClient>().list('/addresses'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final addresses = snapshot.data ?? [];
        if (addresses.isEmpty) {
          return const Center(child: Text('No shipping addresses found.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: addresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final address = addresses[index];
            final lines = [
              address['name'],
              if ((address['marks'] ?? '').toString().isNotEmpty) 'Marks: ${address['marks']}',
              address['address_1'],
              address['address_2'],
              if ((address['entrance_no'] ?? '').toString().isNotEmpty) 'Entrance No.: ${address['entrance_no']}',
              address['country'],
              address['province'],
              address['city'],
              address['state'],
              address['detailed_address'],
              address['number'],
              address['zip_code'],
            ].where((value) => value != null && value.toString().trim().isNotEmpty).join('\n');

            return Card(
              child: ListTile(
                title: Text('${address['flag'] ?? ''} ${address['label'] ?? 'Address'}'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(lines),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
