# ============================================================
# RESUMO CONSOLIDADO CANDLE1A4 + IFR - TOP 10 GERAL
# ============================================================

function Parse-BRNumber([string]$s){
  if([string]::IsNullOrWhiteSpace($s)){ return 0.0 }
  $t = $s.Trim()
  if($t -eq '-' -or $t -eq ' - ' -or $t -eq ''){ return 0.0 }
  $t = $t -replace '[^\d,\.-]',''
  try { return [double]::Parse($t.Replace('.','').Replace(',','.'), [System.Globalization.CultureInfo]::InvariantCulture) }
  catch { return 0.0 }
}

$bases = @(
  @{U='CANDLE1A4'; P='c:\Users\zilva\RepoRobos-marco_Tradeoperador\automacao_backtests\CANDLE1A4\resultadosPorTimeFrame';
    Pat='^robo_candle1a4_(v\d+_cm\d+_rm\d+)_tfcurto(\d+)\s*$'},
  @{U='IFR_RSI';   P='c:\Users\zilva\RepoRobos-marco_Tradeoperador\automacao_backtests\IFR_RSI\resultadosAprovadosPorTimeframe';
    Pat='^robo_ifr_(v\d+_.+?)(\d{1,2})min\d*%?$'}
)

$DIAS_BT    = 252
$DIAS_MARCO = 21

$tfRows = @()
foreach($b in $bases){
  Get-ChildItem $b.P -Filter "*.csv" | ForEach-Object {
    $n = $_.BaseName.ToLower().Trim()
    if($n -notmatch $b.Pat){ return }
    $robo = $Matches[1].TrimEnd('_'); $tf = [int]$Matches[2]

    $linhas = Get-Content $_.FullName -Encoding UTF8 | Where-Object { $_ -match '^WIN' }
    if($linhas.Count -eq 0){ return }

    $trades=0; $wins=0; $saldo=0.0; $pico=0.0; $dd=0.0; $acum=0.0
    foreach($ln in $linhas){
      $p = $ln -split ';'; if($p.Count -lt 21){ continue }
      $res = Parse-BRNumber $p[14]; $trades++
      if($res -gt 0){ $wins++ }
      $acum += $res
      if($acum -gt $pico){ $pico = $acum }
      $v = $pico - $acum; if($v -gt $dd){ $dd = $v }
      $saldo = $acum
    }
    if($trades -eq 0){ return }

    $wr     = [math]::Round(100.0 * $wins / $trades, 1)
    $falhas = @()
    if($wr   -le 60)  { $falhas += "WR $wr%" }
    if($saldo -le 0)  { $falhas += "saldo neg" }
    if($dd    -gt 700){ $falhas += "DD alto" }
    if($trades -lt 5) { $falhas += "poucos trades" }

    $trDia  = [math]::Round($trades / $DIAS_BT, 3)
    $trMar  = [math]::Round($trDia * $DIAS_MARCO, 1)
    $valMar = [int][math]::Round(($saldo / $DIAS_BT) * $DIAS_MARCO, 0)

    $tfRows += [pscustomobject]@{
      Universo=$b.U; Robo=$robo; TF=$tf; Trades=$trades; WR=$wr
      Saldo=[int][math]::Round($saldo,0); DD=[int][math]::Round($dd,0)
      Aprovado=($falhas.Count -eq 0)
      Falhas=if($falhas){$falhas -join ' | '}else{'OK'}
      TrDia=$trDia; TrMar=$trMar; ValMar=$valMar
    }
  }
}

$robos = $tfRows | Group-Object Universo,Robo | ForEach-Object {
  $g  = $_.Group | Sort-Object TF
  $ap = $g | Where-Object { $_.Aprovado }
  $qtdTF=$g.Count; $qtdAp=$ap.Count
  $univ=$g[0].Universo; $nome=$g[0].Robo

  $saldoAp   = [int][math]::Round(($ap|Measure-Object Saldo  -Sum).Sum,0)
  $tradesAp  = [int](($ap|Measure-Object Trades -Sum).Sum)
  $wrMed     = if($qtdAp -gt 0){[math]::Round(($ap|Measure-Object WR -Average).Average,1)}else{0}
  $ddPior    = if($qtdAp -gt 0){[int](($ap|Measure-Object DD -Maximum).Maximum)}else{9999}
  $consist   = if($qtdTF -gt 0){[int][math]::Round(100.0*$qtdAp/$qtdTF,0)}else{0}
  $trMar     = [math]::Round(($ap|Measure-Object TrMar -Sum).Sum,1)
  $valMar    = [int](($ap|Measure-Object ValMar -Sum).Sum)
  $patMin    = [int][math]::Max(1000,[math]::Round($ddPior*2.5,0))
  $patCons   = [int][math]::Max(1500,[math]::Round($ddPior*3.5,0))
  $tfsOK     = ($ap|Sort-Object TF|ForEach-Object{"$($_.TF)min"}) -join ', '

  [pscustomobject]@{
    Universo=$univ; Robo=$nome; QtdTF=$qtdTF; QtdAp=$qtdAp; Consist=$consist
    WRMed=$wrMed; SaldoAp=$saldoAp; DDPior=$ddPior; TradesAp=$tradesAp
    TrMar=$trMar; ValMar=$valMar; PatMin=$patMin; PatCons=$patCons; TFsOK=$tfsOK
    Linhas=$g
  }
} | Where-Object { $_.QtdAp -ge 1 }

