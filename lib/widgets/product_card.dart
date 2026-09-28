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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D0202),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.surface,
                            child: Icon(product.icon, size: 56, color: Colors.white70),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: _badgeColor(product.badge),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            product.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xAA0A0101),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              store.toggleFavorite(product);
                              await SupabaseService.instance.syncFavorite(
                                product,
                                store.isFavorite(product),
                              );
                            },
                            icon: Icon(
                              favorite ? Icons.favorite : Icons.favorite_border,
                              color: favorite ? AppTheme.primary : AppTheme.textPrimary,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: i < product.rating.round()
                                    ? const Color(0xFFF59E0B)
                                    : AppTheme.border,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              product.rating.toStringAsFixed(1) + ' (' + product.reviews.toString() + ')',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          formatMoney(product.oldPrice),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatMoney(product.price),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () {
                                store.addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(product.name + ' adicionado ao carrinho'),
                                    duration: const Duration(milliseconds: 900),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 14),
                              label: const Text('Carrinho'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _badgeColor(String badge) {
    if (badge == 'Popular') return const Color(0xFF7C3AED);
    if (badge == 'Oferta') return const Color(0xFFD97706);
    if (badge == 'Destaque') return const Color(0xFF059669);
    return AppTheme.primary;
  }
}
