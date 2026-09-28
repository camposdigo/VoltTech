import 'package:flutter/material.dart';
import '../controllers/volttech_store.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final products = store.favoriteProducts;
        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 64),
                  SizedBox(height: 16),
                  Text('Nenhum favorito ainda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Toque no coração de um produto para salvar aqui.', textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .60,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (_, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
              ),
            );
          },
        );
      },
    );
  }
}
