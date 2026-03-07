# GitHub Copilot — Instruções para RepoRobos

## Contexto do Projeto

Este workspace é um sistema de **day trade quantitativo** focado no mercado brasileiro (B3), especificamente no minicontrato de índice **WIN**. O trabalho envolve:

- Desenvolvimento de **robôs/estratégias** na plataforma **Neologica Profit** (linguagem NTSL)
- **Backtesting** em Python de estratégias baseadas em IFR/RSI
- **Base de conhecimento técnico** em Markdown para consulta operacional
- **Indicadores visuais** (colorações/estudos) para o gráfico no Profit

---

## Linguagem e Tom

- Sempre responder em **português brasileiro**
- Usar terminologia de **análise técnica** e mercado financeiro brasileiro
- Ser direto e objetivo, com exemplos práticos quando possível

---

## Estrutura do Workspace

```
automacao_backtests/
├── IFR_RSI/                 → Scripts IFR legados + resultados
├── GRUPO_X/                 → Cada grupo tem a mesma estrutura interna:
│   ├── ntsl/                → Scripts Neologica Profit (.ntsl)
│   ├── mql5/                → Scripts MetaTrader 5 (.mq5)
│   ├── resultsBackTestTimeframe/ → CSVs: mar_GRUPO_NN_descricao_timeframe.csv
│   ├── reprovados/          → Versões descartadas
│   └── GRUPO.md             → Documentação / notas do grupo
└── MAPA_GRUPOS.md           → Índice de todos os grupos

estudo_teorias/
├── 0_diario/                → Diário de bordo e aulas
├── 1_operacional/           → Consulta pré-trade (risco, WIN, horários)
├── 2_teorias/               → Indicadores técnicos (IFR, MACD, médias...)
├── 3_tendencia_contexto/    → Tendência, pivôs e panorama
└── 4_volume_institucional/  → VSA, VWAP, volume, Wyckoff

profit_estudos_cores/        → Indicadores/colorações prontos para o Profit
WorkspaceRobosTrade/         → Orientações e documentação do workspace
```

---

## Regras para Geração de Código

### Convenção de Nomenclatura de Arquivos

| Plataforma           | Formato                                 | Exemplo                                   |
| -------------------- | --------------------------------------- | ----------------------------------------- |
| Profit (NTSL)        | `mar_GRUPO_NN_descricao_timeframe.ntsl` | `mar_5M1_01_candle_forca_50pts_5min.ntsl` |
| MetaTrader (MQL5)    | `mar_GRUPO_NN_descricao_timeframe.mq5`  | `mar_5M1_01_candle_forca_50pts_5min.mq5`  |
| Resultado backtest   | `mar_GRUPO_NN_descricao_timeframe.csv`  | `mar_REV_01_pullback_mme21_15min.csv`     |
| Indicador/cor Profit | `mar_NomeDoEstudo.ntsl`                 | `mar_VWAPsemanalDiario.ntsl`              |

> **Regras:** sem número de versão (`vX`) no nome; timeframe **sempre no final**, antes da extensão; `.txt` é reservado exclusivamente para anotações livres.

### Scripts NTSL (Neologica Profit)

- Extensão: **`.ntsl`** (nunca `.txt` nem `.ntsl.txt`)
- Nomenclatura: `mar_GRUPO_NN_descricao_timeframe.ntsl`
- Sempre incluir comentário de cabeçalho com: timeframe, descrição, taxa de acerto se disponível
- **OBRIGATÓRIO:** todos os parâmetros de risco declarados como `input` (ver bloco padrão na seção Gerenciamento de Risco)

#### Sintaxe NTSL — Estrutura obrigatória

```ntsl
{
  Estrategia: nome_do_robo
  Descricao:  o que faz, timeframe, taxa de acerto
}

input
  Parametro1(valorPadrao);    { descricao do parametro }
  Parametro2(100.0);
  FlagBooleana(true);

var
  fVariavelFloat   : float;
  bVariavelBool    : boolean;
  iVariavelInteira : integer;

begin
  { logica aqui }
end;
```

