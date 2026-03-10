$base = "c:\Users\zilva\RepoRobos-marco_Tradeoperador\automacao_backtests\CANDLE1A4\versoes_tf_menor"
$files = Get-ChildItem -Path $base -File | Where-Object { $_.Name -like 'robo_candle1a4_v*.txt' }

$updated = 0
foreach ($file in $files) {
  $strategyName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
  $lines = Get-Content -Path $file.FullName

  if ($lines.Count -eq 0) { continue }

  if ($lines[0].Trim() -eq "{") {
    $endIdx = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
      if ($lines[$i].Trim() -eq "}") {
        $endIdx = $i
        break
      }
    }

    if ($endIdx -ge 0 -and $endIdx -lt ($lines.Count - 1)) {
      $lines = $lines[($endIdx + 1)..($lines.Count - 1)]
      while ($lines.Count -gt 0 -and [string]::IsNullOrWhiteSpace($lines[0])) {
        if ($lines.Count -eq 1) { break }
        $lines = $lines[1..($lines.Count - 1)]
      }
    }
  }

  $content = ($lines -join "`r`n")

  $content = $content -replace 'MinPercCorpoC1\((\d+),(\d+)\);', 'MinPercCorpoC1($1.$2);'
  $content = $content -replace 'ConfirmacaoC2MinPerc\((\d+),(\d+)\);', 'ConfirmacaoC2MinPerc($1.$2);'
  $content = $content -replace 'RazaoPavio\((\d+),(\d+)\);', 'RazaoPavio($1.$2);'

  $content = $content -replace '(?m)^\s*if HabilitarApenasTFMenor and \(Interval\(\) > 5\) then\s*\r?\n\s*Exit;\s*\r?\n', ''
  $content = $content -replace 'if \(BarNumber > 1\) then', 'if true then'
  $content = $content -replace 'if \(BarNumber > 2\) then', 'if true then'
  $content = $content -replace 'if \(BarNumber > 3\) then', 'if true then'
  $content = $content -replace 'if \(BarNumber > 4\) then', 'if true then'
  $content = $content -replace 'if \(IsBought or IsSold\) and \(BarNumber > 4\) then', 'if (IsBought or IsSold) then'

  if ($content -notmatch '(?m)^//\s*Estrategia:\s*') {
    $header = @(
      "// Estrategia: $strategyName",
      "// Tema: Candle1A4 (Candle 1 ate Candle 4)",
      "// Descricao: Leitura do Candle 1, entrada no Candle 2 e saida por rejeicao/tempo.",
      ""
    ) -join "`r`n"
    $content = $header + $content
  }

  Set-Content -Path $file.FullName -Value $content -Encoding UTF8
  $updated++
}

"TOTAL_AJUSTADOS=$updated"
