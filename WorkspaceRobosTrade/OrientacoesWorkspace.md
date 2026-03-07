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
├── automacao_backtests/          # Scripts Python de backtest + resultados IFR/RSI
│   └── IFR_RSI/                  # 50+ variações de estratégia IFR catalogadas e testadas
├── estudo_teorias/               # Base de conhecimento técnico (Markdown)
├── profit_estudos_cores/         # Scripts NTSL prontos para colar no Profit (indicadores/cores)
│   └── marco2026_IFR_top5/       # Top 5 robôs IFR ativos do ciclo de março/2026
└── WorkspaceRobosTrade/          # Este arquivo + orientações do workspace
```

---

## 3. Para Que Serve Cada Pasta

### `estudo_teorias/`
Base teórica de consulta antes e durante o trade. Arquivos chave:

| Arquivo | Uso |
|---|---|
| `tabela_confluencias.md` | **Hierarquia de decisão** — seguir antes de qualquer entrada |
| `mapa_de_uso_operacional.md` | Roteiro passo a passo do dia (pré-mercado → encerramento) |
| `gerenciamento_risco.md` | Regras de stop, contratos e risco por operação |
| `caracteristicas_WIN_mini_indice.md` | Verdades operacionais do WIN |
| `organizacao_B3_Internacional_horarios.md` | Calendário, horários críticos e janelas de risco |
| `teoria_IFR.md` | Referência técnica principal dos robôs |
| `teoria_panorama_contexto.md` | Contexto macro antes do gatilho |
| `teoria_tendencia.md` / `teoria_tendencia_pivots.md` | Estrutura de tendência |
| `teoria_vwap.md` | VWAP como filtro institucional |
| `teoria_VSA.md` / `teoria_volume.md` | Leitura de volume e assinatura institucional |

### `profit_estudos_cores/`
Scripts NTSL para a plataforma Profit. Cada arquivo é um indicador/coloração aplicável ao gráfico.

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

- `IFR_RSI/robos_IFR.txt` — catálogo completo das versões testadas
- `IFR_RSI/catalogo_50_opcoes_IFR.txt` — 50 variações catalogadas para priorização
- `IFR_RSI/resultadosAprovadosPorTimeframe/` — resultados filtrados por aprovação
- `IFR_RSI/top10/` — os 10 melhores robôs IFR por desempenho
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

| Prefixo | Significado | Exemplo |
|---|---|---|
| `fev_` | Script do ciclo de fevereiro/2026 | `fev_VWAPsemanalDiario.txt` |
| `mar_IFR_` | Robô IFR do ciclo de março/2026 | `mar_IFR_01_v6_60min_saida_hibrida.ntsl.txt` |
| `robo_ifr_vNN_` | Versão numerada de robô IFR em backtest | `robo_ifr_v31_reversao_volume_relativo60min72%.txt` |
| `teoria_` | Arquivo teórico de consulta | `teoria_IFR.md` |
| `caracteristicas_` | Verdades práticas de um ativo | `caracteristicas_WIN_mini_indice.md` |

---

## 8. Convenções para o Agente (GitHub Copilot)

- Linguagem dos arquivos: **português brasileiro**
- Plataforma alvo dos scripts `.txt`/`.ntsl.txt`: **Neologica Profit (NTSL)**
- Scripts de backtest: **Python**
- Quando sugerir código NTSL, respeitar a sintaxe da plataforma Profit
- Ao editar teorias, manter a estrutura de heading `#` e tabelas Markdown existentes
- Ao criar novos robôs IFR, seguir a nomenclatura `mar_IFR_NN_vX_TIMEFRAME_descricao.ntsl.txt`
- Registros de sessão/diário: usar `estudo_teorias/0326_diarioDeBordo.md`
