import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class SupabaseService {
  SupabaseService._();
  static final instance = SupabaseService._();
  bool enabled = false;
  String? initializationError;
  SupabaseClient get client {
    if (!enabled) {
      throw StateError('Configure a conexão antes de continuar.');
    }
    return Supabase.instance.client;
  }

  User? get user => enabled ? client.auth.currentUser : null;
  Future<void> initialize() async {
    const url = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: String.fromEnvironment('NEXT_PUBLIC_SUPABASE_URL'),
    );
    const key = String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
      defaultValue: String.fromEnvironment(
        'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY',
        defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
      ),
    );
    if (url.isEmpty || key.isEmpty) {
      initializationError = 'A conexão não foi configurada. Execute com dart run tool/run.dart run -d chrome.';
      return;
    }
    try {
      if (key.startsWith('sb_secret_')) throw const FormatException();
      if (key.split('.').length == 3) {
        final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(key.split('.')[1]))),
        );
        if (payload['role'] != 'anon') throw const FormatException();
      } else if (!key.startsWith('sb_publishable_')) {
        throw const FormatException();
      }
      await Supabase.initialize(url: url, publishableKey: key);
      enabled = true;
    } catch (_) {
      initializationError = 'Não foi possível iniciar a conexão. Confira a URL e a chave pública.';
    }
  }

  Future<List<Product>> products() async {
    final data = await client
        .from('products')
        .select(
          '*, categories!inner(name), product_specs(*), product_explanations(*), product_use_cases(*)',
        )
        .order('price', ascending: true);
    return data.map(Product.fromJson).toList();
  }
}

String friendlyError(Object error) {
  if (error is AuthException) {
    if (error.code == 'invalid_credentials') {
      return 'E-mail ou senha incorretos.';
    }
    if (error.code == 'email_not_confirmed') {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (error.code?.contains('rate_limit') == true) {
      return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
    }
    return 'Não foi possível acessar sua conta. Confira os dados e tente novamente.';
  }
  if (error is PostgrestException && error.code == 'P0001') {
    return error.message;
  }
  if (error is StateError) return error.message.toString();
  return 'Não foi possível concluir. Confira sua conexão e tente novamente.';
}
