# Orientações do Workspace — RepoRobos

> **Branch ativa:** `marco_Tradeoperador` | **Repositório:** wesleyzilva/RepoRobos  
> **Atualizado em:** março/2026

---

## 1. Visão Geral do Workspace

Este repositório organiza toda a estrutura de estudo, desenvolvimento e automação de **robôs de day trade** para o mercado brasileiro (B3), com foco no minicontrato de índice (WIN) e na plataforma **Neologica Profit**.

---

## 2. Estrutura de Pastas

```
RepoRobos/
├── automacao_backtests/           # Robôs NTSL, MQL5 e resultados de backtest
│   ├── GRUPO_X/                   # Um grupo por lógica de estratégia
│   │   ├── ntsl/              # Robôs Neologica Profit (.ntsl)
│   │   ├── mql5/              # Robôs MetaTrader 5 (.mq5)
│   │   ├── resultsBackTestTimeframe/  # mar_GRUPO_NN_descricao_timeframe.csv
│   │   ├── reprovados/        # Versões descartadas
│   │   └── GRUPO.md           # Documentação do grupo
│   ├── IFR_RSI/                   # Scripts IFR legados + resultados
│   └── MAPA_GRUPOS.md             # Índice de todos os grupos
├── estudo_teorias/                # Base de conhecimento técnico (Markdown)
├── profit_estudos_cores/          # Indicadores/colorações prontos para o Profit
└── WorkspaceRobosTrade/           # Este arquivo + orientações do workspace
```

---

## 3. Para Que Serve Cada Pasta

### `estudo_teorias/`
Base teórica organizada por tema:

| Subpasta | Conteúdo | Arquivos chave |
|---|---|---|
| `0_diario/` | Diário de bordo e aulas | `0326_diarioDeBordo.md`, `AulaVascoMamede.md` |
| `1_operacional/` | Consulta pré-trade e regras práticas | `tabela_confluencias.md`, `mapa_de_uso_operacional.md`, `gerenciamento_risco.md`, `caracteristicas_WIN_mini_indice.md` |
| `2_teorias/` | Indicadores técnicos | `teoria_IFR.md`, `teoria_MACD.md`, `teoria_medias.md`, `teoria_priceaction.md` |
| `3_tendencia_contexto/` | Tendência, pivôs e panorama | `teoria_tendencia.md`, `teoria_tendencia_pivots.md`, `teoria_panorama_contexto.md` |
| `4_volume_institucional/` | Volume, VSA, VWAP e Wyckoff | `teoria_VSA.md`, `teoria_vwap.md`, `teoria_volume.md`, `teoria_wyckoff.md` |

### `profit_estudos_cores/`
Scripts NTSL para a plataforma Profit, organizados por ciclo mensal:

- `fev2026/` — todos os indicadores/colorações do ciclo de fevereiro/2026
- `marco2026_IFR_top5/` — top 5 robôs IFR ativos do ciclo de março/2026

Cada arquivo é um indicador/coloração aplicável ao gráfico.

**Hierarquia de uso (do mais importante para o menos):**

| Peso | Arquivo | Função |
|---|---|---|
| 🟥 5 | `fev_VWAPsemanalDiario.txt` | Filtro institucional — porteiro da operação |
| 🟥 5 | `fev_VWAPreferenciaPreco.txt` | Região de preferência institucional |
| 🟧 4 | `fev_TendenciaPivoTesteDeOuro.txt` | Confirmação de estrutura rompida |
| 🟧 4 | `fev_TendenciaLongoPrazo.txt` | Contexto de tendência maior |
| 🟨 3 | `fev_PriceActionCorpoSombraExecucao.txt` | Gatilho de entrada (Gold Signal) |
| 🟨 3 | `fev_PriceActionNewton.txt` / `fev_PriceActionNewtonIFR.txt` | Força do movimento |
| 🟦 2 | `fev_PriceActionAnaliseSombra.txt` | Veto por pavio contra |
| 🟦 2 | `fev_OBVvolumeVerdadeiro.txt` | Confirmação de fluxo real |
| 🟪 2 | `fev_DetectorFasesMercado.txt` | Identificação de lateralidade vs tendência |
| ⬜ 1 | `fev_PriceActionTiposCandlesLeitura.txt` | Leitura de padrão de candle |

**Subpasta `marco2026_IFR_top5/`:** Os 5 robôs IFR aprovados no ciclo de março/2026 para uso em produção.

### `automacao_backtests/`
Scripts de backtest e catálogos de estratégias IFR.

- `IFR_RSI/robos_IFR.txt` — índice de todas as versões testadas
- `IFR_RSI/catalogo_50_opcoes_IFR.txt` — 50 variações catalogadas para priorização
- `IFR_RSI/codigo_fonte/` — scripts NTSL `.txt` das versões de robô
- `IFR_RSI/top10/` — os 10 melhores robôs IFR por desempenho
- `IFR_RSI/resultadosAprovadosPorTimeframe/` — CSVs de resultados por timeframe
- `IFR_RSI/Reprovados/` — versões descartadas
- `NeologicaProfitAPIbacktest.txt` — referência de API Neologica para automação

---

## 4. Fluxo Operacional Diário (Resumo)

