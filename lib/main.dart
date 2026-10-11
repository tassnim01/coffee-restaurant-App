import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/menu/data/mock_menu_repository.dart';
import 'features/admin/menu/providers/menu_provider.dart';
import 'features/admin/menu/screens/menu_management_screen.dart';

void main() {
  runApp(const CoffeeShopApp());
}

class CoffeeShopApp extends StatelessWidget {
  const CoffeeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuProvider>(
          // Swap MockMenuRepository for a Firebase repository later.
          create: (_) => MenuProvider(MockMenuRepository())..loadMenu(),
        ),
      ],
      child: MaterialApp(
        title: 'Coffee Shop Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MenuManagementScreen(),
      ),
    );
  }
}