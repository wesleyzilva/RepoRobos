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
automacao_backtests/   → Scripts Python de backtest + catálogos IFR
estudo_teorias/        → Teoria técnica em Markdown (consulta e edição)
profit_estudos_cores/  → Scripts NTSL para Neologica Profit
WorkspaceRobosTrade/   → Orientações e documentação do workspace
```

---

## Regras para Geração de Código

### Scripts NTSL (Neologica Profit)

- Extensão: `.txt` ou `.ntsl.txt`
- Nomenclatura robôs março/2026: `mar_IFR_NN_vX_TIMEFRAME_descricao.ntsl.txt`
- Nomenclatura indicadores/cores: `mar_NomeDoEstudo.ntsl.txt`
- Sempre incluir comentário de cabeçalho com: versão, timeframe, descrição, taxa de acerto se disponível
- Respeitar a sintaxe NTSL da plataforma Profit (variáveis, séries, funções nativas)

### Scripts Python (Backtest)

- Usar Python 3.10 (`C:/Program Files/Python310/python.exe`)
- Seguir estrutura de backtest existente na pasta `automacao_backtests/IFR_RSI/`
- Nomear resultados com timeframe e taxa de acerto no nome do arquivo: `robo_ifr_vNN_descricao_TIMEFRAME_XX%.txt`

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
