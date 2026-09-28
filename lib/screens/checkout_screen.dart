import 'package:flutter/material.dart';
import '../controllers/volttech_store.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: 'Cliente VoltTech');
  final emailController = TextEditingController(text: 'cliente@volttech.com');
  final addressController = TextEditingController(text: 'Av. Paulista, 1000 - São Paulo/SP');
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> finishOrder() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);

    await SupabaseService.instance.saveOrder(
      customerName: nameController.text.trim(),
      email: emailController.text.trim(),
      address: addressController.text.trim(),
    );

    VoltTechStore.instance.clearCart();

    if (!mounted) return;
    setState(() => loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = VoltTechStore.instance.cartTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar compra')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Dados de entrega', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.person_outline)),
              validator: (value) => value == null || value.trim().isEmpty ? 'Informe seu nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)),
              validator: (value) => value != null && value.contains('@') ? null : 'Informe um e-mail válido',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Endereço', prefixIcon: Icon(Icons.location_on_outlined)),
              validator: (value) => value == null || value.trim().length < 8 ? 'Informe o endereço' : null,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Frete'), Text('GRÁTIS', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w800))],
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total do pedido', style: TextStyle(fontWeight: FontWeight.w800)),
                      Text(formatMoney(total), style: const TextStyle(color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Pagamento demonstrativo: cartão final 4242 • nenhum pagamento real será processado.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: loading ? null : finishOrder,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('CONFIRMAR PEDIDO'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
