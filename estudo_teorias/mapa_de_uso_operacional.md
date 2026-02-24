# Mapa de Uso Operacional (Branch fevereiro_tradeOperador)

Este mapa organiza, em ordem prática, como usar os materiais da branch durante o dia de trade.

## 1) Pré-mercado (planejamento)

### Objetivo
Definir viés do dia e cenários de risco antes de procurar entrada.

### Ler/consultar
- `estudo_teorias/teoria_panorama_contexto.md`
- `estudo_teorias/teoria_tendencia.md`
- `estudo_teorias/teoria_tendencia_institucional.md`
- `estudo_teorias/organizacao_B3_Internacional_horarios.md`
- `estudo_teorias/gerenciamento_risco.md`

### Resultado esperado
- Viés inicial (comprador, vendedor ou neutro).
- Janelas de maior atenção (abertura, horários turbulentos, eventos).
- Limite de risco do dia definido.

---

## 2) Leitura de contexto no gráfico (filtro de permissão)

### Objetivo
Só operar quando houver contexto institucional e estrutura favoráveis.

### Aplicar no Profit
- `profit_estudos_cores/fev_VWAPsemanalDiario.txt`
- `profit_estudos_cores/fev_VWAPreferenciaPreco.txt`
- `profit_estudos_cores/fev_DetectorFasesMercado.txt`
- `profit_estudos_cores/fev_panorama920.txt`
- `profit_estudos_cores/fev_panoramaMedias9_20_50_200.txt`

### Regra prática
- Se VWAP/estrutura/fase estiverem indefinidas ou conflitantes: **não clicar**.
- Se houver alinhamento de tendência/fase: avançar para gatilho.

---

## 3) Estrutura e confirmação de direção

### Objetivo
Confirmar que não é apenas ruído/lateral curta.

### Aplicar no Profit
- `profit_estudos_cores/fev_TendenciaPivoTesteDeOuro.txt`
- `profit_estudos_cores/fev_TendenciaLongoPrazo.txt`
- `profit_estudos_cores/fev_mediasTrend9_20_50_200.txt`
- `profit_estudos_cores/fev_MediasSetupDiario.txt`
- `profit_estudos_cores/fev_MediasSetupSemana.txt`

### Regra prática
- Só buscar entrada quando pivô/rompimento e tendência estiverem coerentes entre si.
- Se sinais forem mistos, reduzir frequência (esperar nova barra de confirmação).

---

## 4) Gatilho de entrada (execução)

### Objetivo
Executar entrada apenas com candle/gatilho qualificado.

### Aplicar no Profit
- `profit_estudos_cores/fev_PriceActionCorpoSombraExecucao.txt`
- `profit_estudos_cores/fev_PriceActionAnaliseCorpo.txt`
- `profit_estudos_cores/fev_PriceActionAnaliseSombra.txt`
- `profit_estudos_cores/fev_PriceActionTiposCandlesLeitura.txt`
- `profit_estudos_cores/fev_priceActionPrimeiroCandle.txt`

### Regra prática
- Contexto bom + gatilho ruim = **sem entrada**.
- Contexto bom + gatilho limpo = entrada com risco previamente definido.

---

## 5) Confirmação de fluxo/força

### Objetivo
Evitar entrada em rompimento fraco ou divergente.

### Aplicar no Profit
- `profit_estudos_cores/fev_OBVvolumeVerdadeiro.txt`
- `profit_estudos_cores/fev_VSAassinaturaInstitucional.txt`
- `profit_estudos_cores/fev_PriceActionVSA_OBV.txt`
- `profit_estudos_cores/fev_DivergenciaIFR.txt`
- `profit_estudos_cores/fev_ATRmovimentoDoPrecoComVontade.txt`

### Regra prática
- Se fluxo divergir da direção da operação: abortar ou reduzir exposição.
- Priorizar operações com confluência de força (VSA/OBV/ATR).

---

## 6) Tomada de decisão unificada (checklist final)

### Objetivo
Consolidar os filtros em uma decisão única e repetível.

### Aplicar no Profit
- `profit_estudos_cores/fev_PainelDecisao.txt`
- `profit_estudos_cores/fev_PainelDecisaoAlarme.ntsl.txt`

### Regra prática
- Usar o painel como “porteiro” final: só operar em confluência.
- Sem confluência completa: aguardar, sem forçar trade.

---

## 7) Gestão intraday

### Objetivo
Gerenciar ritmo operacional e proteger capital durante o pregão.

### Aplicar no Profit
- `profit_estudos_cores/fev_direcaoDoDia.txt`
- `profit_estudos_cores/fev_HorarioTurbulencia.txt`
- `profit_estudos_cores/fev_2minReversaoComVolumeWIN.txt`
- `profit_estudos_cores/fev_RegraDeDow_Rompimento.txt`

### Regra prática
- Em horário turbulento: exigir confirmação extra.
- Se perder contexto do dia: parar, reavaliar, só depois voltar.

---

## 8) Pós-mercado (revisão)

### Objetivo
Evoluir processo e reduzir erro repetido.

### Revisar com base em
- `estudo_teorias/tabela_confluencias.md`
- `estudo_teorias/teoria_sentimentosTrade.md`
- `estudo_teorias/teoria_wyckoff.md`
- `estudo_teorias/teoria_volume.md`
- `estudo_teorias/eficiencia_tributaria.md`

### Checklist de revisão
- A entrada respeitou contexto institucional?
- O gatilho foi limpo ou antecipado?
- Havia confluência de fluxo/força?
- O risco do plano foi respeitado?
- Houve overtrade por emoção?

---

## Ordem rápida (resumo de bolso)

1. Contexto (VWAP + fase + panorama)
2. Estrutura (tendência/pivô/médias)
3. Gatilho (price action corpo/sombra)
4. Fluxo (OBV/VSA/ATR)
5. Painel final (autoriza ou não)
6. Gestão intraday (horário e risco)
7. Revisão pós-mercado

Se qualquer etapa falhar, não avançar para a próxima.