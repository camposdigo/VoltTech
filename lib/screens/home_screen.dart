import 'package:flutter/material.dart';
import '../controllers/volttech_store.dart';
import '../data/mock_products.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'product_details_screen.dart';
import 'products_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final pages = <Widget>[
          const _LandingPage(),
          const ProductsScreen(),
          const FavoritesScreen(),
          const ProfileScreen(),
        ];

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: _TopBar(
              desktop: desktop,
              selectedIndex: currentIndex,
              onSelect: (index) => setState(() => currentIndex = index),
              store: store,
            ),
          ),
          body: IndexedStack(index: currentIndex, children: pages),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) => setState(() => currentIndex = index),
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Início'),
                    NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Produtos'),
                    NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
                    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
                  ],
                ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool desktop;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoltTechStore store;

  const _TopBar({
    required this.desktop,
    required this.selectedIndex,
    required this.onSelect,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Color(0xFF090101),
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => onSelect(0),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          _LogoMark(),
                          SizedBox(width: 8),
                          Text(
                            'Volt',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Tech',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (desktop) ...[
                    _NavText(label: 'Produtos', onTap: () => onSelect(1)),
                    _NavText(label: 'Ofertas', onTap: () => onSelect(0)),
                    _NavText(label: 'Categorias', onTap: () => onSelect(0)),
                    _NavText(label: 'Sobre', onTap: () => onSelect(0)),
                    _NavText(label: 'Contato', onTap: () => onSelect(0)),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 150,
                      height: 38,
                      child: TextField(
                        readOnly: true,
                        onTap: () => onSelect(1),
                        decoration: const InputDecoration(
                          hintText: 'Buscar...',
                          prefixIcon: Icon(Icons.search, size: 18),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  AnimatedBuilder(
                    animation: store,
                    builder: (context, _) => Badge(
                      label: Text(store.cartCount.toString()),
                      isLabelVisible: store.cartCount > 0,
                      child: IconButton(
                        tooltip: 'Carrinho',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavText({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
    );
  }
}

class _LandingPage extends StatelessWidget {
  const _LandingPage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        return SingleChildScrollView(
          child: Column(
            children: [
              _Hero(desktop: desktop),
              _CategoriesSection(desktop: desktop),
              _ProductsSection(desktop: desktop),
              _DealsSection(desktop: desktop),
              const _ShippingCta(),
              _TestimonialsSection(desktop: desktop),
              _Footer(desktop: desktop),
            ],
          ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  final bool desktop;
  const _Hero({required this.desktop});

  @override
  Widget build(BuildContext context) {
    final heroProduct = mockProducts[1];

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow('LANÇAMENTO 2026'),
        const SizedBox(height: 22),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: desktop ? 54 : 42,
              height: 1.02,
              fontWeight: FontWeight.w400,
              color: AppTheme.textPrimary,
            ),
            children: const [
              TextSpan(text: 'Tecnologia\n'),
              TextSpan(text: 'do futuro,\n', style: TextStyle(color: AppTheme.primary)),
              TextSpan(text: 'hoje.', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SizedBox(
          width: 430,
          child: Text(
            'Os melhores eletrônicos do mundo com entrega em até 24h, garantia estendida e preços imbatíveis. Experiência de compra redefinida.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _CatalogPage()),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text('Explorar Produtos  →'),
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Text('Ver Ofertas'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Stat('50k+', 'Clientes'),
            SizedBox(width: 30),
            _Stat('4,9★', 'Avaliação'),
            SizedBox(width: 30),
            _Stat('24h', 'Entrega'),
          ],
        ),
      ],
    );

    final visual = InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: heroProduct)),
      ),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: .12),
              blurRadius: 50,
              spreadRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  heroProduct.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.laptop_mac_rounded, size: 120),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC0A0101)],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(heroProduct.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text(
                              'A partir de ' + formatMoney(heroProduct.price),
                              style: const TextStyle(color: AppTheme.primary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: heroProduct)),
                        ),
                        child: const Text('Comprar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: desktop ? 690 : 0),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(.5, -.2),
          radius: 1.15,
          colors: [Color(0xFF240303), AppTheme.background],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, desktop ? 80 : 44, 20, 72),
            child: desktop
                ? Row(
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: 56),
                      Expanded(child: visual),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      copy,
                      const SizedBox(height: 42),
                      visual,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final bool desktop;
  const _CategoriesSection({required this.desktop});

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('Smartphones', '148 produtos', Icons.smartphone_rounded, 'Smartphone'),
      ('Laptops', '92 produtos', Icons.laptop_mac_rounded, 'Laptop'),
      ('Áudio', '76 produtos', Icons.headphones_rounded, 'Áudio'),
      ('Câmeras', '54 produtos', Icons.photo_camera_rounded, 'Câmeras'),
      ('Smartwatches', '38 produtos', Icons.watch_rounded, 'Smartwatches'),
      ('Acessórios', '210 produtos', Icons.cable_rounded, 'Acessórios'),
    ];

    return _SectionShell(
      background: AppTheme.surface,
      child: Column(
        children: [
          const _Eyebrow('NAVEGUE POR CATEGORIA'),
          const SizedBox(height: 14),
          const Text(
            'Encontre o que procura',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 30),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = desktop ? 6 : (constraints.maxWidth > 620 ? 3 : 2);
              return GridView.builder(
                itemCount: categories.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  childAspectRatio: desktop ? 1.45 : 1.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final item = categories[i];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _CatalogPage(initialCategory: item.$4),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0202),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.$3, color: AppTheme.textPrimary, size: 30),
                          const SizedBox(height: 10),
                          Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(item.$2, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductsSection extends StatelessWidget {
  final bool desktop;
  const _ProductsSection({required this.desktop});

  @override
  Widget build(BuildContext context) {
    final products = mockProducts.take(6).toList();

    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('CATÁLOGO'),
          const SizedBox(height: 12),
          const Text('Produtos em Destaque', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 26),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = desktop ? 3 : (constraints.maxWidth > 650 ? 2 : 1);
              return GridView.builder(
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  childAspectRatio: desktop ? .82 : .78,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (_, i) => ProductCard(
                  product: products[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: products[i])),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.center,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _CatalogPage()),
              ),
              child: const Text('Ver todos os produtos →'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DealsSection extends StatelessWidget {
  final bool desktop;
  const _DealsSection({required this.desktop});

  @override
  Widget build(BuildContext context) {
    final deals = mockProducts.skip(6).take(2).toList();

    return _SectionShell(
      background: AppTheme.surface,
      child: Column(
        children: [
          const _Eyebrow('TEMPO LIMITADO'),
          const SizedBox(height: 14),
          const Text('Ofertas do Dia', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 28),
          if (desktop)
            Row(
              children: [
                Expanded(child: _DealCard(product: deals[0], label: 'SMARTPHONE DO DIA')),
                const SizedBox(width: 16),
                Expanded(child: _DealCard(product: deals[1], label: 'LAPTOP EM OFERTA')),
              ],
            )
          else
            Column(
              children: [
                _DealCard(product: deals[0], label: 'SMARTPHONE DO DIA'),
                const SizedBox(height: 16),
                _DealCard(product: deals[1], label: 'LAPTOP EM OFERTA'),
              ],
            ),
        ],
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final Product product;
  final String label;
  const _DealCard({required this.product, required this.label});

  @override
  Widget build(BuildContext context) {
    final store = VoltTechStore.instance;
    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0202),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            height: 210,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
              child: Image.network(
                product.imageUrl,
                width: 170,
                height: 210,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.surface,
                  alignment: Alignment.center,
                  child: Icon(product.icon, size: 62),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Eyebrow(label),
                  const SizedBox(height: 10),
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatMoney(product.price),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () {
                      store.addToCart(product);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
                      );
                    },
                    child: const Text('Comprar Agora'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingCta extends StatelessWidget {
  const _ShippingCta();

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 58),
        decoration: BoxDecoration(
          color: const Color(0xFF140202),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            const _Eyebrow('FRETE GRÁTIS'),
            const SizedBox(height: 14),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(text: 'Compras acima de '),
                  TextSpan(text: 'R\$ 999', style: TextStyle(color: AppTheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Entrega expressa em 24h para todo o Brasil. Garantia de 1 ano e suporte técnico especializado.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _CatalogPage()),
              ),
              child: const Text('Aproveitar Oferta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestimonialsSection extends StatelessWidget {
  final bool desktop;
  const _TestimonialsSection({required this.desktop});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Lucas Ferreira', 'Designer UX', 'Recebi meu MacBook em 2 dias. Embalagem perfeita, produto original, preço justo. Já é a terceira vez que compro aqui.', 'LF'),
      ('Mariana Costa', 'Desenvolvedora', 'Atendimento impecável. Tive uma dúvida sobre o processador e o suporte respondeu em minutos com detalhes técnicos.', 'MC'),
      ('Rafael Oliveira', 'Fotógrafo', 'Melhor loja de eletrônicos online. Variedade enorme, fotos reais dos produtos e garantia de 1 ano direto pela loja.', 'RO'),
    ];

    return _SectionShell(
      background: AppTheme.surface,
      child: Column(
        children: [
          const _Eyebrow('CLIENTES SATISFEITOS'),
          const SizedBox(height: 14),
          const Text('O que dizem sobre nós', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = desktop ? 3 : 1;
              return GridView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  childAspectRatio: desktop ? 1.75 : 1.8,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0202),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('★★★★★', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12)),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Text(
                            '“' + item.$3 + '”',
                            style: const TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 12),
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.border,
                              child: Text(item.$4, style: const TextStyle(fontSize: 10, color: AppTheme.primary)),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                                Text(item.$2, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool desktop;
  const _Footer({required this.desktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D0101),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 46),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 70,
                runSpacing: 30,
                children: [
                  const SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _LogoMark(),
                            SizedBox(width: 8),
                            Text('Volt', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            Text('Tech', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: 14),
                        Text(
                          'A loja de eletrônicos mais confiável do Brasil. Tecnologia de ponta com preços acessíveis.',
                          style: TextStyle(color: AppTheme.textSecondary, height: 1.5, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const _FooterColumn('Produtos', ['Smartphones', 'Laptops', 'Áudio', 'Câmeras', 'Tablets', 'Acessórios']),
                  const _FooterColumn('Empresa', ['Sobre nós', 'Blog', 'Carreiras', 'Imprensa', 'Parceiros']),
                  const _FooterColumn('Suporte', ['Central de Ajuda', 'Garantia', 'Trocas', 'Rastreamento', 'Contato']),
                ],
              ),
              const SizedBox(height: 38),
              const Divider(color: AppTheme.border),
              const SizedBox(height: 12),
              const Text(
                '© 2026 VoltTech. Todos os direitos reservados.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;
  const _FooterColumn(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(item, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  final Widget child;
  final Color background;
  const _SectionShell({
    required this.child,
    this.background = AppTheme.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 68),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: child,
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primary.withValues(alpha: .6)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 9,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
      ],
    );
  }
}

class _CatalogPage extends StatelessWidget {
  final String initialCategory;
  const _CatalogPage({this.initialCategory = 'Todos'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo')),
      body: ProductsScreen(initialCategory: initialCategory),
    );
  }
}
