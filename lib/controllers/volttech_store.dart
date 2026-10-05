import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/supabase_service.dart';

class VoltTechStore extends ChangeNotifier {
  VoltTechStore({List<Product> initialProducts = const []})
    : _products = List.of(initialProducts);
  static final instance = VoltTechStore();
  final service = SupabaseService.instance;
  List<Product> _products;
  List<Map<String, dynamic>> categories = [];
  final Set<String> _favorites = {};
  final Map<String, int> _cart = {};
  final Set<String> comparison = {};
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> orders = [];
  bool loading = false, busy = false;
  String? error;
  StreamSubscription? _authSubscription;
  int _generation = 0;
  String? _userId;
  Future<void>? _userLoad;
  String? _loadingUserId;
  List<Product> get products => List.unmodifiable(_products);
  Map<String, int> get cart => Map.unmodifiable(_cart);
  bool get signedIn => service.user != null;
  List<Product> get favoriteProducts =>
      products.where((p) => _favorites.contains(p.id)).toList();
  List<Product> get comparedProducts =>
      products.where((p) => comparison.contains(p.id)).toList();
  int get cartCount => _cart.values.fold(0, (a, b) => a + b);
  double get cartTotal =>
      products.fold(0, (sum, p) => sum + p.price * quantityOf(p));
  int quantityOf(Product p) => _cart[p.id] ?? 0;
  bool isFavorite(Product p) => _favorites.contains(p.id);
  Future<void> initialize() async {
    if (!service.enabled) {
      error = service.initializationError;
      notifyListeners();
      return;
    }
    await loadCatalog();
    await loadUser();
    _authSubscription ??= service.client.auth.onAuthStateChange.listen((event) {
      if (event.session?.user.id != _userId) unawaited(loadUser());
    });
  }

  Future<void> loadCatalog() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await service.products();
      final cats = await service.client
          .from('categories')
          .select()
          .order('name', ascending: true);
      _products = data;
      categories = List<Map<String, dynamic>>.from(cats);
    } catch (e) {
      error = friendlyError(e);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadUser() {
    final uid = service.user?.id;
    if (_userLoad != null && _loadingUserId == uid) return _userLoad!;
    _loadingUserId = uid;
    final future = _loadUser();
    _userLoad = future;
    return future.whenComplete(() {
      if (identical(_userLoad, future)) _userLoad = null;
    });
  }

  Future<void> _loadUser() async {
    final generation = ++_generation;
    final previous = _userId;
    final uid = service.user?.id;
    _userId = uid;
    // Retrying a catalog load must preserve a visitor's cart.
    if (uid == null && previous == null) return;
    final guestCart = previous == null
        ? Map<String, int>.from(_cart)
        : <String, int>{};
    _favorites.clear();
    _cart.clear();
    orders = [];
    profile = null;
    notifyListeners();
    if (uid == null) return;
    try {
      final db = service.client;
      final savedCart = await db.from('cart_items').select().eq('user_id', uid);
      final merged = <String, int>{
        for (final c in savedCart)
          c['product_id'] as String: c['quantity'] as int,
      };
      for (final p in products) {
        if (guestCart.containsKey(p.id) && p.stock > 0) {
          final qty = ((merged[p.id] ?? 0) + guestCart[p.id]!).clamp(
            1,
            p.stock.clamp(1, 99),
          );
          await db.from('cart_items').upsert({
            'user_id': uid,
            'product_id': p.id,
            'quantity': qty,
          }, onConflict: 'user_id,product_id');
          merged[p.id] = qty;
        }
      }
      final fav = await db
          .from('favorites')
          .select('product_id')
          .eq('user_id', uid);
      final userProfile = await db
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      final userOrders = await db
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      if (generation != _generation) return;
      _cart.addAll(merged);
      _favorites.addAll(fav.map((f) => f['product_id'] as String));
      profile = userProfile;
      orders = List<Map<String, dynamic>>.from(userOrders);
      error = null;
    } catch (e) {
      if (generation == _generation) error = friendlyError(e);
    }
    if (generation == _generation) notifyListeners();
  }

  Future<void> refreshOrders() async {
    final uid = service.user?.id;
    if (uid == null) return;
    final data = await service.client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    if (service.user?.id != uid) return;
    orders = List<Map<String, dynamic>>.from(data);
    notifyListeners();
  }

  Future<void> toggleFavorite(Product p) async {
    final uid = service.user?.id;
    if (uid == null) throw StateError('Entre para salvar seus favoritos.');
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      if (isFavorite(p)) {
        await service.client
            .from('favorites')
            .delete()
            .eq('user_id', uid)
            .eq('product_id', p.id);
        if (service.user?.id == uid) _favorites.remove(p.id);
      } else {
        await service.client.from('favorites').upsert({
          'user_id': uid,
          'product_id': p.id,
        }, onConflict: 'user_id,product_id');
        if (service.user?.id == uid) _favorites.add(p.id);
      }
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> setQuantity(Product p, int quantity) async {
    if (busy) return;
    if (quantity < 0 || quantity > p.stock || quantity > 99) {
      throw StateError('Quantidade indisponível em estoque.');
    }
    final uid = service.user?.id;
    busy = true;
    notifyListeners();
    try {
      if (uid != null) {
        if (quantity == 0) {
          await service.client
              .from('cart_items')
              .delete()
              .eq('user_id', uid)
              .eq('product_id', p.id);
        } else {
          await service.client.from('cart_items').upsert({
            'user_id': uid,
            'product_id': p.id,
            'quantity': quantity,
          }, onConflict: 'user_id,product_id');
        }
      }
      if (service.user?.id == uid) {
        if (quantity == 0) {
          _cart.remove(p.id);
        } else {
          _cart[p.id] = quantity;
        }
      }
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product p) => setQuantity(p, quantityOf(p) + 1);
  Future<void> decrease(Product p) =>
      setQuantity(p, (quantityOf(p) - 1).clamp(0, 99));
  Future<void> removeFromCart(Product p) => setQuantity(p, 0);
  Future<void> removeUnavailableItem(String productId) async {
    if (busy) return;
    final uid = service.user?.id;
    busy = true;
    notifyListeners();
    try {
      if (uid != null) {
        await service.client
            .from('cart_items')
            .delete()
            .eq('user_id', uid)
            .eq('product_id', productId);
      }
      if (service.user?.id == uid) _cart.remove(productId);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void toggleComparison(Product p) {
    if (comparison.contains(p.id)) {
      comparison.remove(p.id);
    } else {
      if (comparison.length >= 3) {
        throw StateError('Compare até 3 produtos por vez.');
      }
      if (comparedProducts.any((item) => item.categoryId != p.categoryId)) {
        throw StateError('Escolha produtos da mesma categoria para comparar.');
      }
      comparison.add(p.id);
    }
    notifyListeners();
  }

  Future<String> checkout({
    required String requestId,
    required String name,
    required String email,
    required String address,
    required String payment,
  }) async {
    if (!signedIn) throw StateError('Entre na sua conta para confirmar.');
    final id = await service.client.rpc(
      'checkout',
      params: {
        'p_request_id': requestId,
        'p_name': name,
        'p_email': email,
        'p_address': address,
        'p_payment': payment,
      },
    ) as String;
    _cart.clear();
    notifyListeners();
    await loadCatalog();
    try {
      await refreshOrders();
    } catch (e) {
      error = friendlyError(e);
      notifyListeners();
    }
    return id;
  }

  Future<void> signOut() async {
    await service.client.auth.signOut();
    await loadUser();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
