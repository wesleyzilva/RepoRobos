# Horários Operacionais — Internacional (Tickmill / MT5)

> Fonte: `organizacao_B3_Internacional_horarios.md` + `organizacao_B3_Internacional.md`  
> Plataforma: MetaTrader 5 (Tickmill) + TradingView (análise)  
> Última atualização: 04/04/2026

---

## 1. Sessões Globais (Horário de Brasília — GMT-3)

| Sessão | Centros | Horário BRT | Característica |
|--------|---------|-------------|----------------|
| **Asiática** | Tóquio, Sydney, Hong Kong | 20:00 – 05:00 | Menor volatilidade (exceto Yen e AUD). Bom para scalp técnico e range. |
| **Europeia** | Londres (LSE), Frankfurt | 04:00 – 13:30 | Alta vol na abertura (04:00–06:00). Define o tom antes dos EUA. |
| **Americana** | Nova York (NYSE/Nasdaq) | 10:30 – 18:00 | **Máxima liquidez.** Grandes movimentos, reversões, agulhadas. |

> **Observação:** Abertura NYSE varia: **10:30 BRT** (horário de verão EUA) ou **11:30 BRT** (horário de inverno EUA).

---

## 2. Ativos Operados e Horários

### Índices Futuros
| Ativo | Símbolo | Pregão | Melhor janela BRT |
|-------|---------|--------|------------------|
| E-mini S&P 500 | ES / US500 | 23h/dia (pausa 18:00-19:00) | 10:30 – 17:00 |
| Nasdaq 100 | NQ / USTEC | 23h/dia | 10:30 – 17:00 |
| DAX 40 | FDAX | 23h (futuro estendido) | 04:00 – 13:30 |
| Nikkei 225 | NK | Madrugada BRT | 20:00 – 04:00 |

### Commodities
| Ativo | Símbolo | Pregão | Melhor janela BRT |
|-------|---------|--------|------------------|
| Petróleo WTI | CL | 23h/dia | 10:30 – 17:00 |
| Ouro | GC / XAUUSD | 23h/dia | 04:00 – 12:00 |

### Forex
| Ativo | Símbolo | Pregão | Melhor janela BRT |
|-------|---------|--------|------------------|
| Euro/Dólar | EURUSD / 6E | 24h (dom 18h – sex 18h) | 04:00 – 13:00 |
| Dólar/Yen | USDJPY / 6J | 24h | 20:00 – 05:00 (Ásia) |
| Libra/Dólar | GBPUSD / 6B | 24h | 04:00 – 12:00 |

### Cripto
| Ativo | Pregão | Nota |
|-------|--------|------|
| Bitcoin (BTC) | 24h / 7 dias | Único mercado que nunca fecha |

---

## 3. Cronograma do Dia (foco em operar junto com B3)

### 04:00 – 05:00 | Abertura de Londres
- Alta volatilidade no EURUSD e GBPUSD
- Se Europa muito negativa → WIN (B3) tende a abrir com Gap de Baixa às 09:00
- **Ouro (XAUUSD):** começa a ganhar liquidez

### 08:30 – 09:00 | Pré-Market B3 (preparação)
- Verificar US500 (S&P Futuro) no MT5/TradingView
- Checar DXY (Índice Dólar) para estimar direção do WDO
- Checar EURUSD para confirmar força/fraqueza do dólar global

### 09:00 – 10:30 | B3 no foco — Internacional como bússola
- **Não operar** Tickmill neste bloco (foco total na B3)
- Usar US500 e DXY apenas como referência direcional

### 10:30 – 12:00 | ⭐ Prime Time Internacional + B3 simultâneos
- Abertura NYSE (horário de verão EUA) — **volume máximo**
- Melhor janela para operar Tickmill e B3 em paralelo
- EURUSD, XAUUSD e US500 com máxima liquidez
- XAUUSD: correlacionar com juros US (US10Y) e DXY

### 12:00 – 13:30 | Fechamento Europa
- EURUSD perde liquidez após 13:30
- Continuar ES/NQ com volume sustentado
- B3 no almoço — focar só no internacional neste bloco se necessário

### 14:00 – 18:00 | Tarde americana — continuação
- ES/NQ/CL com tendências mais limpas
- Horário de rolagem de posições americanas
- Fechar posições abertas no Tickmill antes das 18:00 (pausa ES/NQ)

---

## 4. Correlações Chave Internacional → B3

| Se no Internacional... | Impacto na B3 |
|------------------------|--------------|
| US500 cai forte | Venda WIN |
| US500 sobe | Compra WIN |
| DXY sobe | Compra WDO |
| DXY cai | Venda WDO |
| EURUSD sobe | Venda WDO |
| Petróleo WTI sobe | Positivo WIN (PETR4) |
| Ouro sobe muito (risk-off) | Negativo WIN (fuga de risco) |

---

## 5. Setup da Plataforma

| Tarefa | Ferramenta |
|--------|-----------|
| Análise gráfica | **TradingView** (dados OANDA ou FXCM) |
| Execução de ordens | **MetaTrader 5** (Tickmill) |
| Calendário econômico | ForexFactory.com / Investing.com |
| Índice Dólar (DXY) | TradingView — ticker `DXY` |

### Tela recomendada
```
[Esquerda]         [Direita]
ProfitChart (B3)   TradingView / MT5 (Internacional)
WIN + WDO          US500 + DXY + EURUSD + XAUUSD
```

---

## 6. Conta Tickmill — Configuração

| Item | Configuração recomendada |
|------|--------------------------|
| **Entidade** | Tickmill **Seychelles (FSA)** — imposto zero na fonte |
| **Tipo de conta** | Pro Account (spreads baixos + comissão fixa) |
| **Alavancagem** | Até 1:500 disponível — usar com gestão profissional |
| **Moeda base** | USD |
| **Tributação BR** | 15% sobre lucro (ganho de capital + variação cambial) — apuração anual |

> ⚠️ Prejuízos no exterior **não compensam** lucros na B3 (caixas separados).

---

## 7. Gestão de Risco Unificada (B3 + Internacional)

- **Stop Loss Diário global:** se perder $50 na Tickmill → reduzir risco na B3 (evitar "dia de fúria duplo")
- **Capital B3 (BRL):** meta de pagar contas do mês
- **Capital Internacional (USD):** meta de crescimento patrimonial com juros compostos
- Nunca aumentar tamanho após perda — só após sequência de ganhos consistentes

---

## 8. Resumo Visual das Sessões

```
BRT   00:00                                                    23:59
      ├──────────────────────────────────────────────────────────┤
Ásia  │████████████████████                                      │ 20:00-05:00
Eur   │                          █████████████████              │ 04:00-13:30
NYSE  │                                    █████████████████    │ 10:30-18:00
B3    │                               ████████████████          │ 09:00-18:00
      ├──────────────────────────────────────────────────────────┤
       ⭐ OVERLAP Eur+NYSE+B3: 10:30-13:30 = Máxima liquidez global
```
