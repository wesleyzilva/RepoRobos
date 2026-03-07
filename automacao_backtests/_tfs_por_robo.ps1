function Parse-BRNumber([string]$s){
  if([string]::IsNullOrWhiteSpace($s)){ return 0.0 }
  $t=$s.Trim(); if($t -eq '-' -or $t -eq ' - '){ return 0.0 }
  return [double]::Parse($t.Replace('.','').Replace(',','.'), [System.Globalization.CultureInfo]::InvariantCulture)
}

$bases = @(
  @{U='CANDLE1A4'; P='c:/Users/zilva/RepoRobos-marco_Tradeoperador/automacao_backtests/CANDLE1A4/resultadosPorTimeFrame'},
  @{U='IFR_RSI';   P='c:/Users/zilva/RepoRobos-marco_Tradeoperador/automacao_backtests/IFR_RSI/resultadosAprovadosPorTimeframe'}
)

$alvos = @('v28_ifr_adx_filtro','v6_saida_hibrida','v27_cm3_rm3','v28_cm1_rm1','v1_reversao_extremos')

$rows = @()
foreach($b in $bases){
  Get-ChildItem $b.P -Filter '*.csv' | ForEach-Object {
    $n = $_.BaseName.ToLower()
    $roboMatch = $null; $tf = $null

    if($b.U -eq 'CANDLE1A4'){
      if($n -match '^robo_candle1a4_(v\d+_cm\d+_rm\d+)_tfcurto(\d+)$'){
        $roboMatch = $Matches[1]; $tf = [int]$Matches[2]
      }
    } else {
      if($n -match '^robo_ifr_(v\d+_.+?)(\d{1,2})min'){
        $roboMatch = $Matches[1].TrimEnd('_'); $tf = [int]$Matches[2]
      }
    }

    $match = $alvos | Where-Object { $roboMatch -like "*$_*" -or $_ -like "*$roboMatch*" }
    if(-not $roboMatch -or -not $match){ return }

    $ops = Get-Content $_.FullName | Where-Object { $_ -match '^WIN' }
    $tr=0; $wi=0; $saldo=0.0
    foreach($ln in $ops){
      $p = $ln -split ';'; if($p.Count -lt 21){ continue }
      $res = Parse-BRNumber $p[14]; $tr++; if($res -gt 0){$wi++}; $saldo += $res
    }
    if($tr -gt 0){
      $rows += [pscustomobject]@{
        Robo=$roboMatch; TF="${tf}min"; Trades=$tr
        WR=[math]::Round(100.0*$wi/$tr,1)
        Saldo=[math]::Round($saldo,0)
        Status=if($saldo -gt 0){'[+]'}else{'[-]'}
      }
    }
  }
}

$rows | Sort-Object Robo,@{Expression={[int]($_.TF -replace 'min','')}} |
  Format-Table Robo,TF,Trades,WR,Saldo,Status -AutoSize | Out-String -Width 120
