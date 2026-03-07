# Grupo HORARIO_ESPECIFICO (HE)

## Por que é Obrigatório Conhecer
O mercado não é aleatório ao longo do dia — existem **janelas de tempo com comportamentos estatisticamente diferentes**. O WIN tem padrões de horário bem documentados que traders profissionais conhecem de memória.

Ignorar horário é operar no escuro. Conhecer os horários é uma vantagem estrutural que não depende de nenhum indicador técnico.

---

## Mapa de Horários do WIN (B3)

| Horário | Evento | Comportamento |
|---------|--------|---------------|
| **09:00–09:15** | Abertura / leilão | Alta volatilidade, gaps, fakeouts — risco alto |
| **09:15–10:30** | 1ª janela de tendência | Tendência do dia se define — melhor janela |
| **10:30–11:30** | Acomodação | Lateralização frequente — evitar |
| **11:30–12:00** | Pré-almoço | Movimento fraco, armadilhas comuns |
| **12:00–13:30** | Almoço B3 | Volume baixo — não operar (slippage) |
| **13:30–14:00** | Reabertura após almoço | Pode ter movimento seco |
| **14:00–16:00** | 2ª janela de tendência | Nova tendência do tarde — segunda melhor janela |
| **16:00–16:30** | Ajuste final | Alta volatilidade, rolagem — evitar ou stop manual |
| **16:30–17:00** | Fechamento | Volume misto — sem automação |

---

## Estratégias de Horário Específico

| Setup | Descrição |
|-------|-----------|
| **Toque de Abertura** (9:15) | Entra na direção do 1º candle de 5min após estabilização |
| **Máx/Mín das 2 primeiras horas** | Nível de referência para breakout após 11h |
| **Retomada do tarde** (14:00) | Trend following na 2ª janela |
| **Horário de Notícia** | Evitar 15 min antes e depois de notícia macro |

---

## Indicadores Utilizados

| Indicador | Função |
|-----------|--------|
| **Hora do Candle** | Filtro de janela de operação |
| **Máx/Mín das primeiras 2h** | Nível de referência gerado automaticamente |
| **IFR** | Sinal dentro da janela permitida |
| **Volume** | Confirma liquidez na janela |

---

## Estrutura dos Robôs HE

```
HE_01 — Janela 09:15–10:30 | IFR + MME200 | fecha às 10:30     (Profit .ntsl)
HE_02 — Janela 14:00–16:00 | IFR + trending | fecha às 16:00   (Profit .ntsl)
HE_03 — Máx/Mín das 2 primeiras horas + breakout após 11h      (Profit .ntsl)
HE_04 — MT5: London Session / NY Overlap (9h–12h UTC)          (MQL5 .mq5)
```

## Estrutura de Pastas
```
HORARIO_ESPECIFICO/
├── horario_especifico.md  ← este arquivo
├── codigo_fonte/          ← robôs Profit (.ntsl.txt)
└── mql5/                  ← robôs MetaTrader (.mq5)
```
