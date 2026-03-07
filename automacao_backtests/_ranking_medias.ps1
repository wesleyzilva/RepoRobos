# ==========================================================
# _ranking_medias.ps1
# Gera ranking dos robos MEDIAS_20_50_200 a partir dos CSVs
# de backtest exportados do Profit/Neologica.
#
# COMO USAR:
#   1. Rode os backtests no Profit para cada robo/TF
#   2. Exporte os resultados como CSV no padrao:
#      roboNome_TF.csv  ex: v1_dt_pullback_mme20_60min.csv
#   3. Coloque os CSVs em:
#      automacao_backtests\MEDIAS_20_50_200\resultadosPorTimeFrame\
#   4. Execute este script com: .\automacao_backtests\_ranking_medias.ps1
# ==========================================================

$pastaBase   = ".\automacao_backtests\MEDIAS_20_50_200\resultadosPorTimeFrame"
$pastaSaida  = ".\automacao_backtests\MEDIAS_20_50_200"
$rs          = "R$"

# ---- Criterios de aprovacao ----
$WR_MIN      = 60.0   # Win Rate minimo (%)
$DD_MAX      = 700    # Drawdown maximo (pontos)
$SALDO_MIN   = 0      # Saldo minimo (pontos)
$TRADES_MIN  = 5      # Trades minimos para amostrar

if (-not (Test-Path $pastaBase)) {
    Write-Host "AVISO: pasta $pastaBase nao encontrada."
    Write-Host "Crie a pasta e exporte os CSVs do Profit antes de rodar este script."
    exit
}

$csvs = Get-ChildItem "$pastaBase\*.csv" -ErrorAction SilentlyContinue
if ($csvs.Count -eq 0) {
    Write-Host "Nenhum CSV encontrado em $pastaBase"
    Write-Host "Exporte os resultados do backtest do Profit e coloque nesta pasta."
    exit
}

Write-Host "Lendo $($csvs.Count) arquivos CSV..."

$registros = @()

foreach ($csv in $csvs) {
    try {
        $dados = Import-Csv $csv.FullName -Delimiter ";"

        # Extrai nome do robo e TF do nome do arquivo: v1_dt_pullback_mme20_60min.csv
        $nomeArquivo = $csv.BaseName
        if ($nomeArquivo -match "^(.+)_(\d+min|\d+h|diario|semanal)$") {
            $nomeRobo = $matches[1]
            $tf       = $matches[2]
        } else {
            $nomeRobo = $nomeArquivo
            $tf       = "desconhecido"
        }

        # Mapeia colunas (ajuste conforme layout do Profit)
        $saldo     = [float]($dados | Select-Object -Last 1).SaldoAcumulado -replace ",","."
        $trades    = [int]($dados.Count)
        $vitorias  = ($dados | Where-Object { [float]($_.Resultado -replace ",",".") -gt 0 }).Count
        $wr        = if ($trades -gt 0) { $vitorias / $trades * 100 } else { 0 }

        $resultados = $dados | ForEach-Object { [float]($_.Resultado -replace ",",".") }
        $picos      = $resultados | ForEach-Object -Begin { $max=0; $dd=0; $saldoAc=0 } -Process {
                        $saldoAc += $_
                        if ($saldoAc -gt $max) { $max = $saldoAc }
                        $recuo = $max - $saldoAc
                        if ($recuo -gt $dd) { $dd = $recuo }
                      } -End { $dd }
        $ddMax = $picos

        $reg = [PSCustomObject]@{
            Robo    = $nomeRobo
            TF      = $tf
            Trades  = $trades
            WR      = [math]::Round($wr, 1)
            Saldo   = [math]::Round($saldo, 0)
            DD      = [math]::Round($ddMax, 0)
            Familia = if ($nomeRobo -match "_dt_") { "DT" } else { "SW" }
            Status  = "PENDENTE"
        }

        # Avaliacao
        if ($reg.WR -ge $WR_MIN -and $reg.Saldo -gt $SALDO_MIN -and
            $reg.DD -le $DD_MAX -and $reg.Trades -ge $TRADES_MIN) {
            $reg.Status = "APROVADO"
        } elseif ($reg.Trades -lt $TRADES_MIN) {
            $reg.Status = "AMOSTRA INSUFICIENTE"
        } elseif ($reg.WR -lt $WR_MIN) {
            $reg.Status = "WR < $WR_MIN%"
        } elseif ($reg.DD -gt $DD_MAX) {
            $reg.Status = "DD > $DD_MAX"
        } elseif ($reg.Saldo -le $SALDO_MIN) {
            $reg.Status = "SALDO NEGATIVO"
        }

        $registros += $reg
    } catch {
        Write-Host "Erro ao ler $($csv.Name): $_"
    }
}

