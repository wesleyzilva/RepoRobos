# resultsBackTestTimeframe

## Nomenclatura dos arquivos de resultado

```
mar_GRUPO_NN_descricao_timeframe.csv
```

> **Regra:** sem `vX` no nome; timeframe sempre no final antes da extensão.

**Timeframes obrigatórios:** `1min`  `2min`  `5min`  `15min`  `30min`  `60min`  `240min`

**Exemplo:**
```
mar_HOR_01_descricao_1min.csv
mar_HOR_01_descricao_60min.csv
mar_HOR_01_descricao_240min.csv
```

O robô correspondente fica em `../ntsl/` com o mesmo nome base.

## Critério de aprovação

| Métrica        | Mínimo   |
|----------------|----------|
| Taxa de acerto | > 60%    |
| Fator de lucro | > 1.3    |
| Max Drawdown   | < 20%    |
| Total trades   |  30     |

Reprovados em todos os TFs  mover para `../reprovados/`.

> Referência completa: [IFR_RSI/resultsBackTestTimeframe/README_convencao.md](../../IFR_RSI/resultsBackTestTimeframe/README_convencao.md)
