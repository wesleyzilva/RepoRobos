# Teoria Operacional: Price Action Puro (Leitura de Candles)

## 1. O Conceito
Price Action é a habilidade de ler a psicologia do mercado através da formação bruta dos preços, sem a necessidade de indicadores atrasados. Cada candle conta uma história de batalha entre compradores e vendedores.

O foco aqui não é apenas o "desenho" do candle, mas **onde** ele aparece e **como** ele fecha.

## 2. Lógica Operacional (Gatilhos)
Buscamos identificar desequilíbrios momentâneos que geram oportunidades de alta probabilidade.

### Padrões de Continuação (Força)
*   **Barra de Ignição (Elephant Bar):** Um candle com corpo grande, pouco pavio e fechamento próximo à máxima/mínima. Indica que um lado assumiu o controle total.
*   **Gift (Presente):** Após uma barra de força, o mercado faz um pequeno recuo (pullback) que não perde a mínima da barra anterior. É um "presente" para entrar a favor da tendência.

### Padrões de Reversão (Exaustão/Rejeição)
*   **Pinbar (Martelo/Estrela):** Um candle com corpo pequeno e pavio longo. O pavio mostra que o preço foi até uma região e foi violentamente rejeitado.
*   **Engolfo:** Um candle que "engole" completamente o corpo do candle anterior, mostrando uma virada de mão súbita dos participantes.

## 3. Regra de Coloração (O Semáforo)
A regra `fev_PriceAction.ntsl` traduz a psicologia dos candles em cores visuais.

### 🔵 CIANO / 🟣 FUCHSIA = FLUXO FORTE (Momentum)
*   **Ciano (RGB 0, 255, 255):** Barra de Força Compradora (Marubozu/Elefante). Corpo grande (>70% do range), fechamento muito próximo à máxima (pavio superior < 20%).
*   **Fuchsia (RGB 255, 0, 255):** Barra de Força Vendedora. Corpo grande (>70% do range), fechamento muito próximo à mínima (pavio inferior < 20%).
*   **Significado:** Urgência e Agressão Pura. O mercado quer ir rápido para uma direção e não aceita rejeição.

### 🔵 AZUL ROYAL / 🟤 MARROM = EXAUSTÃO (Rejeição)
*   **Azul Royal (RGB 65, 105, 225):** Exaustão de Compra. Candle com pavio superior muito longo (Shooting Star/Estrela).
*   **Marrom (RGB 165, 42, 42):** Exaustão de Venda. Candle com pavio inferior muito longo (Hammer/Martelo).
*   **Significado:** Armadilha. O preço tentou romper e falhou. Possível reversão.

### 🟢 VERDE / 🔴 VERMELHO = PADRÃO TÉCNICO
*   **Verde (RGB 0, 255, 0):** Padrão clássico de compra (ex: Engolfo de Alta ou Rompimento de Inside Bar para cima).
*   **Vermelho (RGB 255, 0, 0):** Padrão clássico de venda (ex: Engolfo de Baixa ou Rompimento de Inside Bar para baixo).

### 🟡 AMARELO = GOLD SIGNAL (Confluência Total)
*   **Cor:** Amarelo (RGB 255, 255, 0).
*   **Condição:** Barra de Força Pura (Ciano/Fuchsia) + A favor da Média Móvel de 20 + **Continuação** (Candle anterior também foi a favor).
*   **Significado:** O "Sinal de Ouro". Une a força do candle, a inércia da tendência e a confirmação de fluxo contínuo.

### ⚫ CINZA = NEUTRO
*   **Cor:** Cinza (RGB 105, 105, 105).
*   **Condição:** Candles pequenos, dojis sem direção ou lateralidade.
*   **Ação:** Não fazer nada.

## 4. Gerenciamento

*   **Entrada:**
    *   **Agressiva:** No fechamento do candle de sinal (Ciano/Fuchsia/Amarelo).
    *   **Conservadora:** No rompimento da máxima (compra) ou mínima (venda) do candle de sinal.
*   **Stop Loss:**
    *   Tecnicamente, na extremidade oposta do candle de sinal.
*   **Alvo:**
    *   Projeção de 100% do tamanho do candle de sinal (Risco:Retorno 1:1) ou até a próxima zona de liquidez (Suporte/Resistência).

---
*Estratégia baseada em Leitura de Candles (Al Brooks / Steve Nison)*

## 5. Expansão de Conhecimento: Contexto é Rei

Um Martelo (Marrom) não significa compra automática. O contexto define a qualidade do sinal.

### A. Localização
*   Um **Martelo** em um **Suporte** é um sinal de compra (Rank 5).
*   Um **Martelo** no meio de uma lateralidade é ruído (Rank 0).

### B. Tamanho Relativo
*   Candles muito pequenos em relação à média (ATR) indicam falta de interesse.
*   Candles gigantescos (Climáticos) podem indicar exaustão final, não força. O ideal é a barra de força que sai de uma contração.

### C. Inside Bars (Harami)
*   Representam indecisão ou pausa. O rompimento de uma Inside Bar a favor da tendência prévia é um setup poderoso de continuidade.

