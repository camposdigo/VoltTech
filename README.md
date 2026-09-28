# VoltTech — Checkpoint 5

VoltTech é um aplicativo Flutter de e-commerce de eletrônicos. No Checkpoint 5, o projeto evolui do protótipo visual do CP4 para um protótipo funcional, navegável e demonstrável em ambiente de teste.

## Objetivo do CP5

O foco desta entrega é disponibilizar o fluxo principal do app funcionando, com dados mockados realistas, navegação entre telas, integração preparada com Supabase e documentação de execução.

## Funcionalidades implementadas

- Home com ofertas, categorias e produtos em destaque
- Catálogo completo com busca
- Filtro por categoria
- Página de detalhes do produto
- Favoritos
- Carrinho com alteração de quantidade e remoção
- Checkout demonstrativo
- Confirmação de pedido
- Perfil do usuário
- Dados mockados para demonstração estável
- Integração com Supabase para favoritos e pedidos
- Fallback automático para modo mock caso o banco não esteja configurado ou fique indisponível
- Execução via Chrome/Flutter Web

## Fluxo principal

Início -> Catálogo -> Detalhes do produto -> Carrinho -> Checkout -> Pedido confirmado

Fluxos auxiliares:

- Início -> Favoritos
- Início -> Perfil
- Home -> Categoria -> Catálogo filtrado
- Home -> Busca -> Catálogo

## Dados mockados

O catálogo possui produtos simulados com:

- nome
- categoria
- preço
- preço anterior
- desconto
- avaliação
- estoque
- descrição

Isso permite apresentar o app sem depender de APIs externas durante a aula.

## Banco de dados — Supabase

O app utiliza o pacote supabase_flutter.

A integração é opcional durante o desenvolvimento local: sem as chaves, o aplicativo continua funcionando integralmente com dados mockados. Com as chaves configuradas, favoritos e pedidos são enviados ao Supabase.

### 1. Criar as tabelas

Abra o SQL Editor do projeto Supabase e execute o conteúdo de:

supabase/schema.sql

### 2. Executar com as chaves

Use:

flutter run -d chrome --dart-define=SUPABASE_URL=SUA_URL --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON

Não salve chaves privadas no repositório.

## Como executar

### Pré-requisitos

- Flutter SDK instalado
- Chrome ou outro dispositivo Flutter configurado

Confirme com:

flutter doctor

### Instalação

1. Clone o repositório.
2. Entre na pasta do projeto.
3. Execute:

flutter pub get

4. Para rodar no Chrome sem Supabase:

flutter run -d chrome

5. Para rodar com Supabase:

flutter run -d chrome --dart-define=SUPABASE_URL=SUA_URL --dart-define=SUPABASE_ANON_KEY=SUA_CHAVE_ANON

Caso as pastas de plataforma ainda não existam no clone, execute uma única vez:

flutter create . --platforms=web,android,windows

Depois execute novamente flutter pub get.

## Decisões técnicas desde o CP4

No CP4, o foco estava na identidade visual e na estrutura inicial da Home. Para o CP5 foram realizadas as seguintes evoluções:

1. Separação de responsabilidades em models, data, controllers, services, screens, widgets e utils.
2. Criação de um store simples com ChangeNotifier para estado de carrinho e favoritos.
3. Manutenção da identidade visual escura, vermelha e premium definida no CP4.
4. Criação de dados mockados locais para evitar falhas durante a apresentação.
5. Integração com Supabase sem tornar o funcionamento do app dependente da conexão.
6. Implementação do fluxo completo de compra.
7. Inclusão de busca, categorias, favoritos, carrinho e perfil.

## Estrutura principal

VoltTech/
- lib/
  - controllers/
  - data/
  - models/
  - screens/
  - services/
  - theme/
  - utils/
  - widgets/
  - main.dart
- supabase/
  - schema.sql
- web/
  - index.html
  - manifest.json
- docs/
  - cp5.md
  - documentacao-inicial.md
  - identidade-visual.md
  - marca.md
  - pitch.md
- pubspec.yaml

## Roteiro rápido para apresentação

1. Abrir a Home.
2. Mostrar categorias e dados simulados.
3. Entrar em Áudio e abrir a Caixa de Som Volt Boom.
4. Favoritar o produto.
5. Adicionar o produto ao carrinho.
6. Abrir o carrinho e alterar a quantidade.
7. Avançar para checkout.
8. Mostrar os dados mockados de entrega.
9. Confirmar o pedido.
10. Abrir Perfil e mostrar o status do Supabase.

## Critérios do Checkpoint 5

- Fluxo de telas completo e navegável: implementado
- Fidelidade ao design do CP4: preservada
- Dados mockados realistas: implementados
- Ambiente de teste: Chrome/Flutter Web
- Documentação: README e docs/cp5.md
- Integração de banco: Supabase

## Integrantes

- Gabriel De Biasi Couto — RM 563247
- Lucas Franco de Godoy Fortes — RM 561723
- João Pedro da Silva Costa — RM 565031
- Pedro Noronha dos Santos — RM 564572
- Rodrigo Campos Cordeiro — RM 566386
- Rafael Silva Oliveira Nascimento — RM 565415

## Observação

Este projeto é acadêmico. O checkout não processa pagamentos reais.
