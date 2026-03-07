t# Teoria Operacional: VWAP (Volume Weighted Average Price)

## 1. O Conceito
A VWAP (Preço Médio Ponderado pelo Volume) não é apenas um indicador, é uma **referência econômica**. Ela representa o preço médio exato que foi negociado em um ativo durante o dia, levando em conta o volume de cada negócio.

Diferente de uma Média Móvel simples (que trata todos os candles com o mesmo peso), a VWAP dá mais peso para onde o "dinheiro grande" trocou de mãos.

**Por que é o "Santo Graal" Institucional?**
Grandes fundos e tesourarias são cobrados por execução. Se um trader institucional compra um lote enorme acima da VWAP do dia, ele pagou "caro" (pior que a média do mercado). Se comprou abaixo, pagou "barato". Por isso, eles defendem essa linha com robôs de alta frequência.

## 2. Lógica Operacional (O Filtro Supremo)

A VWAP divide o dia em dois territórios.

### Território de Compra (Touros)
*   **Preço > VWAP:** O mercado está aceitando pagar cada vez mais caro. Os comprados estão no lucro e defendem suas posições.
*   **Atitude:** Procurar apenas por COMPRAS (Pullbacks). Ignorar sinais de venda (são contra-tendência e perigosos).

### Território de Venda (Ursos)
*   **Preço < VWAP:** O mercado está pressionando o preço para baixo. Os vendidos estão no lucro.
*   **Atitude:** Procurar apenas por VENDAS.

## 3. Estratégias de Trade com VWAP
A regra de coloração `fev_VWAPreferenciaPreco.ntsl` funciona como um filtro visual do território institucional.

### 🟢 VERDE = TERRITÓRIO DE COMPRA (Com Força)
*   **Cor:** Verde Padrão.
*   **Condição:** Preço fechou **acima** da VWAP **E** o candle foi positivo.
*   **Significado:** Os compradores estão no controle do território e mostrando força. Cenário ideal para procurar por pullbacks ou continuações de alta.

### 🔴 VERMELHO = TERRITÓRIO DE VENDA (Com Força)
*   **Cor:** Vermelho Padrão.
*   **Condição:** Preço fechou **abaixo** da VWAP **E** o candle foi negativo.
*   **Significado:** Os vendedores estão no controle do território e mostrando força. Cenário ideal para procurar por pullbacks ou continuações de baixa.

### ⚫ CINZA = ZONA DE CONFLITO (Aguardar)
*   **Cor:** Cinza Padrão.
*   **Condição:** Qualquer outra situação (ex: candle negativo acima da VWAP ou candle positivo abaixo da VWAP).
*   **Ação:** O movimento do candle está contra o território dominante. Indica um pullback, um repique ou indecisão. É um sinal para ter cautela.

## 4. Estratégias de Trade com VWAP

### A. O Pullback Institucional (A "Defesa")
É a estratégia mais clássica e confiável.
1.  **Cenário:** O preço se afasta da VWAP (tendência definida).
2.  **Gatilho:** O preço retorna suavemente até tocar (ou chegar muito perto) da VWAP.
3.  **Ação:** Observar um sinal de Price Action (Martelo, VSA Shakeout) exatamente na VWAP.
4.  **Lógica:** Os institucionais que não entraram no início do movimento aproveitam o retorno ao "preço justo" para montar posição, e os que já estão posicionados defendem o médio.

### B. Rompimento com Volume (A "Virada de Mão")
Quando o preço cruza a VWAP com violência.
1.  **Cenário:** O preço estava abaixo da VWAP, mas cruza para cima com um candle de força e volume alto.
2.  **Confirmação:** O preço não volta mais para baixo da VWAP nos candles seguintes.
3.  **Lógica:** O fluxo mudou. Quem estava vendido agora está "no calor" (prejuízo) e começa a estopar, alimentando a alta.

### C. VWAP Bands (Desvio Padrão)
Assim como nas Bandas de Bollinger, podemos projetar desvios padrões a partir da VWAP.
*   **Uso:** Identificar exaustão.
*   **Regra:** Se o preço toca a 2ª ou 3ª banda de desvio padrão da VWAP, ele está estatisticamente "caro demais" ou "barato demais" para o dia. A chance de retorno à média (VWAP) é alta.

## 5. Gerenciamento

*   **Stop Loss:**
    *   Em operações de Pullback: O Stop deve ficar logo atrás da VWAP. Se a VWAP for perdida, a premissa do trade acabou.
*   **Alvo:**
    *   Em tendências: Topos/Fundos anteriores ou projeções de Fibonacci.
    *   Em reversões (Bands): O alvo é a própria linha central da VWAP.

---
*Estratégia baseada em Fluxo e Preço Médio*

## 6. Expansão de Conhecimento: O Ecossistema VWAP

A VWAP tradicional reinicia a cada dia. Mas e se quisermos saber o preço médio de um movimento específico (ex: pós-Payroll, pós-Eleição)?

### A. Anchored VWAP (VWAP Ancorada)
Esta ferramenta permite que você clique em um topo ou fundo importante e trace a VWAP a partir dali.
*   **Aplicação:** Se o mercado fez um fundo relevante há 3 dias, ancore uma VWAP nesse fundo. Essa linha mostrará o preço médio de quem comprou naquele fundo.
*   **Poder:** Quando o preço voltar nessa linha dias depois, ela funcionará como um suporte fortíssimo, muitas vezes invisível para quem usa apenas a VWAP diária.

### B. VWAP Semanal e Mensal (O Contexto Macro)
A VWAP diária mostra o "preço justo" do dia. As VWAPs de períodos maiores mostram o preço justo dos players de longo prazo.
*   **VWAP Semanal:** O preço médio negociado na semana. Funciona como um ímã para o preço. Se o preço se afasta muito, tende a retornar a ela.
*   **VWAP Mensal:** O preço médio do mês. É um suporte/resistência extremamente forte.
*   **Confluência de VWAPs:** Quando a VWAP diária, semanal e mensal estão no mesmo lugar, essa região se torna uma "parede" de suporte ou resistência, pois players de todos os os timeframes estão posicionados ali.

### C. A Relação VWAP vs. Ajuste (A Faixa de Valor)
O Ajuste é o preço de fechamento "oficial" do dia anterior. A VWAP é o preço médio do dia atual. A relação entre eles define o sentimento do mercado.
*   **Preço acima da VWAP e do Ajuste:** Forte viés de alta. O mercado está rejeitando o preço justo de ontem e estabelecendo um novo valor mais alto.
*   **Preço abaixo da VWAP e do Ajuste:** Forte viés de baixa.
*   **Preço entre a VWAP e o Ajuste:** Mercado em equilíbrio ou "range". A área entre a VWAP e o Ajuste é chamada de **Faixa de Valor**. O preço tende a ficar "preso" nessa região até que uma força (compradora ou vendedora) consiga empurrá-lo para fora com convicção.

**Dica de Ouro:** A melhor operação de Pullback na VWAP diária acontece quando o preço também está acima da VWAP Semanal, alinhando o micro com o macro.
