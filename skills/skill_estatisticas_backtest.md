# Skill: Estatísticas de Backtest — Avaliação Rigorosa

> Como calcular, interpretar e validar métricas de backtest para robôs de trading com embasamento estatístico sólido.

---

## Pipeline Automático (caminho mais rápido)

> Antes de calcular qualquer coisa manualmente, use o script:

```bash
# 1. Exportar operações do Profit → aba Relatório de Operações → Exportar .csv
# 2. Salvar em: backtest_resultados/{ROBO}_{TF}_{PERIODO}.csv
# 3. Rodar:
python scripts/analisa_backtest_profit.py backtest_resultados/
```

O script calcula automaticamente: win rate, fator de lucro, RRR, esperança,
drawdown, sequência de perdas, melhor horário, curva de capital e comparativo
entre múltiplos robôs/TFs. Ver `backtest_resultados/README.md`.

---

## Princípios Fundamentais

1. **Sempre descontar custos reais** (spread + slippage = 25 pts/trade no WIN)
2. **Período mínimo de 90 dias** para significância estatística
3. **Mínimo de 100 trades** para confiabilidade das métricas
4. **Separar treino/validação/teste** para evitar overfitting
5. **Usar Tick a Tick** para stops curtos (≤ 150 pts no WIN)

---

## Métricas Obrigatórias

### 1. Taxa de Acerto
```
Taxa = Trades_Vencedores / Total_Trades

Mínimo aceitável: 40%
Ideal: 55%+
```

### 2. RRR Médio Realizado
```
RRR = Média_Ganhos / Média_Perdas

Mínimo: 2.0
Ideal: 2.5+
```

### 3. Fator de Lucro (Profit Factor)
```
PF = Soma_Ganhos / Abs(Soma_Perdas)

< 1.0 → sistema perdedor
1.0–1.3 → marginal (não operar)
1.3–1.7 → aceitável
> 1.7 → bom
> 2.0 → excelente
```

### 4. Esperança Matemática
```
E = (Taxa_Acerto × Media_Ganho) - (Taxa_Perda × Media_Perda)

E > 0: sistema lucrativo
Quanto maior E, mais robusto o sistema
```

### 5. Drawdown Máximo
```
DD_max = max(pico - vale) na curva de capital acumulado

< 300 pts: excelente
300–500 pts: aceitável
> 500 pts: revisar (risco alto para capital de R$ 10k)
```

### 6. Sharpe Ratio (simplificado)
```
Sharpe = Retorno_Médio / Desvio_Padrão_Retornos × √252

< 0.5: fraco
0.5–1.0: moderado
1.0–2.0: bom
> 2.0: excelente
```

---

## Código Python de Cálculo

```python
import numpy as np
import pandas as pd

def calcular_metricas_backtest(trades: list, custo_por_trade: float = 25.0) -> dict:
    """
    trades: lista de resultados em pontos, SEM descontar custos
    custo_por_trade: spread + slippage = 25 pts para WIN
    """
    t = np.array(trades) - custo_por_trade  # descontar custos
    ganhos = t[t > 0]
    perdas = t[t <= 0]
    total  = len(t)

    taxa_acerto     = len(ganhos) / total if total > 0 else 0
    media_ganho     = ganhos.mean() if len(ganhos) > 0 else 0
    media_perda     = abs(perdas.mean()) if len(perdas) > 0 else 0
    rrr_medio       = media_ganho / media_perda if media_perda > 0 else 0
    soma_ganhos     = ganhos.sum() if len(ganhos) > 0 else 0
    soma_perdas     = abs(perdas.sum()) if len(perdas) > 0 else 0
    fator_lucro     = soma_ganhos / soma_perdas if soma_perdas > 0 else float('inf')
    esperanca       = taxa_acerto * media_ganho - (1 - taxa_acerto) * media_perda
    resultado_total = t.sum()
    acum            = np.cumsum(t)
    pico_rolante    = np.maximum.accumulate(acum)
    drawdown_max    = (acum - pico_rolante).min()
    sharpe          = t.mean() / t.std() * np.sqrt(252) if t.std() > 0 else 0

    return {
        'total_trades'    : total,
        'taxa_acerto'     : f'{taxa_acerto:.1%}',
        'media_ganho_pts' : f'{media_ganho:.1f}',
        'media_perda_pts' : f'{media_perda:.1f}',
        'rrr_medio'       : f'{rrr_medio:.2f}',
        'fator_lucro'     : f'{fator_lucro:.2f}',
        'esperanca_pts'   : f'{esperanca:.1f}',
        'resultado_total' : f'{resultado_total:.0f} pts',
        'drawdown_max'    : f'{drawdown_max:.0f} pts',
        'sharpe'          : f'{sharpe:.2f}',
        'aprovado'        : (
            taxa_acerto >= 0.40 and rrr_medio >= 2.0 and
            fator_lucro >= 1.3 and esperanca > 0 and
            abs(drawdown_max) <= 500 and total >= 100
        )
    }
```

---

## Análise de Sazonalidade

```python
# Análise por horário
df_trades['hora'] = df_trades['entrada'].dt.hour
por_hora = df_trades.groupby('hora').agg(
    trades=('resultado','count'),
    acerto=('vencedor','mean'),
    media_pts=('resultado','mean')
)

# Análise por dia da semana
df_trades['dia_sem'] = df_trades['entrada'].dt.dayofweek
por_dia = df_trades.groupby('dia_sem').agg(...)

# Heatmap hora × dia
pivot = df_trades.pivot_table(
    values='resultado',
    index=df_trades['entrada'].dt.hour,
    columns=df_trades['entrada'].dt.dayofweek,
    aggfunc='mean'
)
```

---

## Checklist de Overfitting

**Sinais de alerta:**

| Sinal | Critério |
|---|---|
| Amostra pequena | < 100 trades ou < 60 dias |
| Superparametrização | > 5 parâmetros ajustáveis |
| Diferença treino/teste | resultado treino > 1.5× resultado teste |
| Fator de lucro suspeito | > 3.0 com < 150 trades |
| Taxa de acerto | > 75% (improvável sem lógica especial) |

**Método de validação:**
1. Dividir dados: 60% treino / 20% validação / 20% teste
2. Otimizar APENAS no treino
3. Validar no conjunto de validação
4. Teste final uma única vez (resultado não pode ser reusado)

---

## Critérios de Aprovação Final

| Métrica | Mínimo | ✅ |
|---|---|---|
| Total trades | ≥ 100 | |
| Período testado | ≥ 90 dias | |
| Taxa de acerto | ≥ 40% | |
| RRR médio | ≥ 2.0 | |
| Fator de lucro | ≥ 1.3 | |
| Esperança matemática | > 0 | |
| Drawdown máximo | ≤ 500 pts | |
| Sharpe Ratio | ≥ 0.8 | |
| Consistência treino/teste | diferença < 40% | |
