# Skill: Probabilidade Operacional — Matemática do Trade

> Como usar matemática e estatística para saber se um robô realmente funciona,
> quanto arriscar por trade e se o resultado do backtest é sorte ou consistência.
>
> **Linguagem simples:** cada conceito tem uma explicação do tipo "na prática isso significa..."

---

## 1. Esperança Matemática — "Quanto ganho em média por trade?"

**O que é:** o valor esperado de cada operação levando em conta ganhos e perdas.

$$E = p_{acerto} \times \bar{G} - p_{erro} \times \bar{P}$$

Onde:
- $p_{acerto}$ = % de trades vencedores (ex: 0.34 = 34%)
- $\bar{G}$ = ganho médio em pontos
- $p_{erro}$ = 1 - $p_{acerto}$
- $\bar{P}$ = perda média em pontos (valor positivo)

**Na prática:** se E > 0 o sistema ganha dinheiro no longo prazo.
Se E < 0 você está pagando para operar.

**Exemplo real (60m, 123 trades):**
```
E = 0.34 × 146 - 0.66 × 53
E = 49.6 - 35.0 = +14.6 pts/trade
```
Isso significa: em média você ganha 14.6 pts por operação. Com 120 trades/ano → +1.752 pts/ano.

**Código Python:**
```python
def esperanca(trades_pts: list) -> float:
    ganhos = [t for t in trades_pts if t > 0]
    perdas = [t for t in trades_pts if t < 0]
    p = len(ganhos) / len(trades_pts)
    media_g = sum(ganhos) / len(ganhos) if ganhos else 0
    media_p = abs(sum(perdas) / len(perdas)) if perdas else 0
    return round(p * media_g - (1 - p) * media_p, 2)
```

---

## 2. Kelly — "Quanto por trade sem quebrar a banca?"

**O que é:** fórmula matemática que calcula o tamanho ideal da posição para
maximizar o crescimento da conta sem risco de ruína.

$$K = p - \frac{(1-p)}{r}$$

Onde $r$ = RRR médio realizado (ganho médio / perda média).

**Na prática:**
- K = 10% → arriscar 10% do capital por trade
- K negativo → sistema perdedor, não operar
- **Half-Kelly** (K/2) → mais seguro, cresce mais devagar mas sobrevive drawdowns

**Regra de ouro: usar sempre Half-Kelly (K/2).**

**Exemplo real (60m):**
```
K = 0.34 - (0.66 / 2.75) = 0.34 - 0.24 = 0.10 = 10%
Half-Kelly = 5% do capital por trade
```
Com conta de R$20.000 → arriscar R$1.000 por trade → ~50 pts de SL no WIN = 1 contrato.

**Código Python:**
```python
def kelly(win_rate: float, rrr: float) -> float:
    k = win_rate - (1 - win_rate) / rrr
    return max(0.0, round(k, 4))

def half_kelly(win_rate: float, rrr: float) -> float:
    return kelly(win_rate, rrr) / 2
```

---

## 3. Intervalo de Confiança do Profit Factor — "Posso confiar nesse PF?"

**O que é:** com poucos trades, o Profit Factor calculado pode ser sorte.
O IC 95% mostra o intervalo onde o PF "real" provavelmente está.

**Na prática:** se o IC 95% inclui o valor 1.0 (ex: IC = [0.9, 1.6]), o sistema
pode ser um sistema perdedor — você não tem provas suficientes de que funciona.

**Fórmula aproximada (método de bootstrap simplificado):**
$$IC_{95\%} \approx PF \pm 1.96 \times \frac{PF}{\sqrt{n}}$$

Onde $n$ = número de trades.

**Exemplo real (123 trades, PF = 1.38):**
```
Margem = 1.96 × 1.38 / √123 = 1.96 × 0.124 = 0.24
IC 95% = [1.14, 1.62]
```
O limite inferior (1.14) está acima de 1.0 → sistema lucrativo com 95% de confiança.
Mas 1.14 é marginal → precisamos de mais trades para ter certeza.

