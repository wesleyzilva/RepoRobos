---
description: Gera um robô NTSL completo para Neologica Profit baseado em confluência geométrica
---

# Prompt: Gerador de Robô NTSL — Confluência Geométrica

## Contexto
Você é um especialista em NTSL (Neologica Trading Script Language) e price action.
Sempre leia `skills/skill_ntsl_syntax.md` e `skills/skill_confluencia_geometrica.md` antes de gerar código.

## Instruções para o robô

Crie um robô NTSL completo para **${input:ativo:WIN B3}** no timeframe de **${input:timeframe:5 minutos}** baseado no seguinte padrão: **${input:padrao:confluencia geometrica com forca}**.

### O robô DEVE conter:

#### 1. Cabeçalho obrigatório
```pascal
{
  Robo: NOME
  Descricao: objetivo em uma linha
  Ativo: ...
  Timeframe: ...
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: estrutura geometrica mais proxima
  Spread_descontado: 10 pts
  Slippage_descontado: 15 pts
}
```

#### 2. Inputs configuráveis
- `ForcaMinimaEntrada` (default 60) — limiar de força mínima para considerar entrada
- `RRR_Minimo` (default 2.0) — razão risco/recompensa mínima
- `VolumeMultiplicador` (default 1.5) — volume mínimo vs média 20
- `StopHorario_H` (default 17) e `StopHorario_M` (default 45)
- `MaxBarrasEmPosicao` (default 8)

#### 3. Cálculo de força F = M × A
```pascal
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
```

#### 4. Gradiente de cores
Aplicar gradiente RGB conforme `docs/cores_candles_degrade.md`.

#### 5. Lógica de confluência geométrica
- Identificar níveis de corpo (abertura/fechamento) de candles anteriores relevantes
- Verificar sobreposição de áreas (mínimo 2 referências)
- Só ativar sinal se o preço atual estiver dentro de zona de confluência

#### 6. Condições de entrada
- Long: `fForca >= ForcaMinimaEntrada` + zona de confluência de compra + RRR validado
- Short: `fForca <= -ForcaMinimaEntrada` + zona de confluência de venda + RRR validado
- Volume confirmado: `Volume >= fVolumeMedio * VolumeMultiplicador`

#### 7. Stop Loss e Take Profit
```
SL_Long  = Mínimo da estrutura de confluência
SL_Short = Máximo da estrutura de confluência
SG_Long  = Entrada + (Entrada - SL_Long) * RRR_Minimo
SG_Short = Entrada - (SL_Short - Entrada) * RRR_Minimo
```
Sempre verificar: `(SG - Entrada) >= (Entrada - SL) * RRR_Minimo` antes de entrar.

#### 8. Saídas
- Stop horário: `ClosePosition` quando hora >= StopHorario_H e minuto >= StopHorario_M
- Máximo de barras em posição
- Reversão de força oposta com confirmação

#### 9. Comentários inline obrigatórios
Cada bloco deve ter comentário explicando a lógica de confluência aplicada.

### Formato de saída
Retorne APENAS o código NTSL completo, compilável, sem blocos de markdown.
