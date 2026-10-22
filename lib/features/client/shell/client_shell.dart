import 'package:flutter/material.dart';
import '../home/screens/home_screen.dart';
import '../menu/screens/client_menu_screen.dart';
import 'client_bottom_nav.dart';
import 'client_placeholder_screen.dart';

/// Conteneur de l'espace client : pages + barre de navigation du bas.
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0; // démarre sur "Accueil"
  final _menuCategory = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _menuCategory.dispose();
    super.dispose();
  }

  /// Ouvre l'onglet Menu, éventuellement filtré sur une catégorie.
  void _openMenu(String? categoryId) {
    _menuCategory.value = categoryId;
    setState(() => _index = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenMenu: _openMenu),
          ClientMenuScreen(categoryFilter: _menuCategory),
          const ClientPlaceholderScreen(
              title: 'Panier', icon: Icons.shopping_bag_outlined),
          const ClientPlaceholderScreen(
              title: 'Compte', icon: Icons.person_outline_rounded),
        ],
      ),
      bottomNavigationBar: ClientBottomNav(
        currentIndex: _index,
        onTap: (i) {
          // Toucher l'onglet Menu directement = toutes les catégories.
          if (i == 1 && _index != 1) _menuCategory.value = null;
          setState(() => _index = i);
        },
      ),
    );
  }
}