import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';
import 'auth_screen.dart';
import 'cart_screen.dart';
import 'comparison_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final current =
              store.products.where((p) => p.id == product.id).firstOrNull ??
              product;
          return PageBody(
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  final image = Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: AspectRatio(
                          aspectRatio: 1.15,
                          child: ProductImage(current),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Imagem ilustrativa',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                  final info = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current.category} · ${current.brand}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        current.name,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        current.shortDescription,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        current.description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (current.onSale)
                        Text(
                          formatMoney(current.oldPrice!),
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      Text(
                        formatMoney(current.price),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        current.stock > 0
                            ? '${current.stock} unidades disponíveis'
                            : 'Temporariamente indisponível',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: store.busy || current.stock == 0
                              ? null
                              : () => runAction(
                                  context,
                                  () => store.addToCart(current),
                                  success: 'Produto adicionado ao carrinho',
                                ),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('Adicionar ao carrinho'),
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: store.busy
                                ? null
                                : () async {
                                    if (await requireLogin(context) &&
                                        context.mounted) {
                                      await runAction(
                                        context,
                                        () => store.toggleFavorite(current),
                                      );
                                    }
                                  },
                            icon: Icon(
                              store.isFavorite(current)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: const Text('Favoritar'),
                          ),
                          TextButton.icon(
                            onPressed: () => runAction(
                              context,
                              () async => store.toggleComparison(current),
                            ),
                            icon: Icon(
                              store.comparison.contains(current.id)
                                  ? Icons.check
                                  : Icons.compare_arrows,
                            ),
                            label: const Text('Comparar'),
                          ),
                          TextButton(
                            onPressed: () =>
                                openPage(context, const CartScreen()),
                            child: const Text('Ver carrinho'),
                          ),
                          if (store.comparison.length >= 2)
                            TextButton(
                              onPressed: () =>
                                  openPage(context, const ComparisonScreen()),
                              child: const Text('Abrir comparação'),
                            ),
                        ],
                      ),
                    ],
                  );
                  return c.maxWidth > 800
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: image),
                            const SizedBox(width: 40),
                            Expanded(child: info),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [image, const SizedBox(height: 24), info],
                        );
                },
              ),
              const SectionTitle(
                'Este produto combina com você?',
                'O que importa, explicado de um jeito simples.',
              ),
              explanation('Ideal para', current.explanation('ideal_for')),
              explanation(
                'Serve bem para',
                current.points('good_for').join(' · '),
              ),
              explanation(
                'Não recomendado para',
                current.points('not_recommended_for').join(' · '),
              ),
              explanation(
                'Desempenho no dia a dia',
                current.explanation('performance_explanation'),
              ),
              explanation(
                'Bateria sem mistério',
                current.explanation('battery_explanation'),
              ),
              explanation(
                'Como é a tela',
                current.explanation('display_explanation'),
              ),
              explanation('Pontos fortes', current.points('pros').join('\n')),
              explanation(
                'Pontos de atenção',
                current.points('attention_points').join('\n'),
              ),
              explanation('Por que comprar', current.explanation('why_buy')),
              explanation('Perfil ideal', current.explanation('user_profile')),
              ExpansionTile(
                title: const Text('Ver especificações técnicas'),
                children: [
                  for (final spec in current.specs.entries)
                    ListTile(title: Text(spec.key), subtitle: Text(spec.value)),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Produto do catálogo demonstrativo VoltTech. Informações e preços ilustrativos.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget explanation(String title, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.6),
        ),
      ],
    ),
  );
}
