{
  Robo: ROB_OBV_ACELERACAO_V1
  Descricao: Opera aceleração do OBV — quando o fluxo institucional está acelerando
             (delta atual > delta anterior na mesma direção e crescendo).
             Cor escala com a VELOCIDADE de mudança do OBV, não apenas o valor.
             Verde escurecendo = OBV acelerando compra. Vermelho escurecendo = OBV acelerando venda.
  Ativo: WIN B3 / WDO B3
  Timeframe: TF3 (Gatilho) — padrão 5min, tripleta 30/15/5
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: mínima/máxima local (Minima/Maxima de iJanelaDir barras) + BufferStop
  Spread_descontado: 25 pts

  Lógica de aceleração:
    fMomentum1 = fOBV - fOBV[iJanelaDir]         → velocidade recente (TF2)
    fMomentum2 = fOBV[iJanelaDir] - fOBV[iJanelaCtx]  → velocidade anterior (TF1)
    fAceleracao = fMomentum1 - fMomentum2         → variação da velocidade

    Aceleração ALTA:  fAceleracao > 0 AND fMomentum1 > 0
      = OBV subindo MAIS rápido que antes → pressão compradora crescendo
    Aceleração BAIXA: fAceleracao < 0 AND fMomentum1 < 0
      = OBV caindo MAIS rápido que antes → pressão vendedora crescendo

    Gradiente: intensidade proporcional a fAceleracao normalizada
    Azul vivo = aceleração máxima para cima (ponto de entrada ideal)
    Roxo vivo = aceleração máxima para baixo
    Cinza/branco = desaceleração ou lateralização do OBV
}

input
  iJanelaDir(3);
  iJanelaCtx(6);
  ForcaMinimaCandle(40.0);    // F=MA mínimo para confirmar entrada
  VolumeMultiplicador(1.3);
  RRR_Minimo(2.0);
  BufferStop(5.0);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);
  HoraInicioH(9);
  HoraInicioM(15);

var
  // OBV
  fOBV              : float;
  fMomentum1        : float;   // velocidade atual: fOBV - fOBV[iJanelaDir]
  fMomentum2        : float;   // velocidade anterior: fOBV[iJanelaDir] - fOBV[iJanelaCtx]
  fOBVAceleracao    : float;   // fMomentum1 - fMomentum2
  fVolumeMedio      : float;
  fOBVNorm          : float;   // aceleração normalizada -100..+100
  // F = M × A
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  // Sinais
  bAcelerando Alta  : boolean;
  bAcelerandoAlta   : boolean;
  bAcelerandoBaixa  : boolean;
  // Cores
  iCorR, iCorG, iCorB : integer;
  // Gestão
  fEntrada          : float;
  fStopLoss         : float;
  fTakeProfit       : float;
  fRisco            : float;
  iBarrasEmPosicao  : integer;
  // Controle de Horário
  bDeveOperar       : boolean;

begin

  // ─── SEÇÃO 1: OBV ACUMULADO ───────────────────────────────────────────────
  if Close > Close[1] then
    fOBV := fOBV + Volume
  else if Close < Close[1] then
    fOBV := fOBV - Volume;

  fVolumeMedio := Media(20, Volume);

  // ─── SEÇÃO 2: F = M × A ──────────────────────────────────────────────────
  fCorpoCandle := Close - Open;
  fRangeCandle := High - Low;
  if fRangeCandle < 0.01 then fRangeCandle := 0.01;
  fMassa       := fCorpoCandle / fRangeCandle;
  if fVolumeMedio > 0 then fAceleracao := Volume / fVolumeMedio
  else fAceleracao := 1;
  fForca := fMassa * fAceleracao * 100;
  if fForca >  100 then fForca :=  100;
  if fForca < -100 then fForca := -100;

  // ─── SEÇÃO 3: MOMENTUM E ACELERAÇÃO DO OBV ───────────────────────────────
  fMomentum1     := fOBV - fOBV[iJanelaDir];              // velocidade recente
  fMomentum2     := fOBV[iJanelaDir] - fOBV[iJanelaCtx]; // velocidade anterior
  fOBVAceleracao := fMomentum1 - fMomentum2;              // variação da velocidade

  // Aceleração de alta: OBV subindo e mais rápido que antes
  bAcelerandoAlta  := (fMomentum1 > 0) and (fOBVAceleracao > 0);
  // Aceleração de baixa: OBV caindo e mais rápido que antes
  bAcelerandoBaixa := (fMomentum1 < 0) and (fOBVAceleracao < 0);

  // Normalizar aceleração para gradiente (referência: volume médio × janela)
  if fVolumeMedio > 0 then
    fOBVNorm := (fOBVAceleracao / (fVolumeMedio * iJanelaDir + 1)) * 100
  else
    fOBVNorm := 0;
  if fOBVNorm >  100 then fOBVNorm :=  100;
  if fOBVNorm < -100 then fOBVNorm := -100;

  // ─── SEÇÃO 4: GRADIENTE — ESCALA COM A ACELERAÇÃO ────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;

  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    iCorR := 255; iCorG := 255; iCorB := 255; // branco = indecisão
  end
  else if bAcelerandoAlta then
  begin
    if fForca >= ForcaMinimaCandle then
    begin
      // AZUL VIVO = aceleração máxima + candle confirmando → sinal ideal
      iCorR := 0;
      iCorG := 180 + Round((fOBVNorm / 100) * 75);
      iCorB := 255;
      if iCorG > 255 then iCorG := 255;
    end
    else
    begin
      // VERDE degradê = OBV acelerando mas candle ainda fraco
      iCorG := 128 + Round((fOBVNorm / 100) * 127);
      iCorR := 128 - Round((fOBVNorm / 100) * 128);
      iCorB := 128 - Round((fOBVNorm / 100) * 128);
      if iCorG > 255 then iCorG := 255;
      if iCorR < 0   then iCorR := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end
  else if bAcelerandoBaixa then
  begin
    if fForca <= -ForcaMinimaCandle then
    begin
      // ROXO VIVO = aceleração máxima para baixo + candle confirmando
      iCorR := 180 + Round((-fOBVNorm / 100) * 75);
      iCorG := 0;
      iCorB := 220;
      if iCorR > 255 then iCorR := 255;
    end
    else
    begin
      // VERMELHO degradê = OBV acelerando para baixo mas candle fraco
      iCorR := 128 + Round((-fOBVNorm / 100) * 127);
      iCorG := 128 - Round((-fOBVNorm / 100) * 128);
      iCorB := 128 - Round((-fOBVNorm / 100) * 128);
      if iCorR > 255 then iCorR := 255;
      if iCorG < 0   then iCorG := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end;
  // Desaceleração: permanece cinza (padrão) indicando fim do momentum

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 5: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  if Time() >= (StopHorario_H * 10000 + StopHorario_M * 100) then
  begin
    if IsBought or IsSold then ClosePosition;
    Exit;
    bDeveOperar := false;
  end;
  if (Hour < HoraInicioH) or ((Hour = HoraInicioH) and (Minute < HoraInicioM)) then Exit;
  else
    bDeveOperar := Time() >= (HoraInicioH * 10000 + HoraInicioM * 100);

  // ─── SEÇÃO 6: CONTROLE DE BARRAS ─────────────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;
  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    Exit;
    bDeveOperar := false;
  end;

  // ─── SEÇÃO 7: ENTRADAS — ACELERAÇÃO + CANDLE CONFIRMADOR ─────────────────
  if (not IsBought) and (not IsSold) then
  if bDeveOperar and (not IsBought) and (not IsSold) then
  begin
    // COMPRA: OBV acelerando para cima + candle de força + volume
    if bAcelerandoAlta and (fForca >= ForcaMinimaCandle)
       and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := Minima(iJanelaDir) - BufferStop;
      fStopLoss   := Low[1] - BufferStop; // Usar Low do candle anterior ou gatilho
      fRisco      := fEntrada - fStopLoss;
      fTakeProfit := fEntrada + fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fTakeProfit - fEntrada) >= fRisco * RRR_Minimo) then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

    // VENDA: OBV acelerando para baixo + candle de força + volume
    if bAcelerandoBaixa and (fForca <= -ForcaMinimaCandle)
       and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := Maxima(iJanelaDir) + BufferStop;
      fStopLoss   := High[1] + BufferStop; // Usar High do candle anterior ou gatilho
      fRisco      := fStopLoss - fEntrada;
      fTakeProfit := fEntrada - fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fEntrada - fTakeProfit) >= fRisco * RRR_Minimo) then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;
  end;

end;

erros ao compilar:
Compilando ...
Parser[58,15]: Token inválido: Alta
Parser[96,3]: bAcelerandoAlta não é um identificador válido
Parser[115,11]: Função ou variável inválida: bAcelerandoAlta
Parser[136,3]: Depois de um statement deve vir " ; "
Parser[162,7]: Função ou variável inválida: Hour
Parser[165,5]: Exit não é um identificador válido
Parser[167,7]: Função ou variável inválida: Hour
Parser[178,5]: Exit não é um identificador válido
Parser[185,8]: Função ou variável inválida: bAcelerandoAlta
Parser[189,28]: Depois de um statement deve vir " ; "
Parser[204,28]: Depois de um statement deve vir " ; "
Parser[215,1]: O código deve começar com begin
Erro de Sintaxe

{
  Robo: ROB_OBV_BREAKOUT_V1
  Descricao: Opera quando o OBV rompe o delta máximo ou mínimo das últimas iJanelaCtx barras.
             Breakout do OBV = pressão institucional acumulada se liberando.
             Cor AMARELA intensa = pré-breakout. AZUL/ROXO = breakout confirmado.
  Ativo: WIN B3 / WDO B3
  Timeframe: TF3 (Gatilho) — padrão 5min, tripleta 30/15/5
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: mínima/máxima do candle de breakout + BufferStop
  Spread_descontado: 25 pts

  Lógica de breakout:
    fOBVDeltaAtual   = fOBV - fOBV[iJanelaDir]     (delta recente = TF2)
    fOBVDeltaAnterior = fOBV[iJanelaDir] - fOBV[iJanelaCtx] (delta anterior = TF1)
    Breakout ALTA:  fOBVDeltaAtual > fOBVDeltaAnterior E fOBVDeltaAtual > 0
      = OBV acelerando para cima: mais volume comprando agora que antes
    Breakout BAIXA: fOBVDeltaAtual < fOBVDeltaAnterior E fOBVDeltaAtual < 0
      = OBV acelerando para baixo: mais volume vendendo agora que antes
    Gradiente: escala com a magnitude do breakout (quanto maior o delta, mais intenso)
}

input
  iJanelaDir(3);
  iJanelaCtx(6);
  ForcaMinimaCandle(30.0);     // força mínima do candle no momento do breakout
  VolumeMultiplicador(1.5);    // volume mínimo para confirmar breakout
  RRR_Minimo(2.0);
  BufferStop(5.0);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);
  HoraInicioH(9);
  HoraInicioM(15);

var
  // OBV
  fOBV                 : float;
  fOBVDeltaAtual       : float;   // fOBV - fOBV[iJanelaDir]
  fOBVDeltaAnterior    : float;   // fOBV[iJanelaDir] - fOBV[iJanelaCtx]
  fOBVAceleracao       : float;   // diferença entre os dois deltas (normalized)
  fVolumeMedio         : float;
  // F = M × A (filtro de candle)
  fCorpoCandle         : float;
  fRangeCandle         : float;
  fMassa               : float;
  fAceleracao          : float;
  fForca               : float;
  // Sinais
  bBreakoutAlta        : boolean;
  bBreakoutBaixa       : boolean;
  fOBVNorm             : float;  // normalizado para gradiente
  // Cores
  iCorR, iCorG, iCorB  : integer;
  // Gestão
  fEntrada             : float;
  fStopLoss            : float;
  fTakeProfit          : float;
  fRisco               : float;
  iBarrasEmPosicao     : integer;

begin

  // ─── SEÇÃO 1: OBV ACUMULADO ───────────────────────────────────────────────
  if Close > Close[1] then
    fOBV := fOBV + Volume
  else if Close < Close[1] then
    fOBV := fOBV - Volume;

  fVolumeMedio := Media(20, Volume);

  // ─── SEÇÃO 2: F = M × A ──────────────────────────────────────────────────
  fCorpoCandle := Close - Open;
  fRangeCandle := High - Low;
  if fRangeCandle < 0.01 then fRangeCandle := 0.01;
  fMassa       := fCorpoCandle / fRangeCandle;
  if fVolumeMedio > 0 then fAceleracao := Volume / fVolumeMedio
  else fAceleracao := 1;
  fForca := fMassa * fAceleracao * 100;
  if fForca >  100 then fForca :=  100;
  if fForca < -100 then fForca := -100;

  // ─── SEÇÃO 3: DETECÇÃO DE BREAKOUT ───────────────────────────────────────
  // Delta atual (janela TF2): variação do OBV nas últimas iJanelaDir barras
  fOBVDeltaAtual    := fOBV - fOBV[iJanelaDir];
  // Delta anterior (janela TF1): variação do OBV no período antes do TF2
  fOBVDeltaAnterior := fOBV[iJanelaDir] - fOBV[iJanelaCtx];

  // Aceleração = quanto o delta atual supera o anterior
  fOBVAceleracao := fOBVDeltaAtual - fOBVDeltaAnterior;

  // Breakout: delta atual maior que anterior E na mesma direção
  bBreakoutAlta  := (fOBVDeltaAtual > 0) and (fOBVDeltaAtual > fOBVDeltaAnterior);
  bBreakoutBaixa := (fOBVDeltaAtual < 0) and (fOBVDeltaAtual < fOBVDeltaAnterior);

  // Normalização para gradiente (escala relativa ao volume médio)
  if fVolumeMedio > 0 then
    fOBVNorm := (fOBVDeltaAtual / (fVolumeMedio * iJanelaDir + 1)) * 100
  else
    fOBVNorm := 0;
  if fOBVNorm >  100 then fOBVNorm :=  100;
  if fOBVNorm < -100 then fOBVNorm := -100;

  // ─── SEÇÃO 4: GRADIENTE DE CORES ─────────────────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;

  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    iCorR := 255; iCorG := 255; iCorB := 255; // branco = indecisão
  end
  else if bBreakoutAlta and (fForca >= ForcaMinimaCandle) then
  begin
    // AZUL INTENSO = breakout de OBV para cima + candle confirmando
    iCorR := 0;
    iCorG := 100 + Round((fOBVNorm / 100) * 155);
    iCorB := 255;
    if iCorG > 255 then iCorG := 255;
    if iCorG < 0   then iCorG := 0;
  end
  else if bBreakoutAlta then
  begin
    // AMARELO = breakout de OBV para cima, candle ainda fraco
    iCorR := 255; iCorG := 215; iCorB := 0;
  end
  else if bBreakoutBaixa and (fForca <= -ForcaMinimaCandle) then
  begin
    // ROXO INTENSO = breakout de OBV para baixo + candle confirmando
    iCorR := 100 + Round((-fOBVNorm / 100) * 155);
    iCorG := 0;
    iCorB := 220;
    if iCorR > 255 then iCorR := 255;
    if iCorR < 0   then iCorR := 0;
  end
  else if bBreakoutBaixa then
  begin
    // LARANJA = breakout de OBV para baixo, candle ainda fraco
    iCorR := 255; iCorG := 140; iCorB := 0;
  end
  else if fOBVNorm >= 10 then
  begin
    // Verde fraco = OBV crescendo sem breakout
    iCorG := 128 + Round((fOBVNorm / 100) * 80);
    iCorR := 128 - Round((fOBVNorm / 100) * 60);
    iCorB := 128 - Round((fOBVNorm / 100) * 60);
    if iCorG > 255 then iCorG := 255;
    if iCorR < 0   then iCorR := 0;
    if iCorB < 0   then iCorB := 0;
  end
  else if fOBVNorm <= -10 then
  begin
    // Vermelho fraco = OBV caindo sem breakout
    iCorR := 128 + Round((-fOBVNorm / 100) * 80);
    iCorG := 128 - Round((-fOBVNorm / 100) * 60);
    iCorB := 128 - Round((-fOBVNorm / 100) * 60);
    if iCorR > 255 then iCorR := 255;
    if iCorG < 0   then iCorG := 0;
    if iCorB < 0   then iCorB := 0;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 5: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  begin
    if IsBought or IsSold then ClosePosition;
    Exit;
  end;
  if (Hour < HoraInicioH) or ((Hour = HoraInicioH) and (Minute < HoraInicioM)) then Exit;

  // ─── SEÇÃO 6: CONTROLE DE BARRAS ─────────────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;
  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    Exit;
  end;

  // ─── SEÇÃO 7: ENTRADAS — BREAKOUT + CANDLE CONFIRMADOR ───────────────────
  if (not IsBought) and (not IsSold) then
  begin
    // COMPRA: breakout do OBV para cima + candle de força + volume
    if bBreakoutAlta and (fForca >= ForcaMinimaCandle)
       and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := Low - BufferStop;
      fRisco      := fEntrada - fStopLoss;
      fTakeProfit := fEntrada + fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fTakeProfit - fEntrada) >= fRisco * RRR_Minimo) then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

    // VENDA: breakout do OBV para baixo + candle de força + volume
    if bBreakoutBaixa and (fForca <= -ForcaMinimaCandle)
       and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := High + BufferStop;
      fRisco      := fStopLoss - fEntrada;
      fTakeProfit := fEntrada - fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fEntrada - fTakeProfit) >= fRisco * RRR_Minimo) then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;
  end;

