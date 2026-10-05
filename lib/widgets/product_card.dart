import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../models/product.dart';
import '../screens/auth_screen.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'common.dart';

class ProductImage extends StatelessWidget {
  final Product product;
  const ProductImage(this.product, {super.key});
  @override
  Widget build(BuildContext context) => Image.network(
    product.imageUrl,
    fit: BoxFit.cover,
    semanticLabel: 'Imagem ilustrativa de ${product.category}',
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    errorBuilder: (_, error, stack) => ColoredBox(
      color: AppTheme.surface2,
      child: Center(
        child: Icon(product.icon, size: 64, color: AppTheme.textSecondary),
      ),
    ),
  );
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  InkWell(onTap: onTap, child: ProductImage(product)),
                  if (product.onSale)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Chip(
                        label: Text(
                          '-${((1 - product.price / product.oldPrice!) * 100).round()}%',
                        ),
                        backgroundColor: AppTheme.primary,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: AppTheme.background.withValues(alpha: .85),
                      borderRadius: BorderRadius.circular(30),
                      child: IconButton(
                        tooltip: store.isFavorite(product)
                            ? 'Remover favorito'
                            : 'Salvar favorito',
                        onPressed: store.busy
                            ? null
                            : () async {
                                if (await requireLogin(context) &&
                                    context.mounted) {
                                  await runAction(
                                    context,
                                    () => store.toggleFavorite(product),
                                  );
                                }
                              },
                        icon: Icon(
                          store.isFavorite(product)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: store.isFavorite(product)
                              ? AppTheme.primary
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 42,
                    child: Text(
                      product.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.onSale
                        ? formatMoney(product.oldPrice!)
                        : 'Preço à vista',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      decoration: product.onSale
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Text(
                    formatMoney(product.price),
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: product.stock == 0 || store.busy
                          ? null
                          : () => runAction(
                              context,
                              () => store.addToCart(product),
                              success: 'Produto adicionado ao carrinho',
                            ),
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: Text(
                        product.stock == 0 ? 'Indisponível' : 'Adicionar',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => runAction(
                        context,
                        () async => store.toggleComparison(product),
                      ),
                      icon: Icon(
                        store.comparison.contains(product.id)
                            ? Icons.check
                            : Icons.compare_arrows,
                        size: 18,
                      ),
                      label: Text(
                        store.comparison.contains(product.id)
                            ? 'Selecionado'
                            : 'Comparar',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final void Function(Product) onSelect;
  const ProductGrid({
    super.key,
    required this.products,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = (constraints.maxWidth / 280).floor().clamp(1, 4);
      final scale = MediaQuery.textScalerOf(context).scale(1);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: 460 + (scale - 1) * 240,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemBuilder: (_, i) => ProductCard(
          product: products[i],
          onTap: () => onSelect(products[i]),
        ),
      );
    },
  );
}
