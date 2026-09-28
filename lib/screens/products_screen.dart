import 'package:flutter/material.dart';
import '../data/mock_products.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String initialCategory;
  const ProductsScreen({super.key, this.initialCategory = 'Todos'});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late String selectedCategory;
  String query = '';

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

  List<Product> get filteredProducts {
    final normalized = query.trim().toLowerCase();
    return mockProducts.where((product) {
      final categoryMatch = selectedCategory == 'Todos' || product.category == selectedCategory;
      final searchMatch = normalized.isEmpty ||
          product.name.toLowerCase().contains(normalized) ||
          product.category.toLowerCase().contains(normalized);
      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = filteredProducts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'Buscar produtos...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? const Icon(Icons.tune_rounded)
                : IconButton(onPressed: () => setState(() => query = ''), icon: const Icon(Icons.close)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: mockCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final category = mockCategories[index];
              return ChoiceChip(
                selected: selectedCategory == category,
                label: Text(category),
                selectedColor: AppTheme.primary,
                onSelected: (_) => setState(() => selectedCategory = category),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Catálogo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text(products.length.toString() + ' produtos', style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 14),
        if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: Center(child: Text('Nenhum produto encontrado.')),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .60,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
                ),
              );
            },
          ),
      ],
    );
  }
}
