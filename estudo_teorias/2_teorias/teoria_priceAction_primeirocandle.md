# Teoria Operacional: O Primeiro Candle e o Tom do Dia

## 1. O Conceito: Emoção vs. Razão
A abertura do mercado é o momento de maior ineficiência e volatilidade do dia.

*   **O Leilão:** Antes do mercado abrir, ordens de compra e venda se acumulam. Quando o sino toca, essas ordens são executadas simultaneamente, gerando um "vácuo" de liquidez.
*   **Quem opera a abertura?**
    *   **Amadores:** Operam na emoção (notícias da noite, ansiedade).
    *   **Robôs de HFT:** Operam arbitragem e fechamento de gaps.
    *   **Institucionais (Smart Money):** Geralmente **esperam** a poeira baixar (10:00 - 10:30) para definir a tendência real.

**A Regra de Ouro:** "Abertura é Emoção, Fechamento é Convicção."

---

## 2. O Gap (O Contexto Invisível)
O Primeiro Candle não nasce do nada. Ele nasce em relação ao fechamento de ontem. O espaço entre eles (Gap) define o sentimento inicial.

### A. Gap de Fuga (Breakaway Gap)
*   **Cenário:** O preço abre rompendo uma resistência forte ou suporte de ontem.
*   **Comportamento:** O primeiro candle é uma Barra de Força na direção do Gap.
*   **Significado:** Urgência. O mercado não vai voltar para fechar o gap tão cedo. Tendência forte.

### B. Gap de Exaustão (Trap)
*   **Cenário:** O preço abre com um gap gigante, muito longe das médias.
*   **Comportamento:** O primeiro candle tenta seguir o gap, mas deixa um pavio enorme e fecha contra.
*   **Significado:** O movimento esticou demais. Probabilidade alta de reversão para fechar o gap.

### C. Gap de Área (Common Gap)
*   **Cenário:** O preço abre dentro do range (máxima/mínima) do dia anterior.
*   **Comportamento:** Candles pequenos, sobrepostos.
*   **Significado:** Lateralidade. O mercado está sem direção.

---

## 3. A Regra Operacional do Sistema (Por que ignoramos?)

No nosso Trade System, implementamos uma regra de código (`if Date <> Date[1]`) para pintar o primeiro candle de forma neutra ou apenas direcional (Verde/Vermelho), **sem gerar sinais de entrada** (Gold/Ciano).

### Motivos Técnicos:
1.  **Distorção de Indicadores:** As Médias Móveis e o IFR são calculados com base nos candles anteriores. Um gap grande distorce a matemática, gerando sinais falsos de cruzamento ou sobrecompra/sobrevenda nos primeiros minutos.
2.  **Spread Alto:** Nos primeiros minutos, o spread (diferença compra/venda) é maior, encarecendo o Stop Loss.
3.  **Violinos:** É comum o primeiro candle romper um topo e o segundo candle devolver tudo (Armadilha de Abertura).

### Ação Recomendada:
*   **Observador:** Use o primeiro candle apenas para marcar **Suporte e Resistência** (Máxima e Mínima do dia).
*   **Executor:** Só comece a clicar a partir do **segundo candle** ou após o primeiro pullback.

---

## 4. Estratégias Derivadas (ORB - Opening Range Breakout)

Embora não operemos *dentro* do primeiro candle, usamos seus limites como fronteiras.

### O Setup de Rompimento da Primeira Hora (ou 15m)
Marque a Máxima e a Mínima do primeiro candle de 15 minutos ou 30 minutos.

1.  **Zona de Compra:** Se o mercado rompe e fecha **acima** da Máxima do primeiro candle.
    *   *Viés:* O dia tende a ser de Alta.
2.  **Zona de Venda:** Se o mercado rompe e fecha **abaixo** da Mínima do primeiro candle.
    *   *Viés:* O dia tende a ser de Baixa.
3.  **Zona de Armadilha (No Trade Zone):** Enquanto o preço estiver **dentro** do corpo do primeiro candle.
    *   *Viés:* Consolidação. Operar apenas nas extremidades (vender topo, comprar fundo).

---

## 5. Integração com VSA (Volume)

O primeiro candle quase sempre tem o **maior volume do dia**. A análise deve ser feita na relação Esforço vs. Resultado.

*   **Candle Pequeno com Volume Gigante:**
    *   *Diagnóstico:* Absorção. Muita briga, mas o preço não saiu do lugar.
    *   *Previsão:* O lado que for rompido vai gerar um movimento explosivo.

*   **Candle Gigante com Volume Gigante:**
    *   *Diagnóstico:* Iniciativa Profissional.
    *   *Previsão:* Continuação da tendência.

