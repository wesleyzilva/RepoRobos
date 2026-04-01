# Backtest Resultados

Pasta para receber os CSVs exportados do backtest do Neologica Profit.

---

## Como exportar do Profit

1. Rodar o backtest do robô
2. Na tela de resultados → aba **"Relatório de Operações"**
3. Botão **"Exportar"** (ícone de disquete / Excel)
4. Salvar como `.csv` com o nome no padrão abaixo

---

## Padrão de nome do arquivo

```
{ROBO}_{TF}_{PERIODO}.csv
```

Exemplos:
```
FORCA_SAIDA_OCO_60MIN_jan-mar2026.csv
FORCA_SAIDA_BREAKEVEN_60MIN_jan-mar2026.csv
FORCA_SAIDA_TRAILING_60MIN_jan-mar2026.csv
FORCA_SAIDA_OCO_30MIN_jan-mar2026.csv
```

---

## Como rodar a análise

```bash
# Analisar um arquivo específico:
python scripts/analisa_backtest_profit.py backtest_resultados/FORCA_SAIDA_OCO_60MIN_jan-mar2026.csv

# Analisar TODOS os CSVs da pasta e comparar:
python scripts/analisa_backtest_profit.py backtest_resultados/
```

---

## Formato esperado do CSV (Profit)

O script detecta automaticamente, mas o formato padrão do Profit é:

```
Entrada;Saída;Tipo;Qtde;Preço Entrada;Preço Saída;Resultado (pts);Resultado (R$)
02/01/2026 10:15:00;02/01/2026 11:30:00;Compra;3;125450;125680;230;138,00
```

> Se o seu export tiver colunas diferentes, abra o script e ajuste o dicionário
> `COLUMN_MAP` no início do arquivo.

---

## O que o script calcula

| Métrica | Significado |
|---|---|
| Total de trades | Amostra (mínimo 50 para ser significativo) |
| Win rate | % trades vencedores |
| Fator de lucro | soma_ganhos / soma_perdas (alvo > 1.5) |
| Esperança | resultado médio por trade após custos |
| RRR médio | ganho_médio / perda_média |
| Drawdown máximo | pior sequência consecutiva de perdas |
| Resultado líquido | descontando spread + slippage (25pts/trade) |
| Melhor horário | faixa horária com mais trades positivos |
| Curva de capital | evolução do saldo trade a trade |
