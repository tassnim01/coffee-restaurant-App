import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
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

  runApp(
    CoffeeShopApp(
      menuRepository: menuRepository,
      orderRepository: orderRepository,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CoffeeShopApp extends StatelessWidget {
  final MenuRepository menuRepository;
  final OrderRepository orderRepository;

  const CoffeeShopApp({
    super.key,
    required this.menuRepository,
    required this.orderRepository,
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