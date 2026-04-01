# Dados de Candles para Backtest

## Visão geral
Esta pasta contém dados históricos de candles de **1 minuto** dos ativos, com histórico disponível desde **2012**.

## Campos disponíveis
- Ativo
- Data
- Hora
- Abertura
- Máxima
- Mínima
- Fechamento
- Volume
- Quantidade

## Principais usos
- Análise de price action
- Desenvolvimento e validação de estratégias
- Backtesting de robôs e setups discricionários

## Recomendações para análises consistentes
- Verificar lacunas no histórico (dias sem pregão, feriados e horários fora de sessão)
- Padronizar timezone e horário de negociação antes de comparar ativos
- Validar qualidade dos dados (duplicidades, candles inválidos e volumes zerados)
- Separar períodos de treino, validação e teste para evitar viés

## Estrutura técnica do arquivo (exemplo real)
Com base no arquivo de exemplo **WINJ26_F_0_1min.csv**:

- Separador de colunas: `;`
- Formato de data: `dd/mm/aaaa`
- Formato de hora: `HH:MM:SS`
- Preços com 3 casas decimais (ex.: `167.090`)
- Campo `Volume` no padrão brasileiro (milhar com `.` e decimal com `,`)
- Ordenação dos registros em ordem cronológica decrescente (mais novo para mais antigo)

## Diagnóstico rápido do arquivo de exemplo
- Total de registros: **5.129**
- Período coberto: **22/08/2025 16:31:00** até **30/12/2025 18:24:00**
- Total de dias com registro: **90**
- Timestamps duplicados: **0**
- Intervalos de 1 minuto consecutivos: **2.716**
- Intervalos maiores que 1 minuto: **2.412** (indicando lacunas naturais de mercado e/ou baixa negociação em alguns períodos)

## Informações que vale incluir nos próximos arquivos
- Timezone oficial da base (ex.: BRT/Brasília)
- Fonte dos dados (plataforma, exportador e versão)
- Regras de limpeza aplicadas antes do backtest
- Definição de sessão de negociação usada no estudo
- Política para tratamento de lacunas (preenchimento, exclusão ou manutenção)

## Objetivo
Organizar e manter esta base como referência única para estudos quantitativos e testes de estratégias com foco em consistência e reprodutibilidade.