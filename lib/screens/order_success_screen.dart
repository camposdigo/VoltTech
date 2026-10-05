import 'package:flutter/material.dart';

import '../widgets/common.dart';
import 'orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: EmptyState(
        title: 'Pedido confirmado!',
        description:
            'Seu pedido ${orderId.substring(0, 8).toUpperCase()} foi salvo.\nA compra é simulada: não haverá cobrança ou entrega.',
        icon: Icons.check_circle_outline,
        action: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            FilledButton(
              onPressed: () => openPage(context, const OrdersScreen()),
              child: const Text('Ver meus pedidos'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );
}
