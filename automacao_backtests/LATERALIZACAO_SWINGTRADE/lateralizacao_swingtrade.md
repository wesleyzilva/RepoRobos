# LATERALIZACAO_SWINGTRADE — Estratégias de Range em Timeframes Maiores

## Filosofia

Explorar mercados que oscilam entre níveis técnicos relevantes em timeframes maiores (diário, semanal).
A lateralidade de médio prazo cria oportunidades de swing com alvos maiores e menos ruído de curto prazo.

- **Ativo alvo (Profit):** WIN (minicontrato de índice B3) e WDOFUT (dólar futuro)
- **Timeframes:** 60min, 4h, diário
- **Tipo de operação:** Reversão em suporte/resistência de swing, dentro de range consolidado
- **Meta:** Taxa de acerto > 60%, relação risco/retorno mínima 1:3

---

## Diferença em relação ao DAYTRADE

| Aspecto              | LATERALIZACAO_DAYTRADE         | LATERALIZACAO_SWINGTRADE        |
|----------------------|--------------------------------|--------------------------------|
| Timeframe            | 5min–30min                    | 60min–Diário                  |
| Duração da operação  | Intradiário (fecha no dia)    | 1–5 dias                      |
| Alvo por trade       | 50–200 pontos WIN             | 200–800 pontos WIN            |
| Stop                 | Estrutura intradiária          | Estrutura multiday            |
| Filtro macro         | VWAP diária                   | VWAP semanal + média 200      |

---

## Critérios de Identificação de Range Swing

| Critério          | Condição                                             |
|-------------------|------------------------------------------------------|
| Tempo no range    | Pelo menos 5 dias oscilando no mesmo intervalo       |
| ADX (diário)      | ADX < 20 no gráfico diário                          |
| Bollinger         | Bandas convergindo ou planas no gráfico diário/4h    |
| Pivôs             | Topos e fundos de curto prazo alinhados horizontalmente |
| Volume            | Sem spikes de volume direcional significativos       |

---

## Regras de Entrada

### Compra (suporte do range swing)
1. Preço se aproxima da base do range (suporte estrutural identificado)
2. ADX diário < 20
3. IFR no gráfico 60min < 30 ou diário < 35
4. Confirmar com vela de reversão (martelo, engolfo, inside bar na base)
5. Volume do dia ≤ média — confirmação de acumulação silenciosa
6. STOP: abaixo do suporte estrutural + buffer de 10% do range total

### Venda (resistência do range swing)
1. Preço se aproxima do topo do range
2. ADX diário < 20
3. IFR 60min > 70 ou diário > 65
4. Vela de reversão no topo (doji, estrela cadente, pin bar)
5. STOP: acima da resistência + buffer

---

## Regras de Saída

| Saída              | Condição                                                       |
|--------------------|----------------------------------------------------------------|
| Alvo primário      | Extremo oposto do range (100% do range)                       |
| Alvo parcial       | 50% do range → saída de 50% da posição                       |
| Trailing stop      | Após alvo parcial, trailing de 100 pontos WIN                 |
| Stop loss          | Rompimento confirmado do suporte/resistência com fechamento fora |
| Rompimento range   | ADX diário > 25 por 2 dias seguidos → encerrar posição        |

---

## Filtros Obrigatórios

- **Não operar** quando MME200 no diário está em movimentação acentuada (tendência macro)
- **Respeitar VWAP semanal** — não entrar contra ela
- **Verificar cenário macro:** relatórios econômicos relevantes programados na semana
- **Não operar** na semana do vencimento de contratos futuros (3ª quarta-feira do mês)

---

## Plano de Robôs

| Robô       | Descrição                                           | Status   |
|------------|-----------------------------------------------------|----------|
| `LS_01`    | Range 60min com Bollinger + pivot detection         | Pendente |
| `LS_02`    | Range diário com IFR + ADX filtro                  | Pendente |
| `LS_03`    | Range + trailing automático (exit swing)           | Pendente |
| `LS_04`    | Range + filtro VWAP semanal + média 200             | Pendente |
| `LS_05`    | Swing range com saída híbrida (parcial + trailing) | Pendente |
| `LS_06–50` | Variações de parâmetros e ativos                   | Backlog  |

---

## Parâmetros de Risco (bloco padrão obrigatório)

```ntsl
input UsarGestaoRisco      = true;
input UsarHardLock         = true;
input SaldoConta           = 10000.0;
input RiscoDiaPct          = 1.5;
input RiscoSemanaPct       = 3.0;
input MaxStopsConsecutivos = 2;
input ValorPorPonto        = 0.2;
input DiaSemanaReset       = 2;
```

---

## Referências

- Teoria base: [teoria_tendencia.md](../../estudo_teorias/teoria_tendencia.md)
- Pivôs: [teoria_tendencia_pivots.md](../../estudo_teorias/teoria_tendencia_pivots.md)
- VWAP: [teoria_vwap.md](../../estudo_teorias/teoria_vwap.md)
- Laboratorio Bollinger: [../LABORATORIO_INDICADORES/BOLLINGER/](../LABORATORIO_INDICADORES/BOLLINGER/)
