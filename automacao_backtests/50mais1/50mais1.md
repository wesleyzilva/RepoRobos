# Grupo 50MAIS1 (WR)

## Objetivo
Robôs focados em **taxa de acerto acima de 50%** — simplesmente garantir que o número de vitórias supera o de derrotas, mantendo saldo positivo mesmo com R:R modesto.

A lógica: se você acerta 55%+ das vezes com R:R próximo de 1:1, o saldo é positivo por matemática pura.

---

## Filosofia do Grupo

| Característica | Grupos de alta R:R | **50MAIS1** |
|----------------|--------------------|------------|
| Foco principal | Alvo grande (R:R 1:2+) | **Acertar mais vezes** |
| R:R aceito | ≥ 1:2 | 1:1 a 1:1.5 (suficiente) |
| Taxa de acerto | 50-60% | **> 55% (meta: 65%+)** |
| Volume de operações | Baixo | Médio-alto |
| Stop | Estrutural | Fixo ou ATR conservador |
| Complexidade | Alta confluência | Mais simples (menos filtros) |

> **Matemática da sobrevivência:**
> 55% de acerto com R:R 1:1 → Profit Factor = 1.22
> 60% de acerto com R:R 1:1 → Profit Factor = 1.50
> 65% de acerto com R:R 1:1 → Profit Factor = 1.86

---

## Estratégias Mais Eficientes para Alto % de Acerto

1. **Entrar contra extremo do IFR** (ZS/SO) → mercado "esticado" tende a voltar
2. **Operar com a tendência maior** (MME200) → probabilidade natural a favor
3. **Pullback em tendência** → após recuo, retoma a direção principal
4. **Candle de reversão** em suporte/resistência conhecido
5. **Breakout confirmado** (não antecipado) → aguardar fechamento do candle

---

## Indicadores Utilizados

| Indicador | Função |
|-----------|--------|
| **IFR(9)** | Extremo + retorno (gatilho principal) |
| **MME9 / MME21 / MME200** | Direção e contexto |
| **Estocástico(5,3)** | Confirmação de reversão de curto prazo |
| **Volume** | Filtra entradas falsas |
| **ATR(14)** | Stop conservador (× 1.0) |

---

## Estrutura dos Robôs WR

```
WR_01 — IFR extremo + MME200 + alvo 1:1 fixo (mais validações = alta %)
WR_02 — Estocástico crossover + tendência MME21 + stop ATR × 1.0
WR_03 — Pullback em MME20 (toque + rejeição) + alvo 1:1.2
WR_04 — IFR + MACD confirmação + alvo conservador (60-80 pts)
```

---

## Critério de Aprovação no Backtest

| Métrica | Mínimo | Ideal |
|---------|--------|-------|
| Taxa de acerto | > 55% | > 62% |
| Profit Factor | > 1.3 | > 1.7 |
| Operações totais | > 120 | > 200 |
| R:R médio | ≥ 1:1 | ≥ 1:1.3 |
| Drawdown máximo | < 20% | < 12% |

> **Nota:** este grupo tolera Profit Factor mais baixo desde que a taxa de acerto
> seja consistentemente alta. Com 65%+ acerto é possível sustentar um sistema
> mesmo com R:R 1:1.
