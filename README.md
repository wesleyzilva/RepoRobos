# RepoRobos — Sistema de Day Trade Quantitativo

> **Mercados:** B3 — WIN (minicontrato de índice) · Internacional via MetaTrader 5
> **Plataformas:** Neologica Profit (NTSL) · MetaTrader 5 (MQL5)
> **Capital:** R$10.000 (Profit/B3) · USD$5.000 (MT5/demo Tickmill)
> **Branch ativa:** `marco_Tradeoperador` · PR #2

---

## O que é este repositório

Biblioteca de robôs de day trade quantitativo, base de conhecimento técnico e laboratório de backtesting para o minicontrato de índice WIN na B3 e ativos internacionais no MetaTrader 5.

O projeto organiza estratégias em **grupos por filosofia operacional**, cada grupo com:
- Código-fonte Profit (`.ntsl.txt`) — para importar diretamente no Profit
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

### Em desenvolvimento ativo

| Grupo | Pasta | Robôs NTSL | Robôs MQL5 | Status |
|-------|-------|-----------|-----------|--------|
| Primeiro Candle | `automacao_backtests/CANDLE1/` | 33 | — | ✅ Completo |
| IFR/RSI | `automacao_backtests/IFR_RSI/` | 3 novos + 10 legado | — | 🔄 Em progresso |
| Médias | `automacao_backtests/MEDIAS/` | — | — | ⬜ Pendente |
| Stop Tolerante | `automacao_backtests/STOPTOLERANTE/` | 4 | — | ✅ Completo |
| Poucos Pontos Vencedores | `automacao_backtests/POUCOSPONTOSVENCEDORES/` | 4 | — | 🔄 Faltam 05–08 |
| Drawdown Zero | `automacao_backtests/DRAWDOWNZERO/` | — | — | ⬜ Pendente |
| 50Mais1 | `automacao_backtests/50mais1/` | — | — | ⬜ Pendente |
| Dupla Confirmação | `automacao_backtests/DUPLACONFIRMAÇÃO/` | — | — | ⬜ Pendente |

### Estrutura completa — pastas criadas, robôs pendentes

| Grupo | Conceito central |
|-------|-----------------|
| `SCALPING/` | Capturar 10–30 pts, alta frequência, 1–2min |
| `BREAKOUT/` | Rompimento de range/nível com volume confirmado |
| `VWAP_INSTITUCIONAL/` | Operações referenciadas no fluxo institucional |
| `TENDENCIA_SEGUIR/` | Trend following puro — trailing ATR, sem alvo fixo |
| `REVERSAO_MEDIA/` | Bollinger/VWAP extremo → retorno à média |
| `HORARIO_ESPECIFICO/` | Janelas estatísticas do WIN + sessões MT5 |
| `LABORATORIO_INDICADORES/` | Teste isolado: ADX, Estocástico, Bollinger, OBV e combos |

---

## Convenção de Arquivos

| Extensão | Plataforma | Uso |
|----------|-----------|-----|
| `.ntsl.txt` | **Neologica Profit** | Importar em Estratégias no Profit |
| `.mq5` | **MetaTrader 5** | Compilar e testar no Strategy Tester |
| `.md` | Documentação | Referência e teoria |
| `.csv` | Resultados | Saída dos backtests em Python |

### Nomenclatura dos arquivos

```
Profit:       mar_GRUPO_NN_vX_descricao.ntsl.txt
MetaTrader:   mar_GRUPO_NN_descricao.mq5
```

---

## Gestão de Risco — Padrão Obrigatório (Profit)

Todo robô NTSL deve ter **gestão de risco 100% parametrizável via `input`**:

```pascal
input UsarGestaoRisco      = true;   // false = backtest puro da lógica
input UsarHardLock         = true;   // false = monitora mas não fecha
input SaldoConta           = 10000.0;
input RiscoDiaPct          = 1.5;    // R$150/dia
input RiscoSemanaPct       = 3.0;    // R$300/semana
input MaxStopsConsecutivos = 2;
input ValorPorPonto        = 0.2;    // 1 contrato WIN mini
input DiaSemanaReset       = 2;      // segunda-feira
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
automacao_backtests/         → grupos de robôs e laboratório
estudo_teorias/              → base de conhecimento técnico (Markdown)
profit_estudos_cores/        → indicadores visuais para o gráfico Profit
  ├── fev2026/               → estudos/cores do ciclo fev/2026
  └── marco2026_IFR_top5/    → top 5 robôs IFR ativos mar/2026
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
