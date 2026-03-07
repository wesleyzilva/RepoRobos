PLANO DE ESTUDOS - ROBÔS IFR (RSI) PARA MINI ÍNDICE (WIN)

1) OBJETIVO GERAL
- Usar IFR parametrizável para intraday no WIN.
- Priorizar período da manhã (maior volatilidade e deslocamento inicial).
- Usar sinais de rejeição em Price Action para entrada.
- Buscar capturar o maior range possível até sinal de enfraquecimento/virada via volume e candle.

2) PREMISSAS OPERACIONAIS
- Timeframes foco: 2 minutos e 5 minutos.
- Janela principal: abertura até metade da manhã (ex.: 09:00-11:30).
- IFR padrão inicial: 9 e 14 (comparar os dois).
- Zonas de trabalho:
	- agressiva: 35/65
	- balanceada: 30/70
	- conservadora: 20/80
	- extrema: 10/90

3) GATILHOS BASE (PRICE ACTION + VOLUME)
- Rejeição de fundo (compra): martelo/pavio inferior dominante + fechamento no terço superior + volume acima da média.
- Rejeição de topo (venda): estrela/pavio superior dominante + fechamento no terço inferior + volume acima da média.
- Doji contextual: válido quando acompanhado por volume e extremo de IFR.
- Confirmação opcional: rompimento da máxima/mínima do candle de sinal no candle seguinte.

4) OPÇÕES DE ESTRATÉGIA COM IFR (ALÉM DO BÁSICO)
- Reversão por extremos: entrada em IFR extremo com rejeição, saída por sinal contrário forte.
- Reversão por retorno da zona: entrada quando IFR sai do extremo e cruza de volta o nível (filtro de timing).
- Tendência com pullback: operar apenas a favor da direção do IFR (acima/abaixo de 50) e entrar em correções.
- Divergência IFR + Price Action: operar apenas quando houver divergência e candle de confirmação.
- Regime por volatilidade: mudar parâmetros IFR/volume conforme ATR ou horário.
- Saída híbrida: IFR alvo + trailing por candle contrário + proteção por tempo máximo em posição.

5) VERSÕES DE ROBÔ PARA BACKTEST
- V1 Base Extremos: simples, mais sinais.
- V2 Newton/Força: exige aceleração/força na direção da entrada.
- V3 Confirmação: exige confirmação de rompimento do candle de sinal.
- V4 Score Conservador: pontuação mínima de rejeição (pavio + fechamento + volume + extremo).

6) MATRIZ MÍNIMA DE BACKTEST
- Timeframe: 2m e 5m.
- IFR período: 9 e 14.
- Zonas IFR: 35/65, 30/70, 20/80.
- Filtro de volume: ligado/desligado (fator 1.0, 1.2, 1.4).
- Entrada: no candle de sinal vs confirmação no seguinte.
- Saída: IFR50 vs sinal contrário forte vs híbrida.

7) MÉTRICAS OBRIGATÓRIAS
- Taxa de acerto (%).
- Fator de lucro.
- Drawdown máximo.
- Resultado líquido por dia e por horário.
- Expectância por trade.
- Número de trades (evitar overfitting por baixa amostra).

8) CRITÉRIOS DE APROVAÇÃO
- Fator de lucro > 1.20 em amostra de treino e validação.
- Drawdown compatível com o risco aceitável da conta.
- Estabilidade entre 2m e 5m (não depender de um único setup frágil).
- Consistência por faixa de horário, sem concentrar tudo em 1 ou 2 dias.

9) PRÓXIMOS PASSOS PRÁTICOS
- Rodar grid inicial (V1-V4 x IFR 9/14 x zonas 35/65-30/70-20/80).
- Selecionar top 2 por fator de lucro com drawdown controlado.
- Fazer teste fora da amostra (out-of-sample).
- Definir versão candidata para paper trade antes de colocar em conta real.

10) STATUS ATUAL APÓS RENOMEAÇÃO DOS ARQUIVOS
- Convenção adotada:
	- Arquivos aprovados: nome inclui melhor timeframe e % de vencedoras.
	- Arquivos reprovados: sufixo REPROVADO.

