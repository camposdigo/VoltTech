import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../services/recommendation_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import 'product_details_screen.dart';
import 'comparison_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});
  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int step = 0;
  String? category, use, priority;
  Budget? budget;
  bool saving = false;
  Future<void> next() async {
    if (step < 3) {
      setState(() => step++);
      return;
    }
    setState(() {
      step = 4;
      saving = true;
    });
    final service = SupabaseService.instance;
    if (service.user != null) {
      try {
        await service.client.from('recommendation_sessions').insert({
          'user_id': service.user!.id,
          'category': category,
          'use_case': use,
          'budget_min': budget!.min,
          'budget_max': budget!.max,
          'priority': priority,
        });
      } catch (_) {
        if (mounted) {
          message(
            context,
            'As recomendações estão prontas, mas não foi possível salvar suas preferências.',
          );
        }
      }
    }
    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    final ready = switch (step) {
      0 => category != null,
      1 => use != null,
      2 => budget != null,
      3 => priority != null,
      _ => false,
    };
    final titles = [
      'O que você está procurando?',
      'Como você vai usar?',
      'Quanto pretende gastar?',
      'O que é mais importante para você?',
      'Escolhas que combinam com você',
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Assistente de compra')),
      body: PageBody(
        maxWidth: 900,
        children: [
          Text(
            'PASSO ${step + 1} DE 5',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: (step + 1) / 5, minHeight: 4),
          SectionTitle(
            titles[step],
            step == 4 ? 'Entenda o motivo de cada indicação. A decisão é sua.' : 'Sem termos complicados. Escolha a opção que mais se parece com você.',
          ),
          if (step == 0)
            choices(
              [
                for (final c in store.categories)
                  (c['id'] as String, c['name'] as String),
              ],
              category,
              (v) => setState(() {
                category = v;
                use = null;
                budget = null;
                priority = null;
              }),
            ),
          if (step == 1)
            choices(
              [for (final v in categoryUses[category] ?? []) (v, v)],
              use,
              (v) => setState(() => use = v),
            ),
          if (step == 2)
            choices(
              [for (final b in budgetsFor(category!)) (b.label, b.label)],
              budget?.label,
              (v) => setState(
                () =>
                    budget = budgetsFor(category!)
                        .firstWhere((b) => b.label == v),
              ),
            ),
          if (step == 3)
            choices(
              [for (final v in prioritiesFor(category!)) (v, v)],
              priority,
              (v) => setState(() => priority = v),
            ),
          if (step < 4) ...[
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                if (step > 0)
                  OutlinedButton(
                    onPressed: () => setState(() => step--),
                    child: const Text('Voltar'),
                  ),
                FilledButton(
                  onPressed: ready ? next : null,
                  child: Text(
                    step == 3 ? 'Ver minhas recomendações' : 'Continuar',
                  ),
                ),
              ],
            ),
          ],
          if (step == 4) ...[
            Text(
              '${use!} · ${budget!.label} · ${priority!}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ...results(context),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => step = 2),
                  child: const Text('Ajustar orçamento'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    step = 0;
                    category = null;
                    use = null;
                    budget = null;
                    priority = null;
                  }),
                  child: const Text('Começar de novo'),
                ),
                OutlinedButton.icon(
                  onPressed: () => openPage(context, const ComparisonScreen()),
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Ver comparação'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget choices(
    List<(String, String)> items,
    String? selected,
    void Function(String) onSelect,
  ) => Column(
    children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: selected == item.$1
                  ? AppTheme.primary.withValues(alpha: .14)
                  : AppTheme.surface,
              side: BorderSide(
                color: selected == item.$1 ? AppTheme.primary : AppTheme.border,
              ),
              padding: const EdgeInsets.all(22),
            ),
            onPressed: () => onSelect(item.$1),
            child: Row(
              children: [
                Expanded(
                  child: Text(item.$2, style: const TextStyle(fontSize: 18)),
                ),
                Icon(
                  selected == item.$1
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                ),
              ],
            ),
          ),
        ),
    ],
  );
  List<Widget> results(BuildContext context) {
    final recommendations = RecommendationService.recommend(
      VoltTechStore.instance.products,
      category: category!,
      use: use!,
      budget: budget!,
      priority: priority!,
    );
    if (recommendations.isEmpty) {
      return [
        const EmptyState(
          title: 'Ainda não encontramos uma boa opção',
          description: 'Não vamos indicar algo que não atende ao seu uso ou passa do seu orçamento. Ajuste a faixa ou tente outra necessidade.',
        ),
      ];
    }
    return [
      for (final r in recommendations)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatMoney(r.product.price),
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Por que recomendamos para você?',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(r.reason, style: const TextStyle(height: 1.6)),
                  const SizedBox(height: 12),
                  Text(
                    'Vale saber: ${r.product.points('attention_points').join('. ')}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => openPage(
                          context,
                          ProductDetailsScreen(product: r.product),
                        ),
                        child: const Text('Conhecer produto'),
                      ),
                      TextButton(
                        onPressed: () => runAction(context, () async {
                          VoltTechStore.instance.toggleComparison(r.product);
                        }, success: 'Comparação atualizada'),
                        child: const Text('Selecionar para comparar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }
}
