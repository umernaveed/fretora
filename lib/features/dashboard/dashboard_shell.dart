import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../addresses/addresses_screen.dart';
import '../auth/auth_controller.dart';
import '../delivery/delivery_screen.dart';
import '../invoices/invoices_screen.dart';
import '../notifications/notifications_screen.dart';
import '../packages/packages_screen.dart';
import '../requests/requests_screen.dart';
import '../settings/settings_screen.dart';
import '../wallet/wallet_screen.dart';
import 'home_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _index = 0;

  final _items = const [
    _NavItem('Home', Icons.dashboard_outlined, HomeScreen()),
    _NavItem('Shipping Addresses', Icons.place_outlined, AddressesScreen()),
    _NavItem('Packages', Icons.inventory_2_outlined, PackagesScreen()),
    _NavItem('Pre-Alerts / Requests', Icons.assignment_outlined, RequestsScreen()),
    _NavItem('Delivery', Icons.local_shipping_outlined, DeliveryScreen()),
    _NavItem('Invoices', Icons.receipt_long_outlined, InvoicesScreen()),
    _NavItem('Wallet / Loyalty', Icons.account_balance_wallet_outlined, WalletScreen()),
    _NavItem('Messages & Alerts', Icons.notifications_outlined, NotificationsScreen()),
    _NavItem('Account', Icons.person_outline, SettingsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final courier = auth.activeCourier;
    final current = _items[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text(current.label),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(courier?.companyName ?? 'Customer Portal'),
                subtitle: Text(courier?.courierCode ?? ''),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      selected: index == _index,
                      leading: Icon(item.icon),
                      title: Text(item.label),
                      onTap: () {
                        setState(() => _index = index);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: current.screen,
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.screen);

  final String label;
  final IconData icon;
  final Widget screen;
}