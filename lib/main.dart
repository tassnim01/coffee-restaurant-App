import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/client/data/client_repository.dart';
import 'features/admin/client/data/firebase_client_repository.dart';
import 'features/admin/client/providers/client_provider.dart';
import 'features/admin/menu/data/firebase_menu_repository.dart';
import 'features/admin/menu/data/menu_repository.dart';
import 'features/admin/menu/providers/menu_provider.dart';
import 'features/admin/orders/data/firebase_order_repository.dart';
import 'features/admin/orders/data/order_repository.dart';
import 'features/admin/orders/providers/orders_provider.dart';
import 'features/admin/shell/admin_shell.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final menuRepository = FirebaseMenuRepository();
  await menuRepository.seedIfEmpty();

  final orderRepository = FirebaseOrderRepository();
  await orderRepository.seedIfEmpty();

  final clientRepository = FirebaseClientRepository();
  await clientRepository.seedIfEmpty();

  runApp(
    CoffeeShopApp(
      menuRepository: menuRepository,
      orderRepository: orderRepository,
      clientRepository: clientRepository,
    ),
  );
}

class CoffeeShopApp extends StatelessWidget {
  final MenuRepository menuRepository;
  final OrderRepository orderRepository;
  final ClientRepository clientRepository;

  const CoffeeShopApp({
    super.key,
    required this.menuRepository,
    required this.orderRepository,
    required this.clientRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuProvider>(
          create: (_) => MenuProvider(menuRepository)..loadMenu(),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create: (_) => OrdersProvider(orderRepository),
        ),
        ChangeNotifierProvider<ClientsProvider>(
          create: (_) => ClientsProvider(clientRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Coffee Shop Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AdminShell(),
      ),
    );
  }
}