end;

Compilando ...
Parser[163,7]: Função ou variável inválida: Hour
Parser[166,5]: Exit não é um identificador válido
Parser[168,7]: Função ou variável inválida: Hour
Parser[179,5]: Exit não é um identificador válido
Parser[216,1]: O código deve começar com begin
Erro de Sintaxe
{
  Robo: ROB_OBV_DIVERGENCIA_V1
  Descricao: Opera divergência entre preço e OBV. Preço caindo mas OBV subindo
             (acumulação) = compra. Preço subindo mas OBV caindo (distribuição) = venda.
             Cor LARANJA = divergência detectada. Verde/vermelho = confirmação.
  Ativo: WIN B3 / WDO B3
  Timeframe: TF3 (Gatilho) — padrão 5min, tripleta 30/15/5
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: mínima/máxima do swing de divergência + BufferStop
  Spread_descontado: 25 pts

  Lógica de divergência:
    Janela de comparação = iJanelaDir barras atrás
    Divergência ALTA (compra):
      Close[0] < Close[iJanelaDir]  (preço caiu)  AND
      fOBV[0]  > fOBV[iJanelaDir]   (OBV subiu)   = acumulação oculta
    Divergência BAIXA (venda):
      Close[0] > Close[iJanelaDir]  (preço subiu)  AND
      fOBV[0]  < fOBV[iJanelaDir]   (OBV caiu)    = distribuição oculta
    Confirmação: candle de reversão (F=MA > limiar) na direção da divergência
    Cor laranja = divergência ativa sem confirmação
    Cor azul/roxo = divergência + candle confirmador
}

input
  iJanelaDir(3);
  iJanelaCtx(6);
  ForcaMinimaConfirmacao(40.0);  // força mínima do candle de reversão
  VolumeMultiplicador(1.2);
  RRR_Minimo(2.0);
  BufferStop(5.0);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);
  HoraInicioH(9);
  HoraInicioM(15);

var
  // OBV
  fOBV              : float;
  fOBVDeltaDir      : float;
  fPrecoDelta       : float;
  // F = M × A (confirmação)
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  fVolumeMedio      : float;
  // Divergências
  bDivAltaAtiva     : boolean;  // preço caiu, OBV subiu
  bDivBaixaAtiva    : boolean;  // preço subiu, OBV caiu
  bConfirmCompra    : boolean;  // candle de reversão de alta
  bConfirmVenda     : boolean;  // candle de reversão de baixa
  // Cores
  iCorR, iCorG, iCorB : integer;
  // Gestão
  fEntrada          : float;
  fStopLoss         : float;
  fTakeProfit       : float;
  fRisco            : float;
  iBarrasEmPosicao  : integer;

begin

  // ─── SEÇÃO 1: OBV ACUMULADO ───────────────────────────────────────────────
  if Close > Close[1] then
    fOBV := fOBV + Volume
  else if Close < Close[1] then
    fOBV := fOBV - Volume;

  fVolumeMedio := Media(20, Volume);

  // ─── SEÇÃO 2: F = M × A (para confirmar reversão) ────────────────────────
  fCorpoCandle := Close - Open;
  fRangeCandle := High - Low;
  if fRangeCandle < 0.01 then fRangeCandle := 0.01;
  fMassa       := fCorpoCandle / fRangeCandle;
  if fVolumeMedio > 0 then fAceleracao := Volume / fVolumeMedio
  else fAceleracao := 1;
  fForca := fMassa * fAceleracao * 100;
  if fForca >  100 then fForca :=  100;
  if fForca < -100 then fForca := -100;

  // ─── SEÇÃO 3: DETECÇÃO DE DIVERGÊNCIA ────────────────────────────────────
  fOBVDeltaDir  := fOBV  - fOBV[iJanelaDir];    // OBV agora vs N barras atrás
  fPrecoDelta   := Close - Close[iJanelaDir];    // preço agora vs N barras atrás

  // Divergência de ALTA: preço caiu mas OBV subiu (acumulação oculta)
  bDivAltaAtiva  := (fPrecoDelta < 0) and (fOBVDeltaDir > 0);

  // Divergência de BAIXA: preço subiu mas OBV caiu (distribuição oculta)
  bDivBaixaAtiva := (fPrecoDelta > 0) and (fOBVDeltaDir < 0);

  // Confirmação: candle de força na direção da divergência
  bConfirmCompra := bDivAltaAtiva and (fForca >= ForcaMinimaConfirmacao);
  bConfirmVenda  := bDivBaixaAtiva and (fForca <= -ForcaMinimaConfirmacao);

  // ─── SEÇÃO 4: GRADIENTE DE CORES ─────────────────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128; // cinza padrão

  if bConfirmCompra then
  begin
    // AZUL = divergência de alta confirmada por candle de força
    iCorR := 0; iCorG := 180; iCorB := 255;
  end
  else if bConfirmVenda then
  begin
    // ROXO = divergência de baixa confirmada por candle de força
    iCorR := 160; iCorG := 0; iCorB := 220;
  end
  else if bDivAltaAtiva then
  begin
    // LARANJA = divergência de alta detectada, aguardando confirmação
    iCorR := 255; iCorG := 140; iCorB := 0;
  end
  else if bDivBaixaAtiva then
  begin
    // AMARELO = divergência de baixa detectada, aguardando confirmação
    iCorR := 255; iCorG := 215; iCorB := 0;
  end
  else if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    // BRANCO = indecisão
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  else if fForca >= 20 then
  begin
    // Verde fraco = força de alta sem divergência
    iCorG := 128 + Round((fForca / 100) * 80);
    iCorR := 128 - Round((fForca / 100) * 60);
    iCorB := 128 - Round((fForca / 100) * 60);
    if iCorG > 255 then iCorG := 255;
    if iCorR < 0   then iCorR := 0;
    if iCorB < 0   then iCorB := 0;
  end
  else if fForca <= -20 then
  begin
    // Vermelho fraco = força de baixa sem divergência
    iCorR := 128 + Round((-fForca / 100) * 80);
    iCorG := 128 - Round((-fForca / 100) * 60);
    iCorB := 128 - Round((-fForca / 100) * 60);
    if iCorR > 255 then iCorR := 255;
    if iCorG < 0   then iCorG := 0;
    if iCorB < 0   then iCorB := 0;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 5: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  begin
    if IsBought or IsSold then ClosePosition;
    Exit;
  end;
  if (Hour < HoraInicioH) or ((Hour = HoraInicioH) and (Minute < HoraInicioM)) then Exit;

  // ─── SEÇÃO 6: CONTROLE DE BARRAS ─────────────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;
  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    Exit;
  end;

  // ─── SEÇÃO 7: ENTRADAS — DIVERGÊNCIA + CONFIRMAÇÃO ───────────────────────
  if (not IsBought) and (not IsSold) then
  begin
    // COMPRA: divergência de alta confirmada + volume
    if bConfirmCompra and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := Minima(iJanelaDir) - BufferStop; // mínima do swing da divergência
      fRisco      := fEntrada - fStopLoss;
      fTakeProfit := fEntrada + fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fTakeProfit - fEntrada) >= fRisco * RRR_Minimo) then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

    // VENDA: divergência de baixa confirmada + volume
    if bConfirmVenda and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := Maxima(iJanelaDir) + BufferStop; // máxima do swing da divergência
      fRisco      := fStopLoss - fEntrada;
      fTakeProfit := fEntrada - fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fEntrada - fTakeProfit) >= fRisco * RRR_Minimo) then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;
  end;

end;
Compilando ...
Parser[152,7]: Função ou variável inválida: Hour
Parser[155,5]: Exit não é um identificador válido
Parser[157,7]: Função ou variável inválida: Hour
Parser[168,5]: Exit não é um identificador válido
Parser[178,28]: Depois de um statement deve vir " ; "
Parser[192,28]: Depois de um statement deve vir " ; "
Parser[203,1]: O código deve começar com begin
Erro de Sintaxe

{
  Robo: ROB_OBV_FMA_COMBINADO_V1
  Descricao: F=MA gera o sinal e define o gradiente. OBV filtra: só opera se volume
             institucional confirmar a mesma direção da força do candle.
             Cor cheia (azul/roxo) = F=MA + OBV alinhados. Verde/vermelho = só F=MA.
  Ativo: WIN B3 / WDO B3
  Timeframe: TF3 (Gatilho) — padrão 5min, tripleta 30/15/5
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: mínima/máxima do candle gatilho + BufferStop
  Spread_descontado: 25 pts

  Lógica:
    F=MA = (Corpo/Range) × (Volume/MediaVolume) × 100  → -100..+100
    OBV Delta TF2 = fOBV - fOBV[iJanelaDir]  → direção da acumulação
    Entrada: fForca >= ForcaMinima E OBV confirmando mesma direção
    Cor intensa (azul/roxo) = dupla confirmação F=MA + OBV
    Cor normal (verde/vermelho) = só F=MA, OBV neutro
    Cor cinza/branca = sem sinal
}

input
  iJanelaDir(3);
  iJanelaCtx(6);
  ForcaMinimaEntrada(60.0);
  VolumeMultiplicador(1.3);
  RRR_Minimo(2.0);
  BufferStop(5.0);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);
  HoraInicioH(9);
  HoraInicioM(15);

var
  // F = M × A
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  fVolumeMedio      : float;
  // OBV
  fOBV              : float;
  fOBVDeltaDir      : float;   // delta OBV no TF2
  fOBVDeltaCtx      : float;   // delta OBV no TF1
  bOBVConfirmaCompra  : boolean;
  bOBVConfirmaVenda   : boolean;
  bContextoAlta       : boolean;
  bContextoBaixa      : boolean;
  // Cores
  iCorR, iCorG, iCorB : integer;
  // Gestão
  fEntrada          : float;
  fStopLoss         : float;
  fTakeProfit       : float;
  fRisco            : float;
  iBarrasEmPosicao  : integer;

begin

  // ─── SEÇÃO 1: F = M × A ──────────────────────────────────────────────────
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

  // ─── SEÇÃO 2: OBV ACUMULADO + DELTA POR JANELA ───────────────────────────
  if Close > Close[1] then
    fOBV := fOBV + Volume
  else if Close < Close[1] then
    fOBV := fOBV - Volume;

  fOBVDeltaDir := fOBV - fOBV[iJanelaDir];
  fOBVDeltaCtx := fOBV - fOBV[iJanelaCtx];

  bOBVConfirmaCompra := (fOBVDeltaDir > 0) and (fOBVDeltaCtx > 0);
  bOBVConfirmaVenda  := (fOBVDeltaDir < 0) and (fOBVDeltaCtx < 0);

  // Contexto de preço (proxy TF1)
  bContextoAlta  := (Close > Media(iJanelaCtx, Close));
  bContextoBaixa := (Close < Media(iJanelaCtx, Close));

  // ─── SEÇÃO 3: GRADIENTE — F=MA BASE, OBV MODIFICA A COR ─────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;

  // Indecisão: corpo < 10% do range
  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  else if fForca >= ForcaMinimaEntrada then
  begin
    if bOBVConfirmaCompra and bContextoAlta then
    begin
      // AZUL = F=MA + OBV + contexto todos confirmam compra
      iCorR := 0; iCorG := 150; iCorB := 255;
    end
    else
    begin
      // VERDE degradê = força do candle sem confirmação do OBV
      iCorG := 128 + Round((fForca / 100) * 127);
      iCorR := 128 - Round((fForca / 100) * 128);
      iCorB := 128 - Round((fForca / 100) * 128);
      if iCorG > 255 then iCorG := 255;
      if iCorR < 0   then iCorR := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end
  else if fForca <= -ForcaMinimaEntrada then
  begin
    if bOBVConfirmaVenda and bContextoBaixa then
    begin
      // ROXO = F=MA + OBV + contexto todos confirmam venda
      iCorR := 160; iCorG := 0; iCorB := 220;
    end
    else
    begin
      // VERMELHO degradê = força do candle sem confirmação do OBV
      iCorR := 128 + Round((-fForca / 100) * 127);
      iCorG := 128 - Round((-fForca / 100) * 128);
      iCorB := 128 - Round((-fForca / 100) * 128);
      if iCorR > 255 then iCorR := 255;
      if iCorG < 0   then iCorG := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 4: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  begin
    if IsBought or IsSold then ClosePosition;
    Exit;
  end;
  if (Hour < HoraInicioH) or ((Hour = HoraInicioH) and (Minute < HoraInicioM)) then Exit;

  // ─── SEÇÃO 5: CONTROLE DE BARRAS ─────────────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;
  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    Exit;
  end;

  // ─── SEÇÃO 6: ENTRADAS — F=MA + OBV DUPLA CONFIRMAÇÃO ───────────────────
  if (not IsBought) and (not IsSold) then
  begin
    // COMPRA: candle de força + OBV confirmando acumulação + volume
    if (fForca >= ForcaMinimaEntrada)
       and bOBVConfirmaCompra and bContextoAlta
       and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := Low - BufferStop;
      fRisco      := fEntrada - fStopLoss;
      fTakeProfit := fEntrada + fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fTakeProfit - fEntrada) >= fRisco * RRR_Minimo) then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

    // VENDA: candle de força vendedora + OBV confirmando distribuição + volume
    if (fForca <= -ForcaMinimaEntrada)
       and bOBVConfirmaVenda and bContextoBaixa
       and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := High + BufferStop;
      fRisco      := fStopLoss - fEntrada;
      fTakeProfit := fEntrada - fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fEntrada - fTakeProfit) >= fRisco * RRR_Minimo) then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;
  end;

end;
Compilando ...
Parser[138,7]: Função ou variável inválida: Hour
Parser[141,5]: Exit não é um identificador válido
Parser[143,7]: Função ou variável inválida: Hour
Parser[154,5]: Exit não é um identificador válido
Parser[193,1]: O código deve começar com begin
Erro de Sintaxe

{
  Robo: ROB_OBV_TENDENCIA_TRIPLA_V1
  Descricao: Opera quando OBV está crescendo nos 3 TFs da tripleta (Contexto + Direção + Gatilho).
             Cor azul = alinhamento total. Verde/vermelho degradê = sinal parcial.
  Ativo: WIN B3 / WDO B3
  Timeframe: TF3 (Gatilho) — padrão 5min, tripleta 30/15/5
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: mínima/máxima do candle gatilho + BufferStop
  Spread_descontado: 25 pts (10 spread + 15 slippage)

  Lógica OBV:
    fOBV acumula Volume positivo (close > close anterior) e negativo (close < close anterior)
    TF1 proxy: fOBV - fOBV[iJanelaCtx]   → tendência do contexto
    TF2 proxy: fOBV - fOBV[iJanelaDir]   → tendência da direção
    TF3:       fOBV - fOBV[1]             → tendência do gatilho (barra atual)
    Regra cardinal: opera SOMENTE com TF1 + TF2 + TF3 alinhados
}

