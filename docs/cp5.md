# Checkpoint 5 — Protótipo Funcional

## Escopo entregue

A VoltTech foi evoluída para um protótipo navegável em Flutter. O catálogo usa dados mockados para garantir previsibilidade na demonstração, enquanto favoritos e pedidos possuem integração preparada com Supabase.

## Fluxo demonstrável

Home -> Catálogo -> Produto -> Carrinho -> Checkout -> Confirmação.

Também foram implementados Favoritos e Perfil.

## Estratégia de dados

Os produtos são locais e simulados. Essa decisão evita dependência de API externa durante a apresentação e permite cobrir cenários de preço, desconto, avaliação, estoque e categorias.

## Supabase

O serviço em lib/services/supabase_service.dart inicializa o Supabase somente quando SUPABASE_URL e SUPABASE_ANON_KEY forem fornecidos via dart-define. Sem configuração, o app permanece em modo mock.

O arquivo supabase/schema.sql contém as tabelas necessárias para favoritos, pedidos e itens dos pedidos.

## Ambiente de teste

Ambiente recomendado para a apresentação:

flutter run -d chrome

Antes da aula, executar flutter doctor e flutter pub get.

## Checklist pré-apresentação

- Abrir Home sem erros
- Testar busca
- Testar filtro por categoria
- Abrir detalhes de produto
- Favoritar e desfavoritar
- Adicionar ao carrinho
- Aumentar e reduzir quantidade
- Abrir checkout
- Confirmar pedido
- Voltar à Home
- Validar status do Supabase no Perfil