---

## 6. Alvos Máximos por Timeframe (Price Action)

Para evitar devolução de lucro, usar teto de objetivo por timeframe:

- **2 min:** buscar no máximo **80 a 200 pontos**
- **5 min:** buscar no máximo **150 a 350 pontos**
- **15 min:** buscar no máximo **300 a 700 pontos**
- **30 min:** buscar no máximo **500 a 1.000 pontos**
- **45 min:** buscar no máximo **700 a 1.400 pontos**

### Aplicação prática
- Sinal de força (Ciano/Fuchsia) com contexto limpo: trabalhar no meio/topo da faixa.
- Sinal de exaustão/rejeição (Azul/Marrom): priorizar alvo curto (piso da faixa).
- Em 2m e 5m, após parcial, proteger com stop técnico para não devolver ganho.

# Teoria Operacional: Tipos de Candles, Tamanhos e Nomes (Classificação Rigorosa)

## 1. O Princípio da Validação pelo Anterior
Um candle sozinho não significa nada. Para um padrão ser válido, ele precisa interagir com o candle anterior.
*   Um **Martelo** só é um sinal de reversão se aparecer após um movimento de **baixa**.
*   Um **Engolfo** só existe se houver algo para ser engolido (um candle oposto anterior).

Esta teoria classifica os candles em 4 famílias, cada uma com uma cor distinta para identificação imediata.

## 2. Família de Reversão (Sinais de Exaustão)
Indicam que a força dominante anterior falhou.

### 🟤 Martelo (Hammer) - Rejeição de Fundo
*   **Cor:** **Marrom** (RGB 165, 42, 42).
*   **Anatomia:** Corpo pequeno (no terço superior), pavio inferior longo (> 2x o corpo), pouco ou nenhum pavio superior.
*   **Contexto Obrigatório:** O candle anterior deve ser **Negativo** (Vendedor).
*   **Psicologia:** Os vendedores tentaram empurrar o preço para baixo (continuar a queda anterior), mas falharam e o preço fechou perto da máxima.

### 🔵 Estrela Cadente (Shooting Star) - Rejeição de Topo
*   **Cor:** **Azul Royal** (RGB 65, 105, 225).
*   **Anatomia:** Corpo pequeno (no terço inferior), pavio superior longo (> 2x o corpo), pouco ou nenhum pavio inferior.
*   **Contexto Obrigatório:** O candle anterior deve ser **Positivo** (Comprador).
*   **Psicologia:** Os compradores tentaram romper o topo, mas foram rejeitados violentamente.

## 3. Família de Força (Sinais de Ataque)
Indicam que um lado assumiu o controle absoluto.

### 🟢 Engolfo de Alta (Bullish Engulfing)
*   **Cor:** **Verde** (RGB 0, 255, 0).
*   **Anatomia:** Corpo fecha acima da máxima do candle anterior e abre abaixo (ou igual) ao fechamento anterior. Envolve todo o corpo prévio.
*   **Contexto Obrigatório:** O candle anterior deve ser **Negativo**.
*   **Psicologia:** Virada de mão total. A força compradora anulou a venda anterior.

### 🔴 Engolfo de Baixa (Bearish Engulfing)
*   **Cor:** **Vermelho** (RGB 255, 0, 0).
*   **Anatomia:** Corpo fecha abaixo da mínima do candle anterior. Envolve todo o corpo prévio.
*   **Contexto Obrigatório:** O candle anterior deve ser **Positivo**.
*   **Psicologia:** Virada de mão total. A força vendedora anulou a compra anterior.

### 🔵 Ciano / 🟣 Fuchsia (Barras de Ignição)
*   **Cor:** **Ciano** (Compra) / **Fuchsia** (Venda).
*   **Anatomia:** Corpo grande (> 70% do range total). Fechamento na extremidade (sem pavio contra).
*   **Contexto:** Rompe a máxima/mínima do anterior com deslocamento.

## 4. Família de Indecisão (Pausas)
Indicam equilíbrio ou acumulação de energia.

### 🟠 Inside Bar (Harami)
*   **Cor:** **Laranja** (RGB 255, 140, 0).
*   **Anatomia:** A máxima é menor que a máxima anterior E a mínima é maior que a mínima anterior. O candle está "grávido" (contido).
*   **Contexto:** Qualquer.
*   **Psicologia:** O mercado contraiu a volatilidade. Geralmente precede um movimento explosivo (Breakout).
*   **Operação:** Marcar a máxima e mínima do candle "Mãe" (o anterior) e operar o rompimento.

### ⚪ Doji (Incerteza Total)
*   **Cor:** **Branco** (RGB 255, 255, 255).
*   **Anatomia:** Abertura e Fechamento praticamente iguais (Corpo < 10% do range).
*   **Contexto:** Qualquer.
*   **Psicologia:** Empate técnico. Ninguém ganhou a batalha naquele período.

## 5. Tabela Resumo de Tamanhos

