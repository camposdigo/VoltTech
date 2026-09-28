import 'package:flutter/material.dart';
import '../controllers/volttech_store.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final entries = store.cart.entries.toList();

          if (entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 70),
                  SizedBox(height: 16),
                  Text('Seu carrinho está vazio', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final entry = entries[index];
                    final product = store.products.firstWhere((item) => item.id == entry.key);
                    final quantity = entry.value;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(18)),
                      child: Row(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14)),
                            child: Icon(product.icon, size: 38),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(formatMoney(product.price), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(onPressed: () => store.decrease(product), icon: const Icon(Icons.remove_circle_outline)),
                                    Text(quantity.toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
                                    IconButton(onPressed: () => store.addToCart(product), icon: const Icon(Icons.add_circle_outline)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(onPressed: () => store.removeFromCart(product), icon: const Icon(Icons.delete_outline)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          Text(formatMoney(store.cartTotal), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('CONTINUAR PARA CHECKOUT'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
