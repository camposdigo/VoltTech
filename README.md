# VoltTech — tecnologia sem complicação

> Você não precisa entender de tecnologia para comprar tecnologia.

Aplicativo Flutter para a CP5 de Cross-Platform Application Development. A VoltTech ajuda pessoas sem conhecimento técnico a escolher eletrônicos a partir da rotina, do orçamento e das prioridades. Em vez de começar por siglas, apresenta benefícios, limitações e motivos para cada indicação.

## Executar neste repositório

O projeto Supabase existente já recebeu as migrations e o seed. O `.env` local já contém a configuração e não deve ser enviado ao Git.

```powershell
flutter pub get
dart run tool/run.dart run -d chrome
```

O comando lê o `.env` e passa **somente a URL e a chave pública** ao Flutter. Não inclui o `.env` como asset. Também aceita os nomes `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` que já estavam no ambiente e a chave legada `SUPABASE_ANON_KEY`.

Em um novo clone, copie `.env.example` para `.env` e preencha:

```dotenv
SUPABASE_URL=
SUPABASE_PUBLISHABLE_KEY=
```

Alternativa nativa do Flutter, quando o arquivo contém apenas as duas variáveis públicas:

```powershell
flutter run -d chrome --dart-define-from-file=.env
```

Nunca use `service_role` ou `sb_secret_` no aplicativo. O inicializador e o launcher rejeitam essas chaves. A chave pública é distribuída no aplicativo por definição; a proteção dos dados está nas permissões e no RLS.

## Público e problema

Estudantes, profissionais e pessoas que precisam de um celular, notebook, fone, tablet ou acessório, mas não sabem traduzir especificações em decisões. O diferencial é explicar se um produto atende a faculdade, trabalho, fotos, bateria, transporte, jogos ou outras necessidades — inclusive quando não é uma boa escolha.

## Funcionalidades

- Home com proposta de valor, assistente de compra, categorias, destaques e ofertas.
- Catálogo vindo do Supabase, busca sem distinção de acentos por nome, marca, categoria e casos de uso.
- Filtros por categoria, preço máximo e ofertas; ordenação por preço ou nome.
- Detalhes com perfil ideal, benefícios, limitações, bateria, tela e desempenho explicados.
- Especificações técnicas em seção expansível.
- Assistente em cinco etapas: produto, uso, orçamento, prioridade e resultado.
- Comparação de dois ou três produtos da mesma categoria, em linguagem simples e técnica.
- Cadastro, login por e-mail/senha, persistência e renovação de sessão, logout e edição do nome.
- Favoritos por usuário.
- Carrinho de visitante em memória, mesclado ao carrinho da conta após login.
- Carrinho autenticado persistido, com alteração de quantidade e remoção.
- Checkout simulado com Pix, cartão ou boleto, confirmação e histórico de pedidos.
- Estados de carregamento, vazio e erro; retorno visível nas ações.
- Layouts adaptáveis a celular, tablet e desktop, com componentes Material em português brasileiro.

O aplicativo **não processa pagamentos, não envia produtos e não coleta números de cartão**. Avaliações têm estrutura no banco para evolução futura, mas não há formulário de avaliação implementado.

## Dados demonstrativos, persistência real

O catálogo inclui 15 modelos fictícios da marca VoltTech, em cinco categorias. Preços, especificações e notas de adequação são exemplos realistas para a apresentação, não ofertas comerciais ou benchmarks verificados. Cada produto possui explicações, limitações, especificações e casos de uso. As fotos externas são ilustrativas e têm fallback visual.

Os dados estão em `supabase/seed.sql`, não em uma lista Dart. Não há fallback silencioso para catálogo local nem confirmação fictícia quando uma gravação falha. `test/fixtures/products.json` é usado exclusivamente pelos testes.

Foram removidos os antigos depoimentos inventados, contagens fixas de clientes/produtos, dados pessoais preenchidos e promessas de entrega sem base.

## Stack e arquitetura