| Tipo | Tamanho do Corpo | Tamanho do Pavio | Direção Anterior | Cor |
| :--- | :--- | :--- | :--- | :--- |
| **Martelo** | Pequeno (< 40%) | Grande (Inferior) | Baixa (Vermelho) | 🟤 Marrom |
| **Estrela** | Pequeno (< 40%) | Grande (Superior) | Alta (Verde) | 🔵 Azul Royal |
| **Engolfo Alta** | Grande | Irrelevante | Baixa (Vermelho) | 🟢 Verde |
| **Engolfo Baixa** | Grande | Irrelevante | Alta (Verde) | 🔴 Vermelho |
| **Inside Bar** | Irrelevante | Irrelevante | N/A (Contido) | 🟠 Laranja |
| **Doji** | Nulo (< 10%) | Variável | N/A | ⚪ Branco |

# Teoria Operacional: Price Action Avançado (Estrutura e Ciclos)

## 1. Os 3 Ciclos do Mercado (Al Brooks)
O mercado não se move de forma aleatória. Ele alterna entre fases de desequilíbrio (tendência) e equilíbrio (lateralidade). Identificar o ciclo é mais importante que o candle.

### Fase 1: Rompimento (Breakout / Spike)
*   **Característica:** Movimento vertical forte. Candles grandes da mesma cor, poucos pavios, gaps abertos.
*   **Psicologia:** Urgência. Todos concordam com o preço.
*   **Ação:** Entrar a mercado ou em pullbacks curtos. **Não operar contra.**

### Fase 2: Canal (Channel)
*   **Característica:** A força diminui, mas a direção continua. O preço se move dentro de linhas paralelas. Aparecem correções mais profundas e sobreposições de barras.
*   **Psicologia:** O consenso diminui, mas a inércia mantém o movimento.
*   **Ação:** Comprar correções (Bandeiras) na tendência de alta. Começar a realizar lucros parciais.

### Fase 3: Lateralidade (Trading Range)
*   **Característica:** O preço anda de lado entre um suporte e uma resistência. O mercado "concorda" com um preço justo.
*   **Psicologia:** Incerteza. Compradores acham barato no fundo, vendedores acham caro no topo.
*   **Ação:** Comprar baixo, Vender alto. **Evitar rompimentos** (80% dos rompimentos de lateralidade falham).

## 2. Contagem de Barras (Setup de Correção)
Uma técnica objetiva para cronometrar a entrada em tendências, evitando entrar na "faca caindo".

*   **Conceito:** Em uma tendência de alta, cada vez que o preço perde a mínima do candle anterior, inicia-se uma contagem de correção.
*   **H1 (High 1):** A primeira vez que o mercado tenta retomar a alta (rompe a máxima de um candle anterior). Geralmente é uma armadilha em tendências fortes.
*   **H2 (High 2):** A segunda tentativa de retomada. Se o mercado tentou cair duas vezes e falhou, a probabilidade de subir é alta.
    *   **Setup:** Em tendência de alta, ignore a primeira sinalização de compra (H1). Aguarde o preço tentar cair de novo e, se romper a máxima novamente (H2), entre comprando.

## 3. Armadilhas de Rompimento (Traps)
O combustível dos movimentos fortes são os Stops dos traders presos.

### Padrão 2B (Trader Vic) - A Falha de Topo/Fundo
Um dos setups mais poderosos de reversão.
1.  **Setup:** O preço faz um Topo (T1). Corrige. Tenta romper o Topo anterior (T2).
2.  **A Armadilha:** O preço supera a máxima de T1 por poucos ticks, mas perde força e **fecha abaixo** da máxima de T1.
3.  **Gatilho:** Venda na perda da mínima do candle que tentou romper e falhou.
4.  **Lógica:** Quem comprou o rompimento está preso e vai estopar (vender) assim que o preço virar, acelerando a queda.

## 4. Movimentos Medidos (Measured Moves)
O mercado busca simetria geométrica.

*   **Leg 1 = Leg 2:** Em tendências saudáveis, a perna de alta após uma correção (Pivô) tende a ter o mesmo tamanho (amplitude) da perna anterior.
*   **Projeção de Range:** Se o mercado rompe uma lateralidade de 500 pontos de altura, o alvo inicial é projetar esses 500 pontos na direção do rompimento.

## 5. Fusão de Candles (Blended Candles)
Às vezes, um padrão não é óbvio em um único candle, mas somando dois, a verdade aparece.

*   **Como fazer:**
    *   Abertura = Abertura do 1º candle.
    *   Fechamento = Fechamento do 2º candle.
    *   Máxima = A maior máxima entre os dois.
    *   Mínima = A menor mínima entre os dois.

*   **Exemplo Prático:**
    *   Candle 1: Verde grande (Força).
    *   Candle 2: Vermelho grande que fecha abaixo da abertura do 1 (Engolfo de Baixa).
    *   **Resultado da Soma:** Um candle com corpo pequeno na parte inferior e um pavio superior enorme. Ou seja, um **Shooting Star (Estrela Cadente)**.
    *   **Conclusão:** Engolfo e Shooting Star são a mesma coisa, apenas em tempos gráficos diferentes.

---
*Expansão baseada em Al Brooks (Price Action Trends/Ranges) e Victor Sperandeo (Trader Vic)*