**Código Python:**
```python
import math
def ic_profit_factor(pf: float, n: int, confianca: float = 0.95) -> tuple:
    z = 1.96 if confianca == 0.95 else 2.576  # 95% ou 99%
    margem = z * pf / math.sqrt(n)
    return round(pf - margem, 2), round(pf + margem, 2)
```

**Tabela de trades mínimos por PF alvo:**

| PF real estimado | Trades para IC inferior > 1.0 |
|---|---|
| 1.3 | ~200 trades |
| 1.5 | ~80 trades |
| 1.7 | ~50 trades |
| 2.0 | ~30 trades |

---

## 4. Teste de Hipótese — "Isso é sorte ou sistema?"

**O que é:** verificar se o resultado do backtest é estatisticamente diferente
de um sistema aleatório (que ganha 50% com RRR = 1.0).

**Na prática:** a pergunta é: "Se eu jogasse uma moeda, teria resultado igual?"
Se a resposta for sim (p-value > 0.05) → pode ser sorte.

**Teste simples (proporção binomial):**

$$Z = \frac{p_{obs} - 0.5}{\sqrt{0.5 \times 0.5 / n}}$$

Se |Z| > 1.96 → rejeita H₀ (resultado não é aleatório, p < 0.05)

**Exemplo real (123 trades, 42 ganhos = 34%):**
```
Z = (0.34 - 0.50) / √(0.25 / 123)
Z = -0.16 / 0.0451 = -3.55
|Z| = 3.55 > 1.96 → significativo!
```
O sistema perde MAIS que o aleatório em frequência — mas o RRR alto compensa.
O teste correto não é só a taxa de acerto, mas a **esperança matemática**.

**Teste da esperança:**
```
H₀: E = 0 (sistema aleatório)
H₁: E > 0 (sistema lucrativo)
t = E_médio / (std_trades / √n)
Se t > 1.645 → rejeita H₀ com 95% de confiança
```

**Código Python:**
```python
import math, statistics

def teste_hipotese_esperanca(trades_pts: list) -> dict:
    n = len(trades_pts)
    media = statistics.mean(trades_pts)
    std = statistics.stdev(trades_pts)
    t = media / (std / math.sqrt(n))
    p_value_aprox = 1 - 0.95 if t > 1.645 else "não significativo"
    return {
        "n": n, "media_pts": round(media, 1),
        "t_stat": round(t, 3),
        "significativo_95pct": t > 1.645
    }
```

---

## 5. Sazonalidade — "Qual o melhor horário/dia para operar?"

**O que é:** descobrir em quais horas do dia ou dias da semana o robô performa melhor.

**Na prática:** um robô que ganha de manhã e perde à tarde pode ser configurado
para só operar de 9h às 12h — melhorando muito os resultados.

**Como calcular:**
```python
from collections import defaultdict

def sazonalidade_por_hora(trades: list[dict]) -> dict:
    """trades: lista de dicts com 'hora' (int 9..17) e 'resultado' (pts)"""
    por_hora = defaultdict(list)
    for t in trades:
        por_hora[t['hora']].append(t['resultado'])
    return {
        hora: {
            'n': len(rs),
            'media': round(sum(rs)/len(rs), 1),
            'acerto': round(sum(1 for r in rs if r > 0)/len(rs)*100, 1)
        }
        for hora, rs in sorted(por_hora.items())
    }
```

**Atenção:** com menos de 20 trades por hora, os números não são confiáveis.

---

## 6. Walk-Forward — "O robô funciona fora do período testado?"

**O que é:** testar o robô em dados que ele não "viu" durante o desenvolvimento.

**Na prática:** se você calibrou o robô com dados de 2024 e testou com dados de
2024, qualquer resultado bom pode ser ajuste nos dados históricos (overfitting).
Walk-Forward testa em períodos futuros que o robô não usou para ser criado.

