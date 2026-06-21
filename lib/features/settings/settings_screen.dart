import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import 'courier_switcher_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final courier = auth.activeCourier;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: Text(courier?.companyName ?? 'Courier'),
            subtitle: Text(courier?.courierCode ?? ''),
            leading: const Icon(Icons.local_shipping_outlined),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Switch or add courier'),
            subtitle: const Text('Use another courier code without mixing accounts.'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CourierSwitcherScreen()),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out of this courier'),
            onTap: auth.logout,
          ),
        ),
      ],
    );
  }
}