function Norm($v,$mn,$mx){ if($mx -eq $mn){return 0.5}; return ($v-$mn)/($mx-$mn) }
$maxDD=[int](($robos|Measure-Object DDPior -Maximum).Maximum)
$minDD=[int](($robos|Measure-Object DDPior -Minimum).Minimum)
$maxWR=($robos|Measure-Object WRMed   -Maximum).Maximum
$minWR=($robos|Measure-Object WRMed   -Minimum).Minimum
$maxSa=($robos|Measure-Object SaldoAp -Maximum).Maximum
$minSa=($robos|Measure-Object SaldoAp -Minimum).Minimum
$maxTr=($robos|Measure-Object TradesAp -Maximum).Maximum
$minTr=($robos|Measure-Object TradesAp -Minimum).Minimum

$robos = $robos | ForEach-Object {
  $sc = (1-(Norm $_.DDPior $minDD $maxDD))*0.40 +
        ($_.Consist/100)*0.25 +
        (Norm $_.WRMed  $minWR $maxWR)*0.15 +
        (Norm $_.SaldoAp $minSa $maxSa)*0.10 +
        (Norm $_.TradesAp $minTr $maxTr)*0.10
  $_ | Add-Member -NotePropertyName Score -NotePropertyValue ([math]::Round($sc,4)) -PassThru
} | Sort-Object Score -Descending

$top10 = $robos | Select-Object -First 10

$totalC14   = ($tfRows|Where-Object{$_.Universo -eq 'CANDLE1A4'}|Select-Object Robo -Unique).Count
$totalIFR   = ($tfRows|Where-Object{$_.Universo -eq 'IFR_RSI'}  |Select-Object Robo -Unique).Count
$totalCombs = $tfRows.Count
$totalAprov = ($tfRows|Where-Object{$_.Aprovado}).Count
$totalEleg  = $robos.Count

# ---- GERAR ARQUIVO ----
$rs = "R$"   # prefixo moeda sem ambiguidade no PowerShell
$saida = "c:\Users\zilva\RepoRobos-marco_Tradeoperador\automacao_backtests\resumo_top10_marco2026.txt"
$out = [System.Collections.Generic.List[string]]::new()

$out.Add("==========================================================================")
$out.Add("  RESUMO CONSOLIDADO  -  CANDLE1A4 + IFR_RSI")
$out.Add("  Periodo backtest  : aprox $DIAS_BT dias uteis")
$out.Add("  Projecao marco    : $DIAS_MARCO dias uteis (21 dias uteis em marco/2026)")
$out.Add("  Criterios aprov.  : WR>60% | Saldo>0 | DD<=700 | Trades>=5 por TF")
$out.Add("  Score ponderado   : 40%risco + 25%consist + 15%WR + 10%saldo + 10%amostra")
$out.Add("  Gerado em         : $(Get-Date -Format 'dd/MM/yyyy HH:mm')")
$out.Add("==========================================================================")
$out.Add("")
$out.Add("  UNIVERSO ANALISADO")
$out.Add("  Robos CANDLE1A4             : $totalC14")
$out.Add("  Robos IFR_RSI               : $totalIFR")
$out.Add("  Total combinacoes (robo+TF) : $totalCombs")
$out.Add("  Combinacoes aprovadas       : $totalAprov")
$out.Add("  Robos elegiveis (>=1 TF ok) : $totalEleg")
$out.Add("")
$out.Add("  LEGENDA")
$out.Add("  Ops    = operacoes no backtest  |  Ops/Dia = media por dia util no backtest")
$out.Add("  OpsMAR = projecao ops para marco (21 dias uteis)")
$out.Add("  ValBT  = saldo acumulado backtest  |  ValMAR = projecao saldo marco")
$out.Add("  PatMin = 2.5x DrawDown  |  PatCons = 3.5x DrawDown (recomendado)")
$out.Add("==========================================================================")
$out.Add("")

