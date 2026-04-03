# RepoRobos — Trading Algorítmico em Minicontratos B3

> Desenvolvimento de robôs **NTSL/NTFL** para Neologica Profit focado em **padrões geométricos e confluência multi-TF** como zonas de gatilho de alta probabilidade — RRR ≥ 2.0 com aprovação estatística obrigatória.

**Autor:** Wesley Zilva — Trader · Mestre em Matemática · Desenvolvedor Python  
**Ativos:** WIN (Mini Índice) e WDO (Mini Dólar) — B3  
**Branch ativo:** `abril_teoria`

---

## 🗂️ Estrutura do Repositório

```
RepoRobos/
├── .github/
│   ├── copilot-instructions.md          ← instruções de projeto para a IA (workflow, roteamento)
│   ├── prompts/                         ← 7 prompts reutilizáveis no Copilot Chat
│   │   ├── plano_pre_robo.prompt.md
│   │   ├── gerar_robo_ntsl.prompt.md
│   │   ├── analise_confluencia.prompt.md
│   │   ├── analise_estatistica.prompt.md
│   │   ├── backtest_estatisticas.prompt.md
│   │   ├── analise_padroes_python.prompt.md
│   │   └── calibrar_gestao_risco.prompt.md
│   ├── ISSUE_TEMPLATE/
│   └── pull_request_template.md
│
├── skills/                              ← base de conhecimento (ler antes de gerar código)
│   ├── skill_ntsl_syntax.md             ← sintaxe NTSL/NTFL + funções válidas + erros críticos
│   ├── skill_confluencia_geometrica.md  ← zonas, sobreposição, snippets NTSL prontos
│   ├── skill_padroes_geometricos.md     ← Order Block, FVG, Inside Bar, Pin Bar, Flag, Duplo Fundo
│   ├── skill_contexto_longo_prazo.md    ← viés do dia + swing trade (top-down Mensal→Diário)
│   ├── skill_gestao_risco.md            ← SL mínimo (4 métodos), RRR, dimensionamento
│   ├── skill_probabilidade_operacional.md ← Kelly, Monte Carlo, IC, teste t
│   ├── skill_estatisticas_backtest.md
│   ├── skill_price_action.md
│   ├── skill_WIN_caracteristicas.md     ← ATR, horários, tripletas, custos reais
│   └── skill_WDO_caracteristicas.md
│
├── agents/                              ← agentes IA especializados
│   ├── agent_orquestrador.md
│   ├── agent_gerador_robo.md
│   ├── agent_analisador_candles.md
│   ├── agent_backtest_stats.md
│   ├── agent_WIN_especialista.md
│   └── agent_WDO_especialista.md
│
├── templates/                           ← templates prontos para copiar e ajustar
│   ├── template_robo_padrao.ntsl        ← robô base com stop horário correto
│   ├── template_robo_confluencia.ntsl   ← robô de confluência multi-TF
│   ├── template_indicador_areas.ntfl    ← indicador visual de zonas
│   └── template_semaforo_multiTF.ntsl   ← semáforo tripleta
│
├── robos/                               ← robôs e indicadores organizados por tipo
│   ├── PADROES/
│   │   ├── FORCA_SEMAFORO_CORES_SOM.ntfl        ← semáforo F=MA multi-TF ✅
│   │   ├── FORCA_SAIDA_TRAILING_60MIN.ntsl       ← trailing ATR no 60min ✅
│   │   ├── abril_padroes_orderblock_v001.ntfl    ← ★ Order Block detector
│   │   ├── abril_padroes_fvg_v001.ntfl           ← ★ Fair Value Gap
│   │   ├── abril_padroes_insidebar_v001.ntfl     ← ★ Inside Bar + breakout
│   │   ├── abril_padroes_pinbar_v001.ntfl        ← ★ Pin Bar + score de qualidade
│   │   └── abril_padroes_pivots_v001.ntfl        ← ★ Estrutura HH/HL/LH/LL + CHoCH/BOS
│   ├── CONFLUENCIA/
│   │   ├── zonas_retangulares_60m_v001.ntfl      ← zonas F=MA em tempo real (60min)
│   │   ├── abril_confluencia_v001.ntsl
│   │   └── abril_confluencia_ZonasMultiTF_v001.ntfl
│   └── IFR/ · MACD/ · MEDIA20200/ · ATR/ · ADX/ · VWAP/ · OBV/ · VOLUME/ · FORCA/
│
│   Convenção de nomes: `{mes}_{indicador}_{descricao}_v{NNN}.ntfl|ntsl`
│   ★ = indicadores visuais criados em Abril 2026
│
├── _scripts/                            ← automação e manutenção
│   ├── validate_ntsl.py                 ← valida sintaxe NTSL/NTFL (15 regras)
│   ├── contexto_diario.py               ← relatório matinal: viés do dia + estrutura
│   ├── manutencao.py                    ← auditoria completa do repositório
│   ├── sync_session.py                  ← log de sessão
│   └── git_push.sh                      ← validate → commit → push
│
├── scripts/                             ← análise de dados e backtest
│   ├── analisa_backtest_profit.py       ← métricas completas de CSV exportado do Profit
│   └── analise_triplets.py              ← simula tripletas nos dados históricos
│
├── DadosCandlesBacktest/                ← OHLCV histórico (1min desde 2012)
│   ├── 2012_14/ · 2014_16/ · ... · 2024_26/
│   └── analiseCandles.md
│
├── backtest_resultados/                 ← CSVs exportados do Profit
├── anotacoes/                           ← anotações de aulas e sessões
├── docs/                                ← documentação de referência
├── requirements.txt                     ← dependências Python
└── .vscode/settings.json                ← auto-approve, NTSL=pascal, CSV com ;
```

