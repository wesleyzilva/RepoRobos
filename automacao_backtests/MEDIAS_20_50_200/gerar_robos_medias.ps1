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
  MinPercCorpoPA(__MINCORPOPA__);
  FatorPavioRejeicao(__FATORPAVIO__);
  UsarConfirmacaoCandle(true);
  UsarOCO(true);
  StopLossPontos(__STOP__);
  TakeProfitPontos(__TAKE__);
  UsarSaidaPorTempo(true);
  MaxBarrasPosicao(__MAXBARRAS__);

var
  mme9, mme20, mma50, mma200 : float;
  slope20, slope50, slope200 : float;
  dist920, dist2050, dist50200, dist20200, distPreco20 : float;
  topoLookback, fundoLookback : float;
  rangeCandle, corpoCandle, pavioSup, pavioInf : float;
  iAlta, iBaixa, iBarrasPosicao : integer;
  bCompressao, bLequeAlta, bLequeBaixa : boolean;
  bAcimaTodas, bAbaixoTodas, bEntre9e20, bEntre20e50, bEntre50e200, bZonaNeutra : boolean;
  bCandleForcaAlta, bCandleForcaBaixa, bRejeicaoAlta, bRejeicaoBaixa : boolean;
  bPullbackCompra, bPullbackVenda, bRompAlta, bRompBaixa, bSaindoCompressao : boolean;
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
  dist50200 := Abs(mma50 - mma200);
  dist20200 := Abs(mme20 - mma200);
  distPreco20 := Abs(Close - mme20);

  topoLookback := Highest(High, 12);
  fundoLookback := Lowest(Low, 12);

  rangeCandle := Max(High - Low, 0.01);
  corpoCandle := Abs(Close - Open);
  pavioSup := High - Max(Open, Close);
  pavioInf := Min(Open, Close) - Low;

  bAcimaTodas := (Close > mme9) and (Close > mme20) and (Close > mma50) and (Close > mma200);
  bAbaixoTodas := (Close < mme9) and (Close < mme20) and (Close < mma50) and (Close < mma200);

  bEntre9e20 := ((Close <= mme9) and (Close >= mme20)) or ((Close >= mme9) and (Close <= mme20));
  bEntre20e50 := ((Close <= mme20) and (Close >= mma50)) or ((Close >= mme20) and (Close <= mma50));
  bEntre50e200 := ((Close <= mma50) and (Close >= mma200)) or ((Close >= mma50) and (Close <= mma200));
  bZonaNeutra := bEntre9e20 or bEntre20e50 or bEntre50e200;

  bCompressao := dist20200 <= DistanciaCompressao20x200;
  bSaindoCompressao := (dist20200 > DistanciaCompressao20x200) and (dist20200[1] <= DistanciaCompressao20x200);

  bLequeAlta := bAcimaTodas and (mme9 > mme20) and (mme20 > mma50) and (mma50 > mma200)
                and (slope20 > 0) and (slope50 > 0) and (slope200 >= 0)
                and (dist920 >= DistanciaMinimaLequePontos)
                and (dist2050 >= DistanciaMinimaLequePontos)
                and (dist50200 >= DistanciaMinimaLequePontos);

  bLequeBaixa := bAbaixoTodas and (mme9 < mme20) and (mme20 < mma50) and (mma50 < mma200)
                 and (slope20 < 0) and (slope50 < 0) and (slope200 <= 0)
                 and (dist920 >= DistanciaMinimaLequePontos)
                 and (dist2050 >= DistanciaMinimaLequePontos)
                 and (dist50200 >= DistanciaMinimaLequePontos);

  bCandleForcaAlta := (Close > Open) and ((corpoCandle / rangeCandle) >= MinPercCorpoPA) and (Close > High[1]);
  bCandleForcaBaixa := (Close < Open) and ((corpoCandle / rangeCandle) >= MinPercCorpoPA) and (Close < Low[1]);

  bRejeicaoAlta := (Close > Open)
                   and ((pavioInf >= (corpoCandle * FatorPavioRejeicao)) or (Low <= Low[1]))
                   and (Close > mme20);

  bRejeicaoBaixa := (Close < Open)
                    and ((pavioSup >= (corpoCandle * FatorPavioRejeicao)) or (High >= High[1]))
                    and (Close < mme20);

  bPullbackCompra := (not bCompressao)
                     and (mma50 > mma200)
                     and (slope20 > 0)
                     and (Abs(Low - mme20) <= DistanciaToqueMME20)
                     and bRejeicaoAlta;

  bPullbackVenda := (not bCompressao)
                    and (mma50 < mma200)
                    and (slope20 < 0)
                    and (Abs(High - mme20) <= DistanciaToqueMME20)
                    and bRejeicaoBaixa;

  bRompAlta := (Close > mma200) and (Close[1] <= mma200)
               and (dist20200 <= DistanciaToqueMME20)
               and (Close >= topoLookback[1])
               and (mme9 > mme20)
               and bCandleForcaAlta;

  bRompBaixa := (Close < mma200) and (Close[1] >= mma200)
                and (dist20200 <= DistanciaToqueMME20)
                and (Close <= fundoLookback[1])
                and (mme9 < mme20)
                and bCandleForcaBaixa;

  bConfCompra := (not UsarConfirmacaoCandle) or bCandleForcaAlta;
  bConfVenda := (not UsarConfirmacaoCandle) or bCandleForcaBaixa;

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
    bCompra := bLequeAlta and (not bCompressao) and (not bZonaNeutra)
               and (distPreco20 <= DistanciaMaximaPrecoMME20)
               and bConfCompra and (iAlta >= MinBarrasConfirmacao);

    bVenda := bLequeBaixa and (not bCompressao) and (not bZonaNeutra)
              and (distPreco20 <= DistanciaMaximaPrecoMME20)
              and bConfVenda and (iBaixa >= MinBarrasConfirmacao);
  end
  else if ModoEstrategia = 2 then
  begin
    bCompra := bPullbackCompra and bConfCompra and (iAlta >= MinBarrasConfirmacao);
    bVenda := bPullbackVenda and bConfVenda and (iBaixa >= MinBarrasConfirmacao);
  end
  else if ModoEstrategia = 3 then
  begin
    bCompra := bRompAlta and (iAlta >= ConfirmacoesRompimento);
    bVenda := bRompBaixa and (iBaixa >= ConfirmacoesRompimento);
  end
  else if ModoEstrategia = 4 then
  begin
    bCompra := (not bCompressao) and bSaindoCompressao and bLequeAlta and bConfCompra;
    bVenda := (not bCompressao) and bSaindoCompressao and bLequeBaixa and bConfVenda;
  end
  else
  begin
    bCompra := (not bCompressao) and (not bZonaNeutra)
               and ((bPullbackCompra and bConfCompra) or (bRompAlta and (iAlta >= ConfirmacoesRompimento)));

    bVenda := (not bCompressao) and (not bZonaNeutra)
              and ((bPullbackVenda and bConfVenda) or (bRompBaixa and (iBaixa >= ConfirmacoesRompimento)));
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
      or bZonaNeutra
      or (Close < mme20)
      or bCandleForcaBaixa
      or (UsarSaidaPorTempo and (iBarrasPosicao >= MaxBarrasPosicao))
      or bSaidaOCOCompra
     ) then
    ClosePosition;

  if IsSold and (
      bCompressao
      or bZonaNeutra
      or (Close > mme20)
      or bCandleForcaAlta
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

function Get-FamilyMode($name) {
  if ($name -match 'leque') { return 1 }
  if ($name -match 'pullback') { return 2 }
  if ($name -match 'romp') { return 3 }
  if ($name -match 'compressao') { return 4 }
  if ($name -match 'hibrido') { return 5 }
  return 1
}

function Get-FamilyDesc($mode) {
  switch ($mode) {
    1 { return 'Leque direcional 9/20/50/200 com price action de continuidade e filtro de zona neutra.' }
    2 { return 'Pullback na MME20 com regime por MMA50/200 e rejeicao por price action.' }
    3 { return 'Rompimento da MMA200 com confirmacao por estrutura e candle de forca.' }
    4 { return 'Filtro de compressao 20x200 com entrada na saida da compressao direcional.' }
    5 { return 'Hibrido de pullback e rompimento com filtro de posicao do preco entre medias.' }
    default { return 'Estrategia de medias com leitura de contexto e price action.' }
  }
}

$files = Get-ChildItem -Path $base -File | Where-Object { $_.Name -match '^robo_medias_v\d+.*\.txt$' }

$updated = 0
foreach ($fileObj in $files) {
  $nameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($fileObj.Name)

  $num = 1
  if ($nameNoExt -match '^robo_medias_v(\d+)') {
    $num = [int]$matches[1]
  }

  $mode = Get-FamilyMode $nameNoExt
  $desc = Get-FamilyDesc $mode

  $seed = (($num - 1) % 10) + 1

  $distLeque = 30 + (5 * ($seed % 5))
  $distComp = 70 + (10 * ($seed % 5))
  $distPreco = 180 + (20 * ($seed % 6))
  $distToque = 30 + (10 * ($seed % 4))
  $minBars = 1 + ($seed % 3)
  $conf = 1 + ($seed % 2)
  $minCorpoPA = [Math]::Round(0.45 + (0.05 * ($seed % 4)), 2)
  $fatorPavio = [Math]::Round(1.1 + (0.15 * ($seed % 4)), 2)
  $stop = 120 + (15 * $seed)
  $take = [Math]::Round($stop * (1.5 + (0.1 * ($seed % 4))), 1)
  $maxBars = 8 + ($seed % 6)

  $content = $template.Replace('__STRATEGY__', $nameNoExt)
  $content = $content.Replace('__DESC__', $desc)
  $content = $content.Replace('__MODO__', [string]$mode)
  $content = $content.Replace('__DISTLEQUE__', [string]$distLeque)
  $content = $content.Replace('__DISTCOMP__', [string]$distComp)
  $content = $content.Replace('__DISTPRECO20__', [string]$distPreco)
  $content = $content.Replace('__DISTTOQUE20__', [string]$distToque)
  $content = $content.Replace('__MINBARRAS__', [string]$minBars)
  $content = $content.Replace('__CONF__', [string]$conf)
  $content = $content.Replace('__MINCORPOPA__', ([string]$minCorpoPA).Replace(',', '.'))
  $content = $content.Replace('__FATORPAVIO__', ([string]$fatorPavio).Replace(',', '.'))
  $content = $content.Replace('__STOP__', [string]$stop)
  $content = $content.Replace('__TAKE__', ([string]$take).Replace(',', '.'))
  $content = $content.Replace('__MAXBARRAS__', [string]$maxBars)

  Set-Content -Path $fileObj.FullName -Value $content -Encoding UTF8
  $updated++
}

"TOTAL_ATUALIZADOS=$updated"