#### Tipos de dados
| Tipo | Uso |
|------|-----|
| `float` | Preços, percentuais, valores financeiros |
| `integer` | Contadores, períodos, índices |
| `boolean` | Flags true/false |

#### Séries nativas (barra atual = `[0]`, barra anterior = `[1]`)
| Série | Significado |
|-------|-------------|
| `Open` / `Open[1]` | Abertura da barra atual / anterior |
| `High`, `Low`, `Close` | Máxima, mínima, fechamento |
| `Volume` | Volume da barra |
| `Date` | Data da barra (`Date <> Date[1]` = nova sessão) |

#### Funções nativas mais usadas
```ntsl
IFR(periodo)                    { Índice de Força Relativa }
Media(periodo, serie)           { Média aritmética simples }
MME(periodo)                    { Média Móvel Exponencial }
MMS(periodo)                    { Média Móvel Simples }
Max(a, b)                       { Maior entre dois valores }
Min(a, b)                       { Menor entre dois valores }
Abs(valor)                      { Valor absoluto }
Round(valor)                    { Arredondamento }
DayOfWeek(Date)                 { Dia da semana: 1=Dom 2=Seg ... 7=Sab }
```

#### Funções de posição
```ntsl
IsBought                        { true se posicionado comprado }
IsSold                          { true se posicionado vendido }
BuyAtMarket                     { compra a mercado }
SellShortAtMarket               { venda a mercado }
ClosePosition                   { fecha posição aberta }
BuyLimit(preco, qtd)            { ordem de compra limitada }
SellLimit(preco, qtd)           { ordem de venda limitada }
BuyStop(preco, qtd)             { ordem de compra stop }
SellStop(preco, qtd)            { ordem de venda stop }
```

#### Operadores
```ntsl
and  or  not               { booleanos }
=  <>  <  >  <=  >=        { comparação }
+  -  *  /                 { aritméticos }
```

#### Comentários
```ntsl
{ isto e um comentario de bloco }
```
> NTSL usa `{ }` para comentários — **não** usa `//` nem `/* */`

### Scripts MQL5 (MetaTrader 5)

- Extensão: **`.mq5`**
- Nomenclatura: `mar_GRUPO_NN_descricao_timeframe.mq5`
- Estrutura obrigatória: `#include <Trade\Trade.mqh>` + inputs espelhando o NTSL + `OnInit`, `OnDeinit`, `OnTick`
- Inputs de risco espelham o NTSL: `UsarGestaoRisco`, `UsarHardLock`, `SaldoConta`, `RiscoDiaPct`, `RiscoSemanaPct`, `MaxStopsConsecutivos`, `ValorPorPonto`
- Salvar em `GRUPO/mql5/` ao lado da pasta `ntsl/`

### Scripts Python (Backtest)

- Usar Python 3.10 (`C:/Program Files/Python310/python.exe`)
- Seguir estrutura de backtest existente na pasta `automacao_backtests/IFR_RSI/`
- Nomear resultados: `mar_GRUPO_NN_descricao_timeframe.csv` — timeframe sempre no final
  - Exemplo: `mar_REV_01_pullback_mme21_15min.csv`, `mar_5M1_01_candle_forca_50pts_5min.csv`

### Arquivos de Teoria (Markdown)

- Manter estrutura de headings `#` existente
- Usar tabelas Markdown para hierarquias e comparações
- Referências a scripts Profit no formato: `` `fev_NomeDoScript.ntsl` ``

---

## Hierarquia de Decisão Operacional

Ao sugerir melhorias em estratégias, respeitar esta prioridade:

1. **Peso 5 — Institucional:** VWAP diária/semanal (filtro de permissão — nunca operar contra)
2. **Peso 4 — Estrutura:** Pivôs, rompimentos, tendência de longo prazo
3. **Peso 3 — Gatilho:** Price Action (corpo, sombra, Gold Signal), IFR
4. **Peso 2 — Refino:** OBV, VSA, análise de sombra (veto)
5. **Peso 1 — Leitura:** Padrão de candle (contexto)

---

## Gerenciamento de Risco (Referência)