*   **Candle Gigante com Volume Baixo:**
    *   *Diagnóstico:* Vácuo de Liquidez (Fake).
    *   *Previsão:* O preço vai voltar facilmente, pois não houve barreira.

### 5.1 Volume como Fator Decisivo (não apenas confirmação)

> **Regra central:** O volume do 1º candle, comparado à média histórica dos primeiros candles do ativo, pode ser o sinal mais importante do dia — independente do formato do candle.

| Condição de Volume | Diagnóstico | Ação |
|---|---|---|
| **>3x média** (qualquer corpo) | Iniciativa real — Smart Money agindo | Operar direção do fechamento no 2º candle |
| **>3x média + corpo >70%** | Confluência máxima | Setup mais confiável do dia |
| **1.5x–3x + corpo <30%** | Absorção intensa | Aguardar rompimento da max/min do 1º candle |
| **<0.5x média** | Mercado dormindo | **VETO TOTAL** — não operar o 1º candle |
| **<0.3x média** | Ausência de liquidez | **VETO TOTAL** — não operar nem o 2º candle |
| **D0 < 0.6x volume abertura D-1** | Perda de força institucional | Reduzir tamanho para 0.5x padrão |

**Interpretação prática:** Volume alto com corpo pequeno é sinal mais forte que corpo grande com volume fraco. O corpo mostra resultado; o volume mostra o esforço real por trás.

---

## 6. O Setup de Iniciativa Profissional (A Exceção)

Quando o primeiro candle é uma **Barra de Força (Corpo > 70%)** com **Volume Climático (> 2x Média)**, temos uma "Iniciativa Profissional".

*   **O que muda?** O dia ganha um **Viés Obrigatório**.
*   **Regra de Influência:**
    1.  **Se a Iniciativa for de COMPRA:** O sistema deve ignorar vendas de reversão. Procurar apenas por Pullbacks de compra (Gift, Bandeira) ou rompimentos a favor.
    2.  **Se a Iniciativa for de VENDA:** O sistema deve ignorar compras. Foco total na venda.
    3.  **Validade:** O viés dura até que a mínima (na compra) ou máxima (na venda) do primeiro candle seja violada.

*Resumo: O Primeiro Candle define o campo de batalha, mas a guerra só começa depois.*

---

## 7. VWAP Diária vs VWAP Semanal (Como usar sem overfitting)

### Regra de Prioridade
1.  **VWAP Diária:** Referência principal para o intraday (curto prazo).
2.  **VWAP Semanal:** Filtro de contexto macro da semana.

### Interpretação Prática
*   **Preço acima da VWAP diária e semanal:** contexto comprador mais limpo.
*   **Preço abaixo da VWAP diária e semanal:** contexto vendedor mais limpo.
*   **Conflito (acima de uma e abaixo da outra):** reduzir agressividade, priorizar rompimento confirmado.

### Regra Operacional
*   **Não usar VWAP isolada como gatilho de entrada.**
*   Usar VWAP para **confirmar viés** do que o primeiro candle já mostrou em preço + volume.

---

## 8. O que o Primeiro Candle costuma respeitar

Em ordem de relevância prática:

1.  **Fechamento do dia anterior** (ímã de preço em dias de gap).
2.  **Máxima e mínima do dia anterior** (fronteiras institucionais).
3.  **Faixa do próprio 1º candle** (opening range inicial).
4.  **Preço de abertura do dia** (nível psicológico e de marcação de book).
5.  **VWAP diária** (equilíbrio do pregão).
6.  **VWAP semanal** (confluência direcional).

> Quando o mercado ignora todos esses níveis com corpo forte e volume alto, aumenta a probabilidade de **iniciativa profissional**.

---

## 9. Indicadores para analisar o Primeiro Candle

### Núcleo obrigatório (sempre)
*   **Price Action:** corpo, pavio, fechamento na máxima/mínima, relação corpo/range.
*   **Volume Relativo:** volume do 1º candle vs candle anterior e vs média dos primeiros candles.
*   **Gap:** distância da abertura vs fechamento anterior e posição dentro/fora do range de ontem.

### Filtros de contexto (fortemente recomendados)
*   **VWAP diária** (direção intraday).
*   **VWAP semanal** (alinhamento da semana).
*   **MME200 diária** — ver seção 9.1 abaixo.
*   **ATR consumido** — ver seção 9.2 abaixo.

### Complementares (opcional)
*   **Médias (9/20/50):** apenas como estrutura, não como gatilho imediato na abertura.
*   **IFR:** evitar leitura isolada no 1º candle por distorção de gap.
*   **Fluxo/Agressão:** excelente para confirmar iniciativa real quando disponível.

---

### 9.1 MME200 — Filtro de Contexto Obrigatório

