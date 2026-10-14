import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/menu/data/firebase_menu_repository.dart';
import 'features/admin/menu/data/menu_repository.dart';
import 'features/admin/menu/providers/menu_provider.dart';
import 'features/admin/menu/screens/menu_management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final repository = FirebaseMenuRepository();
  await repository.seedIfEmpty();

  // Pour revenir aux données locales, utilisez plutôt :
  // final repository = MockMenuRepository();

  runApp(CoffeeShopApp(repository: repository));
}

class CoffeeShopApp extends StatelessWidget {
  final MenuRepository repository;

  const CoffeeShopApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuProvider>(
          create: (_) => MenuProvider(repository)..loadMenu(),
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