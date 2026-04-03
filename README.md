# RepoRobos — Trading Algorítmico em Minicontratos B3

> Repositório de desenvolvimento de robôs NTSL/NTFL para Neologica Profit, focado em **identificar padrões geométricos e áreas de confluência** como zonas de gatilho de alta probabilidade, com RRR ≥ 2.0 e aprovação estatística rigorosa.

**Autor:** Wesley Zilva — Trader + Mestre em Matemática + Desenvolvedor Python  
**Ativos:** WIN (Mini Índice) e WDO (Mini Dólar) — B3  
**Branch ativo:** `abril_teoria`

---

## 🗂️ Estrutura do Workspace

```
RepoRobos/
├── .github/
│   ├── copilot-instructions.md       ← instruções do projeto para IA (roteamento, workflow)
│   ├── prompts/                      ← 7 prompts reutilizáveis no Copilot Chat
│   │   ├── plano_pre_robo.prompt.md         ← plano obrigatório antes de gerar código
│   │   ├── gerar_robo_ntsl.prompt.md
│   │   ├── analise_confluencia.prompt.md
│   │   ├── analise_estatistica.prompt.md
│   │   ├── backtest_estatisticas.prompt.md
│   │   ├── analise_padroes_python.prompt.md
│   │   └── calibrar_gestao_risco.prompt.md
│   └── ISSUE_TEMPLATE/
│
├── skills/                           ← base de conhecimento (custo zero — ler antes de gerar)
│   ├── skill_ntsl_syntax.md          ← sintaxe NTSL/NTFL completa + funções válidas + erros críticos
│   ├── skill_confluencia_geometrica.md  ← zonas, sobreposição, snippets NTSL prontos
│   ├── skill_padroes_geometricos.md  ← Order Block, FVG, Inside Bar, Pin Bar, Flag, Duplo Fundo
│   ├── skill_contexto_longo_prazo.md ← viés do dia + swing trade (top-down Mensal→Semanal→Diário)
│   ├── skill_gestao_risco.md         ← SL mínimo (4 métodos), RRR, dimensionamento
│   ├── skill_probabilidade_operacional.md  ← Kelly, Monte Carlo, IC, teste t
│   ├── skill_estatisticas_backtest.md
│   ├── skill_price_action.md
│   ├── skill_WIN_caracteristicas.md  ← ATR, horários, tripletas, custos reais
│   └── skill_WDO_caracteristicas.md
│
├── agents/                           ← agentes IA especializados
│   ├── agent_orquestrador.md         ← roteamento de tarefas
│   ├── agent_gerador_robo.md
│   ├── agent_analisador_candles.md
│   ├── agent_backtest_stats.md
│   ├── agent_WIN_especialista.md
│   └── agent_WDO_especialista.md
│
├── templates/                        ← templates NTSL prontos para copiar e ajustar
│   ├── template_robo_padrao.ntsl         ← robô base com stop horário correto
│   ├── template_robo_confluencia.ntsl    ← robô de confluência multi-TF
│   ├── template_indicador_areas.ntfl    ← indicador visual de zonas
│   └── template_semaforo_multiTF.ntsl   ← semáforo tripleta (v2.0)
│
├── robos/                            ← robôs e indicadores (organizados por indicador)
│   ├── PADROES/                      ← padrões de candle e F=MA
│   │   ├── FORCA_SEMAFORO_CORES_SOM.ntfl       ← semáforo F=MA multi-TF (v9.0) ✅ testado
│   │   ├── FORCA_SAIDA_TRAILING_60MIN.ntsl      ← trailing ATR no 60min ✅
│   │   ├── abril_padroes_orderblock_v001.ntfl   ← ★ Order Block detector
│   │   ├── abril_padroes_fvg_v001.ntfl          ← ★ Fair Value Gap
│   │   ├── abril_padroes_insidebar_v001.ntfl    ← ★ Inside Bar + breakout
│   │   ├── abril_padroes_pinbar_v001.ntfl       ← ★ Pin Bar / Rejeição
│   │   └── abril_padroes_pivots_v001.ntfl       ← ★ Estrutura HH/HL/LH/LL
│   ├── CONFLUENCIA/
│   │   ├── zonas_retangulares_60m_v001.ntfl     ← zonas F=MA em tempo real (60min)
│   │   └── abril_confluencia_ZonasMultiTF_v001.ntfl
│   ├── IFR/ | MACD/ | MEDIA20200/ | ATR/ | ADX/ | VWAP/ | OBV/ | VOLUME/ | FORCA/
│
│   Convenção: `{mes}_{indicador}_{descricao}_v{NNN}.ntfl|ntsl`
│   ★ = novos indicadores visuais de padrões geométricos (abril/2026)
│
├── _scripts/                         ← scripts Python de manutenção
│   ├── validate_ntsl.py              ← valida sintaxe NTSL/NTFL (15 regras)
│   ├── contexto_diario.py            ← relatório matinal: viés do dia + swing
│   ├── manutencao.py                 ← auditoria completa do repositório
│   ├── sync_session.py               ← log de sessão e push
│   └── git_push.sh                   ← fluxo completo: validate → commit → push
│
├── scripts/                          ← scripts Python de análise de dados
│   ├── analisa_backtest_profit.py    ← métricas completas de CSV de backtest
│   └── analise_triplets.py           ← simula tripletas nos dados históricos
│
├── DadosCandlesBacktest/             ← dados históricos OHLCV (1min desde 2012)
│   ├── 2012_14/ 2014_16/ ... 2024_26/
│   └── analiseCandles.md
│
├── backtest_resultados/              ← CSVs exportados do Profit para análise
├── docs/                             ← documentação de referência
├── requirements.txt                  ← dependências Python do projeto
└── .vscode/settings.json             ← auto-approve, NTSL=pascal, CSV com ;
```

