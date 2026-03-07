# Como Rodar o Backtest — mar_MT5_PPV01_exemplo

> Passo a passo completo: do arquivo `.mq5` ao resultado no Strategy Tester.

---

## Passo 1 — Abrir o MetaEditor

1. Acesse: https://web.metatrader.app/terminal?mode=demo&lang=pt
2. Clique em **"MetaEditor"** (botão no topo) ou pressione `F4`
3. O MetaEditor abre em nova aba

---

## Passo 2 — Criar o arquivo do EA

1. No MetaEditor: **"File → New"** ou `Ctrl+N`
2. Selecione: **"Expert Advisor (template)"**
3. Nome do arquivo: `mar_MT5_PPV01_exemplo`
4. Clique em **"Next → Finish"**
5. O editor abre com um template básico — **apague tudo**
6. Abra o arquivo: `plataformas/mql5/mar_MT5_PPV01_exemplo.mq5`
7. Copie todo o conteúdo (`Ctrl+A`, `Ctrl+C`)
8. Cole no MetaEditor (`Ctrl+V`)

---

## Passo 3 — Compilar

1. Pressione `F7` ou clique em **"Compile"**
2. Painel inferior deve mostrar: `0 errors, 0 warnings`
3. Se houver erro:

| Erro comum | Causa | Solução |
|-----------|-------|---------|
| `'iRSI' - function not allowed` | Versão antiga do MT5 | Usar MT5 versão 2800+ |
| `'CTrade' - undefined` | Include não encontrado | Verificar `#include <Trade\Trade.mqh>` |
| `'ORDER_FILLING_IOC'` | Corretora não suporta | Trocar para `ORDER_FILLING_FOK` |

---

## Passo 4 — Configurar o Strategy Tester

1. No terminal principal: pressione `Ctrl+R` ou menu **"View → Strategy Tester"**
2. Configure:

```
Expert Advisor:  mar_MT5_PPV01_exemplo
Symbol:          XAUUSD   (primeiro teste — Ouro)
Timeframe:       M15
Model:           1 minute OHLC   (mais rápido para validar)
Date from:       2022.01.01
Date to:         2026.03.07
Deposit:         5000
Currency:        USD
Leverage:        1:100
```

3. Clique no ícone de engrenagem ⚙️ ao lado do EA para ver/ajustar os parâmetros:

```
PeriodoIFR:           9
IFRExtremoCompra:     30
IFREtornoCompra:      35
IFRExtremoVenda:      70
IFREtornoVenda:       65
PeriodoATR:           14
FatorStopInicial:     0.8
FatorAlvo:            1.2
FatorTrailing:        0.5
BreakEvenTrigger:     50.0
BreakEvenOffset:      5.0
UsarFiltroMME200:     true
UsarGestaoRisco:      false     ← PRIMEIRO TESTE SEM GESTAO DE RISCO
VolumeLote:           0.01
MaxBarrasPosicao:     4
```

---

## Passo 5 — Rodar o backtest

1. Clique em **"Start"** (▶)
2. Acompanhe a barra de progresso
3. Tempo estimado (modelo OHLC 1min):
   - XAUUSD 4 anos M15: ~2-5 minutos
   - Se demorar muito: trocar para `M30` ou reduzir período para 2 anos

---

## Passo 6 — Analisar os Resultados

### Aba "Graph" — Equity Curve
- Linha verde subindo = robô com resultado positivo
- Linha azul = drawdown (quanto caiu do pico)
- **O que buscar:** linha verde com inclinação constante, sem quedas bruscas

### Aba "Results" — Lista de Trades
- Cada linha = 1 operação
- Colunas importantes: Time, Type, Price, S/L, T/P, Profit
- **Filtro útil:** clicar em "Profit" para ordenar — ver os piores trades

### Aba "Report" — Métricas

| Campo | onde está | Meta |
|-------|-----------|------|
| Profit Factor | Seção "Total" | > 1.3 |
| Expected Payoff | Seção "Total" | > 0 |
| Maximal Drawdown | Seção "Drawdown" | < 20% |
| % Profitable | Seção "Trades" | > 55% |
| Total Trades | Seção "Trades" | > 100 |
| Sharpe Ratio | Seção "Total" | > 0.5 |

---

## Passo 7 — Segundo Teste COM Gestão de Risco

Após confirmar que o robô opera (tem trades), rode novamente com:
```
UsarGestaoRisco:      true
UsarHardLock:         true
MaxStopsConsecutivos: 2
RiscoDiaPct:          1.5
```

Compare os resultados:
- **Sem gestão:** mostra o potencial bruto da estratégia
- **Com gestão:** mostra o resultado real operacional

---

## Passo 8 — Testar nos Outros 4 Ativos

Após aprovar em XAUUSD, repetir o Passo 4-6 para:

| Ativo | Alterar apenas |
|-------|---------------|
| `US30` | Symbol = US30 |
| `NAS100` | Symbol = NAS100, BreakEvenTrigger = 80 |
| `EURUSD` | Symbol = EURUSD, FatorAlvo = 1.5 |
| `US500` | Symbol = US500 |

---

## Passo 9 — Exportar o Relatório

1. Na aba **"Report"**: clique com botão direito → **"Save as Report"**
2. Salvar como HTML na pasta: `automacao_backtests/POUCOSPONTOSVENCEDORES/resultados/`
3. Nome sugerido: `PPV01_XAUUSD_M15_4anos_semgestao.html`

---

## Checklist rápida antes de colocar no simulador

- [ ] Backtest 4+ anos com > 100 operações
- [ ] Profit Factor > 1.3
- [ ] Drawdown < 25%
- [ ] Testado sem e com gestão de risco
- [ ] Testado em pelo menos 2 ativos diferentes
- [ ] Resultado "com gestão" é positivo
- [ ] Equity curve não tem períodos de queda prolongada (> 3 meses)
