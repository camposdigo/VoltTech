import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final online = SupabaseService.instance.enabled;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        const CircleAvatar(
          radius: 46,
          backgroundColor: AppTheme.primary,
          child: Icon(Icons.person_rounded, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 14),
        const Center(child: Text('Cliente VoltTech', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
        const Center(child: Text('cliente@volttech.com', style: TextStyle(color: AppTheme.textSecondary))),
        const SizedBox(height: 28),
        _ProfileTile(icon: Icons.receipt_long_outlined, title: 'Meus pedidos', subtitle: 'Histórico demonstrativo do protótipo'),
        _ProfileTile(icon: Icons.location_on_outlined, title: 'Endereços', subtitle: 'Av. Paulista, 1000 - São Paulo/SP'),
        _ProfileTile(icon: Icons.credit_card_outlined, title: 'Pagamento', subtitle: 'Cartão demonstrativo final 4242'),
        _ProfileTile(
          icon: online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
          title: 'Supabase',
          subtitle: online ? 'Conectado ao banco de dados' : 'Modo mock ativo — configure as chaves para sincronizar',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
          child: const Text(
            'Checkpoint 5 • Protótipo funcional\nDados de catálogo são simulados para garantir uma demonstração estável.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
