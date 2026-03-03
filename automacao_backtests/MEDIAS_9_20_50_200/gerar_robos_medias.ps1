$base = "automacao_backtests/MEDIAS_9_20_50_200"

$template = @'
{
  Estrategia: __STRATEGY__
  Autor: Wesley
  Descricao: __DESC__
}

input
  ModoEstrategia(__MODO__);
  DistanciaMinimaLequePontos(__DISTLEQUE__);
  DistanciaCompressao20x200(__DISTCOMP__);
  DistanciaMaximaPrecoMME20(__DISTPRECO20__);
  DistanciaToqueMME20(__DISTTOQUE20__);
  MinBarrasConfirmacao(__MINBARRAS__);
  ConfirmacoesRompimento(__CONF__);
  UsarConfirmacaoCandle(true);
  UsarOCO(true);
  StopLossPontos(__STOP__);
  TakeProfitPontos(__TAKE__);
  UsarSaidaPorTempo(true);
  MaxBarrasPosicao(__MAXBARRAS__);

var
  mme9, mme20, mma50, mma200 : float;
  slope20, slope50, slope200 : float;
  dist920, dist2050, dist20200, distPreco20 : float;
  topoLookback, fundoLookback : float;
  iAlta, iBaixa, iBarrasPosicao : integer;
  bCompressao, bLequeAlta, bLequeBaixa : boolean;
  bPullbackCompra, bPullbackVenda : boolean;
  bRompAlta, bRompBaixa : boolean;
  bCompra, bVenda, bConfCompra, bConfVenda : boolean;
  bEstavaPosicionado, bSaidaOCOCompra, bSaidaOCOVenda : boolean;
  fPrecoEntrada, fStopAtual, fAlvoAtual : float;

begin
  mme9 := MediaExp(9, Close);
  mme20 := MediaExp(20, Close);
  mma50 := Media(50, Close);
  mma200 := Media(200, Close);

  slope20 := mme20 - mme20[1];
  slope50 := mma50 - mma50[1];
  slope200 := mma200 - mma200[1];

  dist920 := Abs(mme9 - mme20);
  dist2050 := Abs(mme20 - mma50);
  dist20200 := Abs(mme20 - mma200);
  distPreco20 := Abs(Close - mme20);

  topoLookback := Highest(High, 12);
  fundoLookback := Lowest(Low, 12);

  bCompressao := dist20200 <= DistanciaCompressao20x200;

  bLequeAlta := (Close > mme9) and (mme9 > mme20) and (mme20 > mma50) and (mma50 > mma200)
                and (slope20 > 0) and (slope50 > 0)
                and (dist920 >= DistanciaMinimaLequePontos)
                and (dist2050 >= DistanciaMinimaLequePontos);

  bLequeBaixa := (Close < mme9) and (mme9 < mme20) and (mme20 < mma50) and (mma50 < mma200)
                 and (slope20 < 0) and (slope50 < 0)
                 and (dist920 >= DistanciaMinimaLequePontos)
                 and (dist2050 >= DistanciaMinimaLequePontos);

  bPullbackCompra := (not bCompressao) and (mma50 > mma200) and (slope20 > 0)
                     and (Abs(Low - mme20) <= DistanciaToqueMME20) and (Close > mme20);
  bPullbackVenda := (not bCompressao) and (mma50 < mma200) and (slope20 < 0)
                    and (Abs(High - mme20) <= DistanciaToqueMME20) and (Close < mme20);

  bRompAlta := (dist20200 <= DistanciaToqueMME20) and (Close > mma200) and (Close >= topoLookback[1]) and (mme9 > mme20);
  bRompBaixa := (dist20200 <= DistanciaToqueMME20) and (Close < mma200) and (Close <= fundoLookback[1]) and (mme9 < mme20);

  bConfCompra := (not UsarConfirmacaoCandle) or (Close > High[1]);
  bConfVenda := (not UsarConfirmacaoCandle) or (Close < Low[1]);

  if bLequeAlta or bPullbackCompra or bRompAlta then
    iAlta := iAlta + 1
  else
    iAlta := 0;

  if bLequeBaixa or bPullbackVenda or bRompBaixa then
    iBaixa := iBaixa + 1
  else
    iBaixa := 0;

  bCompra := false;
  bVenda := false;

  if ModoEstrategia = 1 then
  begin
    bCompra := bLequeAlta and (not bCompressao) and (distPreco20 <= DistanciaMaximaPrecoMME20) and (iAlta >= MinBarrasConfirmacao);
    bVenda := bLequeBaixa and (not bCompressao) and (distPreco20 <= DistanciaMaximaPrecoMME20) and (iBaixa >= MinBarrasConfirmacao);
  end
  else if ModoEstrategia = 2 then
  begin
    bCompra := bPullbackCompra and bConfCompra;
    bVenda := bPullbackVenda and bConfVenda;
  end
  else if ModoEstrategia = 3 then
  begin
    bCompra := bRompAlta and (iAlta >= ConfirmacoesRompimento);
    bVenda := bRompBaixa and (iBaixa >= ConfirmacoesRompimento);
  end
  else if ModoEstrategia = 4 then
  begin
    bCompra := (not bCompressao) and bLequeAlta and (slope200 >= 0) and (iAlta >= MinBarrasConfirmacao);
    bVenda := (not bCompressao) and bLequeBaixa and (slope200 <= 0) and (iBaixa >= MinBarrasConfirmacao);
  end
  else
  begin
    bCompra := (bPullbackCompra or bRompAlta) and (not bCompressao) and bConfCompra;
    bVenda := (bPullbackVenda or bRompBaixa) and (not bCompressao) and bConfVenda;
  end;

  if IsBought or IsSold then
    iBarrasPosicao := iBarrasPosicao + 1
  else
    iBarrasPosicao := 0;

  if (not IsBought) and (not IsSold) then
  begin
    if bCompra then
      BuyAtMarket
    else if bVenda then
      SellShortAtMarket;
  end;

  bSaidaOCOCompra := false;
  bSaidaOCOVenda := false;

  if IsBought and bEstavaPosicionado then
  begin
    fStopAtual := fPrecoEntrada - StopLossPontos;
    fAlvoAtual := fPrecoEntrada + TakeProfitPontos;
    bSaidaOCOCompra := UsarOCO and ((Low <= fStopAtual) or (High >= fAlvoAtual));
  end;

  if IsSold and bEstavaPosicionado then
  begin
    fStopAtual := fPrecoEntrada + StopLossPontos;
    fAlvoAtual := fPrecoEntrada - TakeProfitPontos;
    bSaidaOCOVenda := UsarOCO and ((High >= fStopAtual) or (Low <= fAlvoAtual));
  end;

  if IsBought and (
      bCompressao
      or (Close < mme20)
      or (UsarSaidaPorTempo and (iBarrasPosicao >= MaxBarrasPosicao))
      or bSaidaOCOCompra
     ) then
    ClosePosition;

  if IsSold and (
      bCompressao
      or (Close > mme20)
      or (UsarSaidaPorTempo and (iBarrasPosicao >= MaxBarrasPosicao))
      or bSaidaOCOVenda
     ) then
    ClosePosition;

  if (not bEstavaPosicionado) and IsBought then
    fPrecoEntrada := Close;

  if (not bEstavaPosicionado) and IsSold then
    fPrecoEntrada := Close;

  bEstavaPosicionado := IsBought or IsSold;