- Aprovados (melhor resultado identificado):
	- robo_ifr_v1_reversao_extremos60min71%.txt
	- robo_ifr_v4_divergencia_confirmada60min90%.txt
	- robo_ifr_v5_regime_volatilidade60min90%.txt
	- robo_ifr_v6_saida_hibrida60min77%.txt
	- robo_ifr_v7_resgate_contexto30min84%.txt

- Reprovados (desempenho fraco em múltiplos timeframes):
	- Reprovados/robo_ifr_v2_retorno_zonaREPROVADO.txt
	- Reprovados/robo_ifr_v3_tendencia_pullbackREPROVADO.txt
	- Reprovados/robo_ifr_v8_resgate_breakout_ifrREPROVADO.txt

11) PRÓXIMA ETAPA RECOMENDADA
- Rodar validação fora da amostra nos aprovados (janela e período diferentes dos usados no ajuste).
- Priorizar v4, v5 e v7 para comparação final por fator de lucro, drawdown e número de trades.

12) NOVOS ROBÔS CRIADOS (V9-V11)
- V9 Conservador Contexto (`robo_ifr_v9_conservador_contexto.txt`)
	- Lógica: retorno de IFR extremo com filtros de tendência (MME9/21) e volume mais rígido.
	- Perfil: menos trades, maior seletividade.
	- Base: IFR(9), retorno 30->35 compra e 70->65 venda, volume fator 1.2.

- V10 Balanceado Regime (`robo_ifr_v10_balanceado_regime.txt`)
	- Lógica: alterna comportamento por regime.
	- Em tendência: pullback IFR (45/55).
	- Em lateral: reversão por extremos (30/70).
	- Perfil: equilíbrio entre frequência e qualidade de sinal.

- V11 Agressivo Reentrada (`robo_ifr_v11_agressivo_reentrada.txt`)
	- Lógica: entradas mais cedo (40/60) após extremos (30/70) com 1 reentrada por direção.
	- Perfil: maior número de operações e maior sensibilidade a ruído.
	- Base: saída em IFR50 e/ou tempo máximo em posição.

13) STATUS DE VALIDAÇÃO (HOJE)
- Versões validadas:
	- v1, v4, v5, v6, v7
	- v10 (`robo_ifr_v10_balanceado_regime60min63%.txt`)
	- v11 (`robo_ifr_v11_agressivo_reentrada30min58%.txt`)
	- v18 (`robo_ifr_v18_bandas_dinamicas60min60%.txt`)

- Versões reprovadas:
	- v2, v3, v8, v9
	- v12 (`Reprovados/robo_ifr_v12_multitimeframe_alinhadoREPROVADO.txt`)
	- v13 (`Reprovados/robo_ifr_v13_divergencia_estruturaREPROVADO.txt`)
	- v15 (`Reprovados/robo_ifr_v15_saida_estagio_trailingREPROVADO.txt`)
	- v16 (`Reprovados/robo_ifr_v16_slope_cooldownREPROVADO.txt`)
	- v17 (`Reprovados/robo_ifr_v17_failure_swingREPROVADO.txt`)

14) NOVAS OPÇÕES CRIADAS PARA PRÓXIMA RODADA
- V12 Multi-timeframe Alinhado (`robo_ifr_v12_multitimeframe_alinhado.txt`)
	- Entrada no timeframe atual com filtro direcional por IFR de contexto.
	- Objetivo: reduzir entradas contra o fluxo predominante.

- V13 Divergência + Estrutura (`robo_ifr_v13_divergencia_estrutura.txt`)
	- Exige divergência de IFR e confirmação por quebra curta de estrutura.
	- Objetivo: evitar divergência sem confirmação de preço.

- V15 Saída em Estágio + Trailing (`robo_ifr_v15_saida_estagio_trailing.txt`)
	- Após atingir IFR 50, ativa estágio de saída por trailing simples de candle.
	- Objetivo: capturar mais continuidade quando o movimento estica.

15) RESULTADO DA RODADA V12-V13-V15
- As três variações foram reprovadas na validação atual e movidas para a pasta `Reprovados`.
- Permanecem como candidatas válidas: v1, v4, v5, v6, v7, v10, v11 e v18.

16) NOVAS SUGESTÕES IMPLEMENTADAS (V16-V18)
- V16 Slope + Cooldown (`robo_ifr_v16_slope_cooldown.txt`)
	- Entrada por retorno de extremo com inclinação mínima do IFR.
	- Aplica cooldown de barras após saída para evitar reentrada imediata.

