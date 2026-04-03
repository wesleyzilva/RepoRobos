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

## Stop Loss Mínimo — Eixo 2

> **Objetivo:** SL o menor possível que ainda seja matematicamente válido — abaixo do ponto de invalidação do setup sem ruído desnecessário.

### Hierarquia de tamanho: menor → maior

| Método | Tamanho típico (WIN 5min) | Quando usar |
|---|---|---|
| **Tick mínimo** | 5 pts | Nunca — cobre só o spread, sem margem |
| **Corpo do candle** | 20–60 pts | Scalp extremo — alta taxa de stop |
| **Wick do candle gatilho** | 30–90 pts | Padrão mínimo recomendado |
| **Estrutura do padrão** | 40–120 pts | ✅ Preferencial — alinhado ao setup |
| **ATR fracionado** | 40–150 pts | ✅ Adaptativo — responde à volatilidade |
| **Zona de confluência** | 60–200 pts | Máximo — alta qualidade mas menor RRR |

> **Regra prática:** SL mínimo válido = spread + slippage + buffer = **40 pts** no WIN
> Abaixo disso o custo de transação (25 pts) consome a margem de segurança.

---

### Método A — SL no Corpo do Candle Gatilho (mais agressivo)

```pascal
// SL imediatamente abaixo/acima do fechamento (corpo)
// Risco: pavio pode acionar stop antes de ir na direção certa

// Long:
fSL_Corpo := Open - BufferStop;   // abaixo da abertura do candle bullish
if fSL_Corpo > Close then fSL_Corpo := Open;  // ajuste se Close < Open

// Short:
fSL_Corpo := Open + BufferStop;
```

### Método B — SL no Wick (Recomendado mínimo) ✅

```pascal
// SL abaixo/acima do pavio — zona que o mercado já testou e rejeitou
// Equilíbrio: SL pequeno + ponto de invalidação claro

// Long:
fSL_Wick := Low - BufferStop;       // abaixo da mínima do candle gatilho

// Short:
fSL_Wick := High + BufferStop;      // acima da máxima do candle gatilho

// BufferStop padrão: 5 pts (1 tick)
// BufferStop conservador: 10 pts (2 ticks)
```

### Método C — SL ATR Fracionado ✅ (Adaptativo)

```pascal
// O SL se adapta à volatilidade atual do ativo
// Em períodos de baixa volatilidade: SL menor → RRR melhor
// Em períodos de alta volatilidade: SL maior → não stop por ruído

fATR := ATR(14);

// Frações testadas por timeframe (WIN):
// 5min  → SL = ATR(14) × 0.5 (ex: ATR=60 → SL=30 — cuidado, próximo do mínimo)
// 15min → SL = ATR(14) × 0.6
// 60min → SL = ATR(14) × 0.7 (mais amplo, menos ruído)

fSL_ATR := fATR * ATR_FracaoSL;    // input: ATR_FracaoSL(0.6)
if fSL_ATR < 40 then fSL_ATR := 40;   // nunca abaixo do mínimo de 40 pts

// Long:
fStopLoss := Close - fSL_ATR;

// Short:
fStopLoss := Close + fSL_ATR;
```

### Método D — SL na Estrutura do Padrão (Preferencial)

```pascal
// Cada padrão tem seu ponto natural de invalidação:
//
// Order Block:      SL = Low do candle OB - BufferStop (compra)
// FVG:              SL = fundo do gap - BufferStop (compra)
// Inside Bar:       SL = Low do candle pai - BufferStop (compra)
// Engolfo:          SL = Low[1] - BufferStop (candle engolfado)
// Pin Bar:          SL = Low - BufferStop (cauda inferior)
// Duplo Fundo:      SL = Low mínimo dos dois fundos - BufferStop

// Exemplo para Inside Bar breakout de alta:
fSL_Estrutura := Low[2] - BufferStop;   // Low do candle pai (2 períodos atrás após o IB)

// Exemplo para Order Block:
fSL_Estrutura := fZonaOBMin - BufferStop;  // Low do candle que formou o OB
```

### Comparativo — Qual método usar por setup

| Setup | Método SL | SL típico WIN 5min | RRR para Alvo 2× |
|---|---|---|---|
| Order Block premium | Estrutura (Método D) | 50–80 pts | Alvo 100–160 pts |
| FVG com F=MA ≥ 70 | Wick (Método B) | 30–60 pts | Alvo 60–120 pts |
| Inside Bar breakout | Estrutura (Método D) | 40–80 pts | Alvo 80–160 pts |
| Engolfo forte | Wick (Método B) | 40–70 pts | Alvo 80–140 pts |
| Qualquer (default) | ATR × 0.6 (Método C) | 40–90 pts | Alvo 80–180 pts |

> **Dica chave:** o SL deve ficar **do lado de fora da estrutura** do padrão.
> Um SL dentro da zona (no meio do pavio, por exemplo) tem alta probabilidade de ser acionado por ruído.

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
// ⚠️ Hour(), Minute() e Exit NÃO EXISTEM em NTSL — padrão Único correto:
if Time() >= (StopHorario_H * 10000 + StopHorario_M * 100) then
begin
  if IsBought or IsSold then ClosePosition;
  bDeveOperar := false;
end
else
  bDeveOperar := Time() >= (HoraInicioH * 10000 + HoraInicioM * 100);
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
// ⚠️ floor() NÃO EXISTE em NTSL — usar divisão e verificação manual:
fQuantidade     := fRiscoEmReais / (fRiscoEmPontos * 0.20);
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