---

## 🎯 Objetivo Principal

Desenvolver robôs que:
1. **Identificam padrões geométricos** (Order Block, FVG, Inside Bar, Pin Bar, Pivôs) como zonas de gatilho
2. **Usam o menor SL possível** — posicionado fora da estrutura do padrão
3. **Exigem confluência multi-TF** — Contexto (TF1) + Direção (TF2) + Gatilho (TF3)
4. **Aprovação estatística obrigatória** — Kelly > 0%, PF IC > 1.0, teste t > 1.645

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

```pascal
fMassa      := (Close - Open) / (High - Low);     // -1.0 a +1.0
fAceleracao := Volume / Media(20, Volume);         // ratio vs média
fForca      := fMassa * fAceleracao * 100;         // -100 a +100
// F ≥ +60 → compra forte | F ≤ -60 → venda forte
```

---

## 🚦 Tripletas de Timeframes

Opera SOMENTE quando TF1 (Contexto) **e** TF2 (Direção) alinham → TF3 executa.

| Tripleta ⭐ | TF3 | iJanelaDir | iJanelaCtx | SL WIN |
|---|---|---|---|---|
| **60/30/15** | 15min | 2 | 4 | 250 pts |
| **30/15/5** | 5min | 3 | 6 | 150 pts |
| **15/10/5** | 5min | 2 | 3 | 150 pts |

> Regra: `TF2 ÷ TF3` e `TF1 ÷ TF3` devem ser inteiros exatos.

---

## 🔄 Workflow de Desenvolvimento (9 etapas)

```
1. CONTEXTO    → python _scripts/contexto_diario.py  (viés do dia antes de qualquer trade)
               ↓
2. HIPÓTESE    → formular padrão/confluência — usar skill_padroes_geometricos.md
               ↓
3. INDICADOR   → criar .ntfl para ver os padrões no gráfico (templates/)
               ↓
4. VALIDAÇÃO   → python _scripts/validate_ntsl.py --file <arquivo>
               ↓
5. ROBÔ        → criar .ntsl a partir do template_robo_padrao.ntsl
               ↓
6. BACKTEST    → Profit → Tick a Tick → descontar 25 pts/trade
               ↓
7. ESTATÍSTICAS→ python scripts/analisa_backtest_profit.py backtest_resultados/
                 Colar SOMENTE o sumário (~10 linhas) no chat
               ↓
8. SIGNIFICÂNCIA→ skill_probabilidade_operacional.md:
                  ✅ E > 0  ✅ PF IC > 1.0  ✅ t > 1.645  ✅ Kelly > 0%  ✅ WF ≥ 60%
               ↓
9. COMMIT      → bash _scripts/git_push.sh "feat(PADROES): descricao"
```

---

## 🛡️ Critérios de Aprovação

| Métrica | Mínimo | Ideal |
|---|---|---|
| Total de trades | ≥ 100 | ≥ 200 |
| Taxa de acerto | ≥ 40% | ≥ 50% |
| RRR médio | ≥ 2.0 | ≥ 2.5 |
| Fator de lucro | ≥ 1.3 | ≥ 1.5 |
| IC 95% inferior PF | > 1.0 | > 1.2 |
| Teste t | > 1.645 | > 2.0 |
| Kelly | > 0% | > 5% |
| Walk-Forward | ≥ 60% do treino | ≥ 75% |
| Período testado | ≥ 90 dias | ≥ 180 dias |

---

## 🖥️ Scripts de Manutenção

