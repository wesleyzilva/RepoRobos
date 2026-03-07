# ============================================================
# RANKING FINAL CANDLE1A4 - Criterios: WR>60%, Saldo>0, DD<=700
# Score: 40% riskNorm + 25% consistencia + 15% WRnorm + 10% saldoNorm + 10% sampleNorm
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
$saida = "c:\Users\zilva\RepoRobos-marco_Tradeoperador\automacao_backtests\CANDLE1A4\resultadosPorTimeFrame"

# ---- 1. LER TODOS OS CSVs ----
$tfRows = @()

Get-ChildItem $pasta -Filter "*.csv" | ForEach-Object {
  $n = $_.BaseName.ToLower().Trim()
  if($n -notmatch '^robo_candle1a4_(v\d+_cm\d+_rm\d+)_tfcurto(\d+)\s*$'){ return }
  $robo = $Matches[1]
  $tf   = [int]$Matches[2]

  $linhas = Get-Content $_.FullName -Encoding UTF8 | Where-Object { $_ -match '^WIN' }
  if($linhas.Count -eq 0){ return }

  $trades=0; $wins=0; $saldo=0.0; $pico=0.0; $drawdown=0.0; $acum=0.0

  foreach($ln in $linhas){
    $p = $ln -split ';'
    if($p.Count -lt 21){ continue }
    $res = Parse-BRNumber $p[14]
    $trades++
    if($res -gt 0){ $wins++ }
    $acum += $res
    if($acum -gt $pico){ $pico = $acum }
    $dd = $pico - $acum
    if($dd -gt $drawdown){ $drawdown = $dd }
    $saldo = $acum
  }

  if($trades -eq 0){ return }

  $wr = [math]::Round(100.0 * $wins / $trades, 2)

  $tfRows += [pscustomobject]@{
    Robo     = $robo
    TF       = $tf
    Trades   = $trades
    WR       = $wr
    Saldo    = [math]::Round($saldo, 0)
    DD       = [math]::Round($drawdown, 0)
    Aprovado = ($wr -gt 60 -and $saldo -gt 0 -and $drawdown -le 700 -and $trades -ge 5)
  }
}

Write-Host "Total de combinacoes robo+TF lidas: $($tfRows.Count)"

# ---- 2. AGRUPAR POR ROBO ----
$robos = $tfRows | Group-Object Robo | ForEach-Object {
  $g  = $_.Group
  $ap = $g | Where-Object { $_.Aprovado }

  $qtdTF     = $g.Count
  $qtdAprov  = $ap.Count
  $consist   = if($qtdTF -gt 0){ [math]::Round($qtdAprov / $qtdTF, 4) } else { 0 }

  $saldoAprov = ($ap | Measure-Object Saldo -Sum).Sum
  $tradesAprov = ($ap | Measure-Object Trades -Sum).Sum
  $wrMedAprov  = if($qtdAprov -gt 0){ [math]::Round(($ap | Measure-Object WR -Average).Average, 2) } else { 0 }
  $ddPiorAprov = if($qtdAprov -gt 0){ ($ap | Measure-Object DD -Maximum).Maximum } else { 9999 }

  $tfsAprov = ($ap | ForEach-Object { "$($_.TF)min" }) -join ', '

  [pscustomobject]@{
    Robo         = $_.Name
    QtdTF        = $qtdTF
    QtdAprov     = $qtdAprov
    TFsAprov     = $tfsAprov
    Consist      = $consist
    TradesAprov  = $tradesAprov
    WRMedAprov   = $wrMedAprov
    SaldoAprov   = [math]::Round($saldoAprov, 0)
    DDPiorAprov  = $ddPiorAprov
    PatrimMin    = [math]::Max(1000, [math]::Round($ddPiorAprov * 2.5, 0))
    PatrimCons   = [math]::Max(1500, [math]::Round($ddPiorAprov * 3.5, 0))
  }
}

# ---- 3. ELEGÍVEIS (pelo menos 1 TF aprovado) ----
$elegiveis = $robos | Where-Object { $_.QtdAprov -ge 1 }
Write-Host "Robos elegiveis (>=1 TF aprovado): $($elegiveis.Count)"

