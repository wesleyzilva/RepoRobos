# Teoria Operacional: Renko (O Filtro de Ruído)

## 1. O Conceito
O gráfico de Renko é atemporal. Ele ignora o tempo e foca exclusivamente na **variação do preço**. Um novo "tijolo" (brick) só fecha se o preço andar uma quantidade específica de ticks.

*   **Vantagem:** Elimina o "ruído" lateral e a ansiedade de candles pequenos que não vão a lugar nenhum.
*   **Visual:** Mostra tendências e reversões de forma muito mais limpa e geométrica.

## 2. Configuração (O Tamanho do Tijolo)
O segredo do Renko é o tamanho (R).
*   **WIN (Índice):**
    *   **15R a 25R:** Para ver a Tendência Macro (substitui o 15m/60m).
    *   **10R a 12R:** Para Execução (substitui o 5m).
*   **WDO (Dólar):**
    *   **6R a 8R:** Para Tendência.
    *   **4R a 5R:** Para Execução.

## 3. O que procurar nas Zonas (Suporte e Resistência)

No Renko, as zonas de suporte e resistência são muito mais óbvias.

### A. Topos e Fundos Duplos (M e W)
*   **O que é:** O preço sobe, faz um tijolo de reversão, cai, sobe de novo até o *mesmo nível exato* e reverte.
*   **Sinal:** A geometria é perfeita. Se houver um pavio (sombra) no segundo toque rejeitando a zona, é venda confirmada.

### B. O "Caixote" (Lateralidade)
*   **Visual:** Tijolos alternando cores (Verde, Vermelho, Verde, Vermelho) lado a lado, sem deslocamento vertical.
*   **Ação:** Não operar dentro. Marcar o teto e o chão do caixote e operar o rompimento (quando fechar 2 tijolos da mesma cor fora da zona).

### C. Pullback na Média (O Setup de Ouro)
*   **Configuração:** Média de 20 períodos (ou 9) inserida no gráfico Renko.
*   **Cenário:** Tendência de alta (vários tijolos verdes).
*   **O Gatilho:** O preço faz 1 ou 2 tijolos vermelhos (correção) que tocam na média. O próximo tijolo fecha verde.
*   **Entrada:** Na superação desse tijolo de retomada.

## 4. Renko com Pavio (Crucial)
No Profit, ative a opção de visualizar os pavios (sombras) dos tijolos.
*   **Por que?** O tijolo mostra onde fechou, mas o pavio mostra até onde o preço foi e foi rejeitado.
*   **Sinal de Exaustão:** Um tijolo verde em uma resistência com um pavio superior longo indica que compradores tentaram romper e falharam. É o equivalente ao "Shooting Star" no candle.

## 5. Integração com o Setup (Confluência)

Use o Renko para validar as zonas marcadas no `Teoria_AnaliseTopDown.md`.

| Cenário | Gráfico de Candles (Tempo) | Gráfico de Renko (Preço) | Decisão |
| :--- | :--- | :--- | :--- |
| **Rompimento de Pivô** | Candle fecha acima da zona, mas com dúvida. | Tijolo fecha cheio e forte acima da zona. | **Confirmado.** |
| **Lateralidade** | Candles pequenos, pavios para todo lado. | Tijolos alternados (costura). | **Ficar de Fora.** |
| **Tendência** | Candles mistos (verdes e vermelhos). | Sequência de tijolos da mesma cor (Escada). | **Segurar a Operação.** |

---
*Dica:* O Renko é excelente para **Trailing Stop**. Enquanto os tijolos continuarem da mesma cor (ou fazendo fundos mais altos), você segura o trade. Sai apenas na inversão da cor.

## 6. Renko em Timeframes Maiores (Swing e Position)

O Renko é atemporal, mas podemos ajustar o tamanho do tijolo (R) para simular a visão de longo prazo (Diário, Semanal, Mensal).

### Equivalência Aproximada (B3)

| Visão (Timeframe) | Objetivo | WIN (Índice) | WDO (Dólar) | Ações (Ex: PETR4) |
| :--- | :--- | :--- | :--- | :--- |
| **Diário (1D)** | Swing Trade | **40R a 50R** | **12R a 15R** | ~0.5% a 1% do preço |
| **Semanal (1W)** | Position | **80R a 100R** | **25R a 30R** | ~2% a 3% do preço |
| **Mensal (1M)** | Investimento | **150R+** | **50R+** | ~5% a 10% do preço |

### Como Operar (Setup Fractal)
1.  **O Mapa (1W/1D):** Abra um gráfico com o Renko maior (ex: WIN 50R).
    *   Se os tijolos estão **Verdes**, a tendência macro é de alta.
    *   Se estão **Vermelhos**, é de baixa.
2.  **A Execução (Intraday):** Vá para o seu gráfico operacional (ex: WIN 12R).
    *   Só aceite sinais (Gold Signal/Pivô) na direção do Renko Maior.