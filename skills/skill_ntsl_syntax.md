# Skill: Sintaxe NTSL/NTFL — Neologica Profit

> Referência completa de sintaxe para desenvolvimento de robôs e indicadores no Profit.

---

## Diferença crítica: Robô vs Indicador

| Recurso | Robô (`.ntsl`) | Indicador (`.ntfl`) |
|---|---|---|
| `PaintBar(RGB)` | ✅ | ✅ |
| `BuyAtMarket` | ✅ | ❌ |
| `SellShortAtMarket` | ✅ | ❌ |
| `ClosePosition` | ✅ | ❌ |
| `PlotText()` | ❌ | ✅ |
| `Alert(cor)` | ❌ | ✅ |
| `DrawArrow()` | ❌ | ✅ |
| `DrawLine()` | ❌ | ✅ |

---

## Estrutura padrão de um Robô

```pascal
{
  Robo: NOME_DO_ROBO
  Descricao: objetivo em uma linha
  Ativo: WIN B3
  Timeframe: 5min
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: estrutura geometrica
  Spread_descontado: 10 pts
  Slippage_descontado: 15 pts
}

input
  ForcaMinimaEntrada(60.0);
  RRR_Minimo(2.0);
  VolumeMultiplicador(1.5);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);

var
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  fVolumeMedio      : float;
  fStopLoss         : float;
  fTakeProfit       : float;
  fEntrada          : float;
  iBarrasEmPosicao  : integer;
  bSinalCompra      : boolean;
  bSinalVenda       : boolean;
  iCorR, iCorG, iCorB : integer;

begin
  // ─── SEÇÃO 1: FORÇA F = M × A ──────────────────────────────────────────────
  fCorpoCandle := Close - Open;
  fRangeCandle := High - Low;
  if fRangeCandle < 0.01 then fRangeCandle := 0.01;
  fMassa       := fCorpoCandle / fRangeCandle;
  fVolumeMedio := Media(20, Volume);
  if fVolumeMedio > 0 then fAceleracao := Volume / fVolumeMedio
  else fAceleracao := 1;
  fForca := fMassa * fAceleracao * 100;
  if fForca >  100 then fForca :=  100;
  if fForca < -100 then fForca := -100;

  // ─── SEÇÃO 2: GRADIENTE DE CORES ──────────────────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128; // cinza padrão
  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    iCorR := 255; iCorG := 255; iCorB := 255; // branco = indecisão
  end
  else if fForca >= ForcaMinimaEntrada then
  begin
    iCorG := 128 + Round((fForca / 100) * 127);
    iCorR := 128 - Round((fForca / 100) * 128);
    iCorB := 128 - Round((fForca / 100) * 128);
    if iCorG > 255 then iCorG := 255;
    if iCorR < 0   then iCorR := 0;
    if iCorB < 0   then iCorB := 0;
  end
  else if fForca <= -ForcaMinimaEntrada then
  begin
    iCorR := 128 + Round((-fForca / 100) * 127);
    iCorG := 128 - Round((-fForca / 100) * 128);
    iCorB := 128 - Round((-fForca / 100) * 128);
    if iCorR > 255 then iCorR := 255;
    if iCorG < 0   then iCorG := 0;
    if iCorB < 0   then iCorB := 0;
  end;
  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 3: SINAIS ──────────────────────────────────────────────────────
  bSinalCompra := (fForca >= ForcaMinimaEntrada) and (Volume >= fVolumeMedio * VolumeMultiplicador);
  bSinalVenda  := (fForca <= -ForcaMinimaEntrada) and (Volume >= fVolumeMedio * VolumeMultiplicador);

  // ─── SEÇÃO 4: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  begin
    ClosePosition;
    Exit; // não abrir novas posições
  end;

  // ─── SEÇÃO 5: GERENCIAR BARRAS EM POSIÇÃO ─────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;
  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
    ClosePosition;

  // ─── SEÇÃO 6: ENTRADAS ────────────────────────────────────────────────────
  if (not IsBought) and (not IsSold) then
  begin
    if bSinalCompra then
    begin
      fEntrada    := Close;
      fStopLoss   := Low - 5;   // ajustar para estrutura geométrica
      fTakeProfit := fEntrada + (fEntrada - fStopLoss) * RRR_Minimo;
      if (fTakeProfit - fEntrada) >= (fEntrada - fStopLoss) * RRR_Minimo then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;
    if bSinalVenda then
    begin
      fEntrada    := Close;
      fStopLoss   := High + 5;  // ajustar para estrutura geométrica
      fTakeProfit := fEntrada - (fStopLoss - fEntrada) * RRR_Minimo;
      if (fEntrada - fTakeProfit) >= (fStopLoss - fEntrada) * RRR_Minimo then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;
  end;
end;
```

---

## Funções built-in úteis

```pascal
Media(periodo, serie)          // média simples: Media(20, Volume)
MediaExp(periodo, serie)       // média exponencial
Maxima(periodo)                // máxima dos últimos N candles: Maxima(5)
Minima(periodo)                // mínima dos últimos N candles: Minima(5)
Volume                         // volume do candle atual
High, Low, Open, Close         // OHLC do candle atual
High[1], Low[1]                // OHLC do candle anterior (offset)
IsBought                       // true se em posição comprada
IsSold                         // true se em posição vendida
Hour, Minute, Second           // hora atual
```

---

## Ordens disponíveis em robôs

```pascal
BuyAtMarket;                         // compra a mercado
SellShortAtMarket;                   // venda a mercado
ClosePosition;                       // fecha posição
BuyLimit(preco, quantidade);         // compra limitada
SellShortLimit(preco, quantidade);   // venda limitada
BuyStop(preco, quantidade);          // compra stop
SellShortStop(preco, quantidade);    // venda stop
```

---

## Armadilhas comuns

```pascal
// ❌ ERRO: divisão por zero
fMassa := fCorpoCandle / fRangeCandle; // falha se range = 0

// ✅ CORRETO: guardar contra zero
if fRangeCandle < 0.01 then fRangeCandle := 0.01;
fMassa := fCorpoCandle / fRangeCandle;

// ❌ ERRO: RGB fora dos limites (0–255)
iCorG := 128 + round(forca * 1.3); // pode exceder 255

// ✅ CORRETO: clamp
if iCorG > 255 then iCorG := 255;
if iCorG < 0   then iCorG := 0;

// ❌ ERRO: usar PlotText em robô
PlotText("COMPRA", RGB(0,255,0), 10, 0, Low);  // não compila

// ✅ CORRETO: só PaintBar em robô
PaintBar(RGB(0, 255, 0));
```
