import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/cache/product_local_cache.dart';
import 'data/cache/product_memory_cache.dart';
import 'data/datasources/product_api.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/pages/favorites_page.dart';
import 'presentation/pages/product_list_page.dart';
import 'presentation/viewmodels/favorites_viewmodel.dart';
import 'presentation/viewmodels/product_list_viewmodel.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductListViewModel(
            ProductRepositoryImpl(
              api: ProductApi(),
              memoryCache: ProductMemoryCache(),
              localCache: ProductLocalCache(prefs),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesViewModel(prefs),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Catálogo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/products': (context) => const ProductListPage(),
          '/favorites': (context) => const FavoritesPage(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
