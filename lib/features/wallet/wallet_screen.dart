import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<ApiClient>().get('/wallet'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final wallet = snapshot.data ?? const {};
        final transactions = (wallet['transactions'] as List? ?? const []);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wallet balance', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Text(
                      'JMD ${wallet['balance'] ?? 0}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text('Reward points: ${wallet['reward_points'] ?? 0}'),
                    Text('Referral points: ${wallet['referral_points'] ?? 0}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Recent activity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            for (final raw in transactions)
              Card(
                child: ListTile(
                  title: Text('${raw['description'] ?? raw['transaction_type'] ?? '-'}'),
                  subtitle: Text('${raw['status'] ?? ''}'),
                  trailing: Text('${raw['amount'] ?? ''}'),
                ),
              ),
          ],
        );
      },
    );
  }
}
