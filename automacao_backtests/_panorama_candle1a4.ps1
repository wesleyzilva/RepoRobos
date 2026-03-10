# ============================================================
# PANORAMA COMPLETO - CANDLE1A4
# Mostra cada robo com todos os TFs, resultado e justificativa
# ============================================================

function Parse-BRNumber([string]$s){
  if([string]::IsNullOrWhiteSpace($s)){ return 0.0 }
  $t = $s.Trim()
  if($t -eq '-' -or $t -eq ' - ' -or $t -eq ''){ return 0.0 }
  $t = $t -replace '[^\d,\.-]',''
  try { return [double]::Parse($t.Replace('.','').Replace(',','.'), [System.Globalization.CultureInfo]::InvariantCulture) }
  catch { return 0.0 }
}

$pasta = "c:\Users\zilva\RepoRobos-marco_Tradeoperador\automacao_backtests\CANDLE1A4\resultadosPorTimeFrame"
$saida = "$pasta\panorama_completo_candle1a4.txt"

# ---- LER TODOS OS CSVs ----
$tfRows = @()
Get-ChildItem $pasta -Filter "*.csv" | ForEach-Object {
  $n = $_.BaseName.ToLower().Trim()
  if($n -notmatch '^robo_candle1a4_(v\d+_cm\d+_rm\d+)_tfcurto(\d+)\s*$'){ return }
  $robo = $Matches[1]; $tf = [int]$Matches[2]

  $linhas = Get-Content $_.FullName -Encoding UTF8 | Where-Object { $_ -match '^WIN' }
  if($linhas.Count -eq 0){ return }

  $trades=0; $wins=0; $saldo=0.0; $pico=0.0; $drawdown=0.0; $acum=0.0
  foreach($ln in $linhas){
    $p = $ln -split ';'; if($p.Count -lt 21){ continue }
    $res = Parse-BRNumber $p[14]; $trades++
    if($res -gt 0){ $wins++ }
    $acum += $res
    if($acum -gt $pico){ $pico = $acum }
    $dd = $pico - $acum; if($dd -gt $drawdown){ $drawdown = $dd }
    $saldo = $acum
  }
  if($trades -eq 0){ return }

  $wr = [math]::Round(100.0 * $wins / $trades, 1)
  $falhas = @()
  if($wr -le 60)        { $falhas += "WR $wr% <= 60%" }
  if($saldo -le 0)      { $falhas += "saldo $saldo" }
  if($drawdown -gt 700) { $falhas += "DD $([math]::Round($drawdown,0)) > 700" }
  if($trades -lt 5)     { $falhas += "apenas $trades trades" }

  $tfRows += [pscustomobject]@{
    Robo     = $robo; TF = $tf; Trades = $trades; WR = $wr
    Saldo    = [math]::Round($saldo,0); DD = [math]::Round($drawdown,0)
    Aprovado = ($falhas.Count -eq 0)
    Falhas   = if($falhas){ $falhas -join ' | ' } else { 'OK' }
  }
}

# ---- AGRUPAR E CALCULAR METRICAS CONSOLIDADAS ----
$robos = $tfRows | Group-Object Robo | ForEach-Object {
  $g  = $_.Group | Sort-Object TF
  $ap = $g | Where-Object { $_.Aprovado }
  $qtdTF = $g.Count; $qtdAp = $ap.Count

  $saldoTotalGeral = [math]::Round(($g | Measure-Object Saldo -Sum).Sum, 0)
  $saldoAprov      = [math]::Round(($ap | Measure-Object Saldo -Sum).Sum, 0)
  $wrMedAprov      = if($qtdAp -gt 0){ [math]::Round(($ap | Measure-Object WR -Average).Average, 1) } else { 0 }
  $ddPior          = if($qtdAp -gt 0){ ($ap | Measure-Object DD -Maximum).Maximum } else { 9999 }
  $tradesAprov     = ($ap | Measure-Object Trades -Sum).Sum
  $consist         = if($qtdTF -gt 0){ [math]::Round(100.0 * $qtdAp / $qtdTF, 0) } else { 0 }

  # Score composto
  [pscustomobject]@{
    Robo           = $_.Name
    TFsTestados    = $qtdTF
    TFsAprovados   = $qtdAp
    Consistencia   = $consist
    SaldoTotal     = $saldoTotalGeral
    SaldoAprov     = $saldoAprov
    WRMedAprov     = $wrMedAprov
    DDPior         = $ddPior
    TradesAprov    = $tradesAprov
    TFsOK          = ($ap | Sort-Object TF | ForEach-Object { "$($_.TF)min" }) -join ', '
    Linhas         = $g
  }
} | Where-Object { $_.TFsAprovados -ge 1 }

