# RepoRobos — Sistema de Day Trade Quantitativo

> **Mercados:** B3 — WIN (minicontrato de índice) · Internacional via MetaTrader 5
> **Plataformas:** Neologica Profit (NTSL) · MetaTrader 5 (MQL5)
> **Capital:** R$10.000 (Profit/B3) · USD$5.000 (MT5/demo Tickmill)
> **Branch ativa:** `marco_Tradeoperador` · PR #2

---

## O que é este repositório

Biblioteca de robôs de day trade quantitativo, base de conhecimento técnico e laboratório de backtesting para o minicontrato de índice WIN na B3 e ativos internacionais no MetaTrader 5.

O projeto organiza estratégias em **grupos por filosofia operacional**, cada grupo com:
- Código-fonte Profit (`.ntsl`) — para importar diretamente no Profit
- Código-fonte MT5 (`.mq5`) — para testar no Strategy Tester do MetaTrader
- Documentação com critérios de aprovação e parâmetros de risco

---

## Plataformas

| Plataforma | Mercado | Ativo principal | Acesso |
|-----------|---------|----------------|--------|
| **Neologica Profit** | B3 | WIN (mini índice Bovespa) | [profitweb.nelogica.com.br](https://profitweb.nelogica.com.br/) |
| **MetaTrader 5** | Internacional | XAUUSD, NAS100, US30, EURUSD, US500 | [web.metatrader.app](https://web.metatrader.app/terminal?mode=demo&lang=pt) |

---

## Grupos de Estratégias

| Grupo | Pasta | NTSL | MQL5 | Status |
|-------|-------|------|------|--------|
| Primeiro Candle | `CANDLE1/` | 33 | — | ✅ Completo |
| IFR/RSI | `IFR_RSI/` | 10+ legado | — | 📦 Referência |
| Médias | `MEDIAS/` | 6 | — | ✅ Completo |
| Stop Tolerante | `STOPTOLERANTE/` | 5 | — | ✅ Completo |
| Poucos Pontos Vencedores | `POUCOSPONTOSVENCEDORES/` | 5 | — | ✅ Completo |
| Drawdown Zero | `DRAWDOWNZERO/` | 5 | — | ✅ Completo |
| 50Mais1 | `50mais1/` | 5 | — | ✅ Completo |
| Dupla Confirmação | `DUPLACONFIRMAÇÃO/` | 5 | — | ✅ Completo |
| Scalping | `SCALPING/` | 5 | — | ✅ Completo |
| Breakout | `BREAKOUT/` | 5 | — | ✅ Completo |
| VWAP Institucional | `VWAP_INSTITUCIONAL/` | 5 | — | ✅ Completo |
| Tendência Seguir | `TENDENCIA_SEGUIR/` | 5 | — | ✅ Completo |
| Reversão Média | `REVERSAO_MEDIA/` | 5 | 5 | ✅ Completo |
| Horário Específico | `HORARIO_ESPECIFICO/` | 5 | — | ✅ Completo |
| Laboratório Indicadores | `LABORATORIO_INDICADORES/` | 5 | — | ✅ Completo |
| Lateralização DayTrade | `LATERALIZACAO_DAYTRADE/` | 5 | — | ✅ Completo |
| Lateralização SwingTrade | `LATERALIZACAO_SWINGTRADE/` | 5 | — | ✅ Completo |
| timeframeMenor | `timeframeMenor/` | 5 | — | ✅ Completo |

---

## Convenção de Arquivos

| Extensão | Plataforma | Uso |
|----------|-----------|-----|
| `.ntsl` | **Neologica Profit** | Importar em Estratégias no Profit |
| `.mq5` | **MetaTrader 5** | Compilar e testar no Strategy Tester |
| `.md` | Documentação | Referência e teoria |
| `.csv` | Resultados | Saída dos backtests em Python |
| `.txt` | Anotações | Exclusivamente texto livre / rascunhos |

### Nomenclatura dos arquivos

```
Profit:       mar_GRUPO_NN_descricao_timeframe.ntsl
MetaTrader:   mar_GRUPO_NN_descricao_timeframe.mq5
Resultados:   mar_GRUPO_NN_descricao_timeframe.csv
```

> **Regras:** sem número de versão (`vX`) no nome; timeframe sempre no final antes da extensão.

---

## Gestão de Risco — Padrão Obrigatório

Todo robô deve ter **gestão de risco 100% parametrizável via `input`**, nunca hardcoded.

#### Profit (NTSL)

```ntsl
input
  UsarGestaoRisco(true);      { false = backtest puro da logica }
  UsarHardLock(true);         { false = monitora mas nao fecha }
  SaldoConta(10000.0);
  RiscoDiaPct(1.5);           { R$150/dia }
  RiscoSemanaPct(3.0);        { R$300/semana }
  MaxStopsConsecutivos(2);
  ValorPorPonto(0.2);         { 1 contrato WIN mini }
  DiaSemanaReset(2);          { 2 = segunda-feira }
```

#### MetaTrader 5 (MQL5 / Internacional)

```mql5
input bool   UsarGestaoRisco      = true;   // false = backtest puro
input bool   UsarHardLock         = true;   // false = só bloqueia entradas
input double SaldoConta           = 10000.0;
input double RiscoDiaPct          = 1.5;    // % do saldo — perda máxima diária
input double RiscoSemanaPct       = 3.0;    // % do saldo — perda máxima semanal
input int    MaxStopsConsecutivos = 2;
input double ValorPorPonto        = 0.20;   // varia por ativo (WIN=0.20, XAUUSD=1.0)
input int    DiaSemanaReset       = 1;      // 0=Dom 1=Seg 2=Ter ... (MT5: 0-based)
input double LotePadrao           = 1.0;
```

---

## Hierarquia de Decisão Operacional (WIN)

| Peso | Camada | Indicador/Ferramenta |
|------|--------|---------------------|
| **5** | Institucional | VWAP diária/semanal — filtro de permissão |
| **4** | Estrutura | Pivôs, rompimentos, tendência longo prazo |
| **3** | Gatilho | Price Action (corpo/sombra), IFR |
| **2** | Refino | OBV, VSA, sombra (veto) |
| **1** | Leitura | Padrão de candle (contexto) |

> Nunca operar contra o Peso 5 (VWAP).

---

## Estrutura do Workspace

```
automacao_backtests/
├── GRUPO_X/
│   ├── ntsl/                     → robôs Profit (.ntsl)
│   ├── mql5/                     → robôs MetaTrader (.mq5)
│   ├── resultsBackTestTimeframe/ → resultados CSV por timeframe
│   ├── reprovados/               → versões descartadas
│   └── GRUPO.md                  → documentação do grupo
├── IFR_RSI/                      → scripts IFR legados
└── MAPA_GRUPOS.md                → índice de todos os grupos
estudo_teorias/              → base de conhecimento técnico (Markdown)
profit_estudos_cores/        → indicadores visuais para o gráfico Profit
plataformas/
  ├── profit/                → guia completo Profit
  └── mql5/                  → guia MT5 + EAs de exemplo
WorkspaceRobosTrade/         → orientações do workspace
```

---

## Convenção de Branches

```
main
├── fevereiro_tradeOperador  ← ciclo fev/2026 (encerrado)
├── marco_Tradeoperador      ← ciclo mar/2026 (ATIVO)
└── abril_tradeOperador      ← próximo ciclo
```

- Cada mês uma branch dedicada com prefixo de arquivos correspondente (`fev_`, `mar_`, `abr_`...)
- Merge para `main` via Pull Request ao fim do ciclo

---

## Critérios de Aprovação (backtest)

| Métrica | Mínimo | Ideal |
|---------|--------|-------|
| Profit Factor | > 1.4 | > 2.0 |
| Taxa de acerto | > 55% | > 65% |
| Drawdown máximo | < 20% | < 10% |
| Operações no período | > 80 | > 150 |
| R:R médio | ≥ 1:1 | ≥ 1:2 |
