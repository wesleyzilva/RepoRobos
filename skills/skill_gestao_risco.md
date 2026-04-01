# Skill: Gestão de Risco — WIN B3 e WDO B3

> Parâmetros e regras de risco para operação em minicontratos brasileiros com foco em preservação de capital e maximização do RRR.

---

## Contratos de Referência

| Contrato | Valor por ponto | Tick mínimo | Garantia mínima |
|---|---|---|---|
| WIN (minicontrato índice) | R$ 0,20 | 5 pts | ~R$ 1.500 |
| WDO (minicontrato dólar) | R$ 10,00 | 0,5 pts | ~R$ 800 |

### Conversão Ticks ↔ Pontos (WIN)

| Ticks | Pontos | Valor financeiro |
|-------|--------|-----------------|
| 1 | 5 pts | R$ 1,00 |
| 16 | 80 pts | R$ 16,00 |
| 20 | 100 pts | R$ 20,00 |
| 24 | 120 pts | R$ 24,00 |
| 30 | 150 pts | R$ 30,00 |
| 40 | 200 pts | R$ 40,00 |
| 60 | 300 pts | R$ 60,00 |

---

## Regra Principal: RRR ≥ 2.0

```
Nunca entrar em uma operação onde:
  (Alvo - Entrada) < (Entrada - Stop) × 2.0

Ou seja:
  SG ≥ SL × 2.0  (sempre)
  SG ≥ SL × 2.5  (ideal)
```

**Por que 2.0?**
Com taxa de acerto de 40%, um RRR de 2.0 ainda gera esperança positiva:
```
E = (0.40 × 2.0) - (0.60 × 1.0) = 0.80 - 0.60 = +0.20 por unidade de risco
```

---

## Custos Reais a Descontar

Sempre descontar **25 pts por trade** no WIN (conservador):

| Custo | Valor |
|---|---|
| Spread entrada | 5 pts |
| Spread saída | 5 pts |
| Slippage entrada | 7–8 pts |
| Slippage saída | 7–8 pts |
| **Total mínimo** | **25 pts** |

> Para WDO: desconto mínimo de 1.0 pt por trade.

---

## Calibração do Stop Loss

### Método 1: Estrutura Geométrica (preferencial)
```
SL_Long  = Mínimo da zona de confluência - 5 pts
SL_Short = Máximo da zona de confluência + 5 pts
```

### Método 2: ATR-based
```
SL = ATR(14) × 0.8
```
ATR médio por timeframe (WINJ26, período 2024_26):
| Timeframe | ATR(14) médio | SL recomendado |
|---|---|---|
| 1 min | ~20–40 pts | 30–50 pts |
| 5 min | ~50–100 pts | 60–90 pts |
| 15 min | ~80–150 pts | 80–120 pts |
| 60 min | ~150–300 pts | 150–200 pts |

### Método 3: Range do candle de entrada
```
SL = Range_candle × 1.2
```

---

## Horários Operacionais

| Período | Horário | Observação |
|---|---|---|
| Abertura | 09:00–09:15 | ❌ Evitar — spread alto, volatilidade extrema |
| Morning | 09:15–12:00 | ✅ Ideal — maior liquidez, spreads menores |
| Almoço | 12:00–13:30 | ⚠️ Menor volume — setup deve ser muito claro |
| Tarde | 13:30–16:30 | ✅ Bom — retomada do volume |
| Fechamento | 16:30–17:40 | ⚠️ Volume caindo — apenas saídas |
| Pré-fechamento | 17:40–18:00 | ❌ Fechar tudo — spread voltando a abrir |

**Regra de stop horário no código:**
```pascal
if (Hour >= 17) and (Minute >= 45) then
begin
  ClosePosition;
  Exit;
end;
```

---

## Gestão de Posição

### Stop por tempo (barras)
- Máximo de **8 candles** em posição sem atingir SL ou SG
- Após 8 candles: fechar a mercado

### Trailing Stop (opcional)
```pascal
// Atualizar stop após X pts de ganho
if IsBought and (Close > fEntrada + fStopLoss * 1.5) then
  fStopLoss := fEntrada; // mover stop para breakeven
```

### Parciais
- Realizar 50% na primeira zona de resistência
- Trailing no restante com SL no último pivot de alta

---

## Dimensionamento de Contratos

```
Risco por trade = Capital × RiscoPorcentagem / 100
Qtd contratos   = Risco / (SL_pts × Valor_por_ponto)

Exemplo (WIN):
  Capital = R$ 10.000
  Risco   = 2% = R$ 200
  SL      = 80 pts × R$ 0,20 = R$ 16 por contrato
  Qtd     = 200 / 16 = 12 contratos
```

```pascal
// Código NTSL
fRiscoEmReais   := CapitalConta * (RiscoPorcentagem / 100);
fRiscoEmPontos  := abs(fEntrada - fStopLoss);
fQuantidade     := floor(fRiscoEmReais / (fRiscoEmPontos * 0.20));
if fQuantidade < 1 then fQuantidade := 1;
```

---

## Limites Diários

| Limite | Valor recomendado |
|---|---|
| Máximo de trades/dia | 5 |
| Perda máxima diária | 3% do capital |
| Drawdown máximo acumulado | 15% do capital |

Se qualquer limite for atingido: **parar operações no dia**.