end;
'@

$familias = @(
  @{ Prefix = 'leque';      Modo = 1; Desc = 'Leque direcional 9/20/50/200 com filtro de esticamento.' },
  @{ Prefix = 'pullback';   Modo = 2; Desc = 'Pullback na MME20 com regime por MMA50/200.' },
  @{ Prefix = 'romp200';    Modo = 3; Desc = 'Rompimento da MMA200 com MME20 proxima.' },
  @{ Prefix = 'compressao'; Modo = 4; Desc = 'Evita compressao 20x200 e opera so direcional.' },
  @{ Prefix = 'hibrido';    Modo = 5; Desc = 'Combinacao de pullback e rompimento com filtro de compressao.' }
)

$index = 5
foreach ($fam in $familias) {
  for ($i = 1; $i -le 10; $i++) {
    if ($index -gt 50) { break }

    $num = '{0:D2}' -f $index
    $strategy = "robo_medias_v${num}_$($fam.Prefix)"
    $file = Join-Path $base "$strategy.txt"

    $distLeque = 30 + (5 * ($i % 4))
    $distComp = 70 + (10 * ($i % 5))
    $distPreco = 180 + (30 * ($i % 5))
    $distToque = 35 + (10 * ($i % 4))
    $minBars = 1 + ($i % 3)
    $conf = 1 + ($i % 2)
    $stop = 120 + (15 * $i)
    $take = [Math]::Round($stop * (1.6 + (0.1 * ($i % 3))), 1)
    $maxBars = 8 + ($i % 6)

    $content = $template.Replace('__STRATEGY__', $strategy)
    $content = $content.Replace('__DESC__', $fam.Desc)
    $content = $content.Replace('__MODO__', [string]$fam.Modo)
    $content = $content.Replace('__DISTLEQUE__', [string]$distLeque)
    $content = $content.Replace('__DISTCOMP__', [string]$distComp)
    $content = $content.Replace('__DISTPRECO20__', [string]$distPreco)
    $content = $content.Replace('__DISTTOQUE20__', [string]$distToque)
    $content = $content.Replace('__MINBARRAS__', [string]$minBars)
    $content = $content.Replace('__CONF__', [string]$conf)
    $content = $content.Replace('__STOP__', [string]$stop)
    $content = $content.Replace('__TAKE__', [string]$take)
    $content = $content.Replace('__MAXBARRAS__', [string]$maxBars)

    Set-Content -Path $file -Value $content -Encoding UTF8

    $index++
  }
}

$count = (Get-ChildItem $base -File | Where-Object { $_.Name -like 'robo_medias_v*.txt' }).Count
Write-Output "TOTAL_ROBOS=$count"
