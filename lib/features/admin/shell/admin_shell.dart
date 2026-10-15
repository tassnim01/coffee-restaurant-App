import 'package:flutter/material.dart';
import '../menu/screens/menu_management_screen.dart';
import '../orders/screens/orders_screen.dart';
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
  int _index = 1; // démarre sur "Gestion des commandes"

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
          ComingSoonScreen(title: 'Tableau de bord', onMenuTap: _openDrawer),
          OrdersScreen(onMenuTap: _openDrawer),
          ComingSoonScreen(title: 'Statistiques', onMenuTap: _openDrawer),
          MenuManagementScreen(onMenuTap: _openDrawer),
          ComingSoonScreen(title: 'Paiements', onMenuTap: _openDrawer),
          ComingSoonScreen(title: 'Paramètres', onMenuTap: _openDrawer),
        ],
      ),
    );
  }
}