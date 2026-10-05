import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';
import 'comparison_screen.dart';
import 'favorites_screen.dart';
import 'products_screen.dart';
import 'profile_screen.dart';
import 'landing_page.dart';
export 'landing_page.dart' show LandingPage;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  @override
  void initState() {
    super.initState();
    VoltTechStore.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 900;
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 72,
              titleSpacing: 24,
              title: InkWell(
                onTap: () => setState(() => index = 0),
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Volt'),
                      TextSpan(
                        text: 'Tech',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ],
                  ),
                  semanticsLabel: 'VoltTech',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
              actions: [
                if (wide) ...[
                  for (final item in [
                    (0, 'Início'),
                    (1, 'Catálogo'),
                    (2, 'Favoritos'),
                    (3, 'Minha conta'),
                  ])
                    TextButton(
                      onPressed: () => setState(() => index = item.$1),
                      child: Text(
                        item.$2,
                        style: TextStyle(
                          color: index == item.$1
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                ],
                if (store.comparison.isNotEmpty)
                  IconButton(
                    tooltip: 'Comparar produtos',
                    onPressed: () =>
                        openPage(context, const ComparisonScreen()),
                    icon: Badge(
                      label: Text('${store.comparison.length}'),
                      child: const Icon(Icons.compare_arrows),
                    ),
                  ),
                IconButton(
                  tooltip: 'Carrinho',
                  onPressed: () => openPage(context, const CartScreen()),
                  icon: Badge(
                    isLabelVisible: store.cartCount > 0,
                    label: Text('${store.cartCount}'),
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: Column(
              children: [
                if (store.error != null && store.products.isNotEmpty)
                  MaterialBanner(
                    content: Text(store.error!),
                    actions: [
                      TextButton(
                        onPressed: store.initialize,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                Expanded(
                  child: store.loading && store.products.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : store.error != null && store.products.isEmpty
                      ? EmptyState(
                          title: 'Não foi possível carregar a loja',
                          description: store.error!,
                          action: FilledButton(
                            onPressed: store.initialize,
                            child: const Text('Tentar novamente'),
                          ),
                        )
                      : IndexedStack(
                          index: index,
                          children: const [
                            LandingPage(),
                            ProductsScreen(),
                            FavoritesScreen(),
                            ProfileScreen(),
                          ],
                        ),
                ),
              ],
            ),
            bottomNavigationBar: wide
                ? null
                : NavigationBar(
                    selectedIndex: index,
                    onDestinationSelected: (v) => setState(() => index = v),
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        label: 'Início',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.grid_view),
                        label: 'Catálogo',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.favorite_border),
                        label: 'Favoritos',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_outline),
                        label: 'Conta',
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
