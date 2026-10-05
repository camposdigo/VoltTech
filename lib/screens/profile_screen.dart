import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../services/supabase_service.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool busy = false;
  Future<void> editName() async {
    final store = VoltTechStore.instance;
    final controller = TextEditingController(
      text: store.profile?['name'] ?? '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como podemos chamar você?'),
        content: TextField(
          controller: controller,
          maxLength: 80,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().length >= 2) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    // Dialog route finishes its dismissal animation before releasing the controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (result == null || !mounted) return;
    setState(() => busy = true);
    await runAction(context, () async {
      await store.service.client
          .from('profiles')
          .update({'name': result})
          .eq('id', store.service.user!.id);
      await store.loadUser();
    }, success: 'Nome atualizado');
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        if (!store.signedIn) {
          return EmptyState(
            title: 'Sua conta VoltTech',
            description: 'Salve favoritos, mantenha seu carrinho e acompanhe seus pedidos.',
            icon: Icons.person_outline,
            action: FilledButton(
              onPressed: () => requireLogin(context),
              child: const Text('Entrar ou criar conta'),
            ),
          );
        }
        return PageBody(
          maxWidth: 700,
          children: [
            const Icon(Icons.account_circle_outlined, size: 72),
            SectionTitle(
              store.profile?['name'] ?? 'Sua conta',
              SupabaseService.instance.user?.email ?? '',
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar meu nome'),
              trailing: const Icon(Icons.chevron_right),
              onTap: busy ? null : editName,
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Meus pedidos'),
              subtitle: Text('${store.orders.length} pedidos registrados'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openPage(context, const OrdersScreen()),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: busy ? null : () => runAction(context, store.signOut),
              icon: const Icon(Icons.logout),
              label: const Text('Sair da conta'),
            ),
          ],
        );
      },
    );
  }
}
