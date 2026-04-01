---
description: Calcula métricas completas de backtest para avaliar um robô NTSL
---

# Prompt: Estatísticas de Backtest

## Pipeline automático (caminho mais rápido)

Se tiver CSV exportado do Profit:
```bash
# Salvar CSV em backtest_resultados/{ROBO}_{TF}_{PERIODO}.csv
python scripts/analisa_backtest_profit.py backtest_resultados/
```
Ver instruções completas em `backtest_resultados/README.md`.

---

## Contexto (análise manual quando não há CSV)
Você é especialista em estatística de trading. Calcule as métricas de desempenho de um backtest com rigor matemático, sempre aplicando custos reais de mercado.

## Tarefa
Analise os resultados do robô **${input:nome_robo:ROB_CONFLUENCIA_V1}** e calcule todas as métricas de desempenho.

## Custos a descontar obrigatoriamente
```
Spread:    10 pts por trade (5 entrada + 5 saída)
Slippage:  15 pts por trade
Total:     25 pts por trade
```

## Métricas obrigatórias

```python
import numpy as np

# Dados de entrada: lista de trades [resultado_pts, ...] JÁ com custos descontados

def calcular_metricas(trades: list) -> dict:
    ganhos  = [t for t in trades if t > 0]
    perdas  = [t for t in trades if t <= 0]
    total   = len(trades)

    taxa_acerto      = len(ganhos) / total if total > 0 else 0
    media_ganho      = np.mean(ganhos) if ganhos else 0
    media_perda      = abs(np.mean(perdas)) if perdas else 0
    rrr_medio        = media_ganho / media_perda if media_perda > 0 else 0
    fator_lucro      = sum(ganhos) / abs(sum(perdas)) if perdas else float('inf')
    esperanca_mat    = taxa_acerto * media_ganho - (1 - taxa_acerto) * media_perda
    resultado_total  = sum(trades)
    resultado_acum   = np.cumsum(trades)
    drawdown_max     = np.min(resultado_acum - np.maximum.accumulate(resultado_acum))
    sharpe           = np.mean(trades) / np.std(trades) * np.sqrt(252) if np.std(trades) > 0 else 0

    return {
        'total_trades'   : total,
        'taxa_acerto'    : f'{taxa_acerto:.1%}',
        'rrr_medio'      : f'{rrr_medio:.2f}',
        'fator_lucro'    : f'{fator_lucro:.2f}',
        'esperanca_mat'  : f'{esperanca_mat:.1f} pts',
        'resultado_total': f'{resultado_total:.0f} pts',
        'drawdown_max'   : f'{drawdown_max:.0f} pts',
        'sharpe'         : f'{sharpe:.2f}',
    }
```

## Critérios de aprovação
| Métrica | Mínimo | Ideal |
|---|---|---|
| Taxa de acerto | ≥ 40% | ≥ 55% |
| RRR médio | ≥ 2.0 | ≥ 2.5 |
| Fator de lucro | ≥ 1.3 | ≥ 1.8 |
| Esperança matemática | > 0 | > 20 pts |
| Drawdown máximo | ≤ 500 pts | ≤ 300 pts |
| Sharpe Ratio | ≥ 0.8 | ≥ 1.2 |
| Total de trades | ≥ 100 | ≥ 200 |

## Análise de sazonalidade
Separar por:
- Horário: abertura (09:00–10:00), meio do dia (10:00–15:00), fechamento (15:00–17:45)
- Dia da semana: segunda–sexta
- Mês do ano

## Alertas de overfitting
- Período de teste < 60 dias → **ALERTA: amostra insuficiente**
- Total de trades < 100 → **ALERTA: baixa significância estatística**
- Diferença resultado treino/teste > 40% → **ALERTA: possível overfitting**

## Saída
Retornar tabela completa de métricas + recomendação de aprovação/rejeição com justificativa.
