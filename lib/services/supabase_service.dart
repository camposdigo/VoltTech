import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/volttech_store.dart';
import '../models/product.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  bool _enabled = false;
  bool get enabled => _enabled;

  Future<void> initialize() async {
    if (_url.isEmpty || _anonKey.isEmpty) return;
    try {
      await Supabase.initialize(url: _url, anonKey: _anonKey);
      _enabled = true;
    } catch (_) {
      _enabled = false;
    }
  }

  SupabaseClient? get _client => _enabled ? Supabase.instance.client : null;

  Future<void> syncFavorite(Product product, bool favorite) async {
    final client = _client;
    if (client == null) return;
    try {
      if (favorite) {
        await client.from('favorites').upsert({
          'product_id': product.id,
          'product_name': product.name,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await client.from('favorites').delete().eq('product_id', product.id);
      }
    } catch (_) {}
  }

  Future<void> saveOrder({
    required String customerName,
    required String email,
    required String address,
  }) async {
    final client = _client;
    if (client == null) return;

    final store = VoltTechStore.instance;
    try {
      final order = await client.from('orders').insert({
        'customer_name': customerName,
        'email': email,
        'address': address,
        'total': store.cartTotal,
        'status': 'Confirmado',
      }).select('id').single();

      final orderId = order['id'];
      final items = store.cart.entries.map((entry) {
        final product = store.products.firstWhere((item) => item.id == entry.key);
        return {
          'order_id': orderId,
          'product_id': product.id,
          'product_name': product.name,
          'quantity': entry.value,
          'unit_price': product.price,
        };
      }).toList();

      if (items.isNotEmpty) {
        await client.from('order_items').insert(items);
      }
    } catch (_) {}
  }
}