```bash
# Auditoria completa (rodar a cada sessão)
py _scripts/manutencao.py

# Contexto macro + viés do dia
py _scripts/contexto_diario.py

# Validar NTSL antes de commitar
py _scripts/validate_ntsl.py
py _scripts/validate_ntsl.py --fix   # corrige erros automáticos

# Instalar dependências Python
py -m pip install -r requirements.txt
```

---

## ⚠️ Erros NTSL Críticos (não compile sem checar)

| ❌ ERRADO | ✅ CORRETO |
|---|---|
| `Hour`, `Minute`, `Exit` | `Time() >= H*10000 + M*100` + `bDeveOperar` |
| `div`, `mod` | Comparação direta com `Time()` |
| `Maxima(N)`, `Minima(N)` | Loop manual: `if High[1] > fMax then fMax := High[1]` |
| `Format('%.0f', [x])` | `IntToStr(Round(x))` |
| `Floor(x)` | Divisão + `if x < 1 then x := 1` |
| `PlotText()` em `.ntsl` | Só em `.ntfl` (indicadores) |

---

## 📊 Dados Disponíveis

**Ativos:** WINFUT, WINJ26, WDOFUT, WDOJ26  
**Períodos:** 2012–2026 (biênios em `DadosCandlesBacktest/`)  
**Timeframes:** 1min, 5min, 10min, 15min, 20min, 30min, 60min, Diário, Semanal

```python
import pandas as pd
df = pd.read_csv('DadosCandlesBacktest/2024_26/WINFUT_F_0_5min.csv',
                 sep=';', encoding='utf-8-sig')
```

---

## 🔗 Referências

