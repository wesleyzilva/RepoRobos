---
description: Define parâmetros ótimos de gestão de risco (SL, SG, RRR) baseados em estatísticas do ativo
---

# Prompt: Calibração de Gestão de Risco

## Contexto
Você é especialista em gestão de risco para mercados de futuros brasileiros (WIN/WDO).
Use os dados históricos para calibrar os parâmetros de risco de forma estatisticamente embasada.

## Tarefa
Calcule os parâmetros ótimos de SL e SG para o ativo **${input:ativo:WINJ26}** com base nos dados históricos.

## Dados base do WIN
- Tick mínimo: 5 pontos
- Valor por ponto: R$ 0,20 (minicontrato WIN)
- Horário de operação: 09:00 – 17:55
- Horário seguro: 09:15 – 17:40
- Spread médio: 5–10 pts (horário principal)

## Análise de range médio por timeframe

```python
import pandas as pd
import numpy as np

# Calcular ATR (Average True Range) para calibrar SL
def calcular_atr(df, periodo=14):
    df['TR1'] = df['Maximo'] - df['Minimo']
    df['TR2'] = abs(df['Maximo'] - df['Fechamento'].shift(1))
    df['TR3'] = abs(df['Minimo'] - df['Fechamento'].shift(1))
    df['TR']  = df[['TR1','TR2','TR3']].max(axis=1)
    df['ATR'] = df['TR'].rolling(periodo).mean()
    return df

# Distribuição de range por horário
df['hora'] = df['DateTime'].dt.hour
range_por_hora = df.groupby('hora')['Range'].agg(['mean','std','median','quantile'])
```

## Calibração de SL/SG

### Método 1: ATR-based
```
SL = ATR_14 × 0.8        (abaixo da estrutura mais próxima)
SG = SL × RRR_minimo     (onde RRR_minimo = 2.0)
```

### Método 2: Estrutura geométrica
```
SL = Mínimo/Máximo da zona de confluência ± 5 pts (buffer)
SG = Próxima zona de confluência oposta com RRR ≥ 2.0
```

### Método 3: Range do candle de entrada
```
SL = Range_candle_entrada × 1.2
SG = SL × RRR_minimo
```

## Validação das regras de risco

Para cada período histórico, calcular:
- Quantas vezes o SL de X pts teria sido atingido antes do SG
- Qual o RRR médio realizado (não o teórico)
- Qual a distribuição de movimentos favoráveis após sinal

## Recomendação de saída

| Timeframe | ATR médio | SL recomendado | SG (RRR 2.0) | SG (RRR 2.5) |
|---|---|---|---|---|
| 1min  | ??? pts | ??? pts | ??? pts | ??? pts |
| 5min  | ??? pts | ??? pts | ??? pts | ??? pts |
| 15min | ??? pts | ??? pts | ??? pts | ??? pts |

Preencher com dados reais dos CSV históricos.
