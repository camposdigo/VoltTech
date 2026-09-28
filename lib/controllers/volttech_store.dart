import 'package:flutter/foundation.dart';
import '../data/mock_products.dart';
import '../models/product.dart';

class VoltTechStore extends ChangeNotifier {
  VoltTechStore._();
  static final VoltTechStore instance = VoltTechStore._();

  final Set<String> _favorites = <String>{};
  final Map<String, int> _cart = <String, int>{};

  List<Product> get products => mockProducts;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  Map<String, int> get cart => Map.unmodifiable(_cart);

  List<Product> get favoriteProducts => products.where((product) => _favorites.contains(product.id)).toList();

  int get cartCount => _cart.values.fold(0, (sum, quantity) => sum + quantity);

  double get cartTotal => _cart.entries.fold(0, (sum, entry) {
        final product = products.firstWhere((item) => item.id == entry.key);
        return sum + (product.price * entry.value);
      });

  bool isFavorite(Product product) => _favorites.contains(product.id);
  int quantityOf(Product product) => _cart[product.id] ?? 0;

  void toggleFavorite(Product product) {
    if (!_favorites.add(product.id)) {
      _favorites.remove(product.id);
    }
    notifyListeners();
  }

  void addToCart(Product product) {
    _cart.update(product.id, (value) => value + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void decrease(Product product) {
    final quantity = _cart[product.id] ?? 0;
    if (quantity <= 1) {
      _cart.remove(product.id);
    } else {
      _cart[product.id] = quantity - 1;
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.remove(product.id);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
