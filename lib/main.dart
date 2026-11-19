import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_mode_provider.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/client/orders/data/firebase_client_order_repository.dart';
import 'features/client/orders/providers/client_orders_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/gestion_client/data/client_repository.dart';
import 'features/admin/gestion_client/data/firebase_client_repository.dart';
import 'features/admin/gestion_client/providers/client_provider.dart';
import 'features/admin/menu/data/firebase_menu_repository.dart';
import 'features/admin/menu/data/menu_repository.dart';
import 'features/admin/menu/providers/menu_provider.dart';
import 'features/admin/orders/data/firebase_order_repository.dart';
import 'features/admin/orders/data/order_repository.dart';
import 'features/admin/orders/providers/orders_provider.dart';
import 'firebase_options.dart';
import 'features/client/cart/providers/cart_provider.dart';
import 'features/client/welcome/welcome_screen.dart';
import 'features/payment/widgets/payment_gate.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/client/orders/data/client_order_repository.dart';
import 'features/admin/auth/admin_access_gate.dart';

/// Temporaire : true = espace client, false = espace responsable.
const bool kStartAsClient = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    CoffeeShopApp(
      menuRepository: FirebaseMenuRepository(),
      orderRepository: FirebaseOrderRepository(),
      clientRepository: FirebaseClientRepository(),
    ),
  );
}

class CoffeeShopApp extends StatelessWidget {
  final MenuRepository menuRepository;
  final OrderRepository orderRepository;
  final ClientRepository clientRepository;
  final AuthRepository? authRepository;
  final ClientOrderRepository? clientOrderRepository;
  final bool? startAsClient;

  const CoffeeShopApp({
    super.key,
    required this.menuRepository,
    required this.orderRepository,
    required this.clientRepository,
    this.authRepository,
    this.clientOrderRepository,
    this.startAsClient,
  });

  @override
  Widget build(BuildContext context) {
    final clientMode = startAsClient ?? kStartAsClient;
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
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<ThemeModeProvider>(
          create: (_) => ThemeModeProvider(),
        ),
        if (clientMode) ...[
          ChangeNotifierProvider<AuthProvider>(
            create: (_) =>
                AuthProvider(authRepository ?? FirebaseAuthRepository()),
          ),
          ChangeNotifierProxyProvider<AuthProvider, ClientOrdersProvider>(
            create: (_) => ClientOrdersProvider(
              clientOrderRepository ?? FirebaseClientOrderRepository(),
            ),
            update: (_, auth, orders) => orders!..setUser(auth.user?.uid),
          ),
        ],
      ],
      child: Consumer<ThemeModeProvider>(
        builder: (context, themeMode, _) => MaterialApp(
          title: 'Coffee Shop',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode.themeMode,
          home: clientMode ? const WelcomeScreen() : const AdminAccessGate(),
          builder: (context, child) => PaymentGate(
            isClient: clientMode,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
