import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/courier_brand_header.dart';
import 'auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final courier = auth.activeCourier;

    return Scaffold(
      appBar: AppBar(
        title: Text(courier?.companyName ?? 'Login'),
        actions: [
          TextButton(
            onPressed: auth.changeCourier,
            child: const Text('Change courier'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CourierBrandHeader(
                        courier: courier,
                        title: courier?.companyName ?? 'Customer login',
                        subtitle: 'Customer login',
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
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
                            : const Text('Sign in'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    await context.read<AuthController>().login(_email.text, _password.text);
  }
}
