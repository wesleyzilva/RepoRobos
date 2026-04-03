# RepoRobos — Trading Algorítmico em Minicontratos B3

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
