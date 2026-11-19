import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dashboard/screens/dashboard_screen.dart';
import '../gestion_client/screens/clients_screen.dart';
import '../menu/screens/menu_management_screen.dart';
import '../orders/screens/orders_screen.dart';
import '../settings/screens/admin_settings_screen.dart';
import 'admin_drawer.dart';
import 'coming_soon_scree.dart';
import '../../payment/screens/payments_screen.dart';

/// Conteneur de l'espace responsable : menu latéral + pages.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0; // démarre sur "Tableau de bord"

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _select(int index) {
    _scaffoldKey.currentState?.closeDrawer();
    setState(() => _index = index);
  }

  Future<void> _logout() async {
    _scaffoldKey.currentState?.closeDrawer();
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Impossible de fermer la session.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AdminDrawer(
        selectedIndex: _index,
        onSelect: _select,
        onLogout: _logout,
      ),
      // IndexedStack garde l'état de chaque page (recherche, onglets...).
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            onMenuTap: _openDrawer,
            onSeeOrders: () => setState(() => _index = 1),
          ),
          OrdersScreen(onMenuTap: _openDrawer),
          ComingSoonScreen(title: 'Statistiques', onMenuTap: _openDrawer),
          MenuManagementScreen(onMenuTap: _openDrawer),
          ClientsScreen(onMenuTap: _openDrawer),
          PaymentsScreen(onMenuTap: _openDrawer),
          AdminSettingsScreen(onMenuTap: _openDrawer),
        ],
      ),
    );
  }
}
