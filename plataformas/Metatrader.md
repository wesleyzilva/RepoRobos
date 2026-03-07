# Guia Completo — MetaTrader 5 (MT5)

> Plataforma principal para mercado **internacional** — Forex, índices, cripto (via CFD).  
> Corretoras suportadas: **Tickmill** (Forex/CFD), **XP** (Brasil, versão MT5 disponível).  
> Para cripto direta (sem CFD): **Binance** usa plataforma própria — ver seção 10.

---

## 1. Instalação

### 1.1 Download
1. Acesse diretamente pela corretora (evite instalar MT5 genérico):
   - **Tickmill:** https://www.tickmill.com/platforms/mt5 → Download MT5
   - **XP (MT5):** Plataformas → MetaTrader 5
2. Execute o instalador como Administrador
3. Pasta padrão: `C:\Program Files\MetaTrader 5\`

### 1.2 Requisitos mínimos
| Item | Mínimo | Recomendado |
|------|--------|-------------|
| OS | Windows 10 | Windows 11 |
| RAM | 4 GB | 8 GB+ |
| Processador | Dual-core | Quad-core 3GHz+ |
| Internet | 10 Mbps | 50 Mbps+ |

---

## 2. Conexão com Conta Demo

### 2.1 Tickmill (mercado internacional)
1. Abra o MT5
2. Menu **"Arquivo → Abrir Conta"**
3. Pesquise por: `Tickmill` na lista de servidores
4. Selecione: `Tickmill-Demo` (ou `Tickmill Ltd-Demo`)
5. Clique em **"Abrir Conta Demo"**
6. Preencha:
   - Nome completo
   - E-mail
   - Tipo: **Hedging** (MT5 padrão Forex)
   - Moeda da conta: USD
   - Alavancagem: **1:100** (para operar índices) ou 1:500 (Forex)
   - Depósito virtual: USD 10.000
7. Anote o **login** e **senha** gerados
8. Clique em **"Concluir"** — conexão é automática

### 2.2 Verificando conexão demo
- Canto inferior direito: deve mostrar o servidor e sinal verde
- Na aba **"Terminal"** (Ctrl+T): saldo deve mostrar USD 10.000
- Status: `Autorizado` na aba Conexão

---

## 3. Estrutura do MT5 — Visão Geral

```
MT5
├── Market Watch (Ctrl+M)      → Lista de ativos/cotações em tempo real
├── Navigator (Ctrl+N)         → Expert Advisors, Indicadores, Scripts
├── Terminal (Ctrl+T)          → Posições, ordens, histórico, logs
├── Strategy Tester (Ctrl+R)   → BACKTEST — MAIS IMPORTANTE
└── MetaEditor (F4)            → IDE para programar EAs em MQL5
```

---

## 4. Adaptando os Robôs NTSL para MQL5

> Os robôs `mar_PC_XX` foram escritos em **NTSL** para o Profit.  
> Para rodar no MT5, é necessário **reescrever em MQL5** (linguagem C-like).

### 4.1 Equivalência das funções principais

| NTSL (Profit) | MQL5 (MetaTrader 5) |
|---------------|---------------------|
| `BuyAtMarket` | `trade.Buy(volume, symbol, 0, sl, tp)` |
| `SellShortAtMarket` | `trade.Sell(volume, symbol, 0, sl, tp)` |
| `ClosePosition` | `trade.PositionClose(symbol)` |
| `IsBought` | `PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY` |
| `IsSold` | `PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL` |
| `Media(p, 1, Close)` | `iMA(NULL,0, p, 0, MODE_EMA, PRICE_CLOSE)` |
| `ATR(p)` | `iATR(NULL, 0, p)` |
| `High[n]` | `iHigh(NULL, 0, n)` |
| `Low[n]` | `iLow(NULL, 0, n)` |
| `Close[n]` | `iClose(NULL, 0, n)` |
| `Volume[n]` | `iTickVolume(NULL, 0, n)` |
| `Date <> Date[1]` | `TimeDay(Time[0]) != TimeDay(Time[1])` |
| `DayOfWeek(Date)` | `TimeDayOfWeek(TimeCurrent())` |

### 4.2 Estrutura básica de um EA MQL5
```mql5
// Arquivo: mar_PC_01_EA.mq5
#include <Trade\Trade.mqh>

CTrade trade;
input double RiscoMaxDia = 1.0;       // % do capital
input double MultiplicadorAlvo = 1.5;
input int    PeriodoATR = 14;

// Variáveis globais
double fMaxC1, fMinC1, fRangeC1;
bool   bEntradaExecutada;
datetime dtUltimoDia;

