# CP5 — roteiro de apresentação

A VoltTech ajuda pessoas leigas a comprar eletrônicos pela necessidade, sem começar por especificações técnicas.

1. Execute `dart run tool/run.dart run -d chrome`.
2. Mostre a proposta na Home e abra **Me ajude a escolher**.
3. Escolha **Notebook → Faculdade → Até R$ 3.000 → Portabilidade**.
4. Explique a recomendação do Volt Book Study e seus pontos de atenção.
5. Abra o produto: benefícios primeiro, especificações em seção secundária.
6. No catálogo, pesquise `programacao` e teste categoria, preço e ofertas.
7. Selecione dois notebooks para comparar adequação, bateria e portabilidade.
8. Adicione um produto ao carrinho como visitante e altere a quantidade.
9. Entre na conta; mostre a persistência do carrinho e salve um favorito.
10. Finalize com endereço de exemplo e Pix simulado. Nenhum dado de cartão é solicitado.
11. Abra o histórico e confira os itens e o total do pedido.
12. Atualize a página para mostrar persistência de sessão e dados.
13. Faça logout e mostre que favoritos/pedidos da conta não ficam acessíveis.

## Preparação

O banco deste ambiente já recebeu migrations e seed. Crie sua conta antes da apresentação e confirme o e-mail se solicitado. A conexão com o Supabase é necessária; o aplicativo não disfarça falhas com pedidos ou catálogo locais.

Os produtos são modelos fictícios com características realistas para a CP5, persistidos no banco. Imagens, preços e avaliações de adequação são ilustrativos. O pagamento e a entrega são simulados.

Resultados técnicos e limitações: [validação](validacao.md). Arquitetura e configuração: [README](../README.md).
