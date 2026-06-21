import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final data = auth.bootstrapData;
    final user = data?.user ?? const {};
    final summary = data?.summary ?? const {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Welcome, ${user['full_name'] ?? user['name'] ?? 'Customer'}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('Mailbox: ${user['mailbox'] ?? '-'}'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(label: 'Packages', value: summary['packages'] ?? 0),
            _MetricCard(label: 'Invoices', value: summary['invoices'] ?? 0),
            _MetricCard(label: 'Unread', value: summary['unread_notifications'] ?? 0),
            _MetricCard(label: 'Delivery', value: summary['delivery_requests'] ?? 0),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final Object value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text('$value', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}