Write-Host "Total de combinacoes lidas: $($registros.Count)"

# ---- Calcula score ----
$aprovados = $registros | Where-Object { $_.Status -eq "APROVADO" }

if ($aprovados.Count -eq 0) {
    Write-Host "Nenhum robo aprovado nos criterios definidos."
    exit
}

$maxDD    = ($aprovados | Measure-Object DD -Maximum).Maximum
$maxWR    = ($aprovados | Measure-Object WR -Maximum).Maximum
$maxSaldo = ($aprovados | Measure-Object Saldo -Maximum).Maximum
$maxTrades= ($aprovados | Measure-Object Trades -Maximum).Maximum

# Agrupa por robo para medir consistencia (quantos TFs aprovados)
$gruposPorRobo = $aprovados | Group-Object Robo
$maxTFsAprov   = ($gruposPorRobo | Measure-Object { $_.Count } -Maximum).Maximum

$scorados = @()
foreach ($reg in $aprovados) {
    $riskNorm    = if ($maxDD    -gt 0) { 1 - ($reg.DD    / $maxDD)    } else { 1 }
    $wrNorm      = if ($maxWR    -gt 0) { $reg.WR    / $maxWR          } else { 0 }
    $saldoNorm   = if ($maxSaldo -gt 0) { $reg.Saldo / $maxSaldo       } else { 0 }
    $sampleNorm  = if ($maxTrades -gt 0){ $reg.Trades / $maxTrades     } else { 0 }

    $tfsAprov    = ($gruposPorRobo | Where-Object { $_.Name -eq $reg.Robo }).Count
    $consistNorm = if ($maxTFsAprov -gt 0) { $tfsAprov / $maxTFsAprov } else { 0 }

    $score = ($riskNorm * 0.40) + ($consistNorm * 0.25) + ($wrNorm * 0.15) +
             ($saldoNorm * 0.10) + ($sampleNorm * 0.10)

    $scorados += [PSCustomObject]@{
        Robo       = $reg.Robo
        TF         = $reg.TF
        Familia    = $reg.Familia
        Trades     = $reg.Trades
        WR         = $reg.WR
        Saldo      = $reg.Saldo
        DD         = $reg.DD
        Score      = [math]::Round($score, 4)
        TFsAprov   = $tfsAprov
    }
}

$ranking = $scorados | Sort-Object Score -Descending

# ============================================================
# ARQUIVO 1: Ranking geral
# ============================================================
$linhasGeral = @()
$linhasGeral += "=================================================================="
$linhasGeral += " RANKING GERAL - MEDIAS_20_50_200 (MME20 / MMA50 / MMA200)"
$linhasGeral += "=================================================================="
$linhasGeral += ""
$linhasGeral += "Total combinacoes lidas  : $($registros.Count)"
$linhasGeral += "Total aprovadas          : $($aprovados.Count)"
$linhasGeral += "Robos DT aprovados       : $(($aprovados | Where-Object { $_.Familia -eq 'DT' }).Count)"
$linhasGeral += "Robos SW aprovados       : $(($aprovados | Where-Object { $_.Familia -eq 'SW' }).Count)"
$linhasGeral += ""
$linhasGeral += "Score = 40% StopSeguro + 25% Consistencia + 15% WR + 10% Saldo + 10% Amostra"
$linhasGeral += ""
$linhasGeral += "Pos  Robo                        TF       Fam  Trades   WR%    Saldo    DD    TFsOK  Score"
$linhasGeral += "---  --------------------------  -------  ---  ------  -----  ------  ----  -----  -----"

$pos = 1
foreach ($r in $ranking) {
    $linha = "{0,-4} {1,-28}  {2,-7}  {3,-3}  {4,6}  {5,5:F1}  {6,6}  {7,4}  {8,5}  {9,5:F3}" -f
             $pos, $r.Robo, $r.TF, $r.Familia, $r.Trades, $r.WR, $r.Saldo, $r.DD, $r.TFsAprov, $r.Score
    $linhasGeral += $linha
    $pos++
}

$linhasGeral | Set-Content -Path "$pastaSaida\ranking_geral_medias.txt" -Encoding UTF8
Write-Host "Arquivo gerado: ranking_geral_medias.txt"

