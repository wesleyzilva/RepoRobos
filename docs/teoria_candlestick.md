# Teoria Operacional: Candlestick (A Linguagem do Mercado)

## 1. O Conceito e a Origem
Os Candlesticks (Velas Japonesas) foram desenvolvidos no século 18 por Munehisa Homma para negociar contratos futuros de arroz. Diferente de um gráfico de linha simples que mostra apenas o fechamento, o Candlestick conta a **história completa** do período, revelando a emoção e a intensidade da batalha entre compradores e vendedores.

## 2. Anatomia do Candle (Decodificando a Batalha)
Cada candle é composto por 4 preços (OHLC) e duas partes visuais:

### O Corpo (Body) = A Convicção
*   É a área entre a Abertura e o Fechamento.
*   **Corpo Grande:** Indica forte convicção e fluxo direcional. Um lado dominou a sessão.
*   **Corpo Pequeno:** Indica indecisão ou equilíbrio de forças.

### As Sombras (Wicks/Shadows) = A Rejeição
*   São as linhas finas acima e abaixo do corpo.
*   **Sombra Superior:** Mostra até onde os compradores conseguiram levar o preço antes de serem esmagados pelos vendedores. (Rejeição de Alta).
*   **Sombra Inferior:** Mostra até onde os vendedores conseguiram derrubar o preço antes de entrarem compras. (Rejeição de Baixa).

---

## 3. A Psicologia por Trás dos Preços (OHLC)

1.  **Abertura (Open):** O sentimento inicial. Onde o mercado "acordou" ou iniciou o período.
2.  **Máxima (High):** O ponto de euforia máxima dos touros. Se o fechamento for longe da máxima, houve falha dos compradores.
3.  **Mínima (Low):** O ponto de pânico máximo dos ursos. Se o fechamento for longe da mínima, houve defesa dos compradores.
4.  **Fechamento (Close):** **O dado mais importante.** É o veredito final da batalha. Profissionais operam baseados no fechamento; amadores operam durante a formação.

---

## 4. Biblioteca de Padrões Essenciais

Embora existam dezenas de padrões, focamos nos que mostram **Desequilíbrio** ou **Reversão**.

### Padrões de Reversão (Mudança de Sentimento)
*   **Martelo (Hammer):** Corpo pequeno no topo, sombra inferior longa. Indica que os vendedores tentaram romper o fundo e falharam. (Sinal de Fundo).
*   **Estrela Cadente (Shooting Star):** Corpo pequeno no fundo, sombra superior longa. Indica que os compradores tentaram romper o topo e falharam. (Sinal de Topo).
*   **Engolfo (Engulfing):** O corpo do candle atual "engole" totalmente o corpo do anterior. Mostra uma virada de mão violenta.
*   **Estrela da Manhã/Noite (Morning/Evening Star):** Padrão de 3 candles.
    1.  Movimento forte.
    2.  Pausa/Indecisão (Doji ou corpo pequeno).
    3.  Movimento forte contrário.

### Padrões de Continuação (Fluxo)
*   **Marubozu (Barra de Força):** Candle de corpo grande, praticamente sem sombras. Indica urgência e agressão.
*   **Três Soldados Brancos:** Três candles de alta consecutivos, fechando perto das máximas.
*   **Gift (Presente):** Um candle de força seguido por um candle pequeno de correção que não perde a mínima do anterior.

### Padrões de Indecisão
*   **Doji:** Abertura e Fechamento iguais. Empate técnico.
*   **Spinning Top (Pião):** Corpo pequeno centralizado com sombras iguais para cima e para baixo. Briga intensa sem vencedor.

---

## 5. A Regra do Contexto (Localização é Tudo)

Um padrão de candlestick não tem poder sozinho. Onde ele aparece define sua função.

| Padrão | Localização | Interpretação | Ação no Sistema |
| :--- | :--- | :--- | :--- |
| **Martelo** | Suporte / Média de 20 | Rejeição de Fundo | **Compra (Rank A)** |
| **Martelo** | Resistência | Enforcado (Hanging Man) | **Venda (Se perder a mínima)** |
| **Martelo** | Lateralidade (Meio) | Ruído | **Ignorar** |
| **Barra de Força** | Rompendo Pivô | Breakout | **Compra (Momentum)** |
| **Barra de Força** | Esticado (Longe da Média) | Exaustão Climática | **Aguardar/Realizar** |