input
  // Tripleta (padrão 30/15/5 rodando em 5min)
  // 60/30/15 em 15min → iJanelaDir=2, iJanelaCtx=4
  // 15/5/1   em 1min  → iJanelaDir=5, iJanelaCtx=15
  iJanelaDir(3);             // barras do TF2 em TF3
  iJanelaCtx(6);             // barras do TF1 em TF3
  VolumeMultiplicador(1.2);  // volume mínimo para confirmar sinal
  RRR_Minimo(2.0);
  BufferStop(5.0);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);
  HoraInicioH(9);
  HoraInicioM(15);

var
  fOBV              : float;   // OBV acumulado (persiste entre barras)
  fOBVDeltaGatilho  : float;   // delta OBV no TF3 (1 barra)
  fOBVDeltaDirecao  : float;   // delta OBV no TF2 (iJanelaDir barras)
  fOBVDeltaContexto : float;   // delta OBV no TF1 (iJanelaCtx barras)
  fVolumeMedio      : float;
  fOBVNorm          : float;   // sinal normalizado -100..+100 para gradiente
  iCorR, iCorG, iCorB : integer;
  bOBVAltaGatilho   : boolean;
  bOBVAltaDirecao   : boolean;
  bOBVAltaContexto  : boolean;
  bOBVBaixaGatilho  : boolean;
  bOBVBaixaDirecao  : boolean;
  bOBVBaixaContexto : boolean;
  fEntrada          : float;
  fStopLoss         : float;
  fTakeProfit       : float;
  fRisco            : float;
  iBarrasEmPosicao  : integer;

begin

  // ─── SEÇÃO 1: ACUMULAÇÃO OBV ─────────────────────────────────────────────
  if Close > Close[1] then
    fOBV := fOBV + Volume
  else if Close < Close[1] then
    fOBV := fOBV - Volume;
  // Close = Close[1] → fOBV inalterado (volume neutro)

  fVolumeMedio := Media(20, Volume);

  // ─── SEÇÃO 2: DELTA OBV POR JANELA (PROXY DAS TRIPLETAS) ─────────────────
  fOBVDeltaGatilho  := fOBV - fOBV[1];
  fOBVDeltaDirecao  := fOBV - fOBV[iJanelaDir];
  fOBVDeltaContexto := fOBV - fOBV[iJanelaCtx];

  bOBVAltaGatilho   := fOBVDeltaGatilho  > 0;
  bOBVAltaDirecao   := fOBVDeltaDirecao  > 0;
  bOBVAltaContexto  := fOBVDeltaContexto > 0;
  bOBVBaixaGatilho  := fOBVDeltaGatilho  < 0;
  bOBVBaixaDirecao  := fOBVDeltaDirecao  < 0;
  bOBVBaixaContexto := fOBVDeltaContexto < 0;

  // ─── SEÇÃO 3: NORMALIZAÇÃO → GRADIENTE ───────────────────────────────────
  // Normaliza delta do gatilho em relação ao volume médio (referência de escala)
  if fVolumeMedio > 0 then
    fOBVNorm := (fOBVDeltaGatilho / (fVolumeMedio + 1)) * 100
  else
    fOBVNorm := 0;
  if fOBVNorm >  100 then fOBVNorm :=  100;
  if fOBVNorm < -100 then fOBVNorm := -100;

  // ─── SEÇÃO 4: GRADIENTE DE CORES ─────────────────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128; // cinza padrão

  if fOBVNorm >= 10 then
  begin
    if bOBVAltaContexto and bOBVAltaDirecao then
    begin
      // AZUL = alinhamento total nos 3 TFs → sinal máximo
      iCorR := 0; iCorG := 128; iCorB := 255;
    end
    else
    begin
      // VERDE degradê = OBV subindo apenas no TF3
      iCorG := 128 + Round((fOBVNorm / 100) * 127);
      iCorR := 128 - Round((fOBVNorm / 100) * 128);
      iCorB := 128 - Round((fOBVNorm / 100) * 128);
      if iCorG > 255 then iCorG := 255;
      if iCorR < 0   then iCorR := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end
  else if fOBVNorm <= -10 then
  begin
    if bOBVBaixaContexto and bOBVBaixaDirecao then
    begin
      // ROXO ESCURO = alinhamento total nos 3 TFs para baixo
      iCorR := 80; iCorG := 0; iCorB := 200;
    end
    else
    begin
      // VERMELHO degradê = OBV caindo apenas no TF3
      iCorR := 128 + Round((-fOBVNorm / 100) * 127);
      iCorG := 128 - Round((-fOBVNorm / 100) * 128);
      iCorB := 128 - Round((-fOBVNorm / 100) * 128);
      if iCorR > 255 then iCorR := 255;
      if iCorG < 0   then iCorG := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 5: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  begin
    if IsBought or IsSold then ClosePosition;
    Exit;
  end;
  if (Hour < HoraInicioH) or ((Hour = HoraInicioH) and (Minute < HoraInicioM)) then Exit;

  // ─── SEÇÃO 6: CONTROLE DE BARRAS ─────────────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;
  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    Exit;
  end;

  // ─── SEÇÃO 7: ENTRADAS — REGRA CARDINAL: 3 TFs ALINHADOS ─────────────────
  if (not IsBought) and (not IsSold) then
  begin
    // COMPRA: OBV crescente nos 3 TFs + volume confirmando
    if bOBVAltaContexto and bOBVAltaDirecao and bOBVAltaGatilho
       and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := Low - BufferStop;
      fRisco      := fEntrada - fStopLoss;
      fTakeProfit := fEntrada + fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fTakeProfit - fEntrada) >= fRisco * RRR_Minimo) then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

    // VENDA: OBV decrescente nos 3 TFs + volume confirmando
    if bOBVBaixaContexto and bOBVBaixaDirecao and bOBVBaixaGatilho
       and (Volume >= fVolumeMedio * VolumeMultiplicador) then
    begin
      fEntrada    := Close;
      fStopLoss   := High + BufferStop;
      fRisco      := fStopLoss - fEntrada;
      fTakeProfit := fEntrada - fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fEntrada - fTakeProfit) >= fRisco * RRR_Minimo) then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;
  end;

end;
Compilando ...
Parser[130,7]: Função ou variável inválida: Hour
Parser[133,5]: Exit não é um identificador válido
Parser[135,7]: Função ou variável inválida: Hour
Parser[146,5]: Exit não é um identificador válido
Parser[183,1]: O código deve começar com begin
Erro de Sintaxe
{
  Robo: ROB_SEMAFORO_MULTI_TF_V1
  Descricao: Semáforo de tripleta — Contexto > Direção > Gatilho. Opera somente com TF1+TF2 alinhados.
  Ativo: WIN B3 / WDO B3
  Timeframe: TF3 (Gatilho) — configurar via iJanelaDir e iJanelaCtx
  Versao: 2.0
  RRR_minimo: 2.0
  SL_referencia: extremo do candle gatilho ± BufferStop

  TRIPLETAS RECOMENDADAS (configurar iJanelaDir e iJanelaCtx):
    60/30/15 → rob. roda em 15min → iJanelaDir=2, iJanelaCtx=4   | WIN SL=250pts | WDO SL=10pts
    30/15/5  → rob. roda em 5min  → iJanelaDir=3, iJanelaCtx=6   | WIN SL=150pts | WDO SL=6pts  ← PADRÃO
    15/5/1   → rob. roda em 1min  → iJanelaDir=5, iJanelaCtx=15  | WIN SL=80pts  | WDO SL=3pts
    30/10/5  → rob. roda em 5min  → iJanelaDir=2, iJanelaCtx=6
    60/20/5  → rob. roda em 5min  → iJanelaDir=4, iJanelaCtx=12

  REGRA CARDINAL: Opera SOMENTE quando Contexto(TF1) E Direção(TF2) estão alinhados.
}

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
input
  // ── Tripleta (configurar conforme a tabela de tripletas) ──────────────────
  // Padrão: 30/15/5 rodando em 5min → iJanelaDir=3, iJanelaCtx=6
  // 60/30/15 em 15min → iJanelaDir=2, iJanelaCtx=4
  // 15/5/1  em 1min  → iJanelaDir=5, iJanelaCtx=15
  iJanelaDir(3);                  // barras do TF2 (Direção) em TF3 (Gatilho)
  iJanelaCtx(6);                  // barras do TF1 (Contexto) em TF3 (Gatilho)

  ForcaMinimaEntrada(60.0);       // força mínima no TF3 para acionar gatilho
  ForcaMinimaContexto(20.0);      // força mínima nos proxies de TF1/TF2
  VolumeMultiplicador(1.5);
  RRR_Minimo(2.0);
  BufferStop(5.0);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);
  HoraInicioOperacao_H(9);
  HoraInicioOperacao_M(15);

// ═══════════════════════════════════════════════════════════════════════════════
// VARIÁVEIS
// ═══════════════════════════════════════════════════════════════════════════════
var
  fCorpoCandle         : float;
  fRangeCandle         : float;
  fMassa               : float;
  fAceleracao          : float;
  fForca               : float;
  fVolumeMedio         : float;
  iCorR, iCorG, iCorB  : integer;

  // Proxies da Tripleta (iJanelaDir → TF2 Direção, iJanelaCtx → TF1 Contexto)
  fMediaDir            : float;   // proxy TF2 — Media(iJanelaDir, Close)
  fMediaCtx            : float;   // proxy TF1 — Media(iJanelaCtx, Close)
  bContextoAlta        : boolean; // TF1 inclinando para cima
  bContextoBaixa       : boolean; // TF1 inclinando para baixo
  bDirecaoAlta         : boolean; // TF2 inclinando para cima
  bDirecaoBaixa        : boolean; // TF2 inclinando para baixo

  // Sinais combinados
  bSemVerdeCompra      : boolean;  // TF maior + gatilho = compra
  bSemVerdeVenda       : boolean;  // TF maior + gatilho = venda

  // Semáforo (confirmação de 2 candles consecutivos)
  iContadorCompra      : integer;
  iContadorVenda       : integer;
  bEntradaConfirmada   : boolean;

  // Gestão
  fEntrada             : float;
  fStopLoss            : float;
  fTakeProfit          : float;
  fRiscoEmPontos       : float;
  iBarrasEmPosicao     : integer;
  bRRROk               : boolean;

begin

  // ─── SEÇÃO 1: FORÇA DO CANDLE ATUAL (TF gatilho) ──────────────────────────
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

  // ─── SEÇÃO 2: PROXY DA TRIPLETA (Contexto TF1 + Direção TF2) ────────────────
  // Cada proxy compara o Close atual vs média de iJanela barras.
  // iJanelaDir barras → representa TF2 (Direção)
  // iJanelaCtx barras → representa TF1 (Contexto)
  //
  // Tabela de configuração (ver cabeçalho):
  //   Tripleta 30/15/5  em 5min  → iJanelaDir=3, iJanelaCtx=6
  //   Tripleta 60/30/15 em 15min → iJanelaDir=2, iJanelaCtx=4
  //   Tripleta 15/5/1   em 1min  → iJanelaDir=5, iJanelaCtx=15
  fMediaDir := Media(iJanelaDir, Close);
  fMediaCtx := Media(iJanelaCtx, Close);

  // Direção (TF2): preço acima/abaixo da média de TF2 E média inclinando
  bContextoAlta  := (Close > fMediaCtx) and (fMediaCtx > fMediaCtx[iJanelaCtx]);
  bContextoBaixa := (Close < fMediaCtx) and (fMediaCtx < fMediaCtx[iJanelaCtx]);
  bDirecaoAlta   := (Close > fMediaDir) and (fMediaDir > fMediaDir[iJanelaDir]);
  bDirecaoBaixa  := (Close < fMediaDir) and (fMediaDir < fMediaDir[iJanelaDir]);

  // ─── SEÇÃO 3: GRADIENTE (TF atual + contexto) ─────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;

  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  else if fForca >= ForcaMinimaEntrada then
  begin
    if bContextoAlta then
    begin
      // Azul = confirmação multi-TF de compra
      iCorR := 0; iCorG := 128; iCorB := 255;
    end
    else
    begin
      iCorG := 128 + Round((fForca / 100) * 127);
      iCorR := 128 - Round((fForca / 100) * 128);
      iCorB := 128 - Round((fForca / 100) * 128);
      if iCorG > 255 then iCorG := 255;
      if iCorR < 0   then iCorR := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end
  else if fForca <= -ForcaMinimaEntrada then
  begin
    if bContextoBaixa then
    begin
      // Azul escuro = confirmação multi-TF de venda
      iCorR := 80; iCorG := 0; iCorB := 200;
    end
    else
    begin
      iCorR := 128 + Round((-fForca / 100) * 127);
      iCorG := 128 - Round((-fForca / 100) * 128);
      iCorB := 128 - Round((-fForca / 100) * 128);
      if iCorR > 255 then iCorR := 255;
      if iCorG < 0   then iCorG := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 4: SEMÁFORO — CONFIRMAÇÃO DE 2 CANDLES ────────────────────────
  // REGRA CARDINAL: Contexto(TF1) E Direção(TF2) AMBOS alinhados + força no gatilho
  bSemVerdeCompra := (fForca >= ForcaMinimaEntrada) and
                     bContextoAlta and bDirecaoAlta and
                     (Volume >= fVolumeMedio * VolumeMultiplicador);

  bSemVerdeVenda  := (fForca <= -ForcaMinimaEntrada) and
                     bContextoBaixa and bDirecaoBaixa and
                     (Volume >= fVolumeMedio * VolumeMultiplicador);

  // Contadores de persistência (2 candles consecutivos no mesmo lado)
  if bSemVerdeCompra then
    iContadorCompra := iContadorCompra + 1
  else
    iContadorCompra := 0;

  if bSemVerdeVenda then
    iContadorVenda := iContadorVenda + 1
  else
    iContadorVenda := 0;

  // Entrada confirmada apenas após 2 candles consecutivos (evita sinais rápidos)
  bEntradaConfirmada := (iContadorCompra >= 2) or (iContadorVenda >= 2);

  // ─── SEÇÃO 5: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  begin
    if IsBought or IsSold then ClosePosition;
    Exit;
  end;

  // Aguardar após abertura
  if (Hour = HoraInicioOperacao_H) and (Minute < HoraInicioOperacao_M) then Exit;
  if Hour < HoraInicioOperacao_H then Exit;

  // ─── SEÇÃO 6: CONTROLE DE BARRAS ──────────────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;

  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    Exit;
  end;

  // ─── SEÇÃO 7: ENTRADAS ────────────────────────────────────────────────────
  if (not IsBought) and (not IsSold) and bEntradaConfirmada then
  begin

    if iContadorCompra >= 2 then
    begin
      fEntrada       := Close;
      fStopLoss      := Low - BufferStop;
      fRiscoEmPontos := fEntrada - fStopLoss;
      fTakeProfit    := fEntrada + fRiscoEmPontos * RRR_Minimo;
      bRRROk         := (fTakeProfit - fEntrada) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
        iContadorCompra  := 0;
      end;
    end;

    if iContadorVenda >= 2 then
    begin
      fEntrada       := Close;
      fStopLoss      := High + BufferStop;
      fRiscoEmPontos := fStopLoss - fEntrada;
      fTakeProfit    := fEntrada - fRiscoEmPontos * RRR_Minimo;
      bRRROk         := (fEntrada - fTakeProfit) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
        iContadorVenda   := 0;
      end;
    end;

  end;

