# Skill: Price Action — Base Teórica e Operacional

> Conceitos fundamentais de price action aplicados ao desenvolvimento de robôs para minicontratos brasileiros.

---

## Candle: Anatomia e Classificação

```
   |    ← Pavio superior (shadow)
  ─┼─   ← Máxima
  | |
  | |   ← Corpo (corpo = |Close - Open|)
  | |
  ─┼─   ← Mínima
   |    ← Pavio inferior (shadow)
```

### Métricas do candle

```python
corpo   = abs(Close - Open)
range_c = High - Low
corpo_pct = corpo / range_c         # % do range que é corpo
pavio_sup = High - max(Open, Close)
pavio_inf = min(Open, Close) - Low
pavio_total = pavio_sup + pavio_inf
```

### Classificação por corpo_pct

| corpo_pct | Tipo | Significado |
|---|---|---|
| < 10% | Indecisão (Doji) | Equilíbrio perfeito forças |
| 10–40% | Fraco | Pressão direcional fraca |
| 40–70% | Moderado | Tendência clara |
| > 70% | Forte | Domínio absoluto de um lado |

---

## Padrões Relevantes para Robôs

### 1. Candle de Força (Engulfing / Marubozu)
- `corpo_pct >= 60%`
- Volume acima da média
- Indica momentum institucional
- **Uso:** confirmar entrada na direção da força

### 2. Rejeição Forte (Pin Bar / Martelo / Estrela Cadente)
- `(pavio_sup + pavio_inf) / range_c >= 60%`
- Corpo < 20% do range
- Indica tentativa fracassada de movimento
- **Uso:** sinalizar reversão ou "armadilha" — aguardar confirmação

### 3. Inside Bar
- `High[0] <= High[1] AND Low[0] >= Low[1]`
- Compressão de volatilidade
- **Uso:** acumular posição antes do rompimento

### 4. Outside Bar (Candle de Absorção)
- `High[0] > High[1] AND Low[0] < Low[1]`
- Absorção total do candle anterior
- **Uso:** inversão de tendência de curto prazo

### 5. Rompimento de Máxima/Mínima
- `Close > High[1]` ou `Close < Low[1]`
- Validado com volume acima da média
- **Uso:** entrada na direção do rompimento após 2 candles confirmando

---

## Tendência e Contexto

### Identificação de tendência por pivôts

```
Tendência de ALTA:
  Pivôs de Alta: cada topo > topo anterior
  Pivôs de Baixa: cada fundo > fundo anterior
  HH → Higher High, HL → Higher Low

Tendência de BAIXA:
  LH → Lower High, LL → Lower Low

Lateral (congestão):
  Topos e fundos no mesmo nível
```

### Semáforo multi-timeframe

```
Operação LONG permitida quando:
  TF 60min = alta (série de HH e HL) ← contexto
  TF 15min = alta                     ← direção
  TF 5min  = sinal de compra          ← gatilho

Operação SHORT permitida quando:
  TF 60min = baixa
  TF 15min = baixa
  TF 5min  = sinal de venda
```

---

## Contexto Horário (WIN B3)

| Horário | Perfil | Estratégia |
|---|---|---|
| 09:00–09:30 | Alta volatilidade pós-abertura | Aguardar definição de direção |
| 09:30–11:00 | Tendência do dia formando | ✅ Melhores entradas de tendência |
| 11:00–12:00 | Volume reduzindo | Scalps somente |
| 12:00–13:30 | Almoço — volume mínimo | Evitar entradas |
| 13:30–15:30 | Retomada — NYSE abre às 14:30 | ✅ Bom para tendências |
| 15:30–17:00 | Volume crescendo | Trailing de posições abertas |
| 17:00–17:45 | Fechamento — realizar posições | Apenas saídas |

---

## Correlação com Índices Externos

| Índice | Correlação WIN | Observação |
|---|---|---|
| S&P 500 (SPX) | Alta positiva | NYSE abre 14:30 BRT — watch closely |
| Dólar (USDBRL) | Negativa moderada | WDO sobe → WIN tende a cair |
| Petróleo (WTI) | Moderada | Via Petrobras (peso ~12% no IBOV) |
| Juros (DI1) | Negativa | Juros sobem → IBOV cai |

---

## Price Action puro vs F = M × A

| Abordagem | Vantagem | Limitação |
|---|---|---|
| Price Action visual | Contexto rico, lê o mercado | Subjetivo, difícil de automatizar |
| F = M × A | Objetivo, 100% automatizável | Perde contexto qualitativo |
| **Combinação** | **Objectividade + contexto** | **Recomendada para robôs** |

A fórmula F = M × A captura o price action **quantitativamente**:
- `Massa = Corpo/Range` → intensidade direcional do candle
- `Aceleração = Volume/VolMedio` → confirmação institucional
- `Força = M × A × 100` → sinal unificado pronto para código
