# Estratégias de Stop — WIN B3 (Referência Consolidada)

> Referência rápida para configuração de stops no Profit.
> Ver também: [skills/skill_gestao_risco.md](../skills/skill_gestao_risco.md)

---

## Conversão Rápida (WIN)

| Ticks | Pontos | R$ por contrato |
|-------|--------|-----------------|
| 16 | 80 | R$ 16 |
| 20 | 100 | R$ 20 |
| 24 | 120 | R$ 24 |
| 30 | 150 | R$ 30 |
| 40 | 200 | R$ 40 |
| 60 | 300 | R$ 60 |

---

## 1. OCO — One Cancels Other

Stop + Alvo enviados juntos. O primeiro que bater cancela o outro.

**Configuração sugerida para WIN:**

| TF | Stop | Alvo | BreakEven | Trailing |
|----|------|------|-----------|---------|
| 15min | 20 ticks (100 pts) | 40 ticks (200 pts) | 16 ticks (80 pts) | 20 ticks (100 pts) |
| 30min | 30 ticks (150 pts) | 60 ticks (300 pts) | 20 ticks (100 pts) | 24 ticks (120 pts) |
| 60min | 40 ticks (200 pts) | 80 ticks (400 pts) | 24 ticks (120 pts) | 30 ticks (150 pts) |

**Código NTSL:**
```pascal
// OCO: envia stop + alvo a cada barra (Profit mantém a última ativa)
if IsBought then
begin
  SellToCoverStop (BuyPrice - StopPontos * MinPriceIncrement,
                   BuyPrice - StopPontos * MinPriceIncrement - 5 * MinPriceIncrement,
                   Contratos);
  SellToCoverLimit(BuyPrice + AlvoPontos * MinPriceIncrement, Contratos);
end;
if IsSold then
begin
  BuyToCoverStop (SellPrice + StopPontos * MinPriceIncrement,
                  SellPrice + StopPontos * MinPriceIncrement + 5 * MinPriceIncrement,
                  Contratos);
  BuyToCoverLimit(SellPrice - AlvoPontos * MinPriceIncrement, Contratos);
end;
```

---

## 2. Breakeven (AutoBreakEven)

Move o stop para o preço de entrada após N pontos a favor → risco zero.

**Quando usar:** 30min — protege capital após confirmação, mantém alvo aberto.

**Lógica:**
- Entrada ocorre no candle de força
- Preço anda `BreakevenGatilho` a favor → stop vai para entrada
- Alvo fixo permanece

**Código NTSL:**
```pascal
var
  bBreakevenOn : boolean;

// No corpo do begin:
if (not IsBought) and (not IsSold) then bBreakevenOn := false;

if IsBought then
begin
  if (not bBreakevenOn) and (Close >= BuyPrice + BreakevenPontos * MinPriceIncrement) then
    bBreakevenOn := true;

  if bBreakevenOn then
    fStop := BuyPrice                                       // risco zero
  else
    fStop := BuyPrice - StopInicial * MinPriceIncrement;

  SellToCoverStop (fStop, fStop - 5 * MinPriceIncrement, Contratos);
  SellToCoverLimit(BuyPrice + AlvoPontos * MinPriceIncrement, Contratos);
end;
```

**Configuração sugerida WIN:**
- `StopInicial` = 100 pts (20 ticks)
- `BreakevenGatilho` = 80 pts (16 ticks) → após 80 pts a favor, stop vai para entrada
- `AlvoPontos` = 300 pts (60 ticks)

---

## 3. Trailing Stop

Stop acompanha o preço a uma distância fixa. Sem alvo fixo — deixa o movimento correr.

**Quando usar:** 60min em tendência clara. ❌ Evitar em 15min (muito ruído).

**Código NTSL:**
```pascal
var
  fMelhorPreco : float;

// No corpo do begin:
if (not IsBought) and (not IsSold) then fMelhorPreco := 0;

if IsBought then
begin
  if (fMelhorPreco = 0) or (High > fMelhorPreco) then fMelhorPreco := High;
  fTrailStop := fMelhorPreco - TrailPontos * MinPriceIncrement;
  SellToCoverStop(fTrailStop, fTrailStop - 5 * MinPriceIncrement, Contratos);
end;
if IsSold then
begin
  if (fMelhorPreco = 0) or (Low < fMelhorPreco) then fMelhorPreco := Low;
  fTrailStop := fMelhorPreco + TrailPontos * MinPriceIncrement;
  BuyToCoverStop(fTrailStop, fTrailStop + 5 * MinPriceIncrement, Contratos);
end;
```

**Configuração sugerida WIN por volatilidade:**
| Volatilidade | Trailing |
|---|---|
| Baixa | 80–120 pts (16–24 ticks) |
| Normal | 120–150 pts (24–30 ticks) |
| Alta | 150–250 pts (30–50 ticks) |

---

## 4. Combinada: Breakeven + Trailing (mais completa)

1. Entra com stop inicial
2. Após `BreakevenGatilho` → stop vai para entrada
3. Após `TrailingAtiva` → trailing começa a seguir o preço
4. Alvo fixo como teto

**Configuração sugerida 30min WIN:**
- Stop inicial: 30 ticks (150 pts)
- BreakEven: 20 ticks (100 pts)
- Trailing ativa: 30 ticks (150 pts) — começa quando já está no lucro
- Trailing distância: 24 ticks (120 pts)
- Alvo máximo: 60 ticks (300 pts)

---

## 5. Stop Horário

Sempre fechar posições antes de 17:45 (WIN).

```pascal
// Time() retorna HHMMSS como número inteiro
if Time() >= (17 * 10000 + 45 * 100) then
begin
  if IsBought or IsSold then ClosePosition;
  bDeveOperar := false;
end;
```

---

## Referência por Robô

| Arquivo | Estratégia | TF ideal |
|---------|-----------|---------|
| [FORCA_SAIDA_OCO.ntsl](../robos/PADROES/FORCA_SAIDA_OCO.ntsl) | OCO com ATR dinâmico | 15min |
| [FORCA_SAIDA_BREAKEVEN.ntsl](../robos/PADROES/FORCA_SAIDA_BREAKEVEN.ntsl) | Breakeven + Alvo ATR | 30min |
| [FORCA_SAIDA_TRAILING.ntsl](../robos/PADROES/FORCA_SAIDA_TRAILING.ntsl) | Trailing ATR | 60min |