end;
Compilando ...
Parser[182,7]: Função ou variável inválida: Hour
Parser[185,5]: Exit não é um identificador válido
Parser[189,7]: Função ou variável inválida: Hour
Parser[190,6]: Função ou variável inválida: Hour
Parser[202,5]: Exit não é um identificador válido
Parser[243,1]: O código deve começar com begin
Erro de Sintaxe

{
  Robo: ROB_CONFLUENCIA_V1
  Descricao: Robô de confluência geométrica — entradas em zonas com ≥2 referências sobrepostas
  Ativo: WIN B3
  Timeframe: 5min
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: minima/maxima da zona de confluencia detectada
  Spread_descontado: 10 pts (comentado — desconto no backtest)
  Slippage_descontado: 15 pts (comentado — desconto no backtest)
  Periodo_minimo_backtest: 90 dias / 100 trades
  Aprovado_em: pendente backtest
}

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
input
  ForcaMinimaEntrada(60.0);       // força mínima para considerar candle direcional
  RRR_Minimo(2.0);                // razão risco/recompensa mínima para entrar
  VolumeMultiplicador(1.5);       // volume deve ser X vezes a média de 20 períodos
  ToleranciaZona(50.0);           // buffer em pts para considerar sobreposição de áreas
  FatorTamanhoArea(1.0);          // multiplicador do corpo para tamanho da área
  StopHorario_H(17);              // hora de encerrar posições
  StopHorario_M(45);              // minuto de encerrar posições
  MaxBarrasEmPosicao(8);          // máximo de candles em posição aberta
  CapitalConta(10000.0);          // capital total para dimensionamento
  RiscoPorcentagem(2.0);          // % do capital por trade

// ═══════════════════════════════════════════════════════════════════════════════
// VARIÁVEIS
// ═══════════════════════════════════════════════════════════════════════════════
var
  // Força F = M × A
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  fVolumeMedio      : float;

  // Cores
  iCorR, iCorG, iCorB : integer;

  // Zonas de confluência (corpo dos últimos N candles relevantes)
  // Armazenamos os extremos dos últimos 5 candles de força
  fZonaCompraMin    : float;
  fZonaCompraMax    : float;
  fZonaVendaMin     : float;
  fZonaVendaMax     : float;
  iConfluenciasCompra : integer;
  iConfluenciasVenda  : integer;

  // Gestão de risco
  fEntrada          : float;
  fStopLoss         : float;
  fTakeProfit       : float;
  fRiscoEmPontos    : float;
  fRiscoEmReais     : float;
  fQuantidade       : float;

  // Sinais
  bSinalCompra      : boolean;
  bSinalVenda       : boolean;
  bNaZonaCompra     : boolean;
  bNaZonaVenda      : boolean;
  bVolConfirmado    : boolean;
  bRRROk            : boolean;

  // Controle
  iBarrasEmPosicao  : integer;

begin

  // ─── SEÇÃO 1: FORÇA F = M × A ──────────────────────────────────────────────
  // Mede a intensidade direcional do candle atual ponderada pelo volume relativo
  fCorpoCandle := Close - Open;
  fRangeCandle := High - Low;
  if fRangeCandle < 0.01 then fRangeCandle := 0.01;  // guard divisão por zero

  fMassa       := fCorpoCandle / fRangeCandle;        // -1.0 a +1.0
  fVolumeMedio := Media(20, Volume);
  if fVolumeMedio > 0 then
    fAceleracao := Volume / fVolumeMedio
  else
    fAceleracao := 1;

  fForca := fMassa * fAceleracao * 100;
  if fForca >  100 then fForca :=  100;
  if fForca < -100 then fForca := -100;

  // ─── SEÇÃO 2: GRADIENTE DE CORES ──────────────────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;  // cinza = padrão

  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    // Branco = indecisão (corpo < 10% do range)
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  else if fForca >= ForcaMinimaEntrada then
  begin
    // Verde degradê — quanto maior a força, mais saturado o verde
    iCorG := 128 + Round((fForca / 100) * 127);
    iCorR := 128 - Round((fForca / 100) * 128);
    iCorB := 128 - Round((fForca / 100) * 128);
    if iCorG > 255 then iCorG := 255;
    if iCorR < 0   then iCorR := 0;
    if iCorB < 0   then iCorB := 0;
  end
  else if fForca <= -ForcaMinimaEntrada then
  begin
    // Vermelho degradê — quanto menor a força, mais saturado o vermelho
    iCorR := 128 + Round((-fForca / 100) * 127);
    iCorG := 128 - Round((-fForca / 100) * 128);
    iCorB := 128 - Round((-fForca / 100) * 128);
    if iCorR > 255 then iCorR := 255;
    if iCorG < 0   then iCorG := 0;
    if iCorB < 0   then iCorB := 0;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 3: ZONAS DE CONFLUÊNCIA ────────────────────────────────────────
  // Verifica se o preço atual está dentro de uma zona de sobreposição de corpos
  // de candles de força anteriores.
  //
  // Estratégia simplificada: usar os últimos 5 candles de força como referência.
  // Zona de compra = região onde corpos de compra se sobrepõem (baixo dos corpos)
  // Zona de venda  = região onde corpos de venda se sobrepõem  (alto dos corpos)

  iConfluenciasCompra := 0;
  iConfluenciasVenda  := 0;
  fZonaCompraMin := 999999; fZonaCompraMax := 0;
  fZonaVendaMin  := 999999; fZonaVendaMax  := 0;

  // --- Candle -1
  if (Close[1] > Open[1]) and (abs(Close[1]-Open[1]) >= 0.40 * (High[1]-Low[1])) then
  begin
    fZonaCompraMin := Open[1];
    fZonaCompraMax := Close[1];
    iConfluenciasCompra := iConfluenciasCompra + 1;
  end;
  if (Close[1] < Open[1]) and (abs(Close[1]-Open[1]) >= 0.40 * (High[1]-Low[1])) then
  begin
    fZonaVendaMin := Close[1];
    fZonaVendaMax := Open[1];
    iConfluenciasVenda := iConfluenciasVenda + 1;
  end;

  // --- Candle -2
  if (Close[2] > Open[2]) and (abs(Close[2]-Open[2]) >= 0.40 * (High[2]-Low[2])) then
  begin
    // Verificar sobreposição com zona existente
    if (fZonaCompraMin < 999999) then
    begin
      if (Open[2] <= fZonaCompraMax + ToleranciaZona) and
         (Close[2] >= fZonaCompraMin - ToleranciaZona) then
      begin
        // Atualizar zona para intersecção
        if Open[2]  > fZonaCompraMin then fZonaCompraMin := Open[2];
        if Close[2] < fZonaCompraMax then fZonaCompraMax := Close[2];
        iConfluenciasCompra := iConfluenciasCompra + 1;
      end;
    end
    else
    begin
      fZonaCompraMin := Open[2];
      fZonaCompraMax := Close[2];
      iConfluenciasCompra := 1;
    end;
  end;

  if (Close[2] < Open[2]) and (abs(Close[2]-Open[2]) >= 0.40 * (High[2]-Low[2])) then
  begin
    if (fZonaVendaMin < 999999) then
    begin
      if (Close[2] <= fZonaVendaMax + ToleranciaZona) and
         (Open[2]  >= fZonaVendaMin - ToleranciaZona) then
      begin
        if Close[2] > fZonaVendaMin then fZonaVendaMin := Close[2];
        if Open[2]  < fZonaVendaMax then fZonaVendaMax := Open[2];
        iConfluenciasVenda := iConfluenciasVenda + 1;
      end;
    end
    else
    begin
      fZonaVendaMin := Close[2];
      fZonaVendaMax := Open[2];
      iConfluenciasVenda := 1;
    end;
  end;

  // --- Candle -3 (mesma lógica)
  if (Close[3] > Open[3]) and (abs(Close[3]-Open[3]) >= 0.40 * (High[3]-Low[3])) then
    if (fZonaCompraMin < 999999) and
       (Open[3] <= fZonaCompraMax + ToleranciaZona) and
       (Close[3] >= fZonaCompraMin - ToleranciaZona) then
      iConfluenciasCompra := iConfluenciasCompra + 1;

  if (Close[3] < Open[3]) and (abs(Close[3]-Open[3]) >= 0.40 * (High[3]-Low[3])) then
    if (fZonaVendaMin < 999999) and
       (Close[3] <= fZonaVendaMax + ToleranciaZona) and
       (Open[3]  >= fZonaVendaMin - ToleranciaZona) then
      iConfluenciasVenda := iConfluenciasVenda + 1;

  // Verificar se o preço atual está dentro das zonas
  bNaZonaCompra := (iConfluenciasCompra >= 2) and
                   (Close >= fZonaCompraMin - ToleranciaZona) and
                   (Close <= fZonaCompraMax + ToleranciaZona);

  bNaZonaVenda  := (iConfluenciasVenda >= 2) and
                   (Close >= fZonaVendaMin  - ToleranciaZona) and
                   (Close <= fZonaVendaMax  + ToleranciaZona);

  // ─── SEÇÃO 4: CONFIRMAÇÃO DE VOLUME ───────────────────────────────────────
  bVolConfirmado := (Volume >= fVolumeMedio * VolumeMultiplicador);

  // ─── SEÇÃO 5: SINAIS DE ENTRADA ───────────────────────────────────────────
  bSinalCompra := bNaZonaCompra and
                  (fForca >= ForcaMinimaEntrada) and
                  bVolConfirmado;

  bSinalVenda  := bNaZonaVenda and
                  (fForca <= -ForcaMinimaEntrada) and
                  bVolConfirmado;

  // ─── SEÇÃO 6: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  begin
    if IsBought or IsSold then ClosePosition;
    Exit;  // não abrir novas posições após horário limite
  end;

  // Evitar abertura antes de 09:15 (volatilidade da abertura)
  if (Hour = 9) and (Minute < 15) then Exit;

  // ─── SEÇÃO 7: CONTROLE DE BARRAS EM POSIÇÃO ───────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;

  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    Exit;
  end;

  // ─── SEÇÃO 8: ENTRADAS ────────────────────────────────────────────────────
  if (not IsBought) and (not IsSold) then
  begin

    // COMPRA: zona de confluência de alta + candle de força + volume
    if bSinalCompra then
    begin
      fEntrada       := Close;
      // SL = mínimo da zona de confluência de compra com buffer
      fStopLoss      := fZonaCompraMin - 5;
      fRiscoEmPontos := fEntrada - fStopLoss;
      fTakeProfit    := fEntrada + fRiscoEmPontos * RRR_Minimo;

      // Verificar RRR antes de entrar
      bRRROk := (fTakeProfit - fEntrada) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        // Dimensionar quantidade pelo risco
        fRiscoEmReais := CapitalConta * (RiscoPorcentagem / 100);
        fQuantidade   := Floor(fRiscoEmReais / (fRiscoEmPontos * 0.20));
        if fQuantidade < 1 then fQuantidade := 1;

        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

    // VENDA: zona de confluência de baixa + candle de força + volume
    if bSinalVenda then
    begin
      fEntrada       := Close;
      // SL = máximo da zona de confluência de venda com buffer
      fStopLoss      := fZonaVendaMax + 5;
      fRiscoEmPontos := fStopLoss - fEntrada;
      fTakeProfit    := fEntrada - fRiscoEmPontos * RRR_Minimo;

      bRRROk := (fEntrada - fTakeProfit) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        fRiscoEmReais := CapitalConta * (RiscoPorcentagem / 100);
        fQuantidade   := Floor(fRiscoEmReais / (fRiscoEmPontos * 0.20));
        if fQuantidade < 1 then fQuantidade := 1;

        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

  end;

end;
Compilando ...
Parser[228,7]: Função ou variável inválida: Hour
Parser[231,5]: Exit não é um identificador válido
Parser[235,7]: Função ou variável inválida: Hour
Parser[247,5]: Exit não é um identificador válido
Parser[302,1]: O código deve começar com begin
Erro de Sintaxe
{
  Indicador: IND_AREAS_CONFLUENCIA_V1
  Descricao: Indicador visual de áreas de confluência geométrica — corpos sobrepostos
  Ativo: WIN B3
  Timeframe: qualquer
  Versao: 1.0
  Tipo: Indicador (.ntfl) — para validação visual antes de implementar robô
}

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
input
  ForcaMinimaEntrada(60.0);     // força mínima para marcar candle como relevante
  VolumeMultiplicador(1.5);     // volume mínimo vs média 20
  ToleranciaZona(50.0);         // buffer de sobreposição em pts
  MostrarTextoForca(true);      // exibir valor da força no candle
  MostrarAlertas(true);         // emitir alerta quando zona de confluência detectada

// ═══════════════════════════════════════════════════════════════════════════════
// VARIÁVEIS
// ═══════════════════════════════════════════════════════════════════════════════
var
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  fVolumeMedio      : float;
  iCorR, iCorG, iCorB : integer;
  bSinalCompra      : boolean;
  bSinalVenda       : boolean;
  bRejeicaoForte    : boolean;
  bAnomaliaVolume   : boolean;
  fPavioSup         : float;
  fPavioInf         : float;

  // Zonas para visualização
  iConfluenciasCompra : integer;
  iConfluenciasVenda  : integer;

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

  // ─── SEÇÃO 2: PADRÕES ESPECIAIS ───────────────────────────────────────────
  fPavioSup := High - Max(Open, Close);
  fPavioInf := Min(Open, Close) - Low;

  // Rejeição forte: pavios totalizam > 60% do range
  bRejeicaoForte := ((fPavioSup + fPavioInf) / fRangeCandle) >= 0.60;

  // Anomalia de volume: volume > 3× média
  bAnomaliaVolume := (Volume >= fVolumeMedio * 3.0);

  // ─── SEÇÃO 3: GRADIENTE DE CORES + CORES ESPECIAIS ───────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;  // cinza = padrão

  if bRejeicaoForte then
  begin
    // Laranja = rejeição forte
    iCorR := 255; iCorG := 165; iCorB := 0;
  end
  else if bAnomaliaVolume then
  begin
    // Amarelo = anomalia de volume
    iCorR := 255; iCorG := 215; iCorB := 0;
  end
  else if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    // Branco = indecisão
    iCorR := 255; iCorG := 255; iCorB := 255;
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

  // ─── SEÇÃO 4: TEXTO DE FORÇA (apenas indicador) ───────────────────────────
  if MostrarTextoForca and (abs(fForca) >= ForcaMinimaEntrada) then
  begin
    if fForca >= ForcaMinimaEntrada then
      PlotText(Format('%.0f', [fForca]), RGB(0, 200, 0), 8, 0, Low * 0.998)
    else
      PlotText(Format('%.0f', [fForca]), RGB(200, 0, 0), 8, 0, High * 1.002);
  end;

  // ─── SEÇÃO 5: SETAS DE CONFLUÊNCIA ───────────────────────────────────────
  // Detectar confluência simplificada: 2 candles de força na mesma direção
  // dentro de uma janela de ToleranciaZona pts

  bSinalCompra := (fForca >= ForcaMinimaEntrada) and
                  (Volume >= fVolumeMedio * VolumeMultiplicador) and
                  (Close[1] > Open[1]) and
                  (abs(Close[1] - Open[1]) >= 0.40 * (High[1] - Low[1])) and
                  (abs(Close - Open[1]) <= ToleranciaZona);

  bSinalVenda := (fForca <= -ForcaMinimaEntrada) and
                 (Volume >= fVolumeMedio * VolumeMultiplicador) and
                 (Close[1] < Open[1]) and
                 (abs(Close[1] - Open[1]) >= 0.40 * (High[1] - Low[1])) and
                 (abs(Close - Open[1]) <= ToleranciaZona);

  if bSinalCompra then
  begin
    DrawArrow(1, RGB(0, 255, 0), 2, Low * 0.995);  // seta para cima = compra
    if MostrarAlertas then Alert(RGB(0, 255, 0));
    PlotText('CONFLUÊNCIA COMPRA', RGB(0, 200, 0), 9, 1, Low * 0.993);
  end;

  if bSinalVenda then
  begin
    DrawArrow(0, RGB(255, 0, 0), 2, High * 1.005);  // seta para baixo = venda
    if MostrarAlertas then Alert(RGB(255, 0, 0));
    PlotText('CONFLUÊNCIA VENDA', RGB(200, 0, 0), 9, 1, High * 1.007);
  end;

