import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/app_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/courier_code_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CourierCustomerApp());
}

class CourierCustomerApp extends StatelessWidget {
  const CourierCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AppStorage()),
        ProxyProvider<AppStorage, ApiClient>(
          update: (_, storage, __) => ApiClient(storage: storage),
        ),
        ChangeNotifierProxyProvider2<AppStorage, ApiClient, AuthController>(
          create: (_) => AuthController.empty(),
          update: (_, storage, api, controller) =>
              (controller ?? AuthController.empty())..bind(storage, api),
        ),
      ],
      child: Consumer<AuthController>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: auth.activeCourier?.companyName ?? 'Courier Customer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.fromCourier(auth.activeCourier),
            home: const AppGate(),
          );
        },
      ),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AuthController>().restore());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    if (auth.isBooting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.activeCourier == null) {
      return const CourierCodeScreen();
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    return const DashboardShell();
  }
}
