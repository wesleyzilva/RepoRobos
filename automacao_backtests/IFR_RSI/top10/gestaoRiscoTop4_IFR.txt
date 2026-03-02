PLANO OPERACIONAL - ROBÔS IFR

==================================================
PLANO A - MÍNIMO POSSÍVEL PARA COMEÇAR
==================================================

Objetivo
- Começar com o menor capital possível, 1 robô e 1 contrato.

Capital mínimo para início
- R$1.500

Configuração do Plano A
- Robô: v20_30min
- Contratos: 1
- Perda diária máxima (1%): R$15,00
- Perda semanal máxima (3%): R$45,00

Evolução sugerida do Plano A
- Etapa 1: R$1.500 -> rodar apenas v20_30min.
- Etapa 2: R$4.000 -> rodar 2 robôs (v20_30min + v45_60min), 1 contrato cada.
- Etapa 3: migrar para Plano B completo quando atingir estrutura e consistência.

==================================================
PLANO B - ESTRUTURA COMPLETA (CAPITAL R$10.000)
==================================================

RESUMO RÁPIDO - VALOR MÍNIMO PARA USAR OS ROBÔS (PLANO B)
- v6_60min: R$3.500
- v5_60min: R$2.500
- v45_60min: R$2.500
- v20_30min: R$1.500
- Mínimo total para rodar os 4: R$10.000

Mínimo operacional
- 1 contrato por robô/conta.

Base dos robôs (resultado anual histórico do estudo)
1) v6_60min = +2.315
2) v5_60min = +1.563
3) v45_60min = +1.643
4) v20_30min = +1.393

Soma histórica dos 4 = +6.914
Capital base = R$10.000
Retorno simples estimado = +69,14% (sem alavancagem adicional)

==================================================
COMO SEPARAR POR CONTAS (RECOMENDAÇÃO)
==================================================

Estrutura recomendada: 4 contas, 1 robô por conta

Conta_A (35% = R$3.500)
- Robô: v6_60min
- Peso do lucro esperado: 2.315 / 6.914 = 33,48%
- Lucro anual proporcional estimado: R$2.315
- Capital final estimado da conta: R$5.815

Conta_B (25% = R$2.500)
- Robô: v5_60min
- Peso do lucro esperado: 1.563 / 6.914 = 22,61%
- Lucro anual proporcional estimado: R$1.563
- Capital final estimado da conta: R$4.063

Conta_C (25% = R$2.500)
- Robô: v45_60min
- Peso do lucro esperado: 1.643 / 6.914 = 23,76%
- Lucro anual proporcional estimado: R$1.643
- Capital final estimado da conta: R$4.143

Conta_D (15% = R$1.500)
- Robô: v20_30min
- Peso do lucro esperado: 1.393 / 6.914 = 20,15%
- Lucro anual proporcional estimado: R$1.393
- Capital final estimado da conta: R$2.893

Total consolidado (4 contas)
- Lucro estimado: R$6.914
- Capital final estimado: R$16.914

==================================================
CONTROLE DE RISCO POR CONTA
==================================================

Limites sugeridos
- Perda diária por conta: 1,0% do saldo da conta
- Perda semanal por conta: 3,0% do saldo da conta
- Ao bater limite semanal: pausar a conta até semana seguinte

Observação operacional
- Você pode rodar no máximo 2 robôs simultâneos no início.
- Ordem prática de ativação:
	1) v6_60min
	2) v5_60min
	3) v45_60min
	4) v20_30min

==================================================
CENÁRIOS DE RESULTADO (ANUAL)
==================================================

Cenário Base (100% do histórico)
- Lucro: +R$6.914
- Final: R$16.914

Cenário Conservador (75% do histórico, custos/slippage)
- Lucro: +R$5.185,50
- Final: R$15.185,50

Cenário Estressado (50% do histórico)
- Lucro: +R$3.457
- Final: R$13.457

Nota importante
- Isso é projeção baseada no histórico analisado, não garantia de resultado futuro.

==================================================
CONFIGURAÇÃO PRONTA PARA COLOCAR NOS ROBÔS
==================================================

1) LIMITES EM R$ POR CONTA (usar no setup de cada robô)

Conta_A (v6_60min | saldo R$3.500)
- Limite diário (1%): R$35,00
- Limite semanal (3%): R$105,00

Conta_B (v5_60min | saldo R$2.500)
- Limite diário (1%): R$25,00
- Limite semanal (3%): R$75,00

Conta_C (v45_60min | saldo R$2.500)
- Limite diário (1%): R$25,00
- Limite semanal (3%): R$75,00

Conta_D (v20_30min | saldo R$1.500)
- Limite diário (1%): R$15,00
- Limite semanal (3%): R$45,00

2) LÓGICA DE TRAVA (copiar para todos os robôs)

Passo a passo operacional
- No início de cada dia: recalcular limite diário pelo saldo atual da conta.
- No início de cada semana: zerar acumulador semanal.
- Se resultado do dia <= -limite diário: bloquear novas entradas até o próximo dia.
- Se resultado da semana <= -limite semanal: bloquear novas entradas até a próxima semana.

Template (adaptar nomes de variáveis à sua estratégia)

input
	SaldoConta(3500.0);
	RiscoDiaPct(1.0);
	RiscoSemanaPct(3.0);