# ---- 4. NORMALIZAR E SCORE ----
$maxDD     = ($elegiveis | Measure-Object DDPiorAprov -Maximum).Maximum
$minDD     = ($elegiveis | Measure-Object DDPiorAprov -Minimum).Minimum
$maxWR     = ($elegiveis | Measure-Object WRMedAprov  -Maximum).Maximum
$minWR     = ($elegiveis | Measure-Object WRMedAprov  -Minimum).Minimum
$maxSaldo  = ($elegiveis | Measure-Object SaldoAprov  -Maximum).Maximum
$minSaldo  = ($elegiveis | Measure-Object SaldoAprov  -Minimum).Minimum
$maxTrades = ($elegiveis | Measure-Object TradesAprov -Maximum).Maximum
$minTrades = ($elegiveis | Measure-Object TradesAprov -Minimum).Minimum

function Norm($v,$mn,$mx){ if($mx -eq $mn){ return 0.5 }; return ($v - $mn) / ($mx - $mn) }

$scored = $elegiveis | ForEach-Object {
  $riskNorm   = 1 - (Norm $_.DDPiorAprov $minDD $maxDD)   # menor DD = melhor
  $wrNorm     = Norm $_.WRMedAprov $minWR $maxWR
  $saldoNorm  = Norm $_.SaldoAprov $minSaldo $maxSaldo
  $sampleNorm = Norm $_.TradesAprov $minTrades $maxTrades
  $consistN   = $_.Consist

  $score = [math]::Round(
    ($riskNorm * 0.40) + ($consistN * 0.25) + ($wrNorm * 0.15) + ($saldoNorm * 0.10) + ($sampleNorm * 0.10),
    4)

  $_ | Add-Member -NotePropertyName Score -NotePropertyValue $score -PassThru
}

$ranked = $scored | Sort-Object Score -Descending
$top10  = $ranked | Select-Object -First 10
$top5   = $ranked | Select-Object -First 5

# ---- 5. ARQUIVO: RANKING GERAL ----
$linhasSaida = @()
$linhasSaida += "=================================================================="
$linhasSaida += " RANKING FINAL CANDLE1A4 - $(Get-Date -Format 'dd/MM/yyyy')"
$linhasSaida += " Criterios: WinRate > 60% | Saldo > 0 | DrawDown <= 700 | Trades >= 5"
$linhasSaida += " Score: 40% riskNorm + 25% consistencia + 15% WRnorm + 10% saldoNorm + 10% sampleNorm"
$linhasSaida += "=================================================================="
$linhasSaida += ""
$linhasSaida += "Total combinacoes lidas   : $($tfRows.Count)"
$linhasSaida += "Total robos unicos        : $($robos.Count)"
$linhasSaida += "Robos elegiveis (>=1 TF)  : $($elegiveis.Count)"
$linhasSaida += ""
$linhasSaida += "------------------------------------------------------------------"
$linhasSaida += " TOP 10 GERAL"
$linhasSaida += "------------------------------------------------------------------"
$pos = 1
foreach($r in $top10){
  $linhasSaida += ""
  $linhasSaida += "#$pos  $($r.Robo.ToUpper())"
  $linhasSaida += "    Score         : $($r.Score)"
  $linhasSaida += "    TFs aprovados : $($r.QtdAprov)/$($r.QtdTF)  [$($r.TFsAprov)]"
  $linhasSaida += "    Consistencia  : $([math]::Round($r.Consist*100,1))%"
  $linhasSaida += "    WR medio      : $($r.WRMedAprov)%"
  $linhasSaida += "    Saldo total   : R$ $($r.SaldoAprov)"
  $linhasSaida += "    DrawDown pior : $($r.DDPiorAprov) pts"
  $linhasSaida += "    Trades aprov  : $($r.TradesAprov)"
  $linhasSaida += "    Patrimonio min: R$ $($r.PatrimMin)  |  Conservador: R$ $($r.PatrimCons)"
  $pos++
}

$linhasSaida += ""
$linhasSaida += "------------------------------------------------------------------"
$linhasSaida += " TOP 5 OPERACIONAL (para operar JA)"
$linhasSaida += "------------------------------------------------------------------"
$pos = 1
foreach($r in $top5){
  $linhasSaida += "$pos. $($r.Robo)  |  Score: $($r.Score)  |  WR: $($r.WRMedAprov)%  |  Saldo: $($r.SaldoAprov)  |  DD: $($r.DDPiorAprov)  |  TFs: [$($r.TFsAprov)]"
  $pos++
}

$linhasSaida | Out-File "$saida\ranking_geral_final_candle1a4.txt" -Encoding UTF8
Write-Host "Salvo: ranking_geral_final_candle1a4.txt"