$pos = 1
foreach($r in $top10){
  $pfil=@()
  if($r.DDPior  -lt 300) {$pfil+="STOP SEGURO"}
  if($r.WRMed   -ge 72)  {$pfil+="ALTA PRECISAO"}
  if($r.Consist -ge 50)  {$pfil+="CONSISTENTE"}
  if($r.SaldoAp -ge 1500){$pfil+="ALTO RETORNO"}
  if($r.TradesAp -ge 30) {$pfil+="BOA AMOSTRA"}
  $pStr = if($pfil){$pfil -join " + "}else{"-"}

  $out.Add("#$pos  [$($r.Universo)]  $($r.Robo.ToUpper())")
  $out.Add("    Score       : $($r.Score)    Perfil: $pStr")
  $out.Add("    TFs testados: $($r.QtdTF)  |  Aprovados: $($r.QtdAp)/$($r.QtdTF) ($($r.Consist)%)  |  TFs OK: [$($r.TFsOK)]")
  $out.Add("    WR medio    : $($r.WRMed)%   DD maximo : $($r.DDPior) pts")
  $out.Add("    Saldo BT    : ${rs}$($r.SaldoAp)   Trades aprovados: $($r.TradesAp)")
  $out.Add("")
  $out.Add("    PROJECAO MARCO 2026 ($DIAS_MARCO dias uteis)")
  $out.Add("    Operacoes estimadas : ~$($r.TrMar) ops")
  $out.Add("    Saldo estimado      : ${rs}$($r.ValMar)  (proporcional ao historico)")
  $out.Add("    Patrimonio MINIMO   : ${rs}$($r.PatMin)  (2.5 x DrawDown)")
  $out.Add("    Patrimonio CONSERV  : ${rs}$($r.PatCons)  (3.5 x DrawDown)  << recomendado")
  $out.Add("")

  $hTF = "    {0,-7} {1,5} {2,7} {3,7} {4,9} {5,8} {6,6}  {7}" -f "TF","Ops","Ops/Dia","OpsMAR","ValBT","ValMAR","DD","Status"
  $out.Add($hTF)
  $out.Add(("    " + "-"*68))

  foreach($tf in ($r.Linhas | Sort-Object TF)){
    $ic = if($tf.Aprovado){"[OK]"}else{"[--]"}
    $vbt = "${rs}$($tf.Saldo)"
    $vm  = "${rs}$($tf.ValMar)"
    $ln  = "  {0}  {1,-7} {2,5} {3,7} {4,7} {5,9} {6,8} {7,6}  {8}" -f $ic,"$($tf.TF)min",$tf.Trades,$tf.TrDia,$tf.TrMar,$vbt,$vm,$tf.DD,$tf.Falhas
    $out.Add($ln)
  }
  $out.Add("")
  $out.Add(("="*72))
  $out.Add("")
  $pos++
}

$out.Add("==========================================================================")
$out.Add("  TABELA RESUMO - INVESTIMENTO NECESSARIO PARA OPERAR EM MARCO 2026")
$out.Add("==========================================================================")
$out.Add("")
$hdr = "  {0,-3} {1,-9} {2,-22} {3,5} {4,8} {5,5} {6,8} {7,9} {8,10} {9,10}" -f "#","Univ","Robo","WR%","SaldoBT","DD","OpsMAR","ValMAR","PatrimMin","PatrimCons"
$out.Add($hdr)
$out.Add(("  "+"-"*95))

$pos=1
foreach($r in $top10){
  $vbt  = "${rs}$($r.SaldoAp)"
  $vm   = "~${rs}$($r.ValMar)"
  $pm   = "${rs}$($r.PatMin)"
  $pc   = "${rs}$($r.PatCons)"
  $ln   = "  {0,-3} {1,-9} {2,-22} {3,5} {4,8} {5,5} {6,8} {7,9} {8,10} {9,10}" -f $pos,$r.Universo,$r.Robo,"$($r.WRMed)%",$vbt,"$($r.DDPior)pts","~$($r.TrMar)",$vm,$pm,$pc
  $out.Add($ln)
  $pos++
}
$out.Add("")
$out.Add("  * Retorno estimado e PROPORCIONAL ao historico. Nao e garantia futura.")
$out.Add("  * Use sempre o patrimonio CONSERVADOR para iniciar.")

$out | Out-File $saida -Encoding UTF8
Write-Host "Arquivo salvo: $saida"
Write-Host ""

# ---- TELA ----
$rs2 = "R$"
Write-Host "=========================================================================="
Write-Host "  $totalC14 robos CANDLE1A4 + $totalIFR robos IFR = $totalCombs combinacoes | $totalAprov aprovadas | $totalEleg elegiveis"
Write-Host "=========================================================================="
Write-Host ""
Write-Host ("  {0,-3} {1,-9} {2,-22} {3,5} {4,6} {5,5} {6,7} {7,5} {8,6} {9,9} {10,9}  TFs aprovados" -f "#","Univ","Robo","Score","Aprov","WR%","SaldoBT","DD","OpsMAR","PatMin","PatCons")
Write-Host ("  "+("-"*108))
$pos=1
foreach($r in $top10){
  $vbt = "${rs2}$($r.SaldoAp)"
  $pm  = "${rs2}$($r.PatMin)"
  $pc  = "${rs2}$($r.PatCons)"
  Write-Host ("  {0,-3} {1,-9} {2,-22} {3,5} {4,6} {5,5} {6,7} {7,5} {8,6} {9,9} {10,9}  {11}" -f
    $pos,$r.Universo,$r.Robo,$r.Score,"$($r.QtdAp)/$($r.QtdTF)","$($r.WRMed)%",$vbt,$r.DDPior,"~$($r.TrMar)",$pm,$pc,$r.TFsOK)
  $pos++
}
Write-Host ""
Write-Host "Arquivo completo salvo: resumo_top10_marco2026.txt"