---

## 🎯 Objetivo Principal

Identificar **padrões geométricos e zonas de confluência** onde múltiplas referências de preço se sobrepõem, usando-as como gatilhos de entrada com:

- **RRR ≥ 2.0** obrigatório antes de qualquer entrada
- **SL** posicionado fora da estrutura do padrão (Order Block, FVG, IB, Pin Bar)
- **Confluência multi-TF** — Contexto (TF1) + Direção (TF2) + Gatilho (TF3)
- **Aprovação estatística rigorosa** — Kelly > 0%, PF IC₉₅ > 1.0, t > 1.645, WF ≥ 60%

---

## ★ Indicadores Visuais de Padrões Geométricos (Novos — Abril 2026)

Adicionar todos no mesmo gráfico para visualizar a confluência de padrões:

| Indicador | Arquivo | O que plota |
|---|---|---|
| **Order Block** | `robos/PADROES/abril_padroes_orderblock_v001.ntfl` | Zona do OB (candle institucional) |
| **Fair Value Gap** | `robos/PADROES/abril_padroes_fvg_v001.ntfl` | Gap de desequilíbrio (FVG) |
| **Inside Bar** | `robos/PADROES/abril_padroes_insidebar_v001.ntfl` | Nível de rompimento do IB |
| **Pin Bar** | `robos/PADROES/abril_padroes_pinbar_v001.ntfl` | Rejeição forte + score |
| **Pivôs HH/HL** | `robos/PADROES/abril_padroes_pivots_v001.ntfl` | Estrutura de alta/baixa |

**Como usar:** Carregar os 5 indicadores + `FORCA_SEMAFORO_CORES_SOM.ntfl` no mesmo gráfico.
Quando **3+ padrões confluem no mesmo nível de preço** → zona premium de gatilho.

---

## ⚡ Sistema F = M × A

Métrica objetiva de força direcional calculada em cada candle:

```pascal
fRange := High - Low;
fCorpo := Abs(Close - Open) / fRange * 100;   // 0–100% do range
fVol   := Volume / Media(21, Volume);          // ratio vs média móvel
fForca := fCorpo * fVol;                       // 0–100 (cap em 100)

// F ≥ 70 → força forte  |  F ≥ 40 → força moderada  |  F < 40 → fraco
```

---

## 🚦 Tripletas de Timeframes

Opera **somente** quando TF1 (Contexto) **e** TF2 (Direção) alinham → TF3 (Gatilho) executa.

| Tripleta | TF1 | TF2 | TF3 | SL típico WIN |
|---|---|---|---|---|
| **60/30/15** ⭐ | 60min | 30min | 15min | ~250 pts |
| **30/15/5** | 30min | 15min | 5min | ~150 pts |
| **15/10/5** | 15min | 10min | 5min | ~150 pts |

> Regra: `TF2 ÷ TF3` e `TF1 ÷ TF3` devem ser inteiros exatos.  
> Em NTSL: `iJanelaDir := TF2 div TF3` · `iJanelaCtx := TF1 div TF3`

