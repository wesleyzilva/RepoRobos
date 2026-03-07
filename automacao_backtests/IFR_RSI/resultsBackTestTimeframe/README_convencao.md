# resultsBackTestTimeframe — Convenção de Nomenclatura

## Estrutura da pasta

Esta pasta armazena os resultados de backtest organizados por **robô × timeframe**.
Cada robô deve ter um arquivo de resultado por timeframe testado.

---

## Convenção de nome dos arquivos de resultado

```
TFmin_mes_GRUPO_NUM_vVERSAO_descricao.csv
```

| Campo       | Exemplo          | Descrição                              |
|-------------|-----------------|----------------------------------------|
| `TFmin`     | `60min`          | Timeframe testado (ver lista abaixo)   |
| `mes`       | `mar`            | Prefixo do ciclo mensal                |
| `GRUPO_NUM` | `IFR_04`         | Grupo + número sequencial do robô      |
| `vVERSAO`   | `v1`             | Versão do robô                        |
| `descricao` | `bandas_dinamicas` | Tema/estratégia em snake_case        |

### Exemplo completo para um robô:
```
1min_mar_IFR_04_v1_bandas_dinamicas.csv
2min_mar_IFR_04_v1_bandas_dinamicas.csv
5min_mar_IFR_04_v1_bandas_dinamicas.csv
15min_mar_IFR_04_v1_bandas_dinamicas.csv
30min_mar_IFR_04_v1_bandas_dinamicas.csv
60min_mar_IFR_04_v1_bandas_dinamicas.csv
240min_mar_IFR_04_v1_bandas_dinamicas.csv
```

---

## Timeframes obrigatórios por robô

| TF      | Código    | Observação                              |
|---------|-----------|----------------------------------------|
| 1 min   | `1min`    | Scalping / alta frequência             |
| 2 min   | `2min`    | Intermediário curto                    |
| 5 min   | `5min`    | Intradiário padrão                     |
| 15 min  | `15min`   | Curto prazo consolidado                |
| 30 min  | `30min`   | Melhor equilíbrio ruído/sinal          |
| 60 min  | `60min`   | **Referência principal WIN**           |
| 240 min | `240min`  | Swing / tendência maior                |

> Usar o máximo de histórico disponível no Profit (mínimo 2 anos, ideal 5 anos).

---

## Colunas esperadas no CSV

```
Timeframe,TaxaAcerto,TotalTrades,FinanceiroBruto,FinanceiroLiq,MaxDrawdown,FatorLucro,MediaGanho,MediaPerda
60min,67.5,120,R$8500,R$7200,R$1200,2.3,R$180,R$82
```

---

## Robô correspondente

O arquivo `.ntsl` do robô fica em `../ntsl/` com o **mesmo nome base** (sem o prefixo do timeframe):
```
../ntsl/mar_IFR_04_bandas_dinamicas_60min.ntsl
         ↓ resultados gerados ↓
mar_IFR_04_bandas_dinamicas_60min.csv
...
```

---

## Critério de aprovação / reprovação

| Métrica          | Mínimo aceito | Ideal         |
|------------------|---------------|---------------|
| Taxa de acerto   | > 60%         | > 65%         |
| Fator de lucro   | > 1.3         | > 1.8         |
| Max Drawdown     | < 20% capital | < 10%         |
| Total de trades  | ≥ 30          | ≥ 80          |
| R/R médio        | ≥ 1:1.5       | ≥ 1:2         |

Robôs **reprovados** em todos os timeframes vão para `../reprovados/`.
