import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_controller.dart';

class CourierCodeScreen extends StatefulWidget {
  const CourierCodeScreen({super.key});

  @override
  State<CourierCodeScreen> createState() => _CourierCodeScreenState();
}

class _CourierCodeScreenState extends State<CourierCodeScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.local_shipping, size: 54, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 18),
                  Text(
                    'Enter your courier code',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the code provided by your courier to open the correct branded portal.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Courier code',
                      prefixIcon: Icon(Icons.qr_code_2),
                    ),
                    onSubmitted: (_) => _submit(context),
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: auth.isBusy ? null : () => _submit(context),
                    child: auth.isBusy
                        ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (_code.text.trim().isEmpty) return;
    await context.read<AuthController>().resolveCourier(_code.text);
  }
}