int OnInit() {
  // Configurações iniciais
  return INIT_SUCCEEDED;
}

void OnTick() {
  // Detecta novo dia
  if(TimeDay(TimeCurrent()) != TimeDay(dtUltimoDia)) {
    bEntradaExecutada = false;
    dtUltimoDia = TimeCurrent();
  }
  // Captura C1, verifica sinal...
}

void OnDeinit(const int reason) {}
```

### 4.3 Para usar os robôs PC_XX no MT5
- Cada robô precisa ser **portado manualmente** (lógica é idêntica, sintaxe diferente)
- A pasta `plataformas/mql5/` conterá as versões MQL5 quando criadas
- Priorize os Tier 1 para portar primeiro (PC_01 a PC_10)

---

## 5. Executando Backtest de 5 Anos no MT5

### 5.1 Abrir o Strategy Tester
- Pressione **Ctrl+R** ou menu **"Exibir → Strategy Tester"**

### 5.2 Configurar o backtest

**Aba "Configurações":**
```
Expert Advisor:    [selecionar o EA compilado]
Símbolo:           US500 (S&P500) | XAUUSD (Ouro) | EURUSD (Forex)
Timeframe:         M15 (15 min) ou M30 (30 min)
Modelo:            Every tick based on real ticks (mais realista)
               OU: 1 minute OHLC (mais rápido)
Data (De):         01.01.2020
Data (Até):        07.03.2026
Depósito:          10000 USD
Alavancagem:       1:100
```

### 5.3 Baixar histórico para 5 anos
1. Menu **"Ferramentas → Histórico de Cotações"** (Ctrl+H)
2. Selecione o símbolo (ex: `US500`)
3. Clique em **"Baixar"** — o MT5 baixa direto do servidor da corretora
4. Aguarde completar (pode demorar para dados tick-by-tick)
5. Verifique: painel mostrará barras disponíveis por timeframe

### 5.4 Configurar comissão real (Tickmill)
- Tickmill cobra ~$3 por lote round-trip para micropares
- No Strategy Tester, **não há ajuste manual de spread/comissão** — ele usa o spread real da corretora configurada

### 5.5 Iniciar o backtest
1. Clique em **"Iniciar"** (botão ▶)
2. Progresso aparece na barra inferior
3. Tempo estimado:
   - Modelo "Every tick": 10-60 min (5 anos, 15min)
   - Modelo "1 min OHLC": 1-5 min

---

## 6. Analisando Resultados no MT5

### 6.1 Abas de resultado após backtest

| Aba | O que mostra |
|-----|-------------|
| **Gráfico** | Equity curve + drawdown |
| **Resultados** | Lista de cada operação |
| **Relatório** | Métricas completas |
| **Otimização** | Grid de parâmetros (se otimização) |

### 6.2 Métricas-chave no Relatório MT5

| Métrica | Campo no relatório | Mínimo aceitável |
|---------|--------------------|-----------------|
| Fator de lucro | `Profit Factor` | > 1.3 |
| Drawdown máximo | `Maximal Drawdown` | < 20% |
| Resultado esperado | `Expected Payoff` | > $0 |
| Taxa de acerto | `% of profitable trades` | > 55% |
| Sharpe Ratio | `Sharpe Ratio` | > 0.5 |
| Operações totais | `Total Trades` | > 100 |

### 6.3 Exportar relatório
1. Clique com o botão direito no painel de Resultados
2. **"Salvar Como Relatório HTML"** — abre no navegador
3. Para CSV: clique com o botão direito → **"Copiar"** → colar no Excel

---

## 7. Otimização de Parâmetros no MT5

### 7.1 Configurar otimização
1. No Strategy Tester, marque **"Optimization"**
2. Tipo de otimização: **"Slow complete algorithm"** (mais preciso) ou **"Fast genetic algorithm"** (mais rápido)
3. Critério: **"Balance max"** (maximizar saldo) — ou **"Custom max"** (criar sua métrica)

### 7.2 Definir faixas de parâmetros
No código MQL5, use a linha `input` com faixa:
- Clique no ícone de propriedades ao lado do parâmetro no Tester
- Defina: Valor inicial | Passo | Valor final

Exemplo:
```
MultiplicadorAlvo:  1.0  →  0.25  →  3.0
PeriodoATR:         7    →  1     →  21
```

### 7.3 Análise do gráfico de otimização ("Optimization Graph")
- Aparece após conclusão
- Eixo X = combinação de parâmetros, Eixo Y = resultado
- Buscar **"platô"** (região estável, não pico isolado) → robustez

### 7.4 Walk-Forward no MT5
1. Após otimizar em 2020-2023, manualmente altere as datas para 2024-2026
2. Use os melhores parâmetros encontrados (sem re-otimizar)
3. Se resultado fora da amostra ≥ 50% do dentro → aprovado

---

## 8. Ativos Recomendados por Corretora

### 8.1 Tickmill — Mercado Internacional
| Ativo | Símbolo MT5 | Mercado | Horário BR |
|-------|-------------|---------|-----------|
| S&P 500 | `US500` | Ações EUA | 10h-17h |
| Nasdaq | `US100` | Tech EUA | 10h-17h |
| Ouro | `XAUUSD` | Commodities | 24h |
| EUR/USD | `EURUSD` | Forex | 24h |
| BTC/USD | `BTCUSD` | Cripto CFD | 24h |

> **Nota Binance:** A Binance não usa MT5. Para cripto direta na Binance, é necessário usar a API própria (Python/ccxt). Os robôs PC_XX são específicos para análise de 1º candle do dia — compatível com Binance via script Python separado.

### 8.2 Estratégia de 1º candle no MT5
Os robôs `mar_PC_XX` foram projetados para o WIN (Brasil). Para adaptar ao MT5:
- **Timeframe equivalente:** 15min ou 30min
- **"Dia" na abertura:** 1º candle após abertura do pregão do ativo
- Para `US500`: primeiro candle das 09:30 EST (14:30 BRT, horário de verão EUA)
- Para `XAUUSD`: sem horário fixo — adaptar para candle diário de abertura da sessão Londres (08:00 GMT)

---

## 9. Configuração Final — Resumo Rápido

```
OBJETIVO: Backtest 5 anos de um EA no MT5 (Tickmill demo)

