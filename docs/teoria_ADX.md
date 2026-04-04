# Teoria do ADX (Average Directional Index)

O **ADX (Average Directional Index)** é um indicador de análise técnica criado por J. Welles Wilder, utilizado para medir a força de uma tendência, seja ela de alta ou de baixa. Muito usado no day trade brasileiro, especialmente no WIN (mini índice B3), o ADX não indica direção, mas sim a intensidade da tendência.

---

## Como funciona o ADX?

O ADX é composto por três linhas:

| Linha         | O que mostra                        |
|-------------- |-------------------------------------|
| **+DI**       | Força dos movimentos de alta        |
| **-DI**       | Força dos movimentos de baixa       |
| **ADX**       | Força da tendência (sem direção)    |

- **ADX alto** (acima de 25): tendência forte (pode ser alta ou baixa)
- **ADX baixo** (abaixo de 20): mercado lateral, sem tendência definida

> **Dica prática:**
> - ADX subindo: tendência está ganhando força
> - ADX caindo: tendência está perdendo força

---

## Fórmula do ADX (resumida)

1. Calcule +DI e -DI (Directional Indicators)
2. Calcule o valor absoluto da diferença entre +DI e -DI
3. Divida pelo total de movimento direcional
4. Suavize com média móvel (geralmente 14 períodos)

> No Profit, basta usar a função nativa `ADX(periodo)`

---

## Parâmetros mais usados

| Parâmetro | Valor padrão | Observação                  |
|-----------|-------------|-----------------------------|
| Período   | 14          | Mais sensível: menor valor  |
| Timeframe | 5min, 15min | Day trade: 5min ou 15min    |

---

## Interpretação prática

- **ADX < 20:** mercado lateral, evite operar tendência
- **ADX > 25:** tendência forte, buscar operações a favor
- **+DI acima de -DI:** tendência de alta
- **-DI acima de +DI:** tendência de baixa

### Exemplo prático (WIN 5min)

1. ADX cruza acima de 25 → tendência forte
2. +DI acima de -DI → buscar compras
3. -DI acima de +DI → buscar vendas

---

## Estratégias com ADX

| Estratégia                  | Sinal de entrada                        |
|---------------------------- |-----------------------------------------|
| Seguir tendência            | ADX > 25 e +DI > -DI (compra)           |
|                             | ADX > 25 e -DI > +DI (venda)            |
| Evitar falso rompimento     | Não operar se ADX < 20                  |
| Filtro de lateralidade      | Só operar price action se ADX > 20      |

---

## Vantagens e Limitações

**Vantagens:**
- Ajuda a filtrar períodos de lateralidade
- Evita entradas em falso rompimento
- Fácil de combinar com outros indicadores (MME, IFR)

**Limitações:**
- Não mostra direção, apenas força
- Pode atrasar sinais em reversões rápidas
- Falso positivo em movimentos curtos

---

## Como usar no Profit (NTSL)

```ntsl
if ADX(14) > 25 and +DI(14) > -DI(14) then
	BuyAtMarket;
```

---

## Referências
- Livro: New Concepts in Technical Trading Systems — J. Welles Wilder
- [Investopedia: ADX](https://www.investopedia.com/terms/a/adx.asp)
- Manual ProfitChart: função ADX