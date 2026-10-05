import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../services/supabase_service.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await VoltTechStore.instance.refreshOrders();
    } catch (e) {
      error = friendlyError(e);
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Meus pedidos'),
      actions: [
        IconButton(
          tooltip: 'Atualizar pedidos',
          onPressed: loading ? null : load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? EmptyState(
            title: 'Não foi possível carregar',
            description: error!,
            action: FilledButton(
              onPressed: load,
              child: const Text('Tentar novamente'),
            ),
          )
        : AnimatedBuilder(
            animation: VoltTechStore.instance,
            builder: (context, _) {
              final orders = VoltTechStore.instance.orders;
              if (orders.isEmpty) {
                return const EmptyState(
                  title: 'Sua história começa com uma escolha',
                  description:
                      'Quando finalizar uma compra, seu pedido aparecerá aqui.',
                  icon: Icons.receipt_long_outlined,
                );
              }
              return PageBody(
                maxWidth: 850,
                children: [
                  for (final order in orders)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        child: ExpansionTile(
                          title: Text(
                            'Pedido ${order['id'].toString().substring(0, 8).toUpperCase()}',
                          ),
                          subtitle: Text(
                            '${dateLabel(order['created_at'])}\n${order['status']} · ${formatMoney((order['total'] as num).toDouble())}',
                          ),
                          children: [
                            for (final item in order['order_items'])
                              ListTile(
                                title: Text(item['product_name']),
                                subtitle: Text(
                                  '${item['quantity']} × ${formatMoney((item['unit_price'] as num).toDouble())}',
                                ),
                              ),
                            ListTile(
                              title: Text(
                                'Pagamento: ${order['payment_method']} (simulado)',
                              ),
                              subtitle: Text(
                                '${order['customer_name']}\n${order['address']}',
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

String dateLabel(String value) {
  final d = DateTime.parse(value).toLocal();
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
