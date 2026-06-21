import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_models.dart';
import '../auth/auth_controller.dart';

class CourierSwitcherScreen extends StatelessWidget {
  const CourierSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Courier accounts')),
      body: FutureBuilder<List<CourierWorkspace>>(
        future: auth.savedCouriers(),
        builder: (context, snapshot) {
          final couriers = snapshot.data ?? const [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final courier in couriers)
                Card(
                  child: ListTile(
                    title: Text(courier.companyName),
                    subtitle: Text(courier.courierCode),
                    leading: const Icon(Icons.local_shipping_outlined),
                    onTap: () async {
                      await auth.switchCourier(courier);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add another courier'),
                  onTap: () async {
                    await auth.changeCourier();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}