# LATERALIZACAO_DAYTRADE — Estratégias de Range Intradiário

## Filosofia

Explorar mercados que oscilam entre suporte e resistência dentro da sessão do dia.
Quando o mercado não tem tendência definida (ADX baixo), a tendência **é a lateralidade** — operar reversão nos extremos do range.

- **Ativo alvo (Profit):** WIN (minicontrato de índice B3)
- **Timeframes:** 5min, 15min, 30min
- **Tipo de operação:** Reversão nos extremos do range intradiário
- **Meta:** Taxa de acerto > 65%, relação risco/retorno mínima 1:2

---

## Critérios de Identificação de Range

| Critério          | Condição                                      |
|-------------------|-----------------------------------------------|
| ADX               | ADX < 20 (sem tendência direcionada)          |
| Bandas Bollinger  | Preço dentro das bandas, bandas planas        |
| IFR/RSI           | Oscilando entre 30–70 sem extremos persistentes |
| Velas             | Sem sequência de 3+ velas na mesma direção    |
| VWAP              | Preço cruzando a VWAP com frequência          |

---

## Regras de Entrada

### Compra (reversão no suporte do range)
1. ADX < 20 (confirmado nos últimos 5 períodos)
2. Preço toca ou viola a Banda Bollinger inferior (Desvio 2.0)
3. IFR < 35 (sobrevendido no contexto lateral)
4. Vela sinalizadora com sombra longa para baixo ou engolfo de alta
5. Volume da vela de entrada ≥ média dos últimos 5 candles
6. STOP: abaixo da mínima da vela sinalizadora

### Venda (reversão na resistência do range)
1. ADX < 20
2. Preço toca ou viola a Banda Bollinger superior (Desvio 2.0)
3. IFR > 65 (sobrecomprado no contexto lateral)
4. Vela sinalizadora com sombra longa para cima ou engolfo de baixa
5. Volume ≥ média 5 candles
6. STOP: acima da máxima da vela sinalizadora

---

## Regras de Saída

| Saída              | Condição                                                           |
|--------------------|--------------------------------------------------------------------|
| Alvo primário      | Oposto do range (banda ao alvo)                                    |
| Alvo VWAP          | Cruzamento da VWAP diária (saída parcial 50%)                      |
| Stop               | Rompimento da banda oposta (1 vela de fechamento fora do range)    |
| Tempo              | Fechar posição aberta nos últimos 15 min antes das 17h30           |
| ADX > 25           | Saída imediata — range foi rompido, tendência se formou            |

---

## Filtros Obrigatórios

- **Não operar** após rompimento de suporte/resistência claro (pivô diário)
- **Não operar** nas primeiras 2 velas do dia (range ainda se formando)
- **Não operar** contra VWAP semanal (peso institucional)
- **Verificar horário:** evitar 09h00–09h30 (abertura turbulenta)

---

## Plano de Robôs

| Robô       | Descrição                                         | Status  |
|------------|---------------------------------------------------|---------|
| `LD_01`    | Range puro com Bollinger + IFR                   | Pendente |
| `LD_02`    | Range + ADX + volume acima da média              | Pendente |
| `LD_03`    | Range + VWAP como pivô central                   | Pendente |
| `LD_04`    | Range + saída por tempo (horário encerramento)   | Pendente |
| `LD_05`    | Range com dupla confirmação (Bollinger + estocástico) | Pendente |
| `LD_06–50` | Variações de parâmetros e filtros adicionais     | Backlog  |

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
- Volume: [teoria_volume.md](../../estudo_teorias/teoria_volume.md)
- VWAP: [teoria_vwap.md](../../estudo_teorias/teoria_vwap.md)
- Bollinger: [LABORATORIO_INDICADORES/BOLLINGER/](../LABORATORIO_INDICADORES/BOLLINGER/)