# ---- 6. ARQUIVO: CONSISTENCIA (por mais TFs aprovados) ----
$consist = $elegiveis | Sort-Object @{E='QtdAprov';D=$true}, @{E='WRMedAprov';D=$true}
$linhasC = @()
$linhasC += "=================================================================="
$linhasC += " RANKING CONSISTENCIA - CANDLE1A4 (mais TFs aprovados)"
$linhasC += " $(Get-Date -Format 'dd/MM/yyyy')"
$linhasC += "=================================================================="
$linhasC += ""
$linhasC += "{0,-25} {1,5} {2,5} {3,10} {4,8} {5,8} {6,8} {7,8}" -f "Robo","Aprov","Total","TFs","WR%","Saldo","DD","Trades"
$linhasC += "-" * 85
foreach($r in $consist){
  $linhasC += "{0,-25} {1,5} {2,5} {3,10} {4,8} {5,8} {6,8} {7,8}" -f $r.Robo, $r.QtdAprov, $r.QtdTF, $r.TFsAprov.Substring(0,[math]::Min(10,$r.TFsAprov.Length)), $r.WRMedAprov, $r.SaldoAprov, $r.DDPiorAprov, $r.TradesAprov
}
$linhasC | Out-File "$saida\ranking_consistencia_candle1a4.txt" -Encoding UTF8
Write-Host "Salvo: ranking_consistencia_candle1a4.txt"

# ---- 7. ARQUIVO: MENORES PERDAS (stop pequeno) ----
$stopPeq = $elegiveis | Where-Object { $_.SaldoAprov -gt 0 -and $_.WRMedAprov -ge 60 } |
           Sort-Object DDPiorAprov, @{E='WRMedAprov';D=$true}
$linhasS = @()
$linhasS += "=================================================================="
$linhasS += " RANKING STOP PEQUENO (menores perdas) - CANDLE1A4"
$linhasS += " Filtro: Saldo > 0 | WR >= 60% | ordenado por MENOR DrawDown"
$linhasS += " $(Get-Date -Format 'dd/MM/yyyy')"
$linhasS += "=================================================================="
$linhasS += ""
$linhasS += "{0,-3} {1,-25} {2,6} {3,8} {4,8} {5,8} {6,8} {7,10}" -f "#","Robo","DD","WR%","Saldo","Trades","Consist","TFs"
$linhasS += "-" * 85
$pos = 1
foreach($r in $stopPeq | Select-Object -First 20){
  $linhasS += "{0,-3} {1,-25} {2,6} {3,8} {4,8} {5,8} {6,8} {7,10}" -f $pos, $r.Robo, $r.DDPiorAprov, $r.WRMedAprov, $r.SaldoAprov, $r.TradesAprov, "$([math]::Round($r.Consist*100,0))%", $r.TFsAprov.Substring(0,[math]::Min(10,$r.TFsAprov.Length))
  $pos++
}
$linhasS | Out-File "$saida\ranking_stop_pequeno_candle1a4.txt" -Encoding UTF8
Write-Host "Salvo: ranking_stop_pequeno_candle1a4.txt"

# ---- 8. DETALHAMENTO POR TF DE TODOS OS ROBOS ----
$linhasD = @()
$linhasD += "=================================================================="
$linhasD += " DETALHAMENTO POR TIMEFRAME - CANDLE1A4"
$linhasD += " $(Get-Date -Format 'dd/MM/yyyy')"
$linhasD += "=================================================================="
$linhasD += ""
$linhasD += "{0,-25} {1,5} {2,7} {3,8} {4,8} {5,6}" -f "Robo","TF","Trades","WR%","Saldo","DD"
$linhasD += "-" * 65
$tfRows | Sort-Object Robo, TF | ForEach-Object {
  $ap = if($_.Aprovado){'[OK]'}else{'    '}
  $linhasD += "$ap {0,-25} {1,5}min {2,7} {3,8} {4,8} {5,6}" -f $_.Robo, $_.TF, $_.Trades, $_.WR, $_.Saldo, $_.DD
}
$linhasD | Out-File "$saida\detalhamento_tfs_candle1a4.txt" -Encoding UTF8
Write-Host "Salvo: detalhamento_tfs_candle1a4.txt"

# ---- RESUMO TELA ----
Write-Host ""
Write-Host "=========================================="
Write-Host " TOP 10 CANDLE1A4 - RANKING FINAL"
Write-Host "=========================================="
$ranked | Select-Object -First 10 |
  Format-Table @{L='#';E={[array]::IndexOf(($ranked | Select-Object -First 10), $_)+1}},
               Robo, Score, QtdAprov,
               @{L='WR%';E={$_.WRMedAprov}},
               @{L='Saldo';E={$_.SaldoAprov}},
               @{L='DD';E={$_.DDPiorAprov}},
               @{L='Trades';E={$_.TradesAprov}} -AutoSize
