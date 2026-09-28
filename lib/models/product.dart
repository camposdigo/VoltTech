import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double oldPrice;
  final int discount;
  final IconData icon;
  final String imageUrl;
  final String description;
  final double rating;
  final int reviews;
  final int stock;
  final String badge;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.icon,
    required this.imageUrl,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.stock,
    required this.badge,
  });
}