- [PriceAction_Fisica](https://github.com/wesleyzilva/PriceAction_Fisica) — teorias, guias e indicadores base
- Branch de desenvolvimento: `abril_teoria` | Branch estável: `main`


> Repositório de desenvolvimento de robôs NTSL/NTFL para Neologica Profit, focado em identificar **áreas de confluência geométrica** como zonas de gatilho de alta probabilidade, com RRR ≥ 2.0.

**Autor:** Wesley Zilva (wesley.zilva@gmail.com) — Trader + Mestre em Matemática + Desenvolvedor Python  
**Objetivo:** Sincronizar janelas de oportunidade através de tripletas matemáticas. O foco é a **Eficiência de Janela**: Operar apenas quando as 10 janelas de 60m (Contexto) e as 19 de 30m (Direção) autorizarem os gatilhos no TF menor.

---

---

## 🗂️ Estrutura do Workspace

```
RepoRobos/
├── .github/
│   ├── copilot-instructions.md       ← instruções completas do projeto para IA
│   ├── prompts/                      ← prompts reutilizáveis no Copilot Chat
│   │   ├── gerar_robo_ntsl.prompt.md
│   │   ├── analise_confluencia.prompt.md
│   │   ├── backtest_estatisticas.prompt.md
│   │   ├── analise_padroes_python.prompt.md
│   │   └── calibrar_gestao_risco.prompt.md
│   ├── ISSUE_TEMPLATE/               ← templates de issues do GitHub
│   │   ├── novo_robo.md
│   │   ├── resultado_backtest.md
│   │   └── bug_report.md
│   └── pull_request_template.md      ← checklist de PR para robôs
│
├── skills/                           ← base de conhecimento especializado
│   ├── skill_ntsl_syntax.md          ← sintaxe NTSL/NTFL completa
│   ├── skill_confluencia_geometrica.md  ← como construir e validar zonas
│   ├── skill_gestao_risco.md         ← SL, SG, RRR, dimensionamento
│   ├── skill_estatisticas_backtest.md   ← métricas, código Python, critérios
│   └── skill_price_action.md         ← padrões de candle e contexto
│
├── agents/                           ← definições de agentes IA especializados
│   ├── agent_gerador_robo.md         ← gera código NTSL completo
│   ├── agent_analisador_candles.md   ← analisa CSVs históricos em Python
│   └── agent_backtest_stats.md       ← avalia resultados e aprova/reprova
│
├── templates/                        ← templates NTSL prontos para usar
│   ├── template_robo_confluencia.ntsl    ← robô de confluência completo
│   ├── template_indicador_areas.ntfl    ← indicador visual de zonas
│   └── template_semaforo_multiTF.ntsl   ← semáforo tripleta (v2.0)
│
├── robos/                            ← robôs e indicadores aprovados em backtest
│   ├── IFR/                          ← estratégias com IFR (RSI)
│   ├── MACD/                         ← estratégias com MACD
│   ├── MEDIA20200/                   ← estratégias com Médias 20/200
│   ├── ATR/                          ← estratégias com ATR
│   ├── ADX/                          ← estratégias com ADX
│   ├── VWAP/                         ← estratégias com VWAP
│   ├── OBV/                          ← estratégias com OBV
│   ├── VOLUME/                       ← estratégias com Volume/VSA
│   ├── FORCA/                        ← estratégias F = M × A
│   ├── PADROES/                      ← padrões de candle (engolfo, doji, OCO...)
│   └── CONFLUENCIA/                  ← zonas de confluência múltipla
│
│   Convenção de nomes: {mes}_{indicador}_{descricaoCurta}_v{NNN}.ntfl
│   Exemplo: abril_ifr_divergencia_v001.ntfl  →  robos/IFR/
│            abr_atr_semaforoPorVolume_v001.ntsl  →  robos/ATR/
├── scripts/                          ← scripts Python de análise e backtest
├── DadosCandlesBacktest/             ← dados históricos OHLCV em CSV
│   ├── 2012_14/ ... 2024_26/         ← por biênio
│   └── analiseCandles.md
│
├── docs/                             ← referências e documentação legacy
│   ├── tabela_verdade_timeframes.md  ← tabela de tripletas TF1/TF2/TF3
│   ├── cores_candles_degrade.md      ← sistema de gradiente RGB
│   ├── exemplos_codigo_pascal.md     ← exemplos NTSL de referência
│   ├── regras_semaforo_operacao.md
│   ├── opcao1_definicao_areas_operacao_corpoCandle.md
│   ├── opcao2_definicao_areas_operacao_maxima_minima.md
│   └── README_MCP.md                 ← guia do servidor MCP filesystem
│
└── .vscode/
    ├── mcp.json                      ← servidor MCP filesystem para IA
    ├── settings.json                 ← configurações (.ntsl = pascal, CSV com ;)
    └── extensions.json               ← extensões recomendadas
```

---

## 🎯 Objetivo Principal

Identificar **áreas de confluência geométrica** — zonas onde múltiplas referências de preço se sobrepõem — e usá-las como gatilhos de entrada com:

- **RRR ≥ 2.0** obrigatório antes de qualquer entrada
- **SL** posicionado abaixo/acima da estrutura geométrica mais próxima
- **Confirmação por F = M × A** (força direcional objetiva)
- **Custos reais** descontados: 25 pts/trade (spread + slippage)

---

## ⚡ Como Usar os Templates

### 1. Criar um novo robô a partir do template
```bash
cp templates/template_robo_confluencia.ntsl robos/ROB_MEU_SETUP_V1.ntsl
```
Editar o cabeçalho com o nome, ativo, timeframe e parâmetros do setup.

### 2. Criar um indicador de validação visual
```bash
cp templates/template_indicador_areas.ntfl robos/IND_VALIDACAO_V1.ntfl
```
Usar no Profit para validar visualmente o padrão antes de ativar o robô.

### 3. Análise de dados com Python
Usar os prompts em `.github/prompts/` com Copilot Chat ou chamar o agente `agent_analisador_candles`.

---

## 📊 Dados Disponíveis

**Ativos:** WINJ26, WDOJ26, WINFUT, WDOFUT  
**Períodos:** 2012–2026 (biênios)  
**Timeframes:** 1min, 5min, 10min, 15min, 20min, 30min, 60min, Diário, Semanal

```python
# Leitura padrão Python
import pandas as pd
df = pd.read_csv('DadosCandlesBacktest/2024_26/WINJ26_F_0_5min.csv',
                 sep=';', encoding='latin1')
```

---

## 🔄 Workflow de Desenvolvimento

```
1. HIPÓTESE     Formular padrão/confluência a testar
                ↓
2. ANÁLISE      Usar agent_analisador_candles para validar nos dados CSV
                ↓
3. INDICADOR    Criar .ntfl a partir do template_indicador_areas para ver visualmente
                ↓
4. ROBÔ         Criar .ntsl a partir do template_robo_confluencia
                ↓
5. BACKTEST     Profit → Tick a Tick → descontar 25 pts/trade
                ↓
6. ESTATÍSTICAS Usar agent_backtest_stats para calcular métricas
                ↓
7. DECISÃO      Aprovado → mover para robos/ | Reprovado → ajustar ou descartar
                ↓
8. COMMIT       Criar PR com checklist preenchido
```

---

## 🚦 Critérios de Aprovação de Robô

| Métrica | Mínimo |
|---|---|
| Total de trades | ≥ 100 |
| Taxa de acerto | ≥ 40% |
| RRR médio | ≥ 2.0 |
| Fator de lucro | ≥ 1.3 |
| Drawdown máximo | ≤ 500 pts |
| Período testado | ≥ 90 dias |

---

## 🔗 Referências

- [PriceAction_Fisica](https://github.com/wesleyzilva/PriceAction_Fisica) — teorias, guias e indicadores base
- Branch de desenvolvimento: `abril_teoria`
- Contato: wesley.zilva@gmail.com