**Como fazer (manual, sem código):**
```
Dados disponíveis: jan/2024 → mar/2026 (26 meses)

Passo 1: Treinar em jan/2024–jun/2024 (6 meses)
          Testar em jul/2024–ago/2024 (2 meses)

Passo 2: Treinar em jan/2024–ago/2024 (8 meses)
          Testar em set/2024–out/2024 (2 meses)

... repetir até esgotar os dados ...

Se o resultado dos períodos de TESTE for parecido com o de TREINO → robusto.
Se cair muito no teste → overfitting → não usar em conta real.
```

**Regra prática:** resultado do período de teste deve ser ≥ 60% do resultado do treino.

---

## 7. Monte Carlo — "Qual o pior drawdown que posso esperar?"

**O que é:** simular milhares de ordens aleatórias dos trades históricos para ver
qual o pior cenário de sequência de perdas.

**Na prática:** você tem 123 trades. O Monte Carlo embaralha esses 123 trades
10.000 vezes e calcula o drawdown máximo de cada sequência. Com isso você sabe:
"Em 95% das possíveis sequências, o pior drawdown foi ≤ X pontos."

**Código Python:**
```python
import random, statistics

def monte_carlo(trades_pts: list, n_simulacoes: int = 10000) -> dict:
    max_dds = []
    for _ in range(n_simulacoes):
        seq = random.sample(trades_pts, len(trades_pts))
        capital = 0
        pico = 0
        max_dd = 0
        for t in seq:
            capital += t
            if capital > pico:
                pico = capital
            dd = pico - capital
            if dd > max_dd:
                max_dd = dd
        max_dds.append(max_dd)
    max_dds.sort()
    return {
        "dd_mediano":  round(max_dds[len(max_dds)//2], 0),
        "dd_95pct":    round(max_dds[int(len(max_dds)*0.95)], 0),
        "dd_99pct":    round(max_dds[int(len(max_dds)*0.99)], 0),
    }
```

**Como usar o resultado:**
```
dd_mediano = 500 pts → em metade das sequências o drawdown foi até 500 pts
dd_95pct   = 800 pts → em 95% das sequências o drawdown foi até 800 pts

Se dd_95pct > 15% do capital → reduzir o tamanho da posição (usar menos Kelly)
```

---

## 8. Critérios mínimos para operar em conta real

Antes de colocar um robô para operar com dinheiro real, todos esses critérios
devem ser atendidos:

| Critério | Mínimo | Ideal |
|---|---|---|
| Número de trades | ≥ 100 | ≥ 200 |
| Período testado | ≥ 90 dias | ≥ 180 dias |
| Esperança matemática | > 0 | > 10 pts/trade |
| Profit Factor (PF) | ≥ 1.3 | ≥ 1.5 |
| IC 95% inferior do PF | > 1.0 | > 1.15 |
| Teste de hipótese | t > 1.645 | t > 2.0 |
| Walk-Forward | resultado teste ≥ 60% do treino | ≥ 80% |
| Monte Carlo dd 95% | ≤ 15% do capital | ≤ 10% |
| Kelly calculado | > 0% | > 5% |

---

## 9. Script completo de análise

> Rodar antes de qualquer decisão de "operar ou não":

```bash
# Exportar operações do Profit → CSV → rodar:
python scripts/analisa_backtest_profit.py backtest_resultados/PASTA/
```

O script já calcula automaticamente todos os itens acima.
**Nunca colar CSV no chat** — colar apenas as 10 linhas de resultado do script.

---

## 10. Resumo visual para decisão rápida

```
SISTEMA PASSA SE:
  ✅ E > 0          (esperança positiva)
  ✅ PF > 1.3       (mais ganho que perda)
  ✅ IC_inf > 1.0   (com 95% de confiança ainda é lucrativo)
  ✅ t > 1.645      (resultado não é aleatório)
  ✅ Walk-Forward ok (funciona fora do período de treino)

SISTEMA REPROVADO SE QUALQUER UM FOR ❌
  → Ajustar parâmetros ou descartar
  → NUNCA colocar em conta real sem todos os ✅
```