- Flutter 3.47.2 / Dart 3.13.2 usados na validação.
- Material 3 com tema escuro preto, vermelho e vinho.
- `supabase_flutter` 2.18.0, versão fixada; dependências transitivas em `pubspec.lock`.
- Supabase Auth, API PostgREST e PostgreSQL 17.
- `ChangeNotifier` / `AnimatedBuilder` para estado; navegação com `Navigator`.
- Sem React, servidor Node de aplicação ou provedor de IA.

Fluxo de dados: **tela → VoltTechStore → SupabaseService / Supabase client → banco com RLS**. A recomendação é uma função Dart independente e testável. O checkout transacional fica no banco, onde preço, estoque e identidade são confiáveis.

```text
lib/
  main.dart                  inicialização, idioma e tema
  controllers/               estado de catálogo, sessão, carrinho e favoritos
  models/                    produto e leitura de relações do banco
  services/                  conexão Supabase e regras do recomendador
  screens/                   telas e rotas
  widgets/                   cards, grade, mensagens e estrutura de páginas
  theme/                     cores e componentes Material
  utils/                     moeda brasileira
supabase/
  config.toml                configuração de desenvolvimento local
  migrations/                schema, permissões, RLS, checkout e concorrência
  seed.sql                   catálogo demonstrativo idempotente
  tests/                     regressão SQL com rollback
android/                     plataforma Android no mesmo aplicativo
web/                         bootstrap Flutter Web
test/                        testes Dart/widget e fixtures
tool/                        execução local e verificações auxiliares
```

## Compra guiada

1. As opções de uso mudam com a categoria.
2. As faixas de orçamento também são específicas da categoria.
3. O resultado considera apenas produtos da categoria, em estoque, dentro da faixa selecionada e com nota de adequação ao uso de pelo menos 3/5.
4. Ordenação: **70% adequação ao uso + 30% prioridade**. Para menor preço, a prioridade é calculada pela distância ao teto do orçamento. Empates favorecem o menor preço.
5. Até três opções são apresentadas, com justificativa e pontos de atenção. Se nenhuma atende, o app convida a ajustar a escolha; não extrapola o orçamento silenciosamente.

As notas vão de 1 (pouco indicado) a 5 (excelente). São curadoria do catálogo demonstrativo. O fluxo não é chatbot, não chama IA e funciona para visitantes. Preferências são gravadas em `recommendation_sessions` quando há sessão autenticada; falha nessa gravação não impede visualizar o resultado.

## Banco e permissões

| Tabela | Responsabilidade | Acesso pelo aplicativo |
| --- | --- | --- |
| `profiles` | Nome, e-mail e avatar | Dono lê; pode atualizar nome/avatar |
| `categories` | Categorias ativas | Leitura pública |
| `products` | Produto, preço, imagem, estoque | Leitura pública de produtos/categorias ativos |
| `product_specs` | Especificações ordenadas | Leitura pública conforme produto |
| `product_explanations` | Benefícios e limitações | Leitura pública conforme produto |
| `product_use_cases` | Notas de adequação | Leitura pública conforme produto |
| `favorites` | Favoritos por usuário/produto | Somente o dono |
| `cart_items` | Quantidade por usuário/produto | Somente o dono |
| `orders` | Pedido e endereço de entrega | Dono lê; gravação somente pelo checkout |
| `order_items` | Preço e nome no momento da compra | Dono do pedido lê |
| `reviews` | Estrutura para avaliações futuras | Leitura pública; escrita pelo próprio autor |
| `recommendation_sessions` | Preferências da compra guiada | Somente o dono |

Todas as 12 tabelas têm RLS. As policies privadas usam `auth.uid()`; updates validam também o novo proprietário. Grants são explícitos. Há foreign keys, unicidade de carrinho/favorito, limites de quantidade, preço, estoque e notas, além de índices nas relações e consultas por usuário.

O trigger de Auth cria o perfil. Funções com privilégio elevado ficam no schema `private`, com `search_path` fixo e execução restrita. Não se utiliza `user_metadata` para autorização. O endpoint `public.checkout` é `SECURITY INVOKER` e encaminha a transação privada, que exige usuário autenticado.

### Checkout

O banco trava as alterações do carrinho por usuário, bloqueia os produtos em ordem determinística, confere estoque, calcula o total usando preços do banco, cria pedido/itens, desconta estoque e limpa o carrinho na mesma transação. Qualquer erro desfaz todas as alterações. Um identificador de requisição evita duplicação ao repetir a confirmação na mesma tela.

