# Grupo TENDENCIA_SEGUIR (TS)

## Por que é Obrigatório Conhecer
"A tendência é sua amiga" — este clichê existe porque é verdade estatisticamente. Um ativo em tendência forte tem probabilidade comprovada de continuar naquela direção no curto prazo.

Trend Following puro é diferente de operar médias: aqui o objetivo é **sentar no trade e deixar o lucro correr** enquanto a tendência durar — usando trailing stop em vez de alvo fixo.

---

## Diferença: Tendência Seguir vs. Médias (grupo MEDIAS)

| Aspecto | MEDIAS | TENDENCIA_SEGUIR |
|---------|--------|-----------------|
| Foco | Cruzamento de médias | Manter posição na tendência |
| Saída | Alvo fixo ou cruzamento | Trailing stop — sem alvo |
| Trade típico | 1–3 candles | 5–20+ candles |
| Lucro quando funciona | 100–300 pts | 500–2000 pts (pegar o "trem") |
| Frequência | Média | Baixa |
| Psicologia | Fácil (tem alvo definido) | Difícil (não saber quando sair) |

---

## Filosofia — Deixar o Trade Correr

```
REGRA 1: Nunca coloque alvo fixo — use trailing stop
REGRA 2: Break-even só ativa se o trade andar > 2× o stop inicial
REGRA 3: Trailing baseado em ATR (não incomoda por ruído pequeno)
REGRA 4: Se o indicador de tendência virar → fecha imediatamente
```

---

## Indicadores Utilizados

| Indicador | Função |
|-----------|--------|
| **ADX(14)** | Força da tendência (ADX > 25 = tendência forte) |
| **MME9 / MME21 / MME200** | Direção e alinhamento |
| **ATR(14)** | Trailing stop dinâmico |
| **Parabolic SAR** | Alternativa ao trailing ATR |
| **IFR(14)** | Entrada em pullback dentro da tendência |

---

## Estrutura dos Robôs TS

```
TS_01 — ADX > 25 + alinhamento MME9/21/200 + trailing ATR × 2   (Profit .ntsl)
TS_02 — Parabolic SAR como trailing + filtro ADX                 (Profit .ntsl)
TS_03 — IFR pullback em tendência forte (IDX>30) + trailing      (Profit .ntsl)
TS_04 — MT5: Trend following NAS100 / US30 (tendências longas)   (MQL5 .mq5)
```

## Estrutura de Pastas
```
TENDENCIA_SEGUIR/
├── tendencia_seguir.md  ← este arquivo
├── codigo_fonte/        ← robôs Profit (.ntsl.txt)
└── mql5/                ← robôs MetaTrader (.mq5)
```
