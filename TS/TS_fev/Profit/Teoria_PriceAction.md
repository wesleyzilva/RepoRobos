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