import 'package:flutter/material.dart';
import '../controllers/volttech_store.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final favorite = store.isFavorite(product);
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: .04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 112,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Icon(product.icon, size: 58, color: Colors.white70)),
                    ),
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                        child: Text('-' + product.discount.toString() + '%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton(
                        onPressed: () async {
                          store.toggleFavorite(product);
                          await SupabaseService.instance.syncFavorite(product, store.isFavorite(product));
                        },
                        icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? AppTheme.primary : Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(product.category.toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .7)),
                const SizedBox(height: 4),
                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const Spacer(),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                  const SizedBox(width: 3),
                  Text(product.rating.toStringAsFixed(1), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ]),
                const SizedBox(height: 5),
                Text(formatMoney(product.oldPrice), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, decoration: TextDecoration.lineThrough)),
                Text(formatMoney(product.price), style: const TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: FilledButton(
                    onPressed: () {
                      store.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(product.name + ' adicionado ao carrinho'), duration: const Duration(milliseconds: 900)),
                      );
                    },
                    child: const Text('ADICIONAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
