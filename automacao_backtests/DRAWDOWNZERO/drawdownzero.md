# Grupo DRAWDOWNZERO (DZ)

## Objetivo
Robôs projetados para manter o **drawdown próximo de zero** — a curva de capital deve subir de forma suave, sem quedas expressivas, mesmo que o lucro total seja mais modesto.

A premissa é: **capital protegido = capital disponível amanhã**. Melhor ganhar pouco e consistente do que ganhar muito e devolver tudo.

---

## Filosofia do Grupo

| Característica | Grupos comuns | **DRAWDOWNZERO** |
|----------------|--------------|-----------------|
| Prioridade | Lucro total | **Preservação de capital** |
| Número de operações | Alto | Baixo (seletividade máxima) |
| Stop | Por estrutura | Apertado — sai cedo se errar |
| Alvo | R:R ≥ 1:2 | Pequeno mas certo (R:R 1:1.5 aceitável) |
| Break-even | Condicional | **Obrigatório** — ativa sempre que possível |
| Trailing | Variável | Agressivo — não devolve nada |
| Encerramento diário | Por HardLock | Fecha tudo ao 1º stop no dia |

> **Regra de ouro:** ao primeiro sinal de reversão contra a posição, sai.
> Não "aguenta" o trade — preservação é mais importante que alvo.

---

## Critérios de Parada Imediata (além do HardLock padrão)

```
1. HardLock: 1 stop no dia → encerra o dia (MaxStopsConsecutivos = 1)
2. Se o preço voltou para o preço de entrada → break-even imediato
3. Alvo reduzido: metade do stop como alvo mínimo
4. Só opera em janelas de alta liquidez: 09:05–10:30 e 14:00–16:00
```

---

## Indicadores Utilizados

| Indicador | Função |
|-----------|--------|
| **IFR(9)** | Gatilho de entrada (extremo + retorno) |
| **MME200** | Filtro — só opera a favor da tendência maior |
| **ATR(14)** | Dimensiona stop (curto: ATR × 0.8) |
| **Volume** | Filtra entradas sem liquidez |
| **Hora de abertura** | Janela de operação permitida |

---

## Estrutura dos Robôs DZ

```
DZ_01 — BE imediato (40 pts) + trailing 25 pts + 1 stop fecha o dia
DZ_02 — IFR extremo + alvo fixo conservador (60 pts) + stop 40 pts
DZ_03 — Candle de força + break-even instantâneo após entrada + trailing
DZ_04 — Horário restrito (9:05–10:30) + IFR + MME200 + fechamento automático
```

---

## Critério de Aprovação no Backtest

| Métrica | Mínimo | Ideal |
|---------|--------|-------|
| Drawdown máximo | < 8% | < 4% |
| Profit Factor | > 1.3 | > 1.8 |
| Taxa de acerto | > 60% | > 70% |
| Curva de capital | Monotônica crescente | Sem vales profundos |
| Sequência máx. de stops | ≤ 2 | 1 |

> **Nota:** para este grupo, drawdown máximo < 8% é inegociável.
> Um resultado com PF=2.0 mas drawdown de 20% **não passa**.
