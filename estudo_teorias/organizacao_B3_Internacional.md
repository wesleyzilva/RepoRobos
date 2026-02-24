# Organização Operacional: B3 (Toro) & Internacional (Tickmill)

Este documento estrutura a rotina para operar simultaneamente no Brasil e no Exterior, aproveitando as correlações e diversificando risco.

## 1. Estrutura de Plataformas e Contas

### 🇧🇷 B3 (Brasil) - Toro Investimentos
*   **Foco:** Day Trade em Índice/Dólar e Swing Trade em Ações.
*   **Plataforma:** ProfitChart (Toro Trader).
*   **Vantagem:** Corretagem Zero (com RLP) e plataforma robusta para fluxo (Tape Reading) e técnica.
*   **Moeda Base:** BRL (Real).

### 🌎 Internacional - Tickmill (Corretora CFD)
*   **Foco:** Forex, Ouro (XAUUSD) e Índices Americanos (US500/S&P, USTEC/Nasdaq).
*   **Plataforma:** MetaTrader 4 (MT4) ou MetaTrader 5 (MT5).
    *   *Dica:* Use o **TradingView** para análise gráfica (dados da OANDA ou FXCM são próximos) e o MT4/MT5 apenas para executar a ordem (boleta).
*   **Conta Recomendada:** "Pro Account" (Spreads baixos + Comissão fixa). Melhor para estratégias técnicas.
*   **Moeda Base:** USD (Dólar).

## 2. Seleção de Ativos e Correlações

Não opere tudo ao mesmo tempo. Use a correlação a seu favor.

| Mercado | Ativo Principal | Ativo Correlato (Monitorar) | Horário Nobre |
| :--- | :--- | :--- | :--- |
| **B3** | **WIN (Mini Índice)** | S&P 500 (Tickmill: US500) | 09:00 - 11:00 |
| **B3** | **WDO (Mini Dólar)** | DXY e EURUSD (Tickmill) | 09:00 - 11:00 |
| **Intl** | **EURUSD** | DXY (Índice Dólar) | 09:00 - 12:00 |
| **Intl** | **XAUUSD (Ouro)** | Juros US (US10Y) / Dólar | 10:30 - 12:00 |

### Regra de Ouro da Correlação
*   Se **S&P 500 (US500)** está caindo forte na Tickmill -> **Venda WIN** na Toro.
*   Se **Dólar Global (DXY)** está subindo -> **Venda EURUSD** na Tickmill e **Compre WDO** na Toro.

### Meus Ativos na B3 (Carteira de Trabalho)
*   **Futuros (Day Trade/Hedge):**
    *   `WINFUT` (Mini Índice)
    *   `WDOFUT` (Mini Dólar)
    *   `WSPFUT` (Micro S&P 500 - Correlação direta com US500)
    *   `BITFUT` (Futuro de Bitcoin - Correlação com Crypto Global)
*   **Ações (Blue Chips):**
    *   `VALE3` (Vale - Correlação com Minério/China)
    *   `PETR4` (Petrobras - Correlação com Petróleo WTI/Brent)
    *   `ITUB4` (Itaú - Setor Financeiro)
*   **BDRs (Tech/Growth):**
    *   `ROXO34` (Nubank)
    *   `AMAZO34` (Amazon)

## 3. Rotina Operacional (O "Turno de Trabalho")

*   **08:30 - 09:00 (Pré-Market):**
    *   Abra o TradingView/MT4.
    *   Verifique como fechou a Ásia e como está a Europa.
    *   **Calendário Econômico:** Liste os horários de notícias de 3 estrelas/touros (Investing/ForexFactory). Defina alarmes.
    *   Marque suportes e resistências no **US500** e **XAUUSD**.
*   **09:00 - 10:00 (Abertura B3):**
    *   Foco total na **Toro (Profit)**.
    *   O mercado internacional serve apenas como "bússola" (direção).
*   **10:00 - 10:15 (Abertura Ações BR - O "Samba do Crioulo Doido"):**
    *   **Alerta Vermelho:** Abertura do mercado à vista (Ibovespa).
    *   **WIN:** Alta volatilidade devido à arbitragem com as ações. Muitas violinadas.
    *   **WDO:** Primeira janela de Ptax (briga de taxas).
    *   **Ação:** Evite abrir novas posições exatamente às 10:00. Espere a poeira baixar (10:15).
*   **10:30 - 12:00 (Abertura NYSE + Prime Time):**
    *   Abertura de NY (considerando horário de verão). Se for inverno lá, é 11:30.
    *   Melhor horário para operar **Tickmill** (Forex/Ouro) e **B3** simultaneamente. Volume máximo.
*   **12:00 - 13:00 (Almoço):**
    *   Reduza a mão ou encerre o dia. Liquidez cai drasticamente.

## 4. Gestão de Risco Unificada

*   **Capital B3 (Toro):** Risco em Reais (R$). Meta de pagar contas do mês.
*   **Capital Intl (Tickmill):** Risco em Dólar (USD). Meta de crescimento patrimonial (Juros Compostos).
*   **Stop Loss Diário:** Defina um limite global.
    *   *Exemplo:* Se perder $50 na Tickmill, reduza o risco na B3 para não ter um "dia de fúria" duplo.

## 5. Aspectos Tributários (Resumo Prático)

*   **Toro (Brasil):**
    *   Apuração Mensal.
    *   DARF: 20% sobre lucro Day Trade.
    *   Compensação de prejuízos permitida.
*   **Tickmill (Exterior):**
    *   Apuração Anual (Lei 14.754 - Novas regras 2024).
    *   Alíquota única de **15%** sobre o lucro (ganho de capital + variação cambial).
    *   Não precisa pagar DARF mensalmente (apenas na declaração anual de ajuste), mas recomenda-se reservar o valor.
    *   *Atenção:* Diferente da B3, prejuízos lá fora não compensam lucros no Brasil (são caixas separadas).

## 6. Checklist de Instalação

1.  [ ] Instalar **ProfitChart** (Toro).
2.  [ ] Instalar **MetaTrader 5** (Tickmill) ou conectar conta no TradingView (se disponível).
3.  [ ] Configurar tela com gráficos lado a lado (B3 na esquerda, Intl na direita).
4.  [ ] Criar planilha de controle separada (uma aba BRL, uma aba USD).

## 7. Estratégia de Paraíso Fiscal (Offshore Prática)

Para maximizar a eficiência no internacional, a escolha da "filial" da corretora é crucial.

*   **Escolha da Jurisdição (Entidade):** Ao abrir conta na Tickmill, escolha a entidade regulada em **Seychelles (FSA)**.
    *   **O que é:** Seychelles é um paraíso fiscal clássico.
    *   **Vantagem:** **Imposto Zero na Fonte.** A corretora não retém nada sobre seus lucros. Todo o resultado líquido fica na sua conta para reinvestimento (Juros Compostos).
    *   **Diferença:** Se abrir na Tickmill UK (Reino Unido), você estaria sujeito a regulações europeias (ESMA) que limitam a alavancagem (máx 1:30) e podem ter regras tributárias locais mais rígidas.
*   **Alavancagem:** Em paraísos fiscais, a alavancagem permitida é maior (1:500), o que exige gestão de risco profissional, mas permite operar com menos capital travado em margem.

Na B3 opero:
ROXO34
AMAZO34
VALE3
PETR4
ITUB4
BITFUTV
WDOFUTV
WSPFUT
WINFUT