end;
Compilando ...
Parser[111,16]: Uma String necessita ser delimitada por aspas duplas ""
Parser[134,5]: DrawArrow não é um identificador válido
Parser[136,14]: Uma String necessita ser delimitada por aspas duplas ""
Parser[141,5]: DrawArrow não é um identificador válido
Parser[143,14]: Uma String necessita ser delimitada por aspas duplas ""
Parser[146,1]: O código deve começar com begin
Erro de Sintaxe

{
  Indicador: IND_AREAS_CONFLUENCIA_V1
  Descricao: Indicador visual de áreas de confluência geométrica — corpos sobrepostos
  Ativo: WIN B3
  Timeframe: qualquer
  Versao: 1.0
  Tipo: Indicador (.ntfl) — para validação visual antes de implementar robô
}

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
input
  ForcaMinimaEntrada(60.0);     // força mínima para marcar candle como relevante
  VolumeMultiplicador(1.5);     // volume mínimo vs média 20
  ToleranciaZona(50.0);         // buffer de sobreposição em pts
  MostrarTextoForca(true);      // exibir valor da força no candle
  MostrarAlertas(true);         // emitir alerta quando zona de confluência detectada

// ═══════════════════════════════════════════════════════════════════════════════
// VARIÁVEIS
// ═══════════════════════════════════════════════════════════════════════════════
var
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  fVolumeMedio      : float;
  iCorR, iCorG, iCorB : integer;
  bSinalCompra      : boolean;
  bSinalVenda       : boolean;
  bRejeicaoForte    : boolean;
  bAnomaliaVolume   : boolean;
  fPavioSup         : float;
  fPavioInf         : float;

  // Zonas para visualização
  iConfluenciasCompra : integer;
  iConfluenciasVenda  : integer;

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

  // ─── SEÇÃO 2: PADRÕES ESPECIAIS ───────────────────────────────────────────
  fPavioSup := High - Max(Open, Close);
  fPavioInf := Min(Open, Close) - Low;

  // Rejeição forte: pavios totalizam > 60% do range
  bRejeicaoForte := ((fPavioSup + fPavioInf) / fRangeCandle) >= 0.60;

  // Anomalia de volume: volume > 3× média
  bAnomaliaVolume := (Volume >= fVolumeMedio * 3.0);

  // ─── SEÇÃO 3: GRADIENTE DE CORES + CORES ESPECIAIS ───────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;  // cinza = padrão

  if bRejeicaoForte then
  begin
    // Laranja = rejeição forte
    iCorR := 255; iCorG := 165; iCorB := 0;
  end
  else if bAnomaliaVolume then
  begin
    // Amarelo = anomalia de volume
    iCorR := 255; iCorG := 215; iCorB := 0;
  end
  else if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    // Branco = indecisão
    iCorR := 255; iCorG := 255; iCorB := 255;
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

  // ─── SEÇÃO 4: TEXTO DE FORÇA (apenas indicador) ───────────────────────────
  if MostrarTextoForca and (abs(fForca) >= ForcaMinimaEntrada) then
  begin
    // Format() não existe em NTSL — usar IntToStr(Round(x))
    if fForca >= ForcaMinimaEntrada then
      PlotText(IntToStr(Round(fForca)), RGB(0, 200, 0), 8, 0, Low * 0.998)
    else
      PlotText(IntToStr(Round(fForca)), RGB(200, 0, 0), 8, 0, High * 1.002);
  end;

  // ─── SEÇÃO 5: SETAS DE CONFLUÊNCIA ───────────────────────────────────────
  // Detectar confluência simplificada: 2 candles de força na mesma direção
  // dentro de uma janela de ToleranciaZona pts

  bSinalCompra := (fForca >= ForcaMinimaEntrada) and
                  (Volume >= fVolumeMedio * VolumeMultiplicador) and
                  (Close[1] > Open[1]) and
                  (abs(Close[1] - Open[1]) >= 0.40 * (High[1] - Low[1])) and
                  (abs(Close - Open[1]) <= ToleranciaZona);

  bSinalVenda := (fForca <= -ForcaMinimaEntrada) and
                 (Volume >= fVolumeMedio * VolumeMultiplicador) and
                 (Close[1] < Open[1]) and
                 (abs(Close[1] - Open[1]) >= 0.40 * (High[1] - Low[1])) and
                 (abs(Close - Open[1]) <= ToleranciaZona);

  if bSinalCompra then
  begin
    // DrawArrow não é identificador válido em NTSL — usar PlotText + PaintBar
    PaintBar(RGB(0, 255, 100));  // verde intenso = sinal de compra
    if MostrarAlertas then Alert(RGB(0, 255, 0));
    PlotText("COMPRA", RGB(0, 200, 0), 9, 1, Low * 0.993);
  end;

  if bSinalVenda then
  begin
    // DrawArrow não é identificador válido em NTSL — usar PlotText + PaintBar
    PaintBar(RGB(255, 50, 0));   // vermelho intenso = sinal de venda
    if MostrarAlertas then Alert(RGB(255, 0, 0));
    PlotText("VENDA", RGB(200, 0, 0), 9, 1, High * 1.007);
  end;

end;
Compilando ...
Parser[112,16]: Uma String necessita ser delimitada por aspas duplas ""
Parser[149,1]: O código deve começar com begin
Erro de Sintaxe

{
  Robo: ROB_SEMAFORO_MULTI_TF_V1
  Descricao: Semáforo de tripleta — Contexto > Direção > Gatilho. Opera somente com TF1+TF2 alinhados.
  Ativo: WIN B3 / WDO B3
  Timeframe: TF3 (Gatilho) — configurar via iJanelaDir e iJanelaCtx
  Versao: 2.0
  RRR_minimo: 2.0
  SL_referencia: extremo do candle gatilho ± BufferStop

  TRIPLETAS RECOMENDADAS (configurar iJanelaDir e iJanelaCtx):
    60/30/15 → rob. roda em 15min → iJanelaDir=2, iJanelaCtx=4   | WIN SL=250pts | WDO SL=10pts
    30/15/5  → rob. roda em 5min  → iJanelaDir=3, iJanelaCtx=6   | WIN SL=150pts | WDO SL=6pts  ← PADRÃO
    15/5/1   → rob. roda em 1min  → iJanelaDir=5, iJanelaCtx=15  | WIN SL=80pts  | WDO SL=3pts
    30/10/5  → rob. roda em 5min  → iJanelaDir=2, iJanelaCtx=6
    60/20/5  → rob. roda em 5min  → iJanelaDir=4, iJanelaCtx=12

  REGRA CARDINAL: Opera SOMENTE quando Contexto(TF1) E Direção(TF2) estão alinhados.
}

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
input
  // ── Tripleta (configurar conforme a tabela de tripletas) ──────────────────
  // Padrão: 30/15/5 rodando em 5min → iJanelaDir=3, iJanelaCtx=6
  // 60/30/15 em 15min → iJanelaDir=2, iJanelaCtx=4
  // 15/5/1  em 1min  → iJanelaDir=5, iJanelaCtx=15
  iJanelaDir(3);                  // barras do TF2 (Direção) em TF3 (Gatilho)
  iJanelaCtx(6);                  // barras do TF1 (Contexto) em TF3 (Gatilho)

  ForcaMinimaEntrada(60.0);       // força mínima no TF3 para acionar gatilho
  ForcaMinimaContexto(20.0);      // força mínima nos proxies de TF1/TF2
  VolumeMultiplicador(1.5);
  RRR_Minimo(2.0);
  BufferStop(5.0);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);
  HoraInicioOperacao_H(9);
  HoraInicioOperacao_M(15);

// ═══════════════════════════════════════════════════════════════════════════════
// VARIÁVEIS
// ═══════════════════════════════════════════════════════════════════════════════
var
  fCorpoCandle         : float;
  fRangeCandle         : float;
  fMassa               : float;
  fAceleracao          : float;
  fForca               : float;
  fVolumeMedio         : float;
  iCorR, iCorG, iCorB  : integer;

  // Proxies da Tripleta (iJanelaDir → TF2 Direção, iJanelaCtx → TF1 Contexto)
  fMediaDir            : float;   // proxy TF2 — Media(iJanelaDir, Close)
  fMediaCtx            : float;   // proxy TF1 — Media(iJanelaCtx, Close)
  bContextoAlta        : boolean; // TF1 inclinando para cima
  bContextoBaixa       : boolean; // TF1 inclinando para baixo
  bDirecaoAlta         : boolean; // TF2 inclinando para cima
  bDirecaoBaixa        : boolean; // TF2 inclinando para baixo

  // Sinais combinados
  bSemVerdeCompra      : boolean;  // TF maior + gatilho = compra
  bSemVerdeVenda       : boolean;  // TF maior + gatilho = venda

  // Semáforo (confirmação de 2 candles consecutivos)
  iContadorCompra      : integer;
  iContadorVenda       : integer;
  bEntradaConfirmada   : boolean;

  // Gestão
  fEntrada             : float;
  fStopLoss            : float;
  fTakeProfit          : float;
  fRiscoEmPontos       : float;
  iBarrasEmPosicao     : integer;
  bRRROk               : boolean;
  // Controle de horário (Time() = HHMMSS — Hour/Minute/Exit não existem em NTSL)
  iHoraAtual           : integer;
  iMinutoAtual         : integer;
  bDeveOperar          : boolean;

begin

  // ─── SEÇÃO 1: FORÇA DO CANDLE ATUAL (TF gatilho) ──────────────────────────
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

  // ─── SEÇÃO 2: PROXY DA TRIPLETA (Contexto TF1 + Direção TF2) ────────────────
  // Cada proxy compara o Close atual vs média de iJanela barras.
  // iJanelaDir barras → representa TF2 (Direção)
  // iJanelaCtx barras → representa TF1 (Contexto)
  //
  // Tabela de configuração (ver cabeçalho):
  //   Tripleta 30/15/5  em 5min  → iJanelaDir=3, iJanelaCtx=6
  //   Tripleta 60/30/15 em 15min → iJanelaDir=2, iJanelaCtx=4
  //   Tripleta 15/5/1   em 1min  → iJanelaDir=5, iJanelaCtx=15
  fMediaDir := Media(iJanelaDir, Close);
  fMediaCtx := Media(iJanelaCtx, Close);

  // Direção (TF2): preço acima/abaixo da média de TF2 E média inclinando
  bContextoAlta  := (Close > fMediaCtx) and (fMediaCtx > fMediaCtx[iJanelaCtx]);
  bContextoBaixa := (Close < fMediaCtx) and (fMediaCtx < fMediaCtx[iJanelaCtx]);
  bDirecaoAlta   := (Close > fMediaDir) and (fMediaDir > fMediaDir[iJanelaDir]);
  bDirecaoBaixa  := (Close < fMediaDir) and (fMediaDir < fMediaDir[iJanelaDir]);

  // ─── SEÇÃO 3: GRADIENTE (TF atual + contexto) ─────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;

  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  else if fForca >= ForcaMinimaEntrada then
  begin
    if bContextoAlta then
    begin
      // Azul = confirmação multi-TF de compra
      iCorR := 0; iCorG := 128; iCorB := 255;
    end
    else
    begin
      iCorG := 128 + Round((fForca / 100) * 127);
      iCorR := 128 - Round((fForca / 100) * 128);
      iCorB := 128 - Round((fForca / 100) * 128);
      if iCorG > 255 then iCorG := 255;
      if iCorR < 0   then iCorR := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end
  else if fForca <= -ForcaMinimaEntrada then
  begin
    if bContextoBaixa then
    begin
      // Azul escuro = confirmação multi-TF de venda
      iCorR := 80; iCorG := 0; iCorB := 200;
    end
    else
    begin
      iCorR := 128 + Round((-fForca / 100) * 127);
      iCorG := 128 - Round((-fForca / 100) * 128);
      iCorB := 128 - Round((-fForca / 100) * 128);
      if iCorR > 255 then iCorR := 255;
      if iCorG < 0   then iCorG := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 4: SEMÁFORO — CONFIRMAÇÃO DE 2 CANDLES ────────────────────────
  // REGRA CARDINAL: Contexto(TF1) E Direção(TF2) AMBOS alinhados + força no gatilho
  bSemVerdeCompra := (fForca >= ForcaMinimaEntrada) and
                     bContextoAlta and bDirecaoAlta and
                     (Volume >= fVolumeMedio * VolumeMultiplicador);

  bSemVerdeVenda  := (fForca <= -ForcaMinimaEntrada) and
                     bContextoBaixa and bDirecaoBaixa and
                     (Volume >= fVolumeMedio * VolumeMultiplicador);

  // Contadores de persistência (2 candles consecutivos no mesmo lado)
  if bSemVerdeCompra then
    iContadorCompra := iContadorCompra + 1
  else
    iContadorCompra := 0;

  if bSemVerdeVenda then
    iContadorVenda := iContadorVenda + 1
  else
    iContadorVenda := 0;

  // Entrada confirmada apenas após 2 candles consecutivos (evita sinais rápidos)
  bEntradaConfirmada := (iContadorCompra >= 2) or (iContadorVenda >= 2);

  // ─── SEÇÃO 5: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  begin
    if IsBought or IsSold then ClosePosition;
    Exit;
  end;

  // Aguardar após abertura
  if (Hour = HoraInicioOperacao_H) and (Minute < HoraInicioOperacao_M) then Exit;
  if Hour < HoraInicioOperacao_H then Exit;

  // ─── SEÇÃO 6: CONTROLE DE BARRAS ──────────────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;

  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    Exit;
  end;

  // ─── SEÇÃO 7: ENTRADAS ────────────────────────────────────────────────────
  if (not IsBought) and (not IsSold) and bEntradaConfirmada then
  begin

    if iContadorCompra >= 2 then
    begin
      fEntrada       := Close;
      fStopLoss      := Low - BufferStop;
      fRiscoEmPontos := fEntrada - fStopLoss;
      fTakeProfit    := fEntrada + fRiscoEmPontos * RRR_Minimo;
      bRRROk         := (fTakeProfit - fEntrada) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
        iContadorCompra  := 0;
      end;
    end;

    if iContadorVenda >= 2 then
    begin
      fEntrada       := Close;
      fStopLoss      := High + BufferStop;
      fRiscoEmPontos := fStopLoss - fEntrada;
      fTakeProfit    := fEntrada - fRiscoEmPontos * RRR_Minimo;
      bRRROk         := (fEntrada - fTakeProfit) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
        iContadorVenda   := 0;
      end;
    end;

  end;

end;

Compilando ...
Parser[186,7]: Função ou variável inválida: Hour
Parser[189,5]: Exit não é um identificador válido
Parser[193,7]: Função ou variável inválida: Hour
Parser[194,6]: Função ou variável inválida: Hour
Parser[206,5]: Exit não é um identificador válido
Parser[247,1]: O código deve começar com begin
Erro de Sintaxe
{
  Robo: ROB_CONFLUENCIA_V1
  Descricao: Robô de confluência geométrica — entradas em zonas com ≥2 referências sobrepostas
  Ativo: WIN B3
  Timeframe: 5min
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: minima/maxima da zona de confluencia detectada
  Spread_descontado: 10 pts (comentado — desconto no backtest)
  Slippage_descontado: 15 pts (comentado — desconto no backtest)
  Periodo_minimo_backtest: 90 dias / 100 trades
  Aprovado_em: pendente backtest
}

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
input
  ForcaMinimaEntrada(60.0);       // força mínima para considerar candle direcional
  RRR_Minimo(2.0);                // razão risco/recompensa mínima para entrar
  VolumeMultiplicador(1.5);       // volume deve ser X vezes a média de 20 períodos
  ToleranciaZona(50.0);           // buffer em pts para considerar sobreposição de áreas
  FatorTamanhoArea(1.0);          // multiplicador do corpo para tamanho da área
  StopHorario_H(17);              // hora de encerrar posições
  StopHorario_M(45);              // minuto de encerrar posições
  MaxBarrasEmPosicao(8);          // máximo de candles em posição aberta
  CapitalConta(10000.0);          // capital total para dimensionamento
  RiscoPorcentagem(2.0);          // % do capital por trade

// ═══════════════════════════════════════════════════════════════════════════════
// VARIÁVEIS
// ═══════════════════════════════════════════════════════════════════════════════
var
  // Força F = M × A
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  fVolumeMedio      : float;

  // Cores
  iCorR, iCorG, iCorB : integer;

  // Zonas de confluência (corpo dos últimos N candles relevantes)
  // Armazenamos os extremos dos últimos 5 candles de força
  fZonaCompraMin    : float;
  fZonaCompraMax    : float;
  fZonaVendaMin     : float;
  fZonaVendaMax     : float;
  iConfluenciasCompra : integer;
  iConfluenciasVenda  : integer;

  // Gestão de risco
  fEntrada          : float;
  fStopLoss         : float;
  fTakeProfit       : float;
  fRiscoEmPontos    : float;
  fRiscoEmReais     : float;
  fQuantidade       : float;

  // Sinais
  bSinalCompra      : boolean;
  bSinalVenda       : boolean;
  bNaZonaCompra     : boolean;
  bNaZonaVenda      : boolean;
  bVolConfirmado    : boolean;
  bRRROk            : boolean;

  // Controle
  iBarrasEmPosicao  : integer;
  // Controle de horário (Time() = HHMMSS — Hour/Minute/Exit não existem em NTSL)
  iHoraAtual        : integer;
  iMinutoAtual      : integer;
  bDeveOperar       : boolean;

begin

  // ─── SEÇÃO 1: FORÇA F = M × A ──────────────────────────────────────────────
  // Mede a intensidade direcional do candle atual ponderada pelo volume relativo
  fCorpoCandle := Close - Open;
  fRangeCandle := High - Low;
  if fRangeCandle < 0.01 then fRangeCandle := 0.01;  // guard divisão por zero

  fMassa       := fCorpoCandle / fRangeCandle;        // -1.0 a +1.0
  fVolumeMedio := Media(20, Volume);
  if fVolumeMedio > 0 then
    fAceleracao := Volume / fVolumeMedio
  else
    fAceleracao := 1;

  fForca := fMassa * fAceleracao * 100;
  if fForca >  100 then fForca :=  100;
  if fForca < -100 then fForca := -100;

  // ─── SEÇÃO 2: GRADIENTE DE CORES ──────────────────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;  // cinza = padrão

  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    // Branco = indecisão (corpo < 10% do range)
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  else if fForca >= ForcaMinimaEntrada then
  begin
    // Verde degradê — quanto maior a força, mais saturado o verde
    iCorG := 128 + Round((fForca / 100) * 127);
    iCorR := 128 - Round((fForca / 100) * 128);
    iCorB := 128 - Round((fForca / 100) * 128);
    if iCorG > 255 then iCorG := 255;
    if iCorR < 0   then iCorR := 0;
    if iCorB < 0   then iCorB := 0;
  end
  else if fForca <= -ForcaMinimaEntrada then
  begin
    // Vermelho degradê — quanto menor a força, mais saturado o vermelho
    iCorR := 128 + Round((-fForca / 100) * 127);
    iCorG := 128 - Round((-fForca / 100) * 128);
    iCorB := 128 - Round((-fForca / 100) * 128);
    if iCorR > 255 then iCorR := 255;
    if iCorG < 0   then iCorG := 0;
    if iCorB < 0   then iCorB := 0;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 3: ZONAS DE CONFLUÊNCIA ────────────────────────────────────────
  // Verifica se o preço atual está dentro de uma zona de sobreposição de corpos
  // de candles de força anteriores.
  //
  // Estratégia simplificada: usar os últimos 5 candles de força como referência.
  // Zona de compra = região onde corpos de compra se sobrepõem (baixo dos corpos)
  // Zona de venda  = região onde corpos de venda se sobrepõem  (alto dos corpos)

  iConfluenciasCompra := 0;
  iConfluenciasVenda  := 0;
  fZonaCompraMin := 999999; fZonaCompraMax := 0;
  fZonaVendaMin  := 999999; fZonaVendaMax  := 0;

  // --- Candle -1
  if (Close[1] > Open[1]) and (abs(Close[1]-Open[1]) >= 0.40 * (High[1]-Low[1])) then
  begin
    fZonaCompraMin := Open[1];
    fZonaCompraMax := Close[1];
    iConfluenciasCompra := iConfluenciasCompra + 1;
  end;
  if (Close[1] < Open[1]) and (abs(Close[1]-Open[1]) >= 0.40 * (High[1]-Low[1])) then
  begin
    fZonaVendaMin := Close[1];
    fZonaVendaMax := Open[1];
    iConfluenciasVenda := iConfluenciasVenda + 1;
  end;

  // --- Candle -2
  if (Close[2] > Open[2]) and (abs(Close[2]-Open[2]) >= 0.40 * (High[2]-Low[2])) then
  begin
    // Verificar sobreposição com zona existente
    if (fZonaCompraMin < 999999) then
    begin
      if (Open[2] <= fZonaCompraMax + ToleranciaZona) and
         (Close[2] >= fZonaCompraMin - ToleranciaZona) then
      begin
        // Atualizar zona para intersecção
        if Open[2]  > fZonaCompraMin then fZonaCompraMin := Open[2];
        if Close[2] < fZonaCompraMax then fZonaCompraMax := Close[2];
        iConfluenciasCompra := iConfluenciasCompra + 1;
      end;
    end
    else
    begin
      fZonaCompraMin := Open[2];
      fZonaCompraMax := Close[2];
      iConfluenciasCompra := 1;
    end;
  end;

  if (Close[2] < Open[2]) and (abs(Close[2]-Open[2]) >= 0.40 * (High[2]-Low[2])) then
  begin
    if (fZonaVendaMin < 999999) then
    begin
      if (Close[2] <= fZonaVendaMax + ToleranciaZona) and
         (Open[2]  >= fZonaVendaMin - ToleranciaZona) then
      begin
        if Close[2] > fZonaVendaMin then fZonaVendaMin := Close[2];
        if Open[2]  < fZonaVendaMax then fZonaVendaMax := Open[2];
        iConfluenciasVenda := iConfluenciasVenda + 1;
      end;
    end
    else
    begin
      fZonaVendaMin := Close[2];
      fZonaVendaMax := Open[2];
      iConfluenciasVenda := 1;
    end;
  end;

  // --- Candle -3 (mesma lógica)
  if (Close[3] > Open[3]) and (abs(Close[3]-Open[3]) >= 0.40 * (High[3]-Low[3])) then
    if (fZonaCompraMin < 999999) and
       (Open[3] <= fZonaCompraMax + ToleranciaZona) and
       (Close[3] >= fZonaCompraMin - ToleranciaZona) then
      iConfluenciasCompra := iConfluenciasCompra + 1;

  if (Close[3] < Open[3]) and (abs(Close[3]-Open[3]) >= 0.40 * (High[3]-Low[3])) then
    if (fZonaVendaMin < 999999) and
       (Close[3] <= fZonaVendaMax + ToleranciaZona) and
       (Open[3]  >= fZonaVendaMin - ToleranciaZona) then
      iConfluenciasVenda := iConfluenciasVenda + 1;

  // Verificar se o preço atual está dentro das zonas
  bNaZonaCompra := (iConfluenciasCompra >= 2) and
                   (Close >= fZonaCompraMin - ToleranciaZona) and
                   (Close <= fZonaCompraMax + ToleranciaZona);

  bNaZonaVenda  := (iConfluenciasVenda >= 2) and
                   (Close >= fZonaVendaMin  - ToleranciaZona) and
                   (Close <= fZonaVendaMax  + ToleranciaZona);

  // ─── SEÇÃO 4: CONFIRMAÇÃO DE VOLUME ───────────────────────────────────────
  bVolConfirmado := (Volume >= fVolumeMedio * VolumeMultiplicador);

  // ─── SEÇÃO 5: SINAIS DE ENTRADA ───────────────────────────────────────────
  bSinalCompra := bNaZonaCompra and
                  (fForca >= ForcaMinimaEntrada) and
                  bVolConfirmado;

  bSinalVenda  := bNaZonaVenda and
                  (fForca <= -ForcaMinimaEntrada) and
                  bVolConfirmado;

  // ─── SEÇÃO 6: STOP HORÁRIO ────────────────────────────────────────────────
  if (Hour >= StopHorario_H) and (Minute >= StopHorario_M) then
  begin
    if IsBought or IsSold then ClosePosition;
    Exit;  // não abrir novas posições após horário limite
  end;

  // Evitar abertura antes de 09:15 (volatilidade da abertura)
  if (Hour = 9) and (Minute < 15) then Exit;

  // ─── SEÇÃO 7: CONTROLE DE BARRAS EM POSIÇÃO ───────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;

  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    Exit;
  end;

  // ─── SEÇÃO 8: ENTRADAS ────────────────────────────────────────────────────
  if (not IsBought) and (not IsSold) then
  begin

    // COMPRA: zona de confluência de alta + candle de força + volume
    if bSinalCompra then
    begin
      fEntrada       := Close;
      // SL = mínimo da zona de confluência de compra com buffer
      fStopLoss      := fZonaCompraMin - 5;
      fRiscoEmPontos := fEntrada - fStopLoss;
      fTakeProfit    := fEntrada + fRiscoEmPontos * RRR_Minimo;

      // Verificar RRR antes de entrar
      bRRROk := (fTakeProfit - fEntrada) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        // Dimensionar quantidade pelo risco
        fRiscoEmReais := CapitalConta * (RiscoPorcentagem / 100);
        // Floor() não existe em NTSL — usar divisão inteira + guarda mínimo
        fQuantidade   := fRiscoEmReais / (fRiscoEmPontos * 0.20);
        if fQuantidade < 1 then fQuantidade := 1;

        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

    // VENDA: zona de confluência de baixa + candle de força + volume
    if bSinalVenda then
    begin
      fEntrada       := Close;
      // SL = máximo da zona de confluência de venda com buffer
      fStopLoss      := fZonaVendaMax + 5;
      fRiscoEmPontos := fStopLoss - fEntrada;
      fTakeProfit    := fEntrada - fRiscoEmPontos * RRR_Minimo;

      bRRROk := (fEntrada - fTakeProfit) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        fRiscoEmReais := CapitalConta * (RiscoPorcentagem / 100);
        // Floor() não existe em NTSL — usar divisão inteira + guarda mínimo
        fQuantidade   := fRiscoEmReais / (fRiscoEmPontos * 0.20);
        if fQuantidade < 1 then fQuantidade := 1;

        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

  end;

end;

Compilando ...
Parser[232,7]: Função ou variável inválida: Hour
Parser[235,5]: Exit não é um identificador válido
Parser[239,7]: Função ou variável inválida: Hour
Parser[251,5]: Exit não é um identificador válido
Parser[308,1]: O código deve começar com begin
Erro de Sintaxe

{
  Robo: ROB_CONFLUENCIA_V1
  Descricao: Robô de confluência geométrica — entradas em zonas com ≥2 referências sobrepostas
  Ativo: WIN B3
  Timeframe: 5min
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: minima/maxima da zona de confluencia detectada
  Spread_descontado: 10 pts (comentado — desconto no backtest)
  Slippage_descontado: 15 pts (comentado — desconto no backtest)
  Periodo_minimo_backtest: 90 dias / 100 trades
  Aprovado_em: pendente backtest
}

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
input
  ForcaMinimaEntrada(60.0);       // força mínima para considerar candle direcional
  RRR_Minimo(2.0);                // razão risco/recompensa mínima para entrar
  VolumeMultiplicador(1.5);       // volume deve ser X vezes a média de 20 períodos
  ToleranciaZona(50.0);           // buffer em pts para considerar sobreposição de áreas
  FatorTamanhoArea(1.0);          // multiplicador do corpo para tamanho da área
  StopHorario_H(17);              // hora de encerrar posições
  StopHorario_M(45);              // minuto de encerrar posições
  MaxBarrasEmPosicao(8);          // máximo de candles em posição aberta
  CapitalConta(10000.0);          // capital total para dimensionamento
  RiscoPorcentagem(2.0);          // % do capital por trade

// ═══════════════════════════════════════════════════════════════════════════════
// VARIÁVEIS
// ═══════════════════════════════════════════════════════════════════════════════
var
  // Força F = M × A
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  fVolumeMedio      : float;

  // Cores
  iCorR, iCorG, iCorB : integer;

  // Zonas de confluência (corpo dos últimos N candles relevantes)
  // Armazenamos os extremos dos últimos 5 candles de força
  fZonaCompraMin    : float;
  fZonaCompraMax    : float;
  fZonaVendaMin     : float;
  fZonaVendaMax     : float;
  iConfluenciasCompra : integer;
  iConfluenciasVenda  : integer;

  // Gestão de risco
  fEntrada          : float;
  fStopLoss         : float;
  fTakeProfit       : float;
  fRiscoEmPontos    : float;
  fRiscoEmReais     : float;
  fQuantidade       : float;

  // Sinais
  bSinalCompra      : boolean;
  bSinalVenda       : boolean;
  bNaZonaCompra     : boolean;
  bNaZonaVenda      : boolean;
  bVolConfirmado    : boolean;
  bRRROk            : boolean;

  // Controle
  iBarrasEmPosicao  : integer;
  // Controle de horário (Time() = HHMMSS — Hour/Minute/Exit não existem em NTSL)
  iHoraAtual        : integer;
  iMinutoAtual      : integer;
  bDeveOperar       : boolean;

begin

  // ─── SEÇÃO 1: FORÇA F = M × A ──────────────────────────────────────────────
  // Mede a intensidade direcional do candle atual ponderada pelo volume relativo
  fCorpoCandle := Close - Open;
  fRangeCandle := High - Low;
  if fRangeCandle < 0.01 then fRangeCandle := 0.01;  // guard divisão por zero

  fMassa       := fCorpoCandle / fRangeCandle;        // -1.0 a +1.0
  fVolumeMedio := Media(20, Volume);
  if fVolumeMedio > 0 then
    fAceleracao := Volume / fVolumeMedio
  else
    fAceleracao := 1;

  fForca := fMassa * fAceleracao * 100;
  if fForca >  100 then fForca :=  100;
  if fForca < -100 then fForca := -100;

  // ─── SEÇÃO 2: GRADIENTE DE CORES ──────────────────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;  // cinza = padrão

  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    // Branco = indecisão (corpo < 10% do range)
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  else if fForca >= ForcaMinimaEntrada then
  begin
    // Verde degradê — quanto maior a força, mais saturado o verde
    iCorG := 128 + Round((fForca / 100) * 127);
    iCorR := 128 - Round((fForca / 100) * 128);
    iCorB := 128 - Round((fForca / 100) * 128);
    if iCorG > 255 then iCorG := 255;
    if iCorR < 0   then iCorR := 0;
    if iCorB < 0   then iCorB := 0;
  end
  else if fForca <= -ForcaMinimaEntrada then
  begin
    // Vermelho degradê — quanto menor a força, mais saturado o vermelho
    iCorR := 128 + Round((-fForca / 100) * 127);
    iCorG := 128 - Round((-fForca / 100) * 128);
    iCorB := 128 - Round((-fForca / 100) * 128);
    if iCorR > 255 then iCorR := 255;
    if iCorG < 0   then iCorG := 0;
    if iCorB < 0   then iCorB := 0;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 3: ZONAS DE CONFLUÊNCIA ────────────────────────────────────────
  // Verifica se o preço atual está dentro de uma zona de sobreposição de corpos
  // de candles de força anteriores.
  //
  // Estratégia simplificada: usar os últimos 5 candles de força como referência.
  // Zona de compra = região onde corpos de compra se sobrepõem (baixo dos corpos)
  // Zona de venda  = região onde corpos de venda se sobrepõem  (alto dos corpos)

  iConfluenciasCompra := 0;
  iConfluenciasVenda  := 0;
  fZonaCompraMin := 999999; fZonaCompraMax := 0;
  fZonaVendaMin  := 999999; fZonaVendaMax  := 0;

  // --- Candle -1
  if (Close[1] > Open[1]) and (abs(Close[1]-Open[1]) >= 0.40 * (High[1]-Low[1])) then
  begin
    fZonaCompraMin := Open[1];
    fZonaCompraMax := Close[1];
    iConfluenciasCompra := iConfluenciasCompra + 1;
  end;
  if (Close[1] < Open[1]) and (abs(Close[1]-Open[1]) >= 0.40 * (High[1]-Low[1])) then
  begin
    fZonaVendaMin := Close[1];
    fZonaVendaMax := Open[1];
    iConfluenciasVenda := iConfluenciasVenda + 1;
  end;

  // --- Candle -2
  if (Close[2] > Open[2]) and (abs(Close[2]-Open[2]) >= 0.40 * (High[2]-Low[2])) then
  begin
    // Verificar sobreposição com zona existente
    if (fZonaCompraMin < 999999) then
    begin
      if (Open[2] <= fZonaCompraMax + ToleranciaZona) and
         (Close[2] >= fZonaCompraMin - ToleranciaZona) then
      begin
        // Atualizar zona para intersecção
        if Open[2]  > fZonaCompraMin then fZonaCompraMin := Open[2];
        if Close[2] < fZonaCompraMax then fZonaCompraMax := Close[2];
        iConfluenciasCompra := iConfluenciasCompra + 1;
      end;
    end
    else
    begin
      fZonaCompraMin := Open[2];
      fZonaCompraMax := Close[2];
      iConfluenciasCompra := 1;
    end;
  end;

  if (Close[2] < Open[2]) and (abs(Close[2]-Open[2]) >= 0.40 * (High[2]-Low[2])) then
  begin
    if (fZonaVendaMin < 999999) then
    begin
      if (Close[2] <= fZonaVendaMax + ToleranciaZona) and
         (Open[2]  >= fZonaVendaMin - ToleranciaZona) then
      begin
        if Close[2] > fZonaVendaMin then fZonaVendaMin := Close[2];
        if Open[2]  < fZonaVendaMax then fZonaVendaMax := Open[2];
        iConfluenciasVenda := iConfluenciasVenda + 1;
      end;
    end
    else
    begin
      fZonaVendaMin := Close[2];
      fZonaVendaMax := Open[2];
      iConfluenciasVenda := 1;
    end;
  end;

  // --- Candle -3 (mesma lógica)
  if (Close[3] > Open[3]) and (abs(Close[3]-Open[3]) >= 0.40 * (High[3]-Low[3])) then
    if (fZonaCompraMin < 999999) and
       (Open[3] <= fZonaCompraMax + ToleranciaZona) and
       (Close[3] >= fZonaCompraMin - ToleranciaZona) then
      iConfluenciasCompra := iConfluenciasCompra + 1;

  if (Close[3] < Open[3]) and (abs(Close[3]-Open[3]) >= 0.40 * (High[3]-Low[3])) then
    if (fZonaVendaMin < 999999) and
       (Close[3] <= fZonaVendaMax + ToleranciaZona) and
       (Open[3]  >= fZonaVendaMin - ToleranciaZona) then
      iConfluenciasVenda := iConfluenciasVenda + 1;

  // Verificar se o preço atual está dentro das zonas
  bNaZonaCompra := (iConfluenciasCompra >= 2) and
                   (Close >= fZonaCompraMin - ToleranciaZona) and
                   (Close <= fZonaCompraMax + ToleranciaZona);

  bNaZonaVenda  := (iConfluenciasVenda >= 2) and
                   (Close >= fZonaVendaMin  - ToleranciaZona) and
                   (Close <= fZonaVendaMax  + ToleranciaZona);

  // ─── SEÇÃO 4: CONFIRMAÇÃO DE VOLUME ───────────────────────────────────────
  bVolConfirmado := (Volume >= fVolumeMedio * VolumeMultiplicador);

  // ─── SEÇÃO 5: SINAIS DE ENTRADA ───────────────────────────────────────────
  bSinalCompra := bNaZonaCompra and
                  (fForca >= ForcaMinimaEntrada) and
                  bVolConfirmado;

  bSinalVenda  := bNaZonaVenda and
                  (fForca <= -ForcaMinimaEntrada) and
                  bVolConfirmado;

  // ─── SEÇÃO 6: STOP HORÁRIO ────────────────────────────────────────────────
  iHoraAtual   := Time() div 10000;
  iMinutoAtual := (Time() mod 10000) div 100;

  if (iHoraAtual > StopHorario_H) or
     ((iHoraAtual = StopHorario_H) and (iMinutoAtual >= StopHorario_M)) then
  begin
    if IsBought or IsSold then ClosePosition;
    bDeveOperar := false;
  end
  else
    // Evitar abertura antes de 09:15 (volatilidade da abertura)
    bDeveOperar := (iHoraAtual > 9) or
                   ((iHoraAtual = 9) and (iMinutoAtual >= 15));

  // ─── SEÇÃO 7: CONTROLE DE BARRAS EM POSIÇÃO ───────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;

  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    bDeveOperar := false;
  end;

  // ─── SEÇÃO 8: ENTRADAS ────────────────────────────────────────────────────
  if bDeveOperar and (not IsBought) and (not IsSold) then
  begin

    // COMPRA: zona de confluência de alta + candle de força + volume
    if bSinalCompra then
    begin
      fEntrada       := Close;
      // SL = mínimo da zona de confluência de compra com buffer
      fStopLoss      := fZonaCompraMin - 5;
      fRiscoEmPontos := fEntrada - fStopLoss;
      fTakeProfit    := fEntrada + fRiscoEmPontos * RRR_Minimo;

      // Verificar RRR antes de entrar
      bRRROk := (fTakeProfit - fEntrada) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        // Dimensionar quantidade pelo risco
        fRiscoEmReais := CapitalConta * (RiscoPorcentagem / 100);
        // Floor() não existe em NTSL — usar divisão inteira + guarda mínimo
        fQuantidade   := fRiscoEmReais / (fRiscoEmPontos * 0.20);
        if fQuantidade < 1 then fQuantidade := 1;

        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

    // VENDA: zona de confluência de baixa + candle de força + volume
    if bSinalVenda then
    begin
      fEntrada       := Close;
      // SL = máximo da zona de confluência de venda com buffer
      fStopLoss      := fZonaVendaMax + 5;
      fRiscoEmPontos := fStopLoss - fEntrada;
      fTakeProfit    := fEntrada - fRiscoEmPontos * RRR_Minimo;

      bRRROk := (fEntrada - fTakeProfit) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        fRiscoEmReais := CapitalConta * (RiscoPorcentagem / 100);
        // Floor() não existe em NTSL — usar divisão inteira + guarda mínimo
        fQuantidade   := fRiscoEmReais / (fRiscoEmPontos * 0.20);
        if fQuantidade < 1 then fQuantidade := 1;

        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

  end;

end;
Compilando ...
Parser[232,26]: Depois de um statement deve vir " ; "
Parser[233,27]: Faltou um " ) "
Parser[313,1]: O código deve começar com begin
Erro de Sintaxe
{
  Indicador: IND_AREAS_CONFLUENCIA_V1
  Descricao: Indicador visual de áreas de confluência geométrica — corpos sobrepostos
  Ativo: WIN B3
  Timeframe: qualquer
  Versao: 1.0
  Tipo: Indicador (.ntfl) — para validação visual antes de implementar robô
}

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
input
  ForcaMinimaEntrada(60.0);     // força mínima para marcar candle como relevante
  VolumeMultiplicador(1.5);     // volume mínimo vs média 20
  ToleranciaZona(50.0);         // buffer de sobreposição em pts
  MostrarTextoForca(true);      // exibir valor da força no candle
  MostrarAlertas(true);         // emitir alerta quando zona de confluência detectada

// ═══════════════════════════════════════════════════════════════════════════════
// VARIÁVEIS
// ═══════════════════════════════════════════════════════════════════════════════
var
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  fVolumeMedio      : float;
  iCorR, iCorG, iCorB : integer;
  bSinalCompra      : boolean;
  bSinalVenda       : boolean;
  bRejeicaoForte    : boolean;
  bAnomaliaVolume   : boolean;
  fPavioSup         : float;
  fPavioInf         : float;

  // Zonas para visualização
  iConfluenciasCompra : integer;
  iConfluenciasVenda  : integer;

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

  // ─── SEÇÃO 2: PADRÕES ESPECIAIS ───────────────────────────────────────────
  fPavioSup := High - Max(Open, Close);
  fPavioInf := Min(Open, Close) - Low;

  // Rejeição forte: pavios totalizam > 60% do range
  bRejeicaoForte := ((fPavioSup + fPavioInf) / fRangeCandle) >= 0.60;

  // Anomalia de volume: volume > 3× média
  bAnomaliaVolume := (Volume >= fVolumeMedio * 3.0);

  // ─── SEÇÃO 3: GRADIENTE DE CORES + CORES ESPECIAIS ───────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;  // cinza = padrão

  if bRejeicaoForte then
  begin
    // Laranja = rejeição forte
    iCorR := 255; iCorG := 165; iCorB := 0;
  end
  else if bAnomaliaVolume then
  begin
    // Amarelo = anomalia de volume
    iCorR := 255; iCorG := 215; iCorB := 0;
  end
  else if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    // Branco = indecisão
    iCorR := 255; iCorG := 255; iCorB := 255;
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

  // ─── SEÇÃO 4: TEXTO DE FORÇA (apenas indicador) ───────────────────────────
  if MostrarTextoForca and (abs(fForca) >= ForcaMinimaEntrada) then
  begin
    // Format() não existe em NTSL — usar IntToStr(Round(x))
    if fForca >= ForcaMinimaEntrada then
      PlotText(IntToStr(Round(fForca)), RGB(0, 200, 0), 8, 0, Low * 0.998)
    else
      PlotText(IntToStr(Round(fForca)), RGB(200, 0, 0), 8, 0, High * 1.002);
  end;

  // ─── SEÇÃO 5: SETAS DE CONFLUÊNCIA ───────────────────────────────────────
  // Detectar confluência simplificada: 2 candles de força na mesma direção
  // dentro de uma janela de ToleranciaZona pts

  bSinalCompra := (fForca >= ForcaMinimaEntrada) and
                  (Volume >= fVolumeMedio * VolumeMultiplicador) and
                  (Close[1] > Open[1]) and
                  (abs(Close[1] - Open[1]) >= 0.40 * (High[1] - Low[1])) and
                  (abs(Close - Open[1]) <= ToleranciaZona);

  bSinalVenda := (fForca <= -ForcaMinimaEntrada) and
                 (Volume >= fVolumeMedio * VolumeMultiplicador) and
                 (Close[1] < Open[1]) and
                 (abs(Close[1] - Open[1]) >= 0.40 * (High[1] - Low[1])) and
                 (abs(Close - Open[1]) <= ToleranciaZona);

  if bSinalCompra then
  begin
    // DrawArrow não é identificador válido em NTSL — usar PlotText + PaintBar
    PaintBar(RGB(0, 255, 100));  // verde intenso = sinal de compra
    if MostrarAlertas then Alert(RGB(0, 255, 0));
    PlotText("COMPRA", RGB(0, 200, 0), 9, 1, Low * 0.993);
  end;

  if bSinalVenda then
  begin
    // DrawArrow não é identificador válido em NTSL — usar PlotText + PaintBar
    PaintBar(RGB(255, 50, 0));   // vermelho intenso = sinal de venda
    if MostrarAlertas then Alert(RGB(255, 0, 0));
    PlotText("VENDA", RGB(200, 0, 0), 9, 1, High * 1.007);
  end;

end;
Compilando ...
Parser[112,16]: Uma String necessita ser delimitada por aspas duplas ""
Parser[149,1]: O código deve começar com begin
Erro de Sintaxe

{
  Robo: ROB_SEMAFORO_MULTI_TF_V1
  Descricao: Semáforo de tripleta — Contexto > Direção > Gatilho. Opera somente com TF1+TF2 alinhados.
  Ativo: WIN B3 / WDO B3
  Timeframe: TF3 (Gatilho) — configurar via iJanelaDir e iJanelaCtx
  Versao: 2.0
  RRR_minimo: 2.0
  SL_referencia: extremo do candle gatilho ± BufferStop

  TRIPLETAS RECOMENDADAS (configurar iJanelaDir e iJanelaCtx):
    60/30/15 → rob. roda em 15min → iJanelaDir=2, iJanelaCtx=4   | WIN SL=250pts | WDO SL=10pts
    30/15/5  → rob. roda em 5min  → iJanelaDir=3, iJanelaCtx=6   | WIN SL=150pts | WDO SL=6pts  ← PADRÃO
    15/5/1   → rob. roda em 1min  → iJanelaDir=5, iJanelaCtx=15  | WIN SL=80pts  | WDO SL=3pts
    30/10/5  → rob. roda em 5min  → iJanelaDir=2, iJanelaCtx=6
    60/20/5  → rob. roda em 5min  → iJanelaDir=4, iJanelaCtx=12
                                           '
  REGRA CARDINAL: Opera SOMENTE quando Contexto(TF1) E Direção(TF2) estão alinhados.
}

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
input
  // ── Tripleta (configurar conforme a tabela de tripletas) ──────────────────
  // Padrão: 30/15/5 rodando em 5min → iJanelaDir=3, iJanelaCtx=6
  // 60/30/15 em 15min → iJanelaDir=2, iJanelaCtx=4
  // 15/5/1  em 1min  → iJanelaDir=5, iJanelaCtx=15
  iJanelaDir(3);                  // barras do TF2 (Direção) em TF3 (Gatilho)
  iJanelaCtx(6);                  // barras do TF1 (Contexto) em TF3 (Gatilho)

  ForcaMinimaEntrada(60.0);       // força mínima no TF3 para acionar gatilho
  ForcaMinimaContexto(20.0);      // força mínima nos proxies de TF1/TF2
  VolumeMultiplicador(1.5);
  RRR_Minimo(2.0);
  BufferStop(5.0);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);
  HoraInicioOperacao_H(9);
  HoraInicioOperacao_M(15);

// ═══════════════════════════════════════════════════════════════════════════════
// VARIÁVEIS
// ═══════════════════════════════════════════════════════════════════════════════
var
  fCorpoCandle         : float;
  fRangeCandle         : float;
  fMassa               : float;
  fAceleracao          : float;
  fForca               : float;
  fVolumeMedio         : float;
  iCorR, iCorG, iCorB  : integer;

  // Proxies da Tripleta (iJanelaDir → TF2 Direção, iJanelaCtx → TF1 Contexto)
  fMediaDir            : float;   // proxy TF2 — Media(iJanelaDir, Close)
  fMediaCtx            : float;   // proxy TF1 — Media(iJanelaCtx, Close)
  bContextoAlta        : boolean; // TF1 inclinando para cima
  bContextoBaixa       : boolean; // TF1 inclinando para baixo
  bDirecaoAlta         : boolean; // TF2 inclinando para cima
  bDirecaoBaixa        : boolean; // TF2 inclinando para baixo

  // Sinais combinados
  bSemVerdeCompra      : boolean;  // TF maior + gatilho = compra
  bSemVerdeVenda       : boolean;  // TF maior + gatilho = venda

  // Semáforo (confirmação de 2 candles consecutivos)
  iContadorCompra      : integer;
  iContadorVenda       : integer;
  bEntradaConfirmada   : boolean;

  // Gestão
  fEntrada             : float;
  fStopLoss            : float;
  fTakeProfit          : float;
  fRiscoEmPontos       : float;
  iBarrasEmPosicao     : integer;
  bRRROk               : boolean;
  // Controle de horário (Time() = HHMMSS — Hour/Minute/Exit não existem em NTSL)
  iHoraAtual           : integer;
  iMinutoAtual         : integer;
  bDeveOperar          : boolean;