---

## 6. Integração com o Trade System Wesley

Para facilitar a leitura em tempo real, utilizamos a regra de coloração `fev_PriceAction` para destacar automaticamente a psicologia do candle:

*   **Força/Fluxo:** Pintados de **Ciano** (Compra) ou **Fuchsia** (Venda).
*   **Rejeição/Reversão:** Pintados de **Marrom** (Martelo) ou **Azul Royal** (Estrela).
*   **Indecisão/Pausa:** Pintados de **Laranja** (Inside Bar) ou **Branco** (Doji).

*Nota: Para detalhes técnicos da coloração, consulte `Teoria_PriceAction_TiposCandles.md`.*

---

## 7. O Clímax (Euforia e Pânico)

O Clímax é um movimento de **exaustão**. É o último suspiro de uma tendência, onde o desequilíbrio entre oferta e demanda atinge o extremo.

*   **Buying Climax (Clímax de Compra):** Ocorre no topo. O público entra comprando desesperado (FOMO) e os institucionais aproveitam a liquidez para vender (desovar posições).
*   **Selling Climax (Clímax de Venda):** Ocorre no fundo. O público vende em pânico (Stop Loss em massa) e os institucionais aproveitam para comprar barato (absorção).

### Anatomia Matemática (Como Identificar)
Profissionais não usam "olhômetro", usam métricas relativas.

1.  **Tamanho do Candle (Spread) vs. ATR:**
    *   Tem entre **200% a 300%** do tamanho do ATR ou da média dos últimos 10 candles.
    *   **Visual:** É aquela barra gigante que parece "esticar" o gráfico.

2.  **Volume (VSA):**
    *   O volume deve ser **Ultra Alto** (frequentemente o maior volume da sessão ou do dia).
    *   **Divergência:** Se o candle é gigante mas o volume é baixo, não é clímax, é "vácuo de liquidez" (trap).

3.  **Localização (Afastamento):**
    *   O preço deve estar totalmente fora das Bandas de Bollinger (2 Desvios) ou Keltner Channels.
    *   O preço está "esticado" da Média de 20 (Rubber Band Effect).

### Padrões Clássicos de Clímax
*   **A Barra de Exaustão (Blow-off):** Uma única barra gigantesca. Se a barra seguinte não conseguir renovar a máxima/mínima, a tendência acabou.
*   **O Gap de Exaustão:** Gap enorme a favor da tendência após dias de alta. O preço não consegue continuar e fecha o gap.
*   **A Rejeição de 50%:** Se o preço devolve (corrige) **mais de 50%** da barra gigante imediatamente, é Exaustão.

### Como Operar (Setup de Reversão)
Operar contra a tendência é perigoso. Siga este protocolo:
1.  **Identificação:** Candle Gigante (> 2x ATR) + Volume Climático + Longe da Média.
2.  **Gatilho:** Aguarde o preço tentar renovar a máxima do Clímax e falhar (Padrão 2B). Venda na perda da mínima.
3.  **Alvo:** Retorno à Média de 20 ou VWAP.

### Integração com Trade System
*   **Coloração PriceAction:** Candle **Ciano/Fuchsia** aparecendo longe da média após longa tendência.
*   **Alerta:** Se uma Barra Elefante (Ciano) aparece no **início** do movimento, é COMPRA. Se aparece após 3 ondas de alta, longe da média, é VENDA (Clímax).

---

## 8. Alvos Máximos por Timeframe (Execução de Day Trade)

Para transformar leitura de candle em resultado, usar teto de alvo por timeframe:

- **2 min:** buscar no máximo **80 a 200 pontos**
- **5 min:** buscar no máximo **150 a 350 pontos**
- **15 min:** buscar no máximo **300 a 700 pontos**
- **30 min:** buscar no máximo **500 a 1.000 pontos**
- **45 min:** buscar no máximo **700 a 1.400 pontos**

### Regra de gestão
- Candle forte em contexto favorável: alvo no meio/topo da faixa.
- Candle de rejeição/indecisão: alvo no piso da faixa e gestão mais curta.
- Em 2 e 5 minutos, privilegiar parcial e stop no ponto de invalidação do setup.