# Validação da entrega

Validação realizada em 4–5 de outubro de 2026, no Windows, com Flutter 3.47.2, Dart 3.13.2, Chrome e o projeto Supabase indicado pelo `.env`.

## Estado inicial

O repositório já era Flutter e possuía Home, catálogo, detalhes, favoritos, carrinho, checkout, confirmação e perfil. Havia organização em models, controller, serviço e widgets, e uma identidade escura aproveitável.

As principais lacunas eram catálogo Dart hardcoded; ausência de Auth; perfil e endereço fictícios; favoritos sem proprietário; carrinho apenas em memória; exceções do Supabase ignoradas; sucesso de checkout mesmo sem persistência; ausência de comparação, recomendação e histórico real; policies públicas para dados privados; botões sem ação; grade fixa; ausência de testes e `.gitignore`. O `.env` usava nomes NEXT_PUBLIC e não era lido pelo app. O banco remoto estava vazio.

## Verificações executadas

| Verificação | Resultado |
| --- | --- |
| `flutter pub get` | Dependências resolvidas |
| `dart format .` | Código formatado |
| `flutter analyze` | Sem problemas |
| `flutter test` / `flutter test --no-test-assets` | 13 testes aprovados; última rodada sem reconstruir assets |
| `flutter build web` via launcher de ambiente | Build gerado em `build/web` |
| `flutter build apk --release` via launcher | APK gerado; assinatura de desenvolvimento |
| API pública do Supabase | 15 produtos completos, 5 categorias |
| Testes HTTP de Auth e banco | 25 verificações aprovadas |
| `supabase/tests/security.sql` | Aprovado; fixtures e operações revertidas por rollback |
| Supabase Security Advisors | Schema sem alertas; proteção de senhas vazadas desativada na configuração Auth |
| Supabase Performance Advisors | Apenas índices ainda não usados em banco novo |
| Chrome headless | Fluxo real da recomendação ao pedido/histórico sem erro JavaScript |
| Layouts de widget | 320, 390, 768 e 1440 pixels; sem overflow nos cenários testados |
| Acessibilidade | Cards com escala de texto 1,6; tooltips e componentes Material |

Os comandos de build utilizam `dart run tool/run.dart build ...`, que executa os comandos Flutter correspondentes e fornece somente as configurações públicas do Supabase.

## Cobertura Flutter

- Leitura de produto e relações, preço promocional opcional e pesquisa sem acentos.
- Recomendação respeita categoria, estoque, orçamento e adequação mínima.
- Priorização por bateria ou menor preço altera o resultado.
- Nenhum produto indicado quando não existe opção adequada.
- Carrinho rejeita quantidade inválida, calcula subtotal e preserva itens do visitante ao recarregar a sessão.
- Comparação mantém categoria e quantidade selecionada.
- Home, grade, detalhes, checkout e login nos quatro tamanhos.
- Cards com texto ampliado.
- Validação de campos em login/cadastro.
- Perguntas por categoria e navegação das etapas do assistente.

## Verificações reais no Supabase

Dois usuários temporários foram usados para testar login, perfil, favoritos, carrinho, checkout e privacidade. O teste HTTP verificou preço calculado no servidor, pedido/itens, idempotência, histórico, limpeza do carrinho, falha por falta de estoque sem efeitos parciais, renovação de sessão e logout.

O SQL de regressão também verifica reatribuição indevida do proprietário e leitura anônima de dados privados. Ele usa `ROLLBACK`, podendo ser repetido em um banco de teste com o seed.

As contas temporárias e pedidos de teste são removidos ao concluir; apenas os estoques consumidos por essas contas são restaurados. Nenhuma conta pessoal é alterada.

## Limites reais da validação

- O endpoint de cadastro respondeu com limite de envio de e-mails do Supabase. A validação do formulário foi automatizada; o ciclo de recebimento/confirmação por e-mail não foi concluído. Contas temporárias confirmadas foram usadas para testar os demais fluxos reais. A confirmação de e-mail não foi desativada.
- O Figma Make retornou links de fonte que o recurso MCP não conseguiu ler. Screenshot de Make não é suportado pelo conector. A identidade existente e as diretrizes do pedido foram preservadas; fidelidade pixel a pixel não foi verificada.
- A repetição de `flutter test` encontrou uma pasta de assets somente leitura no OneDrive. A limpeza automática foi bloqueada pela política do ambiente. A rodada final passou com `flutter test --no-test-assets`, que dispensa a reconstrução desses assets; os testes não dependem de assets locais do aplicativo.
- O APK foi compilado, mas não instalado em aparelho/emulador nesta sessão. O ambiente indicou licenças Android parcialmente pendentes, porém o build utilizado terminou com sucesso.
- O catálogo é fictício e as fotos são ilustrativas externas. As notas do recomendador são curadoria demonstrativa, não benchmarks.
- O aplicativo exige conexão para catálogo e persistência; não possui modo offline, pagamento, entrega, rastreamento ou formulário de avaliações.
- Testes em quatro tamanhos e texto ampliado reduzem riscos de overflow, mas não equivalem a uma auditoria completa de acessibilidade em todos os dispositivos.

## Roteiro para repetir

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
dart run tool/run.dart build web
dart run tool/run.dart build apk --release
```

Para validação manual, siga [cp5.md](cp5.md). Para regras e configuração, veja o [README](../README.md).
