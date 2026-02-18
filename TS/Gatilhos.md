# Gatilhos Operacionais por Fase de Mercado

Este documento organiza os gatilhos operacionais de acordo com o ciclo de vida do mercado (Wyckoff/Dow), permitindo escolher a ferramenta certa para o momento certo.

## 1. Fase de Lateralidade (Acumulação/Consolidação)
*Característica:* Mercado preso entre suporte e resistência. Baixa volatilidade ou "rabiscos".
*Objetivo:* Comprar barato (fundo) e vender caro (topo) ou aguardar o rompimento.

*   **Gatilho A: Armadilha de Fundo (Spring/Shakeout)**
    *   **Sinal:** O preço perde o suporte, entra volume alto (VSA Verde), mas fecha dentro da lateralidade.
    *   **Ação:** Compra na superação da máxima do candle que falhou.
    *   **Retorno Esperado:** Alto (Stop curto no fundo, alvo no topo da lateralidade).

*   **Gatilho B: Rompimento de Volatilidade (Keltner Squeeze)**
    *   **Sinal:** As bandas de Keltner se estreitam (Squeeze). Um candle de força (Ciano) fecha fora da banda.
    *   **Ação:** Compra a favor do rompimento.
    *   **Retorno Esperado:** Explosivo (Início de tendência).

## 2. Fase de Tendência (Markup/Markdown)
*Característica:* Topos e fundos direcionais. Médias inclinadas.
*Objetivo:* Seguir o fluxo. Não tentar adivinhar topo/fundo.

*   **Gatilho A: Gold Signal (O Clássico)**
    *   **Sinal:** Candle de força a favor da Média de 20.
    *   **Ação:** Entrada na violação.
    *   **Retorno Esperado:** Médio/Alto (Alta probabilidade de acerto).

*   **Gatilho B: Pullback na VWAP**
    *   **Sinal:** Preço retorna à VWAP e deixa gatilho de Price Action (Martelo/Inside Bar).
    *   **Ação:** Entrada na retomada a favor da tendência.
    *   **Retorno Esperado:** Consistente (Defesa institucional).

*   **Gatilho C: Rompimento de Pivô Estrutural**
    *   **Sinal:** Rompimento da cabeça do pivô após correção.
    *   **Ação:** Compra stop ou no fechamento.
    *   **Retorno Esperado:** Seguro (Stop técnico claro).

## 3. Fase de Distribuição (Topo de Mercado)
*Característica:* Volatilidade aumenta no topo, mas o preço não sobe. Pavios superiores longos.
*Objetivo:* Identificar exaustão e preparar para reversão.

*   **Gatilho A: Upthrust (Armadilha de Topo)**
    *   **Sinal:** Rompimento de topo anterior com volume alto, mas fechamento baixo (VSA Vermelho).
    *   **Ação:** Venda na perda da mínima.
    *   **Retorno Esperado:** Muito Alto (Pega o início da queda).

*   **Gatilho B: Falha de Topo (Padrão 2B)**
    *   **Sinal:** Preço tenta renovar máxima e falha, fechando abaixo do topo anterior.
    *   **Ação:** Venda.

## 4. Fase de Reversão (Morte da Tendência)
*Característica:* Quebra de estrutura.
*Objetivo:* Virar a mão.

*   **Gatilho A: Rompimento de LTA/LTB com Força**
    *   **Sinal:** Candle de força cruzando a linha de tendência.
    *   **Ação:** Venda/Compra no reteste da linha (Pullback na LTA rompida).

---

## Matriz de Combinação e Retorno (Scorecard)

Para avaliar qual o melhor trade, use esta tabela de pontuação. Só opere se a pontuação for **>= 3**.

| Fator | Peso 1 (Fraco) | Peso 2 (Médio) | Peso 3 (Forte) |
| :--- | :--- | :--- | :--- |
| **Fase do Mercado** | Lateralidade (Meio) | Fim de Tendência | Início de Tendência (Rompimento/Pivô 1) |
| **Localização** | No meio do nada | Perto de Média/VWAP | Em Suporte/Resistência Majoritário (Rank 5) |
| **Gatilho (Candle)** | Inside Bar / Doji | Engolfo / Harami | **Gold Signal / Shakeout VSA** |
| **Contexto Macro** | Contra S&P/DXY | Neutro | A favor de S&P/DXY |

### Combinações de Ouro (Melhor Retorno Ajustado ao Risco)

1.  **O "Sniper de Fundo" (Retorno 5:1)**
    *   **Fase:** Lateralidade/Acumulação.
    *   **Localização:** Suporte Semanal.
    *   **Gatilho:** VSA Shakeout (Verde) + Martelo.
    *   **Por que:** Stop curtíssimo (na mínima da armadilha), alvo longo (topo do canal ou projeção de tendência).

2.  **O "Surfista de Tendência" (Retorno 2:1, Alta Taxa de Acerto)**
    *   **Fase:** Tendência (Markup).
    *   **Localização:** Toque na VWAP + Média de 20.
    *   **Gatilho:** Gold Signal (Amarelo).
    *   **Por que:** Você tem a inércia e os institucionais a seu favor. É o trade de "pagar contas".

3.  **O "Caçador de Topo" (Retorno 3:1, Risco Médio)**
    *   **Fase:** Distribuição.
    *   **Localização:** Resistência de Ajuste ou VWAP Mensal.
    *   **Gatilho:** Upthrust (VSA Vermelho) ou Quebra de LTA.
    *   **Por que:** Se acertar a reversão, pega todo o movimento de queda.
```

<!--
[PROMPT_SUGGESTION]Gostaria de um exemplo prático passo a passo de um trade usando o "Rompimento de Pivô" no S&P 500, incluindo onde colocar o stop e o alvo.[/PROMPT_SUGGESTION]
[PROMPT_SUGGESTION]Como identificar falsos rompimentos de LTA/LTB usando o volume (VSA)?[/PROMPT_SUGGESTION]
-->