import 'dart:math';

import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../services/supabase_service.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      address = TextEditingController();
  late final String requestId;
  String payment = 'Pix';
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    name.text = VoltTechStore.instance.profile?['name'] ?? '';
    email.text = SupabaseService.instance.user?.email ?? '';
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    requestId =
        '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> confirm() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final id = await VoltTechStore.instance.checkout(
        requestId: requestId,
        name: name.text.trim(),
        email: email.text.trim(),
        address: address.text.trim(),
        payment: payment,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: id)),
        );
      }
    } catch (e) {
      if (mounted) setState(() => error = friendlyError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Finalizar compra')),
      body: PageBody(
        maxWidth: 700,
        children: [
          const SectionTitle(
            'Quase lá. Confira sua escolha.',
            'Esta compra é uma simulação. Não há cobrança ou envio de produtos.',
          ),
          for (final p in VoltTechStore.instance.products.where(
            (p) => VoltTechStore.instance.quantityOf(p) > 0,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${VoltTechStore.instance.quantityOf(p)} × ${p.name} · ${formatMoney(p.price)}',
              ),
            ),
          const SizedBox(height: 24),
          Form(
            key: form,
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  enabled: !busy,
                  decoration: const InputDecoration(
                    labelText: 'Nome para entrega',
                  ),
                  validator: (v) =>
                      v!.trim().length < 2 ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: email,
                  enabled: !busy,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (v) =>
                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v!.trim())
                      ? null
                      : 'Informe um e-mail válido',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: address,
                  enabled: !busy,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Endereço de entrega',
                    hintText: 'Rua, número, bairro, cidade e CEP',
                  ),
                  validator: (v) =>
                      v!.trim().length < 8 ? 'Informe o endereço' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Como prefere pagar? (simulação)',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final value in ['Pix', 'Cartão', 'Boleto'])
                ChoiceChip(
                  label: Text(value),
                  selected: payment == value,
                  onSelected: busy
                      ? null
                      : (_) => setState(() => payment = value),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Não informe dados de cartão. Todas as opções são fictícias.',
          ),
          const SizedBox(height: 24),
          Text(
            'Total: ${formatMoney(VoltTechStore.instance.cartTotal)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const Text('Frete: grátis nesta simulação'),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                error!,
                style: const TextStyle(color: Colors.orangeAccent),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : confirm,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  busy ? 'Confirmando…' : 'Confirmar pedido simulado',
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
