import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../services/recommendation_service.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import 'product_details_screen.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Compare sem complicação')),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final products = store.comparedProducts;
          if (products.length < 2) {
            return const EmptyState(
              title: 'Escolha pelo menos dois produtos',
              description: 'No catálogo, toque em Comparar em até três produtos da mesma categoria.',
              icon: Icons.compare_arrows,
            );
          }
          final uses = categoryUses[products.first.categoryId] ?? [];
          final labels = [
            ...uses,
            'Bateria',
            'Desempenho',
            'Durabilidade',
            'Portabilidade',
          ];
          return PageBody(
            children: [
              const SectionTitle(
                'O que muda na sua rotina?',
                'Arraste a tabela para o lado para ver todas as opções.',
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Seu uso')),
                    for (final p in products)
                      DataColumn(
                        label: SizedBox(width: 180, child: Text(p.name)),
                      ),
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        const DataCell(Text('Preço')),
                        for (final p in products)
                          DataCell(Text(formatMoney(p.price))),
                      ],
                    ),
                    for (final label in labels)
                      DataRow(
                        cells: [
                          DataCell(Text(label)),
                          for (final p in products)
                            DataCell(Text(scoreLabel(p.useCases[label]))),
                        ],
                      ),
                    DataRow(
                      cells: [
                        const DataCell(Text('Conheça melhor')),
                        for (final p in products)
                          DataCell(
                            TextButton(
                              onPressed: () => openPage(
                                context,
                                ProductDetailsScreen(product: p),
                              ),
                              child: const Text('Ver produto'),
                            ),
                          ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        const DataCell(Text('Seleção')),
                        for (final p in products)
                          DataCell(
                            TextButton(
                              onPressed: () => store.toggleComparison(p),
                              child: const Text('Remover'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'As notas representam a adequação ao uso no catálogo de demonstração; não são testes de laboratório.',
              ),
              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text('Ver comparação técnica'),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        const DataColumn(label: Text('Especificação')),
                        for (final p in products)
                          DataColumn(
                            label: SizedBox(width: 180, child: Text(p.name)),
                          ),
                      ],
                      rows: [
                        for (final label
                            in products.expand((p) => p.specs.keys).toSet())
                          DataRow(
                            cells: [
                              DataCell(Text(label)),
                              for (final p in products)
                                DataCell(
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      p.specs[label] ?? 'Não informado',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
