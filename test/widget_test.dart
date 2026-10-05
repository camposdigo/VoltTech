import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volttech/controllers/volttech_store.dart';
import 'package:volttech/models/product.dart';
import 'package:volttech/screens/auth_screen.dart';
import 'package:volttech/screens/home_screen.dart';
import 'package:volttech/screens/product_details_screen.dart';
import 'package:volttech/screens/checkout_screen.dart';
import 'package:volttech/screens/recommendation_screen.dart';
import 'package:volttech/services/recommendation_service.dart';
import 'package:volttech/theme/app_theme.dart';
import 'package:volttech/widgets/product_card.dart';

List<Product> fixtures() =>
    (jsonDecode(File('test/fixtures/products.json').readAsStringSync()) as List)
        .map((j) => Product.fromJson(Map<String, dynamic>.from(j)))
        .toList();
void main() {
  final products = fixtures();
  test('Modelo lê relações, preço opcional e pesquisa sem acentos', () {
    expect(products.length, 15);
    expect(products.first.category, 'Celular');
    expect(products.first.useCases['Uso básico'], 5);
    expect(products.first.specs['Memória'], '4 GB');
    expect(products.firstWhere((p) => p.id == 'volt-endurance').onSale, false);
    expect(
      products.firstWhere((p) => p.id == 'volt-book-work').searchable,
      contains('programacao'),
    );
  });
  test('Recomendação respeita uso, categoria, estoque e orçamento', () {
    final result = RecommendationService.recommend(
      products,
      category: 'notebook',
      use: 'Faculdade',
      budget: const Budget('Até 3000', 0, 3000),
      priority: 'Portabilidade',
    );
    expect(result.map((r) => r.product.id), ['volt-book-study']);
    expect(result.first.reason, contains('faculdade'));
    final empty = RecommendationService.recommend(
      products,
      category: 'notebook',
      use: 'Jogos',
      budget: const Budget('Até 3000', 0, 3000),
      priority: 'Menor preço',
    );
    expect(empty, isEmpty);
  });
  test('Prioridade muda ranking sem indicar produto inadequado', () {
    final battery = RecommendationService.recommend(
      products,
      category: 'celular',
      use: 'Uso básico',
      budget: const Budget('Todos', 0, 5000),
      priority: 'Bateria',
    );
    final price = RecommendationService.recommend(
      products,
      category: 'celular',
      use: 'Uso básico',
      budget: const Budget('Todos', 0, 5000),
      priority: 'Menor preço',
    );
    expect(battery.first.product.id, 'volt-endurance');
    expect(price.first.product.id, 'volt-pocket');
  });
  test('Sem estoque não aparece na recomendação', () {
    final p = Product(
      id: 'none',
      name: 'Sem estoque',
      category: 'Celular',
      categoryId: 'celular',
      brand: 'VoltTech',
      price: 99,
      imageUrl: '',
      description: '',
      shortDescription: '',
      stock: 0,
      useCases: const {'Uso básico': 5},
    );
    expect(
      RecommendationService.recommend(
        [p],
        category: 'celular',
        use: 'Uso básico',
        budget: const Budget('Todos', 0, 5000),
        priority: 'Menor preço',
      ),
      isEmpty,
    );
  });
  test('Carrinho rejeita quantidades inválidas e calcula subtotal', () async {
    final store = VoltTechStore(initialProducts: products);
    addTearDown(store.dispose);
    final p = products.first;
    await store.addToCart(p);
    await store.addToCart(p);
    await store.loadUser();
    // A guest session refresh cannot discard the selected items.
    expect(store.cartCount, 2);
    expect(store.cartTotal, p.price * 2);
    await expectLater(store.setQuantity(p, 21), throwsStateError);
    await expectLater(store.setQuantity(p, -1), throwsStateError);
    await store.decrease(p);
    expect(store.cartCount, 1);
    await store.removeFromCart(p);
    expect(store.cart, isEmpty);
  });
  test('Comparação limita quantidade e mantém a categoria', () {
    final store = VoltTechStore(initialProducts: products);
    addTearDown(store.dispose);
    store.toggleComparison(products[0]);
    expect(() => store.toggleComparison(products[3]), throwsStateError);
    store.toggleComparison(products[1]);
    store.toggleComparison(products[2]);
    expect(store.comparedProducts.length, 3);
    store.toggleComparison(products[1]);
    expect(store.comparedProducts.length, 2);
  });
  for (final width in [320.0, 390.0, 768.0, 1440.0]) {
    testWidgets('Home, cards e detalhes sem overflow em $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Future<void> check(Widget widget) async {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.darkTheme, home: widget),
        );
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
      }

      await check(const Scaffold(body: LandingPage()));
      await check(
        Scaffold(
          body: SingleChildScrollView(
            child: ProductGrid(
              products: products.take(3).toList(),
              onSelect: (_) {},
            ),
          ),
        ),
      );
      await check(ProductDetailsScreen(product: products[3]));
      await check(const CheckoutScreen());
      await check(const AuthScreen());
    });
  }
  testWidgets('Texto ampliado mantém cards utilizáveis', (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: ProductGrid(
                products: products.take(1).toList(),
                onSelect: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
  testWidgets('Login e cadastro validam campos antes de chamar o backend', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.darkTheme, home: const AuthScreen()),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();
    expect(find.text('Informe um e-mail válido'), findsOneWidget);
    expect(find.text('Confira sua senha'), findsOneWidget);
    await tester.tap(find.text('Ainda não tenho conta'));
    await tester.pump();
    await tester.ensureVisible(find.text('Criar minha conta'));
    await tester.tap(find.text('Criar minha conta'));
    await tester.pump();
    expect(find.text('Informe seu nome'), findsOneWidget);
  });
  testWidgets('Assistente muda perguntas por categoria e mostra resultado', (
    tester,
  ) async {
    final store = VoltTechStore.instance;
    store.categories = [
      {'id': 'notebook', 'name': 'Notebook'},
      {'id': 'celular', 'name': 'Celular'},
    ];
    addTearDown(() => store.categories = []);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const RecommendationScreen(),
      ),
    );
    await tester.tap(find.text('Notebook'));
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    expect(find.text('Faculdade'), findsOneWidget);
    expect(find.text('Fotos'), findsNothing);
    await tester.tap(find.text('Faculdade'));
    await tester.pump();
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    await tester.tap(find.text('Até R\$ 3.000'));
    await tester.pump();
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    await tester.ensureVisible(find.text('Portabilidade'));
    await tester.tap(find.text('Portabilidade'));
    await tester.pump();
    await tester.ensureVisible(find.text('Ver minhas recomendações'));
    await tester.tap(find.text('Ver minhas recomendações'));
    await tester.pump();
    expect(find.text('Ainda não encontramos uma boa opção'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