var
	LimiteDia, LimiteSemana : float;
	ResultadoDia, ResultadoSemana : float;
	BloqueioDia, BloqueioSemana : boolean;

begin
	LimiteDia := SaldoConta * (RiscoDiaPct / 100.0);
	LimiteSemana := SaldoConta * (RiscoSemanaPct / 100.0);

	// Atualizar ResultadoDia e ResultadoSemana com o PnL da sua lógica

	if ResultadoDia <= -LimiteDia then
		BloqueioDia := true;

	if ResultadoSemana <= -LimiteSemana then
		BloqueioSemana := true;

	if BloqueioDia or BloqueioSemana then
	begin
		// Não abrir novas posições
		// Exemplo: pular bloco de entrada
	end;
end;

3) PARÂMETRO SaldoConta EM CADA ROBÔ

- No robô da Conta_A (v6_60min), usar SaldoConta(3500.0)
- No robô da Conta_B (v5_60min), usar SaldoConta(2500.0)
- No robô da Conta_C (v45_60min), usar SaldoConta(2500.0)
- No robô da Conta_D (v20_30min), usar SaldoConta(1500.0)

4) REGRA DE REATIVAÇÃO

- Bloqueio diário: reativar no próximo pregão.
- Bloqueio semanal: reativar na segunda-feira seguinte.

==================================================
VALOR MÍNIMO PARA INVESTIR (1 ROBÔ POR CONTA)
==================================================

Premissas usadas neste cálculo
- 1 contrato de mini índice (WIN).
- Valor por ponto: R$0,20 por contrato.
- Custo operacional: R$0,80 por lado (R$1,60 ida + volta por contrato).
- Imposto: 20% sobre lucro líquido (estimativa simplificada).
- Regra de risco: perda diária máxima = 1% do saldo da conta.

1) QUANTOS CONTRATOS NO MÍNIMO?

- Mínimo operacional por robô/conta: 1 contrato.

2) CAPITAL MÍNIMO POR CONTA (PARA 1 CONTRATO)

Fórmula usada
- RiscoTrade(R$) = (StopPontos x 0,20) + 1,60
- CapitalMínimo(R$) = RiscoTrade / 0,01

Tabela prática (1 contrato)
- Stop 50 pts -> risco por trade = R$11,60 -> capital mínimo = R$1.160
- Stop 80 pts -> risco por trade = R$17,60 -> capital mínimo = R$1.760
- Stop 100 pts -> risco por trade = R$21,60 -> capital mínimo = R$2.160

Leitura para suas contas atuais
- Conta_A (R$3.500): suporta 1 contrato com folga.
- Conta_B (R$2.500): suporta 1 contrato com folga.
- Conta_C (R$2.500): suporta 1 contrato com folga.
- Conta_D (R$1.500): suporta 1 contrato em stop curto; fica apertada em stops mais largos.

3) RESUMO DO MÍNIMO PARA RODAR SUA ESTRUTURA

- Mínimo por robô (1 contrato):
	- v6_60min: R$3.500 (configurado)
	- v5_60min: R$2.500 (configurado)
	- v45_60min: R$2.500 (configurado)
	- v20_30min: R$1.500 (configurado)
- Mínimo total para os 4 robôs: R$10.000

4) LUCRO ANUAL LÍQUIDO ESTIMADO (com custo + imposto)

Base bruta do estudo
- v6_60min: +R$2.315
- v5_60min: +R$1.563
- v45_60min: +R$1.643
- v20_30min: +R$1.393
- Total bruto: +R$6.914

Estimativa líquida (após custos operacionais e 20% de imposto)
- Total líquido estimado: +R$5.427,52

Observação importante
- Este valor líquido é projeção com premissas simplificadas.
- Resultado real pode variar por corretagem, emolumentos, slippage e número de operações.

==================================================
AJUSTES RECOMENDADOS PARA FICAR PRONTO PARA PRODUÇÃO
==================================================

Status atual da gestão de risco
- Boa base: limite diário 1%, semanal 3%, bloqueio de novas entradas e reset semanal.
- OCO e breakeven já estão parametrizáveis nos 4 robôs (podem ser ligados/desligados em backtest).

O que falta para robustez máxima
- Hard lock: ao bater limite diário/semanal, fechar posição aberta imediatamente e pausar. (IMPLEMENTADO nos 4 robôs com parâmetro UsarHardLock)
- Resultado realizado: preferir PnL realizado da execução (quando disponível), evitando proxy por fechamento de candle.
- Ordem de ativação da proteção: 1) OCO, 2) breakeven conservador, 3) breakeven agressivo (somente após validação).

Parâmetros iniciais sugeridos para teste
- UsarOCO(true)
- StopLossPontos(100)
- TakeProfitPontos(150)
- UsarBreakEven(true)
- BreakEvenTriggerPontos(80)
- BreakEvenOffsetPontos(5)

Checklist de validação antes de conta real
1) Backtest com e sem OCO (mesmo período).
2) Backtest com OCO + breakeven conservador.
3) Comparar: lucro líquido, drawdown, fator de lucro, sequência máxima de perdas.
4) Forward test por 2 semanas com 1 contrato.
5) Só escalar após manter disciplina de limite diário/semanal.