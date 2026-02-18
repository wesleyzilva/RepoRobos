# Diário de Backtest e Validação de Performance

**Data:** [Data de Hoje]
**Ativo:** WINFUT
**Período do Teste:** [Ex: Últimos 6 meses]

**Instruções:** Para cada timeframe (15m, 30m, 60m), execute as etapas de otimização no ProfitChart. Anote o ID da melhor combinação em cada etapa e use-o como base para a etapa seguinte.

---

## ANÁLISE TIMEFRAME: 15 MINUTOS

### Etapa 1.1: Otimização dos Filtros de Entrada ("Core")
*Configuração Fixa:* `AtivarBreakeven=ON`, `AtivarTrailingStop=ON`, `UsarFiltroInclinacao=OFF`, `UsarFiltroCaixote=OFF`, `SomenteGoldSignal=OFF`.

| ID | VWAP | Tendência (M20) | Estrutura (Pivô) | Veto (Pavio) | Lucro Líquido | Fator de Lucro | Drawdown Máx | Nº Trades |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **01** | OFF | OFF | OFF | OFF | | | | | |
| **02** | **ON** | OFF | OFF | OFF | | | | | |
| **03** | OFF | **ON** | OFF | OFF | | | | | |
| **04** | OFF | OFF | **ON** | OFF | | | | | |
| **05** | OFF | OFF | OFF | **ON** | | | | | |
| **06** | ON | ON | OFF | OFF | | | | | |
| **07** | ON | OFF | ON | OFF | | | | | |
| **08** | OFF | ON | ON | OFF | | | | | |
| **09** | ON | ON | ON | OFF | | | | | |
| **10** | **ON** | **ON** | **ON** | **ON** | | | | | |
*... (Otimizador gerará 16 combinações)*

**Melhor Combinação "Core" (ID):** ________

---

### Etapa 1.2: Otimização dos Filtros de Lateralidade
*Configuração Fixa:* Usar a melhor combinação da Etapa 1.1.

| ID | Filtro Inclinação | Filtro Caixote | Lucro Líquido | Fator de Lucro | Drawdown Máx | Nº Trades |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **A** | OFF | OFF | | | | |
| **B** | **ON** | OFF | | | | |
| **C** | OFF | **ON** | | | | |
| **D** | **ON** | **ON** | | | | |

**Melhor Combinação com Filtros de Ruído (ID):** ________

---

### Etapa 1.3: Otimização da Gestão de Saída
*Configuração Fixa:* Usar a melhor combinação da Etapa 1.2.

| ID | Breakeven (0x0) | Trailing Stop (M9) | Lucro Líquido | Fator de Lucro | Drawdown Máx | Payoff Médio |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **A** | OFF | OFF | | | | |
| **B** | **ON** | OFF | | | | |
| **C** | OFF | **ON** | | | | |
| **D** | **ON** | **ON** | | | | |

**Melhor Gestão de Saída (ID):** ________

---

### Etapa 1.4: Otimização de Seletividade (Modo Sniper)
*Configuração Fixa:* Usar a melhor combinação da Etapa 1.3.

| ID | Somente Gold Signal | Lucro Líquido | Fator de Lucro | Nº Trades | % Acerto |
|:---:|:---:|:---:|:---:|:---:|:---:|
| **X** | **False** (Todos os Sinais) | | | | |
| **Y** | **True** (Apenas Ouro) | | | | |

**Melhor Modo de Seletividade (ID):** ________

---

## [REPETIR AS ETAPAS PARA 30m e 60m]

...

---

## Veredito Final e Parâmetros Otimizados

Comparando os melhores resultados de 15m, 30m e 60m, a configuração final para automação é:

*   **Timeframe Escolhido:** ________
*   **Parâmetros Finais (Copiar do melhor resultado):**
    *   `UsarFiltroVWAP`: ________
    *   `UsarFiltroTendencia`: ________
    *   `UsarFiltroEstrutura`: ________
    *   `UsarFiltroVeto`: ________
    *   `UsarFiltroInclinacao`: ________
    *   `UsarFiltroCaixote`: ________
    *   `AtivarBreakeven`: ________
    *   `AtivarTrailingStop`: ________
    *   `SomenteGoldSignal`: ________

**Expectativa Matemática:**
*   Média de Trades/Dia:
*   Drawdown Máximo Esperado:
*   Meta Diária Sugerida:

---
*Arquivo gerado para documentação do Trade System Wesley - Fev/2026*