# ============================================================
# ARQUIVO 2: Ranking por familia (DT separado de SW)
# ============================================================
$linhasFam = @()
$linhasFam += "=================================================================="
$linhasFam += " RANKING POR FAMILIA - DT e SW separados"
$linhasFam += "=================================================================="

foreach ($fam in @("DT", "SW")) {
    $bloco = $ranking | Where-Object { $_.Familia -eq $fam }
    $linhasFam += ""
    $linhasFam += "--- FAMILIA: $fam ---"
    $linhasFam += "Pos  Robo                        TF       Trades   WR%    Saldo    DD    Score"
    $linhasFam += "---  --------------------------  -------  ------  -----  ------  ----  -----"
    $posF = 1
    foreach ($r in $bloco) {
        $l = "{0,-4} {1,-28}  {2,-7}  {3,6}  {4,5:F1}  {5,6}  {6,4}  {7,5:F3}" -f
             $posF, $r.Robo, $r.TF, $r.Trades, $r.WR, $r.Saldo, $r.DD, $r.Score
        $linhasFam += $l
        $posF++
    }
}

$linhasFam | Set-Content -Path "$pastaSaida\ranking_por_familia_medias.txt" -Encoding UTF8
Write-Host "Arquivo gerado: ranking_por_familia_medias.txt"

# ============================================================
# ARQUIVO 3: Detalhamento por robo (todos os TFs)
# ============================================================
$linhasDet = @()
$linhasDet += "=================================================================="
$linhasDet += " DETALHAMENTO POR ROBO - todos os TFs testados"
$linhasDet += "=================================================================="

$robosUnicos = $registros | Select-Object -ExpandProperty Robo -Unique | Sort-Object

foreach ($nomeRobo in $robosUnicos) {
    $combosRobo = $registros | Where-Object { $_.Robo -eq $nomeRobo }
    $linhasDet += ""
    $linhasDet += "=== $nomeRobo ==="
    $linhasDet += "TF         Status                    Trades   WR%    Saldo    DD"
    $linhasDet += "---------  ------------------------  ------  -----  ------  ----"
    foreach ($c in $combosRobo | Sort-Object TF) {
        $l = "{0,-10} {1,-24}  {2,6}  {3,5:F1}  {4,6}  {5,4}" -f
             $c.TF, $c.Status, $c.Trades, $c.WR, $c.Saldo, $c.DD
        $linhasDet += $l
    }
}

$linhasDet | Set-Content -Path "$pastaSaida\detalhamento_tfs_medias.txt" -Encoding UTF8
Write-Host "Arquivo gerado: detalhamento_tfs_medias.txt"

# ============================================================
# ARQUIVO 4: Estimativa de patrimônio para operar
# ============================================================
$linhasPat = @()
$linhasPat += "=================================================================="
$linhasPat += " PATRIMONIO MINIMO ESTIMADO - MEDIAS_20_50_200"
$linhasPat += "Minimo conservador = 2.5x DD | Ideal = 3.5x DD | Minimo absoluto = 1.000"
$linhasPat += "=================================================================="

# Agrupa por robo, pega o maior DD entre os TFs aprovados
$gruposAprov = $aprovados | Group-Object Robo

$linhasPat += ""
$linhasPat += "Robo                           DD Max  Pat.Min (2.5x)  Pat.Ideal (3.5x)"
$linhasPat += "-----------------------------  ------  --------------  ----------------"

foreach ($g in $gruposAprov | Sort-Object { ($_.Group | Measure-Object DD -Maximum).Maximum }) {
    $ddMax  = ($g.Group | Measure-Object DD -Maximum).Maximum
    $patMin  = [math]::Max([math]::Round($ddMax * 2.5, 0), 1000)
    $patIdeal= [math]::Max([math]::Round($ddMax * 3.5, 0), 1500)
    $l = "{0,-31} {1,6}  {2}  {3}" -f
         $g.Name, $ddMax, "${rs}$patMin", "${rs}$patIdeal"
    $linhasPat += $l
}

$linhasPat | Set-Content -Path "$pastaSaida\patrimonio_medias.txt" -Encoding UTF8
Write-Host "Arquivo gerado: patrimonio_medias.txt"

Write-Host ""
Write-Host "=== CONCLUIDO ==="
Write-Host "4 arquivos gerados em $pastaSaida"
Write-Host ""
Write-Host "TOP 5 geral:"
$ranking | Select-Object -First 5 | Format-Table Robo, TF, Familia, WR, Saldo, DD, Score
