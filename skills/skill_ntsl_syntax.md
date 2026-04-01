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
Time()                         // hora atual em formato HHMMSS (ex: 091500 = 09:15:00)
```

### Controle de horário com Time() — padrão confirmado

> ⚠️ `div` e `mod` **não existem em NTSL** (confirmado em compilação).
> `Time()` retorna HHMMSS como número — comparar diretamente com `H * 10000 + M * 100`.

```pascal
// ✅ PADRÃO Único CORRETO — declarar no var apenas:
// bDeveOperar : boolean;

// No begin:
if Time() >= (StopHorario_H * 10000 + StopHorario_M * 100) then
begin
  if IsBought or IsSold then ClosePosition;
  bDeveOperar := false;
end
else
  bDeveOperar := Time() >= (HoraInicioH * 10000 + HoraInicioM * 100);

// Toda a lógica de barras + entradas DENTRO do if bDeveOperar:
if bDeveOperar then
begin
  // controle de barras e entradas aqui
end;

// ❌ ERRADO: div e mod nao existem em NTSL
// iHoraAtual   := Time() div 10000;           // Parser: "Depois de um statement deve vir ;"
// iMinutoAtual := (Time() mod 10000) div 100; // Parser: "Faltou um )"
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

## ❌ Erros críticos de sintaxe — confirmados em compilação

```pascal
// ❌ ERRO 1: Hour e Minute não existem em NTSL
if (Hour >= 17) and (Minute >= 45) then ...   // Parser: "Função ou variável inválida: Hour"
// ✅ CORRETO:
iHoraAtual := Time() div 10000;               // Time() retorna HHMMSS

// ❌ ERRO 2: Exit não existe em NTSL
Exit;                                          // Parser: "Exit não é um identificador válido"
// ✅ CORRETO: usar bDeveOperar := false e envolver lógica com if bDeveOperar then

// ❌ ERRO 3: strings com aspas simples
PlotText('COMPRA', RGB(0,255,0), 8, 0, Low);  // Parser: "Uma String necessita ser delimitada por aspas duplas"
// ✅ CORRETO: aspas duplas obrigatórias
PlotText("COMPRA", RGB(0,255,0), 8, 0, Low);

// ❌ ERRO 4: espaço no nome de variável
bAcelerando Alta : boolean;                    // Parser: "Token inválido: Alta"
// ✅ CORRETO: sem espaços, camelCase
bAcelerandoAlta : boolean;

// ❌ ERRO 5: Format() estilo Delphi não existe
PlotText(Format('%.0f', [fForca]), ...);       // não compila
// ✅ CORRETO: usar IntToStr(Round(fForca))
PlotText(IntToStr(Round(fForca)), ...);

// ❌ ERRO 6: Floor() pode não existir
fQuantidade := Floor(fRisco / 0.20);
// ✅ CORRETO: truncar manualmente
fQuantidade := fRisco / 0.20;
if fQuantidade < 1 then fQuantidade := 1;

// ❌ ERRO 7: div e mod nao existem em NTSL
iHoraAtual := Time() div 10000;               // Parser: "Depois de um statement deve vir ;"
iMinutoAtual := (Time() mod 10000) div 100;   // Parser: "Faltou um )"
// ✅ CORRETO: comparar Time() diretamente com HHMMSS calculado
bDeveOperar := Time() >= (StopHorario_H * 10000 + StopHorario_M * 100);
// Regra: 09:15 = 91500 | 17:45 = 174500 | H*10000 + M*100 + S

// ❌ ERRO 8: DrawArrow nao existe em NTSL (nem em .ntsl nem em .ntfl confirmado)
DrawArrow(1, RGB(0,255,0), 2, Low);           // Parser: "DrawArrow não é um identificador válido"
// ✅ CORRETO: usar PlotText + PaintBar (apenas em .ntfl)
PlotText("COMPRA", RGB(0,200,0), 9, 1, Low * 0.993);
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

// ❌ ERRO: usar PlotText em robô (.ntsl)
PlotText("COMPRA", RGB(0,255,0), 10, 0, Low);  // não compila em robô

// ✅ CORRETO: só PaintBar em robô
PaintBar(RGB(0, 255, 0));

// ❌ ERRO: condição multi-linha sem parênteses — pode causar "Depois de um statement deve vir ;"
if bCondicao1 and bCondicao2
   and bCondicao3 then ...    // pode falhar

// ✅ CORRETO: envolver em parênteses ou manter em linha única
if (bCondicao1 and bCondicao2 and bCondicao3) then ...
```