PASSOS RÁPIDOS:
1. Instalar MT5 pelo site da Tickmill
2. Arquivo → Abrir Conta → Tickmill-Demo → Criar conta
3. F4 (MetaEditor) → Novo → Expert Advisor → colar/escrever código MQL5
4. Compilar (F7) — sem erros
5. Ctrl+R (Strategy Tester):
   - EA = seu robô compilado
   - Símbolo = US500 ou EURUSD
   - Timeframe = M15
   - Modelo = 1 minute OHLC (rápido) ou Every tick (preciso)
   - Data: 01.01.2020 até hoje
   - Depósito: 10000 USD
6. ▶ Iniciar
7. Analisar: Profit Factor > 1.3, Drawdown < 20%
8. Se aprovado → otimizar parâmetros
9. Walk-forward validation
10. Produção: conta real Tickmill
```

---

## 10. Binance — Backtest via Python (alternativa)

Para a Binance (cripto real, sem CFD), o fluxo é diferente:

### 10.1 Ferramentas
- **Python + ccxt** para baixar dados históricos da Binance
- **Backtrader** ou **vectorbt** para backtest
- Os robôs PC_XX podem ser convertidos para Python (lógica OHLCV)

### 10.2 Fluxo básico Binance
```python
import ccxt
import pandas as pd

binance = ccxt.binance()

# Baixar 5 anos de candles BTCUSDT 15min
ohlcv = binance.fetch_ohlcv('BTC/USDT', '15m',
                              since=binance.parse8601('2020-01-01T00:00:00Z'),
                              limit=1000)
df = pd.DataFrame(ohlcv, columns=['timestamp','open','high','low','close','volume'])
```

### 10.3 Restrições
- Binance limita histórico a ~1000 candles por request (necessário paginar)
- Backtest Python não tem interface visual como MT5 — usar `matplotlib` para equity curve
- Para estratégias de 1º candle: usar candle diário como referência (`1d`) e M15 para execução

---

## 11. Troubleshooting MT5

| Problema | Solução |
|---------|---------|
| "No connection" | Verificar servidor Tickmill-Demo, trocar servidor na lista |
| EA não aparece no Navigator | Recompilar em MetaEditor (F7), verificar pasta `MQL5/Experts/` |
| "Backtesting failed - no data" | Baixar histórico: Ctrl+H, selecionar par, Download |
| Strategy Tester muito lento | Usar modelo "1 minute OHLC" em vez de "Every tick" |
| Resultado diferente em ticks reais | Normal — modelo OHLC é aproximação |
| EA não opera na demo | Verificar `AutoTrading` habilitado (botão na barra superior) |
| "Trade context busy" | Adicionar `Sleep(100)` entre ordens no código MQL5 |
