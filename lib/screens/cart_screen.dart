import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Seu carrinho')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          if (store.cart.isEmpty) {
            return const EmptyState(
              title: 'Seu carrinho está esperando uma boa escolha',
              description: 'Explore o catálogo ou use o assistente de compra.',
              icon: Icons.shopping_bag_outlined,
            );
          }
          final products = store.products
              .where((p) => store.cart.containsKey(p.id))
              .toList();
          return PageBody(
            maxWidth: 900,
            children: [
              if (!store.signedIn)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Você pode escolher agora e entrar ao finalizar. Seu carrinho será salvo na sua conta.',
                  ),
                ),
              for (final p in products)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                p.icon,
                                size: 32,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remover ${p.name}',
                                onPressed: store.busy
                                    ? null
                                    : () => runAction(
                                        context,
                                        () => store.removeFromCart(p),
                                      ),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(formatMoney(p.price)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              IconButton(
                                tooltip: 'Diminuir quantidade',
                                onPressed: store.busy
                                    ? null
                                    : () => runAction(
                                        context,
                                        () => store.decrease(p),
                                      ),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '${store.quantityOf(p)}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                tooltip: 'Aumentar quantidade',
                                onPressed:
                                    store.busy || store.quantityOf(p) >= p.stock
                                    ? null
                                    : () => runAction(
                                        context,
                                        () => store.addToCart(p),
                                      ),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              Text(
                                'Subtotal: ${formatMoney(p.price * store.quantityOf(p))}',
                              ),
                            ],
                          ),
                          if (store.quantityOf(p) > p.stock)
                            const Text(
                              'O estoque mudou. Reduza a quantidade para continuar.',
                              style: TextStyle(color: Colors.orangeAccent),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              for (final id in store.cart.keys.where(
                (id) => !products.any((p) => p.id == id),
              ))
                ListTile(
                  title: const Text('Produto indisponível'),
                  subtitle: const Text('Remova este item para continuar.'),
                  trailing: IconButton(
                    tooltip: 'Remover produto indisponível',
                    onPressed: store.busy
                        ? null
                        : () => runAction(
                            context,
                            () => store.removeUnavailableItem(id),
                          ),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Total: ${formatMoney(store.cartTotal)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Frete gratuito nesta simulação. Nenhuma cobrança será realizada.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: store.busy
                      ? null
                      : () async {
                          if (await requireLogin(context) && context.mounted) {
                            openPage(context, const CheckoutScreen());
                          }
                        },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Continuar para checkout'),
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