- Risco por operação: **máximo 1-2% do capital**
- Relação risco/retorno mínima: **1:2**
- WIN: stop baseado em **estrutura técnica** (suporte/resistência/pivô)
- Nunca sugerir estratégias sem stop definido

### Regra Obrigatória — Gestão Sempre Parametrizável

**TODOS os parâmetros de risco devem ser declarados como `input`**, nunca hardcoded no corpo do código.

#### Bloco padrão — NTSL (Neologica Profit):

```ntsl
input
  UsarGestaoRisco(true);      { false = backtest puro da logica }
  UsarHardLock(true);         { false = monitora mas nao fecha posicao }
  SaldoConta(10000.0);
  RiscoDiaPct(1.5);           { % do saldo - limite de perda diaria }
  RiscoSemanaPct(3.0);        { % do saldo - limite de perda semanal }
  MaxStopsConsecutivos(2);    { stops em sequencia antes de bloquear }
  ValorPorPonto(0.2);         { 1 contrato WIN mini = R$0,20/ponto }
  DiaSemanaReset(2);          { 2 = segunda-feira (DayOfWeek retorna 1=Dom..7=Sab) }
```

> **Sintaxe NTSL:** inputs usam `NomeParam(valorPadrao);` — **sem** `=`, **sem** tipo explícito. Comentários com `{ }`, não `//`.

#### Bloco padrão — MQL5 (MetaTrader 5 / Internacional):

```mql5
// Gestão de Risco
input bool   UsarGestaoRisco      = true;   // false = backtest puro
input bool   UsarHardLock         = true;   // false = só bloqueia entradas
input double SaldoConta           = 10000.0;
input double RiscoDiaPct          = 1.5;    // % do saldo — perda máxima diária
input double RiscoSemanaPct       = 3.0;    // % do saldo — perda máxima semanal
input int    MaxStopsConsecutivos = 2;      // stops consecutivos antes de bloquear
input double ValorPorPonto        = 0.20;   // varia por ativo (WIN=0.20, XAUUSD=1.0 etc.)
input int    DiaSemanaReset       = 1;      // 0=Dom 1=Seg 2=Ter ... (MT5 usa 0-based)
input double LotePadrao           = 1.0;
```

> **MT5 vs NTSL:** `DiaSemanaReset` usa base 0 no MQL5 (segunda = 1) versus base 1 no NTSL (segunda = 2). `ValorPorPonto` deve ser ajustado por ativo.

Regras de uso:

- `UsarGestaoRisco = false` → desativa todos os limites (backtest de lógica pura)
- `UsarHardLock = false` → monitora limites mas não força fechamento (só bloqueia novas entradas)
- `UsarHardLock = true` → fecha posição imediatamente ao atingir o limite (uso operacional)
- O bloco de verificação dos limites deve ser executado **antes de qualquer sinal de entrada**

---

## Padrões de Qualidade para Robôs IFR

Ao criar ou otimizar robôs IFR, priorizar:

- Timeframes com melhor desempenho histórico: **60min e 30min**
- Taxa de acerto mínima aceitável: **>60%**
- Filtros obrigatórios: contexto de tendência (MME200 ou MME9/21) + controle de risco diário
- Estrutura base: entrada IFR extremo → filtro de contexto → saída híbrida (alvo técnico + trailing)

---

## Git

### Convenção de Branches Mensais

A cada mês é criada uma **branch dedicada** com os resultados, novos robôs e teorias do ciclo:

```
main
├── fevereiro_tradeOperador     ← ciclo fev/2026
├── marco_Tradeoperador         ← ciclo mar/2026 (ATIVO)
├── abril_tradeOperador         ← ciclo abr/2026 (futuro)
└── ...                         ← um por mês
```

- Nome da branch: `<mês>_tradeOperador`
- Prefixo dos arquivos NTSL/Python deve coincidir com o mês (`fev_`, `mar_`, `abr_`...)
- Ao iniciar novo ciclo: criar branch a partir de `main` após merge do mês anterior
- Merge para `main` via Pull Request ao fim do ciclo
- Não commitar resultados brutos de backtest sem aprovação explícita
- Branch ativa no momento: `marco_Tradeoperador` | PR ativo: #2