begin

  // ─── SEÇÃO 1: FORÇA DO CANDLE ATUAL (TF gatilho) ──────────────────────────
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

  // ─── SEÇÃO 2: PROXY DA TRIPLETA (Contexto TF1 + Direção TF2) ────────────────
  // Cada proxy compara o Close atual vs média de iJanela barras.
  // iJanelaDir barras → representa TF2 (Direção)
  // iJanelaCtx barras → representa TF1 (Contexto)
  //
  // Tabela de configuração (ver cabeçalho):
  //   Tripleta 30/15/5  em 5min  → iJanelaDir=3, iJanelaCtx=6
  //   Tripleta 60/30/15 em 15min → iJanelaDir=2, iJanelaCtx=4
  //   Tripleta 15/5/1   em 1min  → iJanelaDir=5, iJanelaCtx=15
  fMediaDir := Media(iJanelaDir, Close);
  fMediaCtx := Media(iJanelaCtx, Close);

  // Direção (TF2): preço acima/abaixo da média de TF2 E média inclinando
  bContextoAlta  := (Close > fMediaCtx) and (fMediaCtx > fMediaCtx[iJanelaCtx]);
  bContextoBaixa := (Close < fMediaCtx) and (fMediaCtx < fMediaCtx[iJanelaCtx]);
  bDirecaoAlta   := (Close > fMediaDir) and (fMediaDir > fMediaDir[iJanelaDir]);
  bDirecaoBaixa  := (Close < fMediaDir) and (fMediaDir < fMediaDir[iJanelaDir]);

  // ─── SEÇÃO 3: GRADIENTE (TF atual + contexto) ─────────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;

  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  else if fForca >= ForcaMinimaEntrada then
  begin
    if bContextoAlta then
    begin
      // Azul = confirmação multi-TF de compra
      iCorR := 0; iCorG := 128; iCorB := 255;
    end
    else
    begin
      iCorG := 128 + Round((fForca / 100) * 127);
      iCorR := 128 - Round((fForca / 100) * 128);
      iCorB := 128 - Round((fForca / 100) * 128);
      if iCorG > 255 then iCorG := 255;
      if iCorR < 0   then iCorR := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end
  else if fForca <= -ForcaMinimaEntrada then
  begin
    if bContextoBaixa then
    begin
      // Azul escuro = confirmação multi-TF de venda
      iCorR := 80; iCorG := 0; iCorB := 200;
    end
    else
    begin
      iCorR := 128 + Round((-fForca / 100) * 127);
      iCorG := 128 - Round((-fForca / 100) * 128);
      iCorB := 128 - Round((-fForca / 100) * 128);
      if iCorR > 255 then iCorR := 255;
      if iCorG < 0   then iCorG := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 4: SEMÁFORO — CONFIRMAÇÃO DE 2 CANDLES ────────────────────────
  // REGRA CARDINAL: Contexto(TF1) E Direção(TF2) AMBOS alinhados + força no gatilho
  bSemVerdeCompra := (fForca >= ForcaMinimaEntrada) and
                     bContextoAlta and bDirecaoAlta and
                     (Volume >= fVolumeMedio * VolumeMultiplicador);

  bSemVerdeVenda  := (fForca <= -ForcaMinimaEntrada) and
                     bContextoBaixa and bDirecaoBaixa and
                     (Volume >= fVolumeMedio * VolumeMultiplicador);

  // Contadores de persistência (2 candles consecutivos no mesmo lado)
  if bSemVerdeCompra then
    iContadorCompra := iContadorCompra + 1
  else
    iContadorCompra := 0;

  if bSemVerdeVenda then
    iContadorVenda := iContadorVenda + 1
  else
    iContadorVenda := 0;

  // Entrada confirmada apenas após 2 candles consecutivos (evita sinais rápidos)
  bEntradaConfirmada := (iContadorCompra >= 2) or (iContadorVenda >= 2);

  // ─── SEÇÃO 5: STOP HORÁRIO ────────────────────────────────────────────────
  iHoraAtual   := Time() div 10000;
  iMinutoAtual := (Time() mod 10000) div 100;

  if (iHoraAtual > StopHorario_H) or
     ((iHoraAtual = StopHorario_H) and (iMinutoAtual >= StopHorario_M)) then
  begin
    if IsBought or IsSold then ClosePosition;
    bDeveOperar := false;
  end
  else
    bDeveOperar := (iHoraAtual > HoraInicioOperacao_H) or
                   ((iHoraAtual = HoraInicioOperacao_H) and (iMinutoAtual >= HoraInicioOperacao_M));

  // ─── SEÇÃO 6: CONTROLE DE BARRAS ──────────────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;

  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    bDeveOperar := false;
  end;

  // ─── SEÇÃO 7: ENTRADAS ────────────────────────────────────────────────────
  if bDeveOperar and (not IsBought) and (not IsSold) and bEntradaConfirmada then
  begin

    if iContadorCompra >= 2 then
    begin
      fEntrada       := Close;
      fStopLoss      := Low - BufferStop;
      fRiscoEmPontos := fEntrada - fStopLoss;
      fTakeProfit    := fEntrada + fRiscoEmPontos * RRR_Minimo;
      bRRROk         := (fTakeProfit - fEntrada) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
        iContadorCompra  := 0;
      end;
    end;

    if iContadorVenda >= 2 then
    begin
      fEntrada       := Close;
      fStopLoss      := High + BufferStop;
      fRiscoEmPontos := fStopLoss - fEntrada;
      fTakeProfit    := fEntrada - fRiscoEmPontos * RRR_Minimo;
      bRRROk         := (fEntrada - fTakeProfit) >= (fRiscoEmPontos * RRR_Minimo);

      if bRRROk and (fRiscoEmPontos > 0) then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
        iContadorVenda   := 0;
      end;
    end;

  end;

end;
Compilando ...
Parser[186,26]: Depois de um statement deve vir " ; "
Parser[187,27]: Faltou um " ) "
Parser[250,1]: O código deve começar com begin
Erro de Sintaxe

{
  Robo: ROB_OBV_ACELERACAO_V1
  Descricao: Opera aceleração do OBV — quando o fluxo institucional está acelerando
             (delta atual > delta anterior na mesma direção e crescendo).
             Cor escala com a VELOCIDADE de mudança do OBV, não apenas o valor.
             Verde escurecendo = OBV acelerando compra. Vermelho escurecendo = OBV acelerando venda.
  Ativo: WIN B3 / WDO B3
  Timeframe: TF3 (Gatilho) — padrão 5min, tripleta 30/15/5
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: mínima/máxima local (Minima/Maxima de iJanelaDir barras) + BufferStop
  Spread_descontado: 25 pts

  Lógica de aceleração:
    fMomentum1 = fOBV - fOBV[iJanelaDir]         → velocidade recente (TF2)
    fMomentum2 = fOBV[iJanelaDir] - fOBV[iJanelaCtx]  → velocidade anterior (TF1)
    fAceleracao = fMomentum1 - fMomentum2         → variação da velocidade

    Aceleração ALTA:  fAceleracao > 0 AND fMomentum1 > 0
      = OBV subindo MAIS rápido que antes → pressão compradora crescendo
    Aceleração BAIXA: fAceleracao < 0 AND fMomentum1 < 0
      = OBV caindo MAIS rápido que antes → pressão vendedora crescendo

    Gradiente: intensidade proporcional a fAceleracao normalizada
    Azul vivo = aceleração máxima para cima (ponto de entrada ideal)
    Roxo vivo = aceleração máxima para baixo
    Cinza/branco = desaceleração ou lateralização do OBV
}

input
  iJanelaDir(3);
  iJanelaCtx(6);
  ForcaMinimaCandle(40.0);    // F=MA mínimo para confirmar entrada
  VolumeMultiplicador(1.3);
  RRR_Minimo(2.0);
  BufferStop(5.0);
  StopHorario_H(17);
  StopHorario_M(45);
  MaxBarrasEmPosicao(8);
  HoraInicioH(9);
  HoraInicioM(15);

var
  // OBV
  fOBV              : float;
  fMomentum1        : float;   // velocidade atual: fOBV - fOBV[iJanelaDir]
  fMomentum2        : float;   // velocidade anterior: fOBV[iJanelaDir] - fOBV[iJanelaCtx]
  fOBVAceleracao    : float;   // fMomentum1 - fMomentum2
  fVolumeMedio      : float;
  fOBVNorm          : float;   // aceleração normalizada -100..+100
  // F = M × A
  fCorpoCandle      : float;
  fRangeCandle      : float;
  fMassa            : float;
  fAceleracao       : float;
  fForca            : float;
  // Sinais
  bAcelerandoAlta   : boolean;  // OBV subindo mais rápido que antes
  bAcelerandoBaixa  : boolean;  // OBV caindo mais rápido que antes
  // Cores
  iCorR, iCorG, iCorB : integer;
  // Gestão
  fEntrada          : float;
  fStopLoss         : float;
  fTakeProfit       : float;
  fRisco            : float;
  iBarrasEmPosicao  : integer;
  // Time() retorna HHMMSS — comparar com H*10000+M*100 (div/mod nao existem)
  bDeveOperar       : boolean;

begin

  // ─── SEÇÃO 1: OBV ACUMULADO ───────────────────────────────────────────────
  if Close > Close[1] then
    fOBV := fOBV + Volume
  else if Close < Close[1] then
    fOBV := fOBV - Volume;

  fVolumeMedio := Media(20, Volume);

  // ─── SEÇÃO 2: F = M × A ──────────────────────────────────────────────────
  fCorpoCandle := Close - Open;
  fRangeCandle := High - Low;
  if fRangeCandle < 0.01 then fRangeCandle := 0.01;
  fMassa       := fCorpoCandle / fRangeCandle;
  if fVolumeMedio > 0 then fAceleracao := Volume / fVolumeMedio
  else fAceleracao := 1;
  fForca := fMassa * fAceleracao * 100;
  if fForca >  100 then fForca :=  100;
  if fForca < -100 then fForca := -100;

  // ─── SEÇÃO 3: MOMENTUM E ACELERAÇÃO DO OBV ───────────────────────────────
  fMomentum1     := fOBV - fOBV[iJanelaDir];              // velocidade recente
  fMomentum2     := fOBV[iJanelaDir] - fOBV[iJanelaCtx]; // velocidade anterior
  fOBVAceleracao := fMomentum1 - fMomentum2;              // variação da velocidade

  // Aceleração de alta: OBV subindo e mais rápido que antes
  bAcelerandoAlta  := (fMomentum1 > 0) and (fOBVAceleracao > 0);
  // Aceleração de baixa: OBV caindo e mais rápido que antes
  bAcelerandoBaixa := (fMomentum1 < 0) and (fOBVAceleracao < 0);

  // Normalizar aceleração para gradiente (referência: volume médio × janela)
  if fVolumeMedio > 0 then
    fOBVNorm := (fOBVAceleracao / (fVolumeMedio * iJanelaDir + 1)) * 100
  else
    fOBVNorm := 0;
  if fOBVNorm >  100 then fOBVNorm :=  100;
  if fOBVNorm < -100 then fOBVNorm := -100;

  // ─── SEÇÃO 4: GRADIENTE — ESCALA COM A ACELERAÇÃO ────────────────────────
  iCorR := 128; iCorG := 128; iCorB := 128;

  if abs(fCorpoCandle) < 0.10 * fRangeCandle then
  begin
    iCorR := 255; iCorG := 255; iCorB := 255; // branco = indecisão
  end
  else if bAcelerandoAlta then
  begin
    if fForca >= ForcaMinimaCandle then
    begin
      // AZUL VIVO = aceleração máxima + candle confirmando → sinal ideal
      iCorR := 0;
      iCorG := 180 + Round((fOBVNorm / 100) * 75);
      iCorB := 255;
      if iCorG > 255 then iCorG := 255;
    end
    else
    begin
      // VERDE degradê = OBV acelerando mas candle ainda fraco
      iCorG := 128 + Round((fOBVNorm / 100) * 127);
      iCorR := 128 - Round((fOBVNorm / 100) * 128);
      iCorB := 128 - Round((fOBVNorm / 100) * 128);
      if iCorG > 255 then iCorG := 255;
      if iCorR < 0   then iCorR := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end
  else if bAcelerandoBaixa then
  begin
    if fForca <= -ForcaMinimaCandle then
    begin
      // ROXO VIVO = aceleração máxima para baixo + candle confirmando
      iCorR := 180 + Round((-fOBVNorm / 100) * 75);
      iCorG := 0;
      iCorB := 220;
      if iCorR > 255 then iCorR := 255;
    end
    else
    begin
      // VERMELHO degradê = OBV acelerando para baixo mas candle fraco
      iCorR := 128 + Round((-fOBVNorm / 100) * 127);
      iCorG := 128 - Round((-fOBVNorm / 100) * 128);
      iCorB := 128 - Round((-fOBVNorm / 100) * 128);
      if iCorR > 255 then iCorR := 255;
      if iCorG < 0   then iCorG := 0;
      if iCorB < 0   then iCorB := 0;
    end;
  end;
  // Desaceleração: permanece cinza (padrão) indicando fim do momentum

  PaintBar(RGB(iCorR, iCorG, iCorB));

  // ─── SEÇÃO 5: STOP HORÁRIO ────────────────────────────────────────────────
  // Time() retorna HHMMSS como numero — comparar diretamente (div/mod nao existem)
  if Time() >= (StopHorario_H * 10000 + StopHorario_M * 100) then
  begin
    if IsBought or IsSold then ClosePosition;
    bDeveOperar := false;
  end
  else
    bDeveOperar := Time() >= (HoraInicioH * 10000 + HoraInicioM * 100);

  // ─── SEÇÃO 6: CONTROLE DE BARRAS ─────────────────────────────────────────
  if IsBought or IsSold then
    iBarrasEmPosicao := iBarrasEmPosicao + 1
  else
    iBarrasEmPosicao := 0;
  if iBarrasEmPosicao >= MaxBarrasEmPosicao then
  begin
    ClosePosition;
    iBarrasEmPosicao := 0;
    bDeveOperar := false;
  end;

  // ─── SEÇÃO 7: ENTRADAS — ACELERAÇÃO + CANDLE CONFIRMADOR ─────────────────
  if bDeveOperar and (not IsBought) and (not IsSold) then
  begin
    // COMPRA: OBV acelerando para cima + candle de força + volume
    if (bAcelerandoAlta and (fForca >= ForcaMinimaCandle)
       and (Volume >= fVolumeMedio * VolumeMultiplicador)) then
    begin
      fEntrada    := Close;
      fStopLoss   := Minima(iJanelaDir) - BufferStop;
      fRisco      := fEntrada - fStopLoss;
      fTakeProfit := fEntrada + fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fTakeProfit - fEntrada) >= fRisco * RRR_Minimo) then
      begin
        BuyAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;

    // VENDA: OBV acelerando para baixo + candle de força + volume
    if ((bAcelerandoBaixa and (fForca <= -ForcaMinimaCandle))
       and (Volume >= fVolumeMedio * VolumeMultiplicador)) then
    begin
      fEntrada    := Close;
      fStopLoss   := Maxima(iJanelaDir) + BufferStop;
      fRisco      := fStopLoss - fEntrada;
      fTakeProfit := fEntrada - fRisco * RRR_Minimo;
      if (fRisco > 0) and ((fEntrada - fTakeProfit) >= fRisco * RRR_Minimo) then
      begin
        SellShortAtMarket;
        iBarrasEmPosicao := 0;
      end;
    end;
  end;

end;

Compilando ...
Parser[193,28]: Depois de um statement deve vir " ; "
Parser[208,28]: Depois de um statement deve vir " ; "
Parser[219,1]: O código deve começar com begin
Erro de Sintaxe
