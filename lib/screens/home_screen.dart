import 'package:flutter/material.dart';
import '../controllers/volttech_store.dart';
import '../data/mock_products.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'product_details_screen.dart';
import 'products_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = const [
    _HomeTab(),
    ProductsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  final titles = const ['VoltTech', 'Produtos', 'Favoritos', 'Perfil'];

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: currentIndex == 0
            ? const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 30),
                  SizedBox(width: 6),
                  Text('VOLT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  Text('TECH', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              )
            : Text(titles[currentIndex], style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          AnimatedBuilder(
            animation: store,
            builder: (context, _) => Badge(
              label: Text(store.cartCount.toString()),
              isLabelVisible: store.cartCount > 0,
              child: IconButton(
                tooltip: 'Carrinho',
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Produtos'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final featured = mockProducts.take(4).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        TextField(
          readOnly: true,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _CatalogPage())),
          decoration: const InputDecoration(
            hintText: 'O que você está procurando?',
            prefixIcon: Icon(Icons.search_rounded),
            suffixIcon: Icon(Icons.tune_rounded),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1B090B), Color(0xFF090909)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primary, width: .5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                      child: const Text('OFERTA RELÂMPAGO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 14),
                    const Text('Tecnologia que\nacelera seu mundo.', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900, height: 1.05)),
                    const SizedBox(height: 10),
                    const Text('Até 30% OFF em produtos selecionados.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _CatalogPage())),
                      child: const Text('VER OFERTAS'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.devices_rounded, size: 82, color: AppTheme.primary),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const _SectionTitle(title: 'Categorias'),
        const SizedBox(height: 14),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: mockCategories.length - 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final category = mockCategories[index + 1];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _CatalogPage(initialCategory: category)),
                ),
                child: Container(
                  width: 92,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_categoryIcon(category), size: 25, color: AppTheme.primary),
                      const SizedBox(height: 7),
                      Text(category, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle(title: 'Mais vendidos'),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: featured.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .60,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, index) {
            final product = featured[index];
            return ProductCard(
              product: product,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
              ),
            );
          },
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Benefit(Icons.local_shipping_outlined, 'Entrega rápida'),
              _Benefit(Icons.verified_user_outlined, 'Compra segura'),
              _Benefit(Icons.workspace_premium_outlined, 'Garantia'),
            ],
          ),
        ),
      ],
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Smartphones':
        return Icons.smartphone_rounded;
      case 'Notebooks':
        return Icons.laptop_mac_rounded;
      case 'Áudio':
        return Icons.headphones_rounded;
      case 'Câmeras':
        return Icons.photo_camera_rounded;
      case 'Smartwatches':
        return Icons.watch_rounded;
      default:
        return Icons.cable_rounded;
    }
  }
}

class _CatalogPage extends StatelessWidget {
  final String initialCategory;
  const _CatalogPage({this.initialCategory = 'Todos'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: ProductsScreen(initialCategory: initialCategory),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const Text('Ver todos', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      );
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Benefit(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      );
}