- V17 Failure Swing (`robo_ifr_v17_failure_swing.txt`)
	- Usa pivoteamento do IFR (failure swing) com confirmação simples no preço.
	- Foco em reversões com estrutura mínima confirmada.

- V18 Bandas Dinâmicas (`robo_ifr_v18_bandas_dinamicas.txt`)
	- Níveis de entrada definidos por percentis do range do IFR no lookback.
	- Troca gatilhos fixos por gatilhos adaptativos ao regime do dia.

17) RESULTADO DA RODADA V16-V17-V18
- v16 e v17 foram reprovados e movidos para `Reprovados`.
- v18 foi validado com melhor leitura em 60min e mantido na pasta principal.

18) NOVAS OPÇÕES IMPLEMENTADAS (V19-V21)
- V19 IFR + VWAP Contexto (`robo_ifr_v19_ifr_vwap_contexto.txt`)
	- Filtro direcional por VWAP aproximada (preço ponderado por volume).
	- Compra apenas com preço acima da VWAP; venda apenas abaixo.

- V20 IFR Assimétrico por Lado (`robo_ifr_v20_ifr_assimetrico_lado.txt`)
	- Níveis de entrada/retorno diferentes para compra e venda.
	- Saída também assimétrica para refletir comportamento distinto por direção.

- V21 IFR + Faixa de Volatilidade (`robo_ifr_v21_ifr_atr_faixa.txt`)
	- Usa range médio de candle como proxy de ATR para filtrar regime operável.
	- Evita operar em baixa volatilidade extrema ou explosão de ruído.

19) NOVAS OPÇÕES IMPLEMENTADAS (V22-V24)
- V22 Tendência Forte (`robo_ifr_v22_tendencia_forte.txt`)
	- IFR com filtro de tendência forte por MME9/21 e inclinação mínima da MME longa.
	- Objetivo: reduzir operações em lateralização e priorizar continuidade direcional.

- V23 Dupla Confirmação (`robo_ifr_v23_dupla_confirmacao.txt`)
	- IFR com zona neutra 45-55 e exigência de dois candles de confirmação.
	- Objetivo: reduzir falsos rompimentos de retorno do IFR.

- V24 Controle de Risco Diário (`robo_ifr_v24_controle_risco_diario.txt`)
	- Limita trades por dia e bloqueia novas entradas após excesso de saídas por tempo.
	- Objetivo: conter deterioração de desempenho em dia adverso.

20) NOVAS OPÇÕES IMPLEMENTADAS (V25-V27)
- V25 IFR + MME200 Contexto (`robo_ifr_v25_ifr_mme200_contexto.txt`)
	- Filtra direção pelo contexto estrutural de longo prazo (acima/abaixo da MME200).
	- Objetivo: reduzir operações contra tendência principal.

- V26 Janela + Pivô (`robo_ifr_v26_janela_pivo.txt`)
	- Opera somente em janela horária definida e exige rompimento de pivô curto para confirmar.
	- Objetivo: aumentar qualidade de entrada em horário mais favorável.

- V27 Um Trade por Direção (`robo_ifr_v27_um_trade_por_direcao.txt`)
	- Limita 1 trade de compra e 1 trade de venda por sessão, com saída por tempo curta.
	- Objetivo: controlar overtrading e preservar capital em dias erráticos.

21) NOVAS OPÇÕES IMPLEMENTADAS (V28-V30)
- V28 IFR + ADX Filtro (`robo_ifr_v28_ifr_adx_filtro.txt`)
	- IFR com filtro de força de tendência via ADX mínimo.
	- Objetivo: reduzir entradas em mercado sem direção.

- V29 IFR + Direção da Abertura (`robo_ifr_v29_ifr_direcao_abertura.txt`)
	- Só opera a favor da direção definida na abertura/referência da sessão.
	- Objetivo: alinhar operações com viés intradiário inicial.

- V30 IFR + Circuit Breaker Diário (`robo_ifr_v30_ifr_circuit_breaker_diario.txt`)
	- Limita operações após gatilhos de deterioração diária (saídas por tempo e limite de trades).
	- Objetivo: interromper overtrading em dia adverso.

