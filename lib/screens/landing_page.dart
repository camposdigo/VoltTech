import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'products_screen.dart';
import 'recommendation_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    final featured =
        store.products.where((p) => p.categoryId == 'notebook').firstOrNull ??
        store.products.firstOrNull;
    return PageBody(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESCOLHAS PARA O SEU DIA A DIA',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tecnologia\nsem complicação.',
                  style: TextStyle(
                    fontSize: wide ? 58 : 39,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Para estudar, trabalhar ou aproveitar o tempo livre. Encontre o produto certo para o que você precisa.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.65,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => openPage(context, const CatalogPage()),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Ver produtos'),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      iconAlignment: IconAlignment.end,
                    ),
                    TextButton(
                      onPressed: () =>
                          openPage(context, const RecommendationScreen()),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Me ajude a escolher'),
                      ),
                    ),
                  ],
                ),
              ],
            );
            final photo = ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: wide ? 1.18 : 1.4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (featured != null)
                      ProductImage(featured)
                    else
                      const ColoredBox(
                        color: AppTheme.surface2,
                        child: Icon(
                          Icons.laptop_mac,
                          size: 90,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [.45, 1],
                          colors: [Colors.transparent, Color(0xEB0C0C0E)],
                        ),
                      ),
                    ),
                    if (featured != null)
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 22,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'PARA LEVAR MAIS LONGE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 1.6,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    featured.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMoney(featured.price),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filled(
                              tooltip: 'Conhecer ${featured.name}',
                              onPressed: () => openPage(
                                context,
                                ProductDetailsScreen(product: featured),
                              ),
                              icon: const Icon(Icons.arrow_outward),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
            return Padding(
              padding: const EdgeInsets.only(top: 28, bottom: 36),
              child: wide
                  ? Row(
                      children: [
                        Expanded(child: copy),
                        const SizedBox(width: 60),
                        Expanded(child: photo),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [copy, const SizedBox(height: 28), photo],
                    ),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF201316),
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NÃO SABE QUAL ESCOLHER?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: .5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Responda quatro perguntas e veja opções dentro do seu orçamento.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              );
              final button = TextButton.icon(
                onPressed: () =>
                    openPage(context, const RecommendationScreen()),
                label: const Text('Encontrar meu produto'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                iconAlignment: IconAlignment.end,
              );
              return constraints.maxWidth > 700
                  ? Row(
                      children: [
                        const Expanded(child: text),
                        const SizedBox(width: 24),
                        button,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [text, const SizedBox(height: 12), button],
                    );
            },
          ),
        ),
        const SectionTitle(
          'Explore por categoria',
          'O que você está procurando?',
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 550 ? 2 : 5;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final category in store.categories)
                  SizedBox(
                    width: width,
                    child: Material(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => openPage(
                          context,
                          CatalogPage(initialCategory: category['name']),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 23,
                            horizontal: 12,
                          ),
                          child: Column(
                            children: [
                              Icon(categoryIcon(category['id']), size: 28),
                              const SizedBox(height: 12),
                              Text(
                                category['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SectionTitle(
          'Para a sua rotina',
          'Celulares e notebooks para começar a busca.',
        ),
        ProductGrid(
          products: store.products
              .where(
                (p) => p.categoryId == 'notebook' || p.categoryId == 'celular',
              )
              .take(4)
              .toList(),
          onSelect: (p) => openPage(context, ProductDetailsScreen(product: p)),
        ),
        const SectionTitle(
          'Vale conferir',
          'Uma seleção de produtos com preço reduzido.',
        ),
        ProductGrid(
          products: store.products.where((p) => p.onSale).take(4).toList(),
          onSelect: (p) => openPage(context, ProductDetailsScreen(product: p)),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () =>
                openPage(context, const CatalogPage(onlyOffers: true)),
            label: const Text('Todas as ofertas'),
            icon: const Icon(Icons.arrow_forward, size: 18),
            iconAlignment: IconAlignment.end,
          ),
        ),
        const SizedBox(height: 40),
        const Divider(color: AppTheme.border),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'VoltTech\nCatálogo demonstrativo. Fotos ilustrativas. Compras sem cobrança real.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.8,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
