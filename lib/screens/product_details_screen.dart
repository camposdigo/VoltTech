import 'package:flutter/material.dart';
import '../controllers/volttech_store.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          AnimatedBuilder(
            animation: store,
            builder: (context, _) => IconButton(
              onPressed: () async {
                store.toggleFavorite(product);
                await SupabaseService.instance.syncFavorite(
                  product,
                  store.isFavorite(product),
                );
              },
              icon: Icon(
                store.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                color: store.isFavorite(product) ? AppTheme.primary : null,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 850;
          final image = ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.surface,
                  child: Icon(product.icon, size: 120),
                ),
              ),
            ),
          );

          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.category.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                style: TextStyle(
                  fontSize: wide ? 34 : 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 5),
                  Text(
                    product.rating.toStringAsFixed(1) + ' · ' + product.reviews.toString() + ' avaliações',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                product.description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                formatMoney(product.oldPrice),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                formatMoney(product.price),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.stock.toString() + ' unidades em estoque · até 10x sem juros',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    store.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produto adicionado ao carrinho')),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text('ADICIONAR AO CARRINHO'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text('VER CARRINHO'),
                  ),
                ),
              ),
            ],
          );

          if (wide) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: image),
                      const SizedBox(width: 42),
                      Expanded(child: info),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              image,
              const SizedBox(height: 24),
              info,
            ],
          );
        },
      ),
    );
  }
}