22) CATÁLOGO DE 50 OPÇÕES IFR (PRÉ-OTIMIZAÇÃO)
- Arquivo de referência: `catalogo_50_opcoes_IFR.txt`.
- Objetivo: ampliar repertório de ideias antes da fase de otimização dos vencedores.
- Próxima seleção sugerida: escolher 10 opções do catálogo para nova rodada de implementação.

23) NOVA RODADA IMPLEMENTADA (V31-V35)
- V31 Reversão + Volume Relativo (`robo_ifr_v31_reversao_volume_relativo.txt`)
	- Retorno de extremo IFR com exigência de volume acima da média.

- V32 Retorno + Pivô 3 (`robo_ifr_v32_retorno_pivo3.txt`)
	- Entrada só com confirmação por rompimento de pivô curto.

- V33 Pullback + MME200 (`robo_ifr_v33_pullback_mme200.txt`)
	- Pullback de IFR operando somente a favor do contexto da MME200.

- V34 No-Trade-Zone (`robo_ifr_v34_no_trade_zone.txt`)
	- Bloqueia entradas na faixa IFR 45-55 para evitar indefinição.

- V35 Cooldown Diário (`robo_ifr_v35_cooldown_diario.txt`)
	- Após saída por tempo, aplica cooldown de barras para conter sobreoperação.

24) NOVA RODADA IMPLEMENTADA (V36-V40)
- V36 Divergência Regular + Pivô (`robo_ifr_v36_divergencia_regular_pivo.txt`)
	- Divergência de IFR confirmada por rompimento de pivô curto.

- V37 ADX Faixa Operável (`robo_ifr_v37_adx_faixa_operavel.txt`)
	- Opera IFR apenas quando ADX está dentro de faixa de mercado operável.

- V38 VWAP Distância Máxima (`robo_ifr_v38_vwap_distancia_max.txt`)
	- Bloqueia entrada quando preço está muito distante da VWAP aproximada.

- V39 ORB + IFR (`robo_ifr_v39_orb_ifr.txt`)
	- Exige rompimento da faixa inicial do dia (ORB) junto ao gatilho IFR.

- V40 Saída Estrutura + Tempo (`robo_ifr_v40_stop_estrutura_tempo.txt`)
	- Mantém entrada simples por IFR e reforça saída por perda estrutural/tempo.

25) NOVA RODADA IMPLEMENTADA (V41-V45)
- V41 Percentil 20/80 (`robo_ifr_v41_percentil_20_80.txt`)
	- Bandas dinâmicas de IFR por percentis 20/80.

- V42 Parâmetros por Sessão (`robo_ifr_v42_parametros_por_sessao.txt`)
	- Ajusta extremos/retornos de IFR por bloco horário.

- V43 VWAP Direcional (`robo_ifr_v43_vwap_direcional.txt`)
	- Só compra acima da VWAP aproximada e só vende abaixo.

- V44 VWAP Distância Dupla (`robo_ifr_v44_vwap_distancia_dupla.txt`)
	- Exige faixa de distância mínima e máxima da VWAP.

- V45 Volume por Horário (`robo_ifr_v45_volume_por_horario.txt`)
	- Filtro de volume ajustado por janela da sessão.

26) NOVA RODADA IMPLEMENTADA (V46-V50)
- V46 Direção Abertura Refinada (`robo_ifr_v46_direcao_abertura_refinada.txt`)
	- Viés direcional definido pela referência da abertura.

- V47 ORB Confirmação Dupla (`robo_ifr_v47_orb_confirmacao_dupla.txt`)
	- Exige rompimento da ORB com confirmação por dois candles.

- V48 Circuit Breaker Tempo (`robo_ifr_v48_circuit_breaker_tempo.txt`)
	- Bloqueia novas entradas ao exceder saídas por tempo no dia.

- V49 Limite Trades Progressivo (`robo_ifr_v49_limite_trades_progressivo.txt`)
	- Aplica filtro extra após metade do limite diário de trades.

- V50 Meta/Perda Proxy (`robo_ifr_v50_meta_perda_proxy.txt`)
	- Pausa operacional por metas e limites diários proxy (saída IFR50/tempo).

27) ANÁLISE DOS APROVADOS POR TIMEFRAME (META >= 60%)
- Arquivo de apoio: `analise_aprovados_timeframes_IFR.txt`.
- Cobertura alvo: 60, 30, 15, 5 e 2 minutos.
- Foco: manter positivo e filtrar estratégias abaixo de 60% de vencedoras.