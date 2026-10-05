import 'package:flutter/material.dart';

class Product {
  final String id,
      name,
      category,
      categoryId,
      brand,
      imageUrl,
      description,
      shortDescription;
  final double price;
  final double? oldPrice;
  final int stock;
  final Map<String, String> specs;
  final Map<String, int> useCases;
  final Map<String, dynamic> explanations;
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryId,
    required this.brand,
    required this.price,
    this.oldPrice,
    required this.imageUrl,
    required this.description,
    required this.shortDescription,
    required this.stock,
    this.specs = const {},
    this.useCases = const {},
    this.explanations = const {},
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    final raw = json['product_explanations'];
    final explanations = raw is List
        ? (raw.isEmpty
              ? <String, dynamic>{}
              : Map<String, dynamic>.from(raw.first))
        : Map<String, dynamic>.from(raw ?? {});
    final specs = List<Map<String, dynamic>>.from(json['product_specs'] ?? []);
    specs.sort(
      (a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int),
    );
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['categories']['name'],
      categoryId: json['category_id'],
      brand: json['brand'],
      price: (json['price'] as num).toDouble(),
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      imageUrl: json['image_url'],
      description: json['description'],
      shortDescription: json['short_description'],
      stock: json['stock'],
      specs: {
        for (final s in specs) s['label'] as String: s['value'] as String,
      },
      useCases: {
        for (final u in json['product_use_cases'] ?? [])
          u['use_case'] as String: u['score'] as int,
      },
      explanations: explanations,
    );
  }
  bool get onSale => oldPrice != null && oldPrice! > price;
  String explanation(String key) =>
      explanations[key]?.toString() ?? 'Informação ainda não disponível.';
  List<String> points(String key) => List<String>.from(explanations[key] ?? []);
  IconData get icon => categoryIcon(categoryId);
  String get searchable => normalizeText(
    [
      name,
      brand,
      category,
      shortDescription,
      ...points('good_for'),
      ...useCases.keys,
    ].join(' '),
  );
}

IconData categoryIcon(String id) => switch (id) {
  'celular' => Icons.smartphone_rounded,
  'notebook' => Icons.laptop_mac_rounded,
  'fone' => Icons.headphones_rounded,
  'tablet' => Icons.tablet_mac_rounded,
  _ => Icons.cable_rounded,
};
String normalizeText(String text) {
  var value = text.toLowerCase();
  const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const to = 'aaaaaeeeeiiiiooooouuuuc';
  for (var i = 0; i < from.length; i++) {
    value = value.replaceAll(from[i], to[i]);
  }
  return value;
}