---

## 🔄 Workflow de Desenvolvimento (9 etapas)

```
1. CONTEXTO      py _scripts/contexto_diario.py --ativo WINFUT
                 → viés do dia (COMPRA / VENDA / NEUTRO) antes de qualquer coisa
                 ↓
2. HIPÓTESE      Formular padrão/confluência — skill_padroes_geometricos.md
                 ↓
3. INDICADOR     Criar .ntfl a partir de template_indicador_areas.ntfl e ver no gráfico
                 ↓
4. VALIDAÇÃO     py _scripts/validate_ntsl.py --file robos/PADROES/meu_indicador.ntfl
                 ↓
5. ROBÔ          Criar .ntsl a partir de template_robo_padrao.ntsl
                 ↓
6. BACKTEST      Profit → Tick a Tick → descontar 25 pts/trade (WIN)
                 ↓
7. ESTATÍSTICAS  py scripts/analisa_backtest_profit.py backtest_resultados/arquivo.csv
                 → colar apenas o sumário (~10 linhas) no chat
                 ↓
8. APROVAÇÃO     skill_probabilidade_operacional.md:
                 ✅ E > 0  ✅ PF IC₉₅ > 1.0  ✅ t > 1.645  ✅ Kelly > 0%  ✅ WF ≥ 60%
                 ↓
9. COMMIT        bash _scripts/git_push.sh "feat(PADROES): descricao curta"
```

---

## 🛡️ Critérios de Aprovação

| Métrica | Mínimo | Ideal |
|---|---|---|
| Total de trades | ≥ 100 | ≥ 200 |
| Taxa de acerto | ≥ 40% | ≥ 50% |
| RRR médio | ≥ 2.0 | ≥ 2.5 |
| Fator de Lucro | ≥ 1.3 | ≥ 1.5 |
| IC 95% inferior do PF | > 1.0 | > 1.2 |
| Teste t | > 1.645 | > 2.0 |
| Kelly | > 0% | > 5% |
| Walk-Forward | ≥ 60% do treino | ≥ 75% |
| Período testado | ≥ 90 dias | ≥ 180 dias |

---

## 🖥️ Scripts de Manutenção

```bash
# Dependências (uma vez)
py -m pip install -r requirements.txt

# Auditoria completa do repositório
py _scripts/manutencao.py

# Contexto macro + viés do dia
py _scripts/contexto_diario.py --ativo WINFUT --ano 2026

# Validar sintaxe NTSL antes de commitar
py _scripts/validate_ntsl.py --file robos/PADROES/meu_robo.ntfl
py _scripts/validate_ntsl.py --fix   # corrige automaticamente

# Analisar CSV de backtest exportado do Profit
py scripts/analisa_backtest_profit.py backtest_resultados/resultado.csv
```

---

## ⚠️ Erros NTSL Críticos (causam falha silenciosa em produção)

| ❌ Errado | ✅ Correto |
|---|---|
| `Hour()`, `Minute()`, `Exit` | `Time() >= H*10000 + M*100` + flag `bDeveOperar` |
| `Maxima(N)`, `Minima(N)` | loop manual: `if High[1] > fMax then fMax := High[1]` |
| `Format('%.0f', [x])` | `IntToStr(Round(x))` |
| `Floor(x)` | divisão inteira + ajuste manual |
| `PlotText()`, `XRay()`, `Alert()` em `.ntsl` | apenas em `.ntfl` (indicadores) |

---

## 📊 Dados Disponíveis

**Ativos:** WINFUT · WINJ26 · WDOFUT · WDOJ26  
**Períodos:** 2012–2026 (biênios em `DadosCandlesBacktest/`)  
**Timeframes:** 1min · 5min · 10min · 15min · 20min · 30min · 60min · Diário · Semanal

```python
import pandas as pd
df = pd.read_csv('DadosCandlesBacktest/2024_26/WINFUT_F_0_5min.csv',
                 sep=';', encoding='utf-8-sig')
# Colunas: Data, Hora, Abertura, Maximo, Minimo, Fechamento, Volume
```

---

## 🔗 Referências

- [PriceAction_Fisica](https://github.com/wesleyzilva/PriceAction_Fisica) — teorias, guias e indicadores base
- Branch de desenvolvimento: `abril_teoria` | Branch estável: `main`
- Contato: wesley.zilva@gmail.com

