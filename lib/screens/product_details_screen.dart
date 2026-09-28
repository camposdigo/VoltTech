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
        title: const Text('Detalhes do produto'),
        actions: [
          AnimatedBuilder(
            animation: store,
            builder: (context, _) => IconButton(
              onPressed: () async {
                store.toggleFavorite(product);
                await SupabaseService.instance.syncFavorite(product, store.isFavorite(product));
              },
              icon: Icon(
                store.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                color: store.isFavorite(product) ? AppTheme.primary : null,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(child: Icon(product.icon, size: 130, color: Colors.white70)),
          ),
          const SizedBox(height: 24),
          Text(product.category.toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.star_rounded, color: Colors.amber),
            const SizedBox(width: 5),
            Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 16),
            Text(product.stock.toString() + ' unidades em estoque', style: const TextStyle(color: AppTheme.textSecondary)),
          ]),
          const SizedBox(height: 20),
          Text(product.description, style: const TextStyle(color: AppTheme.textSecondary, height: 1.6, fontSize: 15)),
          const SizedBox(height: 24),
          Text(formatMoney(product.oldPrice), style: const TextStyle(color: AppTheme.textSecondary, decoration: TextDecoration.lineThrough)),
          Text(formatMoney(product.price), style: const TextStyle(color: AppTheme.primary, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('ou em até 10x sem juros • Frete simulado grátis', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 26),
          FilledButton.icon(
            onPressed: () {
              store.addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produto adicionado ao carrinho')));
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('ADICIONAR AO CARRINHO'),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('IR PARA O CARRINHO'),
            ),
          ),
        ],
      ),
    );
  }
}
