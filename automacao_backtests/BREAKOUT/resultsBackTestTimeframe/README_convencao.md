# resultsBackTestTimeframe

## Nomenclatura dos arquivos de resultado

```
TFmin_mes_GRUPO_NUM_vVERSAO_descricao.csv
```

**Timeframes obrigatórios:** `1min`  `2min`  `5min`  `15min`  `30min`  `60min`  `240min`

**Exemplo:**
```
1min_mar_MED_01_v1_cruzamento_mme9_mme21.csv
60min_mar_MED_01_v1_cruzamento_mme9_mme21.csv
240min_mar_MED_01_v1_cruzamento_mme9_mme21.csv
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