A MME200 diária define o **regime de longo prazo** do ativo. Toda leitura do 1º candle deve ser condicionada por ela.

| Posição de abertura | Viés de longo prazo | Regra operacional |
|---|---|---|
| Acima da MME200 | Comprador | Dar preferência a compras; vendas exigem confluência extra |
| Abaixo da MME200 | Vendedor | Dar preferência a vendas; compras exigem confluência extra |
| Cruzando a MME200 | Indefinido | Reduzir tamanho para 0.5x; exigir 3+ confluências |

**Regra de veto:** Não operar contra a MME200. Se o 1º candle sinalizar compra mas o preço estiver abaixo da MME200, descartar o setup — exceto se houver volume >3x média + corpo >80% + gap externo inequívoco.

> **Por que isso importa na abertura:** O 1º candle forma-se em ambiente de alta volatilidade e baixa liquidez. Sem o filtro da MME200, setups contra a tendência maior têm taxa de acerto significativamente pior.

---

### 9.2 ATR — Quanto do Dia Já Foi Consumido

O ATR diário (14 períodos no gráfico diário) representa o **movimento esperado para o dia**. O range do 1º candle consome parte desse potencial.

| Range do 1º candle vs ATR | Situação | Ação |
|---|---|---|
| **<20%** do ATR | Compressão — potencial de expansão alto | Operar rompimento com stop apertado |
| **20%–40%** do ATR | Zona segura | Setup normal, alvo 1:2 viável |
| **40%–70%** do ATR | Zona saudável | Ideal — há espaço para stop + alvo |
| **>70%** do ATR | Consumo alto | Reduzir tamanho para 0.5x; ajustar alvos |
| **>100%** do ATR | Dia esgotado | **VETO** — stops tecnicamente inviáveis |

**Cálculo prático (WIN):** ATR no diário × 0,2 = ponto de alvo mínimo razoável para o 2º candle. Se o range do 1º candle já excede esse valor, a relação risco/retorno está comprometida.

---

## 10. Checklist Operacional de 60 segundos

Antes de operar o segundo candle, responder:

1.  **MME200:** preço está acima ou abaixo? Opera só a favor — se contra, precisa de confluência excepcional.
2.  **ATR consumido:** range do 1º candle é <70% do ATR? Se >100%, VETO.
3.  **Volume:** houve volume climático (>2x referência)? Se <0.3x, VETO.
4.  **Gap:** abriu fora do range de ontem ou dentro?
5.  **Força:** corpo do 1º candle é >70% do range?
6.  **Localização:** preço está acima/abaixo da VWAP diária e semanal?
7.  **Rejeição:** há pavio dominante indicando armadilha?

### Leitura Final
*   **Itens 1, 2 ou 3 com VETO:** não operar, independente dos demais.
*   **5–7 respostas alinhadas:** viés forte (buscar pullback e continuação — tamanho padrão).
*   **3–4 alinhadas:** viés moderado (reduzir mão para 0.5x e exigir confirmação).
*   **0–2 alinhadas:** cenário de ruído (sem entrada — proteção e paciência).

---

## 11. Mapa de Decisão (MVP)

*   **Primeiro candle forte + volume alto + alinhado com VWAP diária/semanal:**
    *Viés obrigatório na direção do candle até perda da mínima/máxima dele.*

*   **Primeiro candle com pavio extremo e fechamento fraco contra o gap:**
    *Tratar como possível trap; aguardar confirmação no 2º candle.*

*   **Primeiro candle pequeno + volume alto (absorção):**
    *Não antecipar; operar apenas rompimento validado da máxima/mínima.*

---

## 12. Erros mais comuns (e como evitar)

1.  **Confundir abertura com tendência do dia:** esperar confirmação do segundo candle.
2.  **Operar contra volume climático:** se houver iniciativa, evitar reversão precoce.
3.  **Ignorar contexto de gap:** gap define o "campo" do primeiro movimento.
4.  **Usar muitos indicadores simultâneos:** priorizar preço + volume + VWAP.
5.  **Aumentar risco na abertura:** spread e ruído são maiores nos primeiros minutos.

---

## 13. Conclusão

O primeiro candle não é, em geral, candle de execução. É candle de **diagnóstico**.

Ele serve para responder quatro perguntas:
1.  **O contexto permite?** (MME200 + ATR disponível + volume mínimo)
2.  **Quem tomou iniciativa?** (comprador ou vendedor)
3.  **A iniciativa é real?** (volume + corpo + contexto)
4.  **Onde está a fronteira do dia?** (máxima/mínima do primeiro candle)

Quando essas respostas estão claras, a execução do restante do pregão fica simples: operar a favor do viés até prova em contrário.