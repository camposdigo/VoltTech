import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';
import 'auth_screen.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        if (!store.signedIn) {
          return EmptyState(
            title: 'Suas escolhas, guardadas',
            description: 'Entre para salvar seus favoritos e encontrar depois.',
            icon: Icons.favorite_border,
            action: FilledButton(
              onPressed: () => requireLogin(context),
              child: const Text('Entrar'),
            ),
          );
        }
        if (store.favoriteProducts.isEmpty) {
          return const EmptyState(
            title: 'Nenhum favorito ainda',
            description:
                'Toque no coração de um produto para guardar sua escolha.',
            icon: Icons.favorite_border,
          );
        }
        return PageBody(
          children: [
            const SectionTitle(
              'Seus favoritos',
              'Boas escolhas merecem ficar por perto.',
            ),
            ProductGrid(
              products: store.favoriteProducts,
              onSelect: (p) =>
                  openPage(context, ProductDetailsScreen(product: p)),
            ),
          ],
        );
      },
    );
  }
}
