import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  int cartItems = 0;
  String selectedCategory = 'Todos';

  final categories = const [
    ('Todos', Icons.grid_view_rounded),
    ('Smartphones', Icons.smartphone_rounded),
    ('Notebooks', Icons.laptop_mac_rounded),
    ('Áudio', Icons.headphones_rounded),
    ('Câmeras', Icons.photo_camera_rounded),
    ('Smartwatches', Icons.watch_rounded),
    ('Acessórios', Icons.cable_rounded),
  ];

  final products = const [
    Product('Smartphone Pro X', 'Smartphones', 'R\$ 3.999,00', 'R\$ 4.599,00', Icons.smartphone_rounded, 13),
    Product('Notebook Ultra', 'Notebooks', 'R\$ 5.499,00', 'R\$ 6.299,00', Icons.laptop_mac_rounded, 12),
    Product('Headphone Air Max', 'Áudio', 'R\$ 899,00', 'R\$ 1.099,00', Icons.headphones_rounded, 18),
    Product('Smartwatch Vision', 'Smartwatches', 'R\$ 1.299,00', 'R\$ 1.599,00', Icons.watch_rounded, 19),
    Product('Câmera Vision 4K', 'Câmeras', 'R\$ 2.799,00', 'R\$ 3.199,00', Icons.photo_camera_rounded, 12),
    Product('Carregador Turbo 65W', 'Acessórios', 'R\$ 199,00', 'R\$ 249,00', Icons.bolt_rounded, 20),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = selectedCategory == 'Todos'
        ? products
        : products.where((p) => p.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 30),
          SizedBox(width: 6),
          Text('VOLT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          Text('TECH', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ]),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded)),
          Badge(
            label: Text('$cartItems'),
            isLabelVisible: cartItems > 0,
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_bag_outlined)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'O que você está procurando?',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1B090B), Color(0xFF090909)]),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primary.withValues(alpha: .35)),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  FilledButton(onPressed: () {}, child: const Text('VER OFERTAS')),
                ])),
                const SizedBox(width: 10),
                const Icon(Icons.devices_rounded, size: 82, color: AppTheme.primary),
              ]),
            ),
            const SizedBox(height: 26),
            const _SectionTitle(title: 'Categorias', action: 'Ver todas'),
            const SizedBox(height: 14),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final item = categories[i];
                  final active = selectedCategory == item.$1;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => selectedCategory = item.$1),
                    child: Container(
                      width: 88,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: active ? AppTheme.primary : AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(item.$2, size: 25),
                        const SizedBox(height: 7),
                        Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Mais vendidos', action: 'Ver todos'),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .63, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemBuilder: (_, i) => _ProductCard(product: visible[i], onAdd: () => setState(() => cartItems++)),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _Benefit(Icons.local_shipping_outlined, 'Entrega rápida'),
                _Benefit(Icons.verified_user_outlined, 'Compra segura'),
                _Benefit(Icons.workspace_premium_outlined, 'Garantia'),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
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

class Product {
  final String name, category, price, oldPrice;
  final IconData icon;
  final int discount;
  const Product(this.name, this.category, this.price, this.oldPrice, this.icon, this.discount);
}

class _SectionTitle extends StatelessWidget {
  final String title, action;
  const _SectionTitle({required this.title, required this.action});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
    Text(action, style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700)),
  ]);
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [
        Container(height: 110, decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14)), child: Center(child: Icon(product.icon, size: 58, color: Colors.white70))),
        Positioned(top: 7, left: 7, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)), child: Text('-${product.discount}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)))),
        Positioned(top: 2, right: 2, child: IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, size: 20))),
      ]),
      const SizedBox(height: 10),
      Text(product.category.toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .7)),
      const SizedBox(height: 4),
      Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      const Spacer(),
      Text(product.oldPrice, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, decoration: TextDecoration.lineThrough)),
      Text(product.price, style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, height: 34, child: FilledButton(onPressed: onAdd, child: const Text('ADICIONAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)))),
    ]),
  );
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Benefit(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, color: AppTheme.primary), const SizedBox(height: 6), Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))]);
}
