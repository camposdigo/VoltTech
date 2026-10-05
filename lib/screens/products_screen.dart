import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../models/product.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'comparison_screen.dart';

class CatalogPage extends StatelessWidget {
  final String initialCategory;
  final bool onlyOffers;
  const CatalogPage({
    super.key,
    this.initialCategory = 'Todos',
    this.onlyOffers = false,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Catálogo')),
    body: ProductsScreen(
      initialCategory: initialCategory,
      onlyOffers: onlyOffers,
    ),
  );
}

class ProductsScreen extends StatefulWidget {
  final String initialCategory;
  final bool onlyOffers;
  const ProductsScreen({
    super.key,
    this.initialCategory = 'Todos',
    this.onlyOffers = false,
  });
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late String category;
  late bool offers;
  final search = TextEditingController();
  String sort = 'Menor preço';
  double? maxPrice;
  @override
  void initState() {
    super.initState();
    category = widget.initialCategory;
    offers = widget.onlyOffers;
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final query = normalizeText(search.text.trim());
        final products = store.products
            .where(
              (p) =>
                  (category == 'Todos' || p.category == category) &&
                  (!offers || p.onSale) &&
                  (maxPrice == null || p.price <= maxPrice!) &&
                  query.split(' ').every(p.searchable.contains),
            )
            .toList();
        products.sort(
          (a, b) => sort == 'Maior preço'
              ? b.price.compareTo(a.price)
              : sort == 'Nome'
              ? a.name.compareTo(b.name)
              : a.price.compareTo(b.price),
        );
        return PageBody(
          children: [
            const SectionTitle(
              'Encontre sua próxima escolha',
              'Busque pelo produto ou pelo que você precisa fazer.',
            ),
            TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Faculdade, bateria, notebook…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        onPressed: () {
                          search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in [
                  'Todos',
                  ...store.categories.map((c) => c['name'] as String),
                ])
                  ChoiceChip(
                    label: Text(name),
                    selected: category == name,
                    onSelected: (_) => setState(() => category = name),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Em oferta'),
                  selected: offers,
                  onSelected: (v) => setState(() => offers = v),
                ),
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    initialValue: sort,
                    decoration: const InputDecoration(labelText: 'Ordenar por'),
                    items: [
                      for (final s in ['Menor preço', 'Maior preço', 'Nome'])
                        DropdownMenuItem(value: s, child: Text(s)),
                    ],
                    onChanged: (v) => setState(() => sort = v!),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<double>(
                    initialValue: maxPrice ?? 0,
                    decoration: const InputDecoration(
                      labelText: 'Quanto quer gastar?',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Qualquer valor')),
                      DropdownMenuItem(value: 500, child: Text('Até R\$ 500')),
                      DropdownMenuItem(
                        value: 2000,
                        child: Text('Até R\$ 2.000'),
                      ),
                      DropdownMenuItem(
                        value: 4000,
                        child: Text('Até R\$ 4.000'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => maxPrice = v == 0 ? null : v),
                  ),
                ),
                if (store.comparison.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () =>
                        openPage(context, const ComparisonScreen()),
                    icon: const Icon(Icons.compare_arrows),
                    label: Text('Comparar (${store.comparison.length})'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('${products.length} produtos encontrados'),
            const SizedBox(height: 16),
            if (products.isEmpty)
              EmptyState(
                title: 'Nenhuma opção com esses filtros',
                description: 'Tente outra necessidade ou aumente o orçamento.',
                action: TextButton(
                  onPressed: () => setState(() {
                    search.clear();
                    category = 'Todos';
                    offers = false;
                    maxPrice = null;
                  }),
                  child: const Text('Limpar filtros'),
                ),
              )
            else
              ProductGrid(
                products: products,
                onSelect: (p) =>
                    openPage(context, ProductDetailsScreen(product: p)),
              ),
          ],
        );
      },
    );
  }
}
