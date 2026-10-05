import '../models/product.dart';

const categoryUses = <String, List<String>>{
  'notebook': [
    'Faculdade',
    'Trabalho',
    'Programação',
    'Jogos',
    'Edição de vídeo/foto',
    'Uso básico',
  ],
  'celular': [
    'Fotos',
    'Redes sociais',
    'Trabalho',
    'Jogos',
    'Bateria longa',
    'Uso básico',
  ],
  'fone': [
    'Transporte',
    'Academia',
    'Trabalho/reuniões',
    'Música',
    'Jogos',
    'Uso cotidiano',
  ],
  'tablet': ['Estudos', 'Leitura', 'Vídeos', 'Desenho', 'Trabalho', 'Jogos'],
  'acessorios': ['Trabalho', 'Viagens', 'Carregamento', 'Organização'],
};
List<String> prioritiesFor(String category) => [
  'Menor preço',
  'Desempenho',
  if (category != 'acessorios') 'Bateria',
  if (category == 'celular') 'Câmera',
  if (['celular', 'notebook', 'tablet'].contains(category)) 'Tela',
  'Durabilidade',
  'Portabilidade',
];

class Budget {
  final String label;
  final double min, max;
  const Budget(this.label, this.min, this.max);
}

List<Budget> budgetsFor(String category) => switch (category) {
  'notebook' => const [
    Budget('Até R\$ 3.000', 0, 3000),
    Budget('De R\$ 3.000 a R\$ 5.000', 3000, 5000),
    Budget('De R\$ 5.000 a R\$ 8.000', 5000, 8000),
  ],
  'celular' || 'tablet' => const [
    Budget('Até R\$ 1.500', 0, 1500),
    Budget('De R\$ 1.500 a R\$ 2.500', 1500, 2500),
    Budget('De R\$ 2.500 a R\$ 5.000', 2500, 5000),
  ],
  _ => const [
    Budget('Até R\$ 200', 0, 200),
    Budget('De R\$ 200 a R\$ 500', 200, 500),
    Budget('De R\$ 500 a R\$ 1.500', 500, 1500),
  ],
};
String scoreLabel(int? score) => switch (score) {
  5 => 'Excelente',
  4 => 'Muito bom',
  3 => 'Bom',
  2 => 'Básico',
  1 => 'Pouco indicado',
  _ => 'Não informado',
};

class Recommendation {
  final Product product;
  final double score;
  final String reason;
  const Recommendation(this.product, this.score, this.reason);
}

class RecommendationService {
  static List<Recommendation> recommend(
    List<Product> products, {
    required String category,
    required String use,
    required Budget budget,
    required String priority,
  }) {
    final candidates = products.where(
      (p) =>
          p.categoryId == category &&
          p.stock > 0 &&
          p.price >= budget.min &&
          p.price <= budget.max &&
          (p.useCases[use] ?? 0) >= 3,
    );
    final result = candidates.map((p) {
      final useScore = p.useCases[use]!;
      final priorityScore = priority == 'Menor preço'
          ? 5 * (1 - p.price / budget.max)
          : (p.useCases[priority] ?? 0).toDouble();
      final reason =
          '${scoreLabel(useScore)} para ${use.toLowerCase()} e dentro da faixa que você escolheu. ${priority == 'Menor preço'
              ? 'Priorizamos o preço entre as opções que atendem ao seu uso.'
              : p.useCases.containsKey(priority)
              ? '$priority: ${scoreLabel(p.useCases[priority]).toLowerCase()}.'
              : 'Não temos uma nota de ${priority.toLowerCase()} para este produto.'} ${p.explanation('why_buy')}';
      return Recommendation(p, useScore * 0.7 + priorityScore * 0.3, reason);
    }).toList();
    result.sort((a, b) {
      final score = b.score.compareTo(a.score);
      return score != 0 ? score : a.product.price.compareTo(b.product.price);
    });
    return result.take(3).toList();
  }
}