```
1. PRÉ-MERCADO
   └── Consultar: teoria_panorama_contexto, teoria_tendencia, gerenciamento_risco
   └── Definir: viés do dia + limite de risco

2. CONTEXTO NO GRÁFICO (Permissão)
   └── Aplicar: fev_VWAPsemanalDiario, fev_DetectorFasesMercado, fev_panorama920
   └── Regra: VWAP indefinida ou conflitante → NÃO OPERAR

3. CONFIRMAÇÃO DE ESTRUTURA
   └── Aplicar: fev_TendenciaPivoTesteDeOuro, fev_mediasTrend9_20_50_200
   └── Regra: pivô/rompimento coerente → avançar

4. GATILHO DE ENTRADA
   └── Aplicar: fev_PriceActionCorpoSombraExecucao, fev_PriceActionNewton
   └── Regra: contexto bom + gatilho ruim → SEM ENTRADA

5. CONFIRMAÇÃO DE FLUXO
   └── Aplicar: fev_OBVvolumeVerdadeiro, fev_VSAassinaturaInstitucional
   └── Regra: OBV divergindo → movimento falso

6. ENCERRAMENTO E REGISTRO
   └── Registrar no diarioDeBordo
   └── Atualizar tabela_confluencias se aprendeu algo novo
```

---

## 5. Regras de Gerenciamento de Risco (Referência Rápida)

- **Risco máximo por operação:** 1% a 2% do capital
- **Relação risco/retorno mínima:** 1:2
- **Capital R$10k:** 2 contratos WIN (stop 200 pts = R$40/contrato)
- **Stop loss:** sempre baseado em estrutura técnica (suporte, resistência, pivô)
- **Regra de ouro:** NUNCA operar contra Peso 5 (VWAP institucional)

---

## 6. Git — Fluxo de Trabalho

| Tarefa | Comando / Task |
|---|---|
| Verificar status | Task: `Git: Status resumido` |
| Baixar atualizações | Task: `Git: Pull marco_Tradeoperador` |
| Enviar alterações | Task: `Git: Push marco_Tradeoperador` |
| Rodar backtest Python | Task: `Backtest: Rodar script Python` |

### Convenção de Branches Mensais

A cada mês é criada uma **branch dedicada** contendo os resultados de backtest, novos robôs e teorias daquele ciclo:

```
main
├── fevereiro_tradeOperador     ← ciclo fev/2026 (robos fev_, estudos)
├── marco_Tradeoperador         ← ciclo mar/2026 (ATIVO)
├── abril_tradeOperador         ← ciclo abr/2026 (futuro)
└── ...                         ← um por mês
```

**Regras:**
- Nome da branch: `<mês>_tradeOperador` (ex: `abril_tradeOperador`)
- Prefixo dos arquivos deve coincidir com o mês (ex: `abr_` para abril)
- Ao iniciar novo ciclo: criar branch a partir de `main` após merge do mês anterior
- Cada branch acumula apenas os artefatos **produzidos naquele mês**
- Merge para `main` via **Pull Request** ao fim do ciclo

**Branch principal:** `main` (protegida — merge via PR)

---

## 7. Padrão de Nomenclatura de Arquivos

| Tipo | Formato | Exemplo |
|---|---|---|
| Robô NTSL | `mar_GRUPO_NN_descricao_timeframe.ntsl` | `mar_5M1_01_candle_forca_50pts_5min.ntsl` |
| Robô MQL5 | `mar_GRUPO_NN_descricao_timeframe.mq5` | `mar_5M1_01_candle_forca_50pts_5min.mq5` |
| Resultado CSV | `mar_GRUPO_NN_descricao_timeframe.csv` | `mar_REV_01_pullback_mme21_15min.csv` |
| Indicador/cor Profit | `mar_NomeDoEstudo.ntsl` | `mar_VWAPsemanalDiario.ntsl` |
| Arquivo teórico | `teoria_TEMA.md` | `teoria_IFR.md` |
| Características ativo | `caracteristicas_ATIVO.md` | `caracteristicas_WIN_mini_indice.md` |

> **Regras obrigatórias:**
> - Sem número de versão (`vX`) no nome do arquivo
> - Timeframe **sempre no final**, antes da extensão: `_1min`, `_5min`, `_15min`, `_30min`, `_60min`
> - `.txt` reservado exclusivamente para anotações livres

---

## 8. Convenções para o Agente (GitHub Copilot)

- Linguagem dos arquivos: **português brasileiro**
- Robôs NTSL: `mar_GRUPO_NN_descricao_timeframe.ntsl` — nunca `.txt`; sem `vX` no nome
- Robôs MQL5: `mar_GRUPO_NN_descricao_timeframe.mq5`, salvos em `GRUPO/mql5/`
- Arquivos `.txt`: reservados exclusivamente para anotações e documentação livre
- Scripts de backtest: **Python**
- Resultados CSV: `mar_GRUPO_NN_descricao_timeframe.csv` — sem `vX`, timeframe no final
- Quando sugerir código NTSL, respeitar a sintaxe da plataforma Profit
- Ao editar teorias, manter a estrutura de heading `#` e tabelas Markdown existentes
- Registros de sessão/diário: usar `estudo_teorias/0326_diarioDeBordo.md`