Pedidos têm preço/nome registrados no momento da compra e status `Confirmado (simulação)`. Não existe escrita direta em pedidos ou estoque para `anon`/`authenticated`.

## Migrations e seed

**Neste ambiente já foram aplicados por MCP ao projeto indicado no `.env`. Não é necessário executar SQL manualmente.** O CLI foi encontrado via `npx`, mas não tinha login; o acesso autenticado disponível foi o MCP.

Para outro ambiente remoto, com CLI autenticada e projeto vinculado:

```powershell
npx supabase login
npx supabase link --project-ref SEU_PROJECT_REF
npx supabase db push --include-seed
```

Para um banco local descartável, com Docker instalado:

```powershell
npx supabase start
npx supabase db reset
```

`db reset` reinicializa o banco local: não use para preservar dados locais existentes. O seed usa `ON CONFLICT DO NOTHING`, portanto reaplicar não repõe estoques consumidos nem sobrescreve edições. O schema inicial foi criado para o banco vazio encontrado; bancos que receberam o SQL demonstrativo antigo precisam de migração específica, não de execução cega deste schema.

Documentação de referência: [Auth Flutter](https://supabase.com/docs/reference/dart/auth-signinwithpassword) e [Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security).

## Testes e builds

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
dart run tool/run.dart build web
dart run tool/run.dart build apk --release
```

Se o OneDrive bloquear a reconstrução de `build/unit_test_assets`, execute `flutter test --no-test-assets`. Os testes deste projeto não dependem de assets locais do aplicativo.

Saídas:

- Web: `build/web/`.
- Android: `build/app/outputs/flutter-apk/app-release.apk`.

O APK usa assinatura de desenvolvimento para instalação e apresentação; publicação em loja exige assinatura própria. A permissão de Internet está no manifesto de release. Não há cobrança real em nenhuma plataforma.

Para visualizar o build web com Node instalado:

```powershell
node tool/preview.mjs
```

Abra `http://127.0.0.1:8787`. O servidor é local e serve apenas `build/web`.

Veja [docs/validacao.md](docs/validacao.md) para resultados, limites e roteiro. Os testes unitários cobrem regras do recomendador, pesquisa, mapeamento e carrinho; os testes de widget verificam formulários, assistente e layouts de 320, 390, 768 e 1440 pixels, incluindo texto ampliado.

## Autenticação e apresentação

Use **Minha conta → Entrar ou criar conta**. Se o Supabase solicitar confirmação, confirme o e-mail antes do login. A configuração de confirmação não foi desativada. O teste de envio atingiu o limite de e-mails do provedor; aguarde a janela de envio se o cadastro exibir limite de tentativas. Para uso continuado com muitos cadastros, configure SMTP no painel Supabase.

Contas temporárias de validação não são contas de demonstração e são removidas após os testes. Nenhuma senha de usuário é incluída no repositório.

## Referência visual

O conteúdo da Home está em [landing_page.dart](lib/screens/landing_page.dart), separado da navegação em [home_screen.dart](lib/screens/home_screen.dart). O acabamento foi revisado com marca unificada, destaque fotográfico do catálogo, categorias acessíveis e textos mais diretos. As setas de ação usam ícones para evitar caracteres corrompidos.

[Figma Make informado](https://www.figma.com/make/cxzkaJaUQSiAKxjIt5rqhP?node-id=0:1). A implementação preserva a identidade escura/vermelho/vinho do repositório e as diretrizes fornecidas, com foco na compra guiada. O MCP retornou links de fonte do Make, mas não permitiu lê-los nem gerar screenshot desse tipo de arquivo. Portanto, não se afirma reprodução pixel a pixel da referência.

## Atendimento aos requisitos da CP5

Esta matriz orienta a **entrega e a avaliação do CHECKPOINT 5 — Cross-Platform Application Development**. Ela cobre os critérios de CP5 e os requisitos detalhados disponibilizados nesta solicitação. **Não foi encontrado um enunciado separado do professor no repositório; eventuais critérios adicionais desse documento ainda precisam ser conferidos.** Não se declara atendimento a exigências que não foram disponibilizadas.

| Requisito | Atendimento e evidência no projeto |
| --- | --- |
| Analisar o repositório existente antes de refatorar | Diagnóstico da stack, telas, mocks, integração e problemas em [docs/validacao.md](docs/validacao.md#estado-inicial). |
| Manter Flutter e o mesmo repositório | Aplicativo em [lib/main.dart](lib/main.dart), dependências em [pubspec.yaml](pubspec.yaml), plataformas [web](web/) e [android](android/). Não foi criada aplicação paralela. |
| Protótipo funcional, executável e navegável | Inicialização em [main.dart](lib/main.dart), navegação em [home_screen.dart](lib/screens/home_screen.dart) e rotas de cada tela em [screens](lib/screens/). |
| Fidelidade à identidade visual/protótipo | Preto, vermelho e vinho em [app_theme.dart](lib/theme/app_theme.dart); hierarquia, cards e Home refatorados. **Parcialmente verificável:** acesso ao conteúdo completo/screenshot do Figma Make indisponível, conforme [Referência visual](#referência-visual). |
| Proposta de valor para pessoas leigas | Home comunica “Tecnologia sem complicação” e oferece o CTA de orientação em [home_screen.dart](lib/screens/home_screen.dart). |
| Home com categorias, destaques e ofertas | [home_screen.dart](lib/screens/home_screen.dart), alimentada pelo estado carregado do Supabase. |
| Catálogo, busca e filtros | Nome, marca, categoria e necessidades sem distinção de acentos; categoria, teto de preço, ofertas e ordenação em [products_screen.dart](lib/screens/products_screen.dart) e [product.dart](lib/models/product.dart). |
| Compra guiada em cinco etapas | Produto, uso por categoria, orçamento, prioridade e resultado em [recommendation_screen.dart](lib/screens/recommendation_screen.dart). |
| Justificar recomendações em linguagem humana | Elegibilidade, ranking, explicação e ausência de resultado em [recommendation_service.dart](lib/services/recommendation_service.dart); regras cobertas por [test/widget_test.dart](test/widget_test.dart). |
| Produtos com benefícios e limitações compreensíveis | Ideal para, usos, restrições, desempenho, bateria, tela, prós, atenção, motivo da compra e perfil em [product_details_screen.dart](lib/screens/product_details_screen.dart) e [seed.sql](supabase/seed.sql). |
| Especificações técnicas em seção secundária | Seção expansível “Ver especificações técnicas” em [product_details_screen.dart](lib/screens/product_details_screen.dart). |
| Comparação simples e técnica | Dois ou três produtos da mesma categoria, notas por uso e tabela técnica em [comparison_screen.dart](lib/screens/comparison_screen.dart). |
| Integração real com banco de dados | Cliente em [supabase_service.dart](lib/services/supabase_service.dart); operações e estado em [volttech_store.dart](lib/controllers/volttech_store.dart). Migrations e seed aplicados ao projeto existente por MCP. |
| Dados realistas para demonstração | 15 produtos fictícios, cinco categorias, especificações e 154 notas de uso em [seed.sql](supabase/seed.sql). Persistência real; fotos e características identificadas como demonstrativas. |
| Remover dependência do catálogo hardcoded | Removido `lib/data/mock_products.dart`; catálogo lido do Supabase. Fixtures de [test/fixtures](test/fixtures/) não integram o aplicativo. |
| Modelagem, relacionamentos, índices e constraints | 12 tabelas, foreign keys, unicidade e validações em [migração principal](supabase/migrations/20261005012803_volttech_storefront.sql). |
| Cadastro, login, logout e sessão persistente | Supabase Auth em [auth_screen.dart](lib/screens/auth_screen.dart), [supabase_service.dart](lib/services/supabase_service.dart) e [volttech_store.dart](lib/controllers/volttech_store.dart). Login, renovação, reload e logout testados. **Limite de validação:** confirmação de cadastro por e-mail não concluída devido ao limite de envio do provedor. |
| Perfil real do usuário | Trigger de criação de perfil na migração; exibição e edição do nome em [profile_screen.dart](lib/screens/profile_screen.dart). |
| Navegação sem login e autenticação quando necessária | Catálogo e assistente públicos; `requireLogin` em [auth_screen.dart](lib/screens/auth_screen.dart) protege favoritos e continuidade do checkout. |
| RLS e proteção entre usuários | Policies por `auth.uid()`, leitura pública apenas do catálogo, grants explícitos e escrita de pedidos restrita na [migração principal](supabase/migrations/20261005012803_volttech_storefront.sql). Regressão em [security.sql](supabase/tests/security.sql). |
| Configuração por ambiente sem chave administrativa no frontend | [.env.example](.env.example), [.gitignore](.gitignore), [tool/run.dart](tool/run.dart) e validação da chave em [supabase_service.dart](lib/services/supabase_service.dart). `.env` real ignorado e não incluído como asset. |
| Favoritos relacionados ao usuário | [favorites_screen.dart](lib/screens/favorites_screen.dart), operações no [store](lib/controllers/volttech_store.dart) e tabela `favorites` protegida por RLS. |
| Carrinho com quantidade, remoção, subtotal e persistência | [cart_screen.dart](lib/screens/cart_screen.dart), [volttech_store.dart](lib/controllers/volttech_store.dart), tabela `cart_items`; carrinho de visitante mesclado após login. |
| Checkout demonstrável sem pagamento real | Dados validados e escolha simulada de Pix/cartão/boleto em [checkout_screen.dart](lib/screens/checkout_screen.dart); não coleta números de cartão. |
| Criar pedido e itens, limpar carrinho e confirmar | Função transacional `checkout` na [migração principal](supabase/migrations/20261005012803_volttech_storefront.sql); bloqueio concorrente em [serialize_cart_mutations](supabase/migrations/20261005014404_serialize_cart_mutations.sql); sucesso em [order_success_screen.dart](lib/screens/order_success_screen.dart). |
| Histórico de pedidos | Consulta dos pedidos e seus itens em [orders_screen.dart](lib/screens/orders_screen.dart), acessível pelo perfil e pela confirmação. |
| UI consistente, feedback, carregamento, erros e vazios | Componentes compartilhados em [common.dart](lib/widgets/common.dart), [product_card.dart](lib/widgets/product_card.dart) e [app_theme.dart](lib/theme/app_theme.dart). Sem sucesso fictício após erro de gravação. |
| Responsividade em smartphone, tablet e desktop | Layouts adaptáveis, grades e rolagem em [screens](lib/screens/) e [widgets](lib/widgets/); testes de 320, 390, 768 e 1440 pixels e texto ampliado em [widget_test.dart](test/widget_test.dart). |
| Organização e qualidade do código | Separação entre models, services, controllers, screens, widgets, theme e utils em [lib](lib/); regras em [analysis_options.yaml](analysis_options.yaml). |
| Ambiente de teste funcionando | 13 testes Flutter, 25 verificações HTTP reais, regressão SQL e percurso no Chrome descritos em [docs/validacao.md](docs/validacao.md). |
| Executar análise, testes e builds | `flutter analyze` sem problemas; testes aprovados; web e APK release gerados. Comandos e ressalva do OneDrive em [Testes e builds](#testes-e-builds). APK ainda não foi validado em aparelho físico. |
| Documentação completa da entrega | Este README cobre proposta, público, funcionalidades, stack, arquitetura, banco, Auth, RLS, ambiente, migrations, seed, execução, testes, builds, compra e recomendador. |
| Roteiro demonstrável para avaliação da CP5 | Passo a passo de apresentação em [docs/cp5.md](docs/cp5.md); resultados e limites em [docs/validacao.md](docs/validacao.md). |
| Critérios adicionais do enunciado oficial do professor | **A conferir quando o documento for disponibilizado.** Não foram presumidos critérios de vídeo, formato de entrega, pontuação ou publicação que não constam do material recebido. |

## Integrantes

- Gabriel De Biasi Couto — RM 563247
- Lucas Franco de Godoy Fortes — RM 561723
- João Pedro da Silva Costa — RM 565031
- Pedro Noronha dos Santos — RM 564572
- Rodrigo Campos Cordeiro — RM 566386
- Rafael Silva Oliveira Nascimento — RM 565415
