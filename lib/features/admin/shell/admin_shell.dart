import 'package:flutter/material.dart';

import '../dashboard/screens/dashboard_screen.dart';
import '../gestion_client/screens/clients_screen.dart';
import '../menu/screens/menu_management_screen.dart';
import '../orders/screens/orders_screen.dart';
import '../settings/screens/settings_screen.dart';
import 'admin_drawer.dart';
import 'coming_soon_scree.dart';

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

  void _logout() {
    _scaffoldKey.currentState?.closeDrawer();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            "La déconnexion sera disponible avec l'authentification.",
          ),
        ),
      );
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
          ComingSoonScreen(title: 'Paiements', onMenuTap: _openDrawer),
          SettingsScreen(onMenuTap: _openDrawer),
        ],
      ),
    );
  }
}
