import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: .15), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.greenAccent, size: 64),
                ),
                const SizedBox(height: 24),
                const Text('Pedido confirmado!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                const Text(
                  'A compra foi registrada no fluxo demonstrativo da VoltTech. Se o Supabase estiver configurado, o pedido também é persistido no banco.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('VOLTAR AO INÍCIO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