# ---- SCORE PARA ORDENAR ----
$maxDD = ($robos | Measure-Object DDPior -Maximum).Maximum
$minDD = ($robos | Measure-Object DDPior -Minimum).Minimum
$maxWR = ($robos | Measure-Object WRMedAprov -Maximum).Maximum
$minWR = ($robos | Measure-Object WRMedAprov -Minimum).Minimum
$maxSa = ($robos | Measure-Object SaldoAprov -Maximum).Maximum
$minSa = ($robos | Measure-Object SaldoAprov -Minimum).Minimum
$maxTr = ($robos | Measure-Object TradesAprov -Maximum).Maximum
$minTr = ($robos | Measure-Object TradesAprov -Minimum).Minimum

function Norm($v,$mn,$mx){ if($mx -eq $mn){ return 0.5 }; return ($v-$mn)/($mx-$mn) }

$robos = $robos | ForEach-Object {
  $rk = 1-(Norm $_.DDPior $minDD $maxDD)
  $wk = Norm $_.WRMedAprov $minWR $maxWR
  $sk = Norm $_.SaldoAprov $minSa $maxSa
  $tk = Norm $_.TradesAprov $minTr $maxTr
  $ck = $_.Consistencia / 100.0
  $_ | Add-Member -NotePropertyName Score -NotePropertyValue ([math]::Round(($rk*0.40)+($ck*0.25)+($wk*0.15)+($sk*0.10)+($tk*0.10),4)) -PassThru
} | Sort-Object Score -Descending

# ---- GERAR ARQUIVO ----
$out = @()
$out += "=================================================================="
$out += "  PANORAMA COMPLETO - CANDLE1A4 | $(Get-Date -Format 'dd/MM/yyyy')"
$out += "  Criterios aprovacao: WR>60% | Saldo>0 | DD<=700 | Trades>=5"
$out += "  Score: 40%risco + 25%consist + 15%WR + 10%saldo + 10%amostra"
$out += "=================================================================="
$out += ""

$pos = 1
foreach($r in $robos){
  $tag = if($pos -le 5){"[TOP5]"} elseif($pos -le 10){"[TOP10]"} else{"      "}

  # Classificacao qualitativa
  $perfil = @()
  if($r.DDPior -lt 300)           { $perfil += "STOP SEGURO" }
  if($r.WRMedAprov -ge 72)        { $perfil += "ALTA PRECISAO" }
  if($r.Consistencia -ge 50)      { $perfil += "CONSISTENTE" }
  if($r.SaldoAprov -ge 1500)      { $perfil += "ALTO RETORNO" }
  if($r.TradesAprov -ge 30)       { $perfil += "BOA AMOSTRA" }
  $perfilStr = if($perfil){ $perfil -join ' + ' } else { "basico" }

  $out += "$tag #$pos  $($r.Robo.ToUpper())  [Score: $($r.Score)]  >> $perfilStr"
  $out += "     TFs testados : $($r.TFsTestados)  |  Aprovados: $($r.TFsAprovados)  ($($r.Consistencia)% dos TFs)  |  [$($r.TFsOK)]"
  $out += "     WR medio(%ap): $($r.WRMedAprov)%   DD pior: $($r.DDPior) pts   Saldo(aprov): R$ $($r.SaldoAprov)   Trades(aprov): $($r.TradesAprov)"
  $out += "     Saldo GERAL (todos TFs): R$ $($r.SaldoTotal)  $(if($r.SaldoTotal -gt 0){'positivo mesmo somando reprovados'}else{'fica negativo se somar TFs ruins'})"
  $out += ""
  $out += "     Detalhe por TF:"
  $out += "     {0,-6} {1,7} {2,7} {3,8} {4,6}  {5}" -f "TF","Trades","WR%","Saldo","DD","Status"
  $out += "     " + ("-"*65)
  foreach($tf in $r.Linhas){
    $icone = if($tf.Aprovado){"  [OK]"}else{"  [--]"}
    $out += "$icone {0,-6} {1,7} {2,7} {3,8} {4,6}  {5}" -f "$($tf.TF)min", $tf.Trades, "$($tf.WR)%", $tf.Saldo, $tf.DD, $tf.Falhas
  }
  $out += ""
  $out += ("=" * 70)
  $out += ""
  $pos++
}

$out | Out-File $saida -Encoding UTF8
Write-Host "Salvo: $saida"
Write-Host ""
Write-Host "RESUMO RAPIDO - TOP 15 (score composto):"
Write-Host ""
Write-Host ("{0,-3} {1,-22} {2,5} {3,5} {4,6} {5,8} {6,8} {7,6} {8,8} {9}" -f "#","Robo","Score","Aprov","Cons%","WR%","SaldoAp","DD","Trades","TFs[OK]")
Write-Host ("-"*105)
$pos=1
foreach($r in $robos | Select-Object -First 15){
  Write-Host ("{0,-3} {1,-22} {2,5} {3,5} {4,6} {5,8} {6,8} {7,6} {8,8} {9}" -f $pos, $r.Robo, $r.Score, "$($r.TFsAprovados)/$($r.TFsTestados)", "$($r.Consistencia)%", "$($r.WRMedAprov)%", $r.SaldoAprov, $r.DDPior, $r.TradesAprov, $r.TFsOK)
  $pos++
}
