# Análise Estatística dos Dados Históricos — WINFUT

> Extraída em 04/04/2026 diretamente dos CSVs da pasta `DadosCandlesBacktest`.
> Base: candles reais de 2020 a 2026 (WIN contínuo — WINFUT).
> Usar como referência para calibrar parâmetros dos robôs.

---

## 1. Disponibilidade de Dados por Período

| Período | 1min | 5min | 15min | 30min | 60min | Candles (60m) |
|---|:---:|:---:|:---:|:---:|:---:|---:|
| 2016_18 | ❌ | ❌ | ❌ | ✅ | ✅ | ~4.415 |
| 2018_20 | ❌ | ❌ | ❌ | ✅ | ✅ | ~4.593 |
| 2020_22 | ❌ | ❌ | ✅ | ✅ | ✅ | 4.625 |
| 2022_24 | ❌ | ❌ | ✅ | ✅ | ✅ | 4.645 |
| 2024_26 | ✅ | ✅ | ✅ | ✅ | ✅ | 5.002 |

**Implicação para Walk-Forward:**
- Treinar em 2020_22 → testar em 2022_24 → testar em 2024_26 (apenas TFs ≥ 15min)
- Para 1min e 5min: base de teste limitada a ~90 dias (2024_26) — resultado ainda inconclusivo

---

## 2. Compressão de Volatilidade — ATR por Período

> A volatilidade caiu drasticamente desde o período pandêmico.
> **Parâmetros de robôs calibrados em 2020_22 estão errados para o mercado atual.**

### ATR mediano (5min ou 15min quando 5min indisponível)

| Período | TF usado | ATR mediano | Variação vs 2024_26 |
|---|---|---:|---:|
| 2020_22 | 15min | **595 pts** | +100% |
| 2022_24 | 15min | **458 pts** | +54% |
| 2024_26 | 5min  | **172 pts** | base |

### ATR mediano por TF — 2024_26 (referência atual)

| TF | ATR mediano |
|---|---:|
| 5min | 172 pts |
| 15min | 297 pts |
| 30min | 430 pts |
| 60min | 597 pts |

---

## 3. SL/TP Calibrados — WINFUT 2024_26

> Baseado em ATR × 1.2 = SL conservador (não stop por ruído)
> Ticket mínimo = 5 pts. Todos arredondados para múltiplos de 5.

| TF Gatilho | ATR med | SL (1.2x) | TP (RRR 2x) | TP (RRR 2.5x) | TP (RRR 3x) |
|---|---:|---:|---:|---:|---:|
| **5min**  | 172 | **205 pts** | **410 pts** | **510 pts** | **615 pts** |
| **15min** | 297 | **355 pts** | **710 pts** | **890 pts** | **1065 pts** |
| **30min** | 430 | **515 pts** | **1030 pts** | **1290 pts** | **1545 pts** |
| **60min** | 597 | **715 pts** | **1430 pts** | **1790 pts** | **2145 pts** |

> **Atenção:** o `skill_WIN_caracteristicas.md` indica SL conservador = 150 pts para 5min.
> O dado real mostra ATR = 172 pts → SL mínimo seguro = **205 pts** no mercado atual.
> SL de 150 pts seria menor que o ATR mediano — stop muito justo para 2024_26.

---

## 4. Sazonalidade por Hora — Volume e Range (5min, 2024_26)

> Base: 41.496 candles operacionais (09h–17h), ~2 anos de pregões.

| Hora | Vol mediano | Vol relativo | Range mediano | n candles |
|---|---:|---:|---:|---:|
| **09h** | 5.547M | **165%** | 211 pts | 4.577 |
| **10h** | 7.744M | **231%** ⬆️ | 256 pts | 4.603 |
| **11h** | 5.592M | **167%** | 207 pts | 4.608 |
| **12h** | 3.586M | 107% | 153 pts | 4.608 |
| **13h** | 2.771M | 83% | 127 pts | 4.620 |
| **14h** | 2.806M | 84% | 125 pts | 4.620 |
| **15h** | 2.614M | 78% | 118 pts | 4.620 |
| **16h** | 2.259M | 67% | 106 pts | 4.620 |
| **17h** | 1.439M | 43% ⬇️ | 96 pts | 4.620 |

**Janelas operacionais:**
- `09h15–12h` → volume máximo, maior range = ideal para momentum/tendência
- `13h–15h` → volume abaixo da média, menor range = scalp ou setups muito qualificados
- `16h–17h40` → volume caindo = saídas e trailing, evitar novas entradas

---

## 5. Distribuição F=MA — Candles Qualificados por Threshold

> Base: 5min, 2024_26, horário operacional. Volume médio = referência para ratio.

| Threshold | % candles acima | n candles (de 41.496) |
|---|---:|---:|
| F ≥ 40 | 41.2% | 17.080 |
| F ≥ 50 | 32.3% | 13.413 |
| **F ≥ 60** | **25.7%** | **10.681** |
| F ≥ 70 | 20.7% | 8.573 |
| F ≥ 80 | 16.9% | 6.997 |

| Filtro de volume | % candles acima |
|---|---:|
| Vol ≥ 1.5× média | 19.3% |
| Vol ≥ 2.0× média | 8.8% |

**Implicação:** F ≥ 60 com Vol ≥ 1.5× → estimativa de ~5–6% dos candles.
É um filtro seletivo: gera poucos sinais por sessão, mas cada um tem contexto forte.

---

## 6. Follow-Through após F=MA ≥ 60 (5min, 2024_26)

> "O próximo candle vai na mesma direção do sinal?"
> Mede a qualidade do momentum — se a taxa for = 50% é aleatório.

| Hora | Follow-through | Qualidade |
|---|---:|---|
| **09h** | 50.5% | ⚠️ Quase aleatório |
| **10h** | 49.9% | ❌ Aleatório |
| **11h** | 50.2% | ⚠️ Quase aleatório |
| **12h** | 55.1% | 🟡 Moderado |
| **13h** | 55.7% | 🟡 Moderado |
| **14h** | 55.4% | 🟡 Moderado |
| **15h** | **60.5%** | ✅ Bom |
| **16h** | **58.2%** | ✅ Bom |
| **17h** | **64.9%** | ✅ Melhor |
| **GERAL** | **52.5%** | ⚠️ Marginalmente acima do aleatório |

> **Descoberta contraintuitiva:** de manhã (09–11h) o sinal F=MA tem qualidade
> quase aleatória, apesar do maior volume. À tarde (15–16h) o follow-through
> é significativamente melhor — o mercado é mais direcional com menos ruído.

---

## 7. Percentis do Range (5min, 2024_26)

Para dimensionar SL sem usar o ATR:

| Percentil | Range |
|---|---:|
| P25 | 104 pts |
| **P50 (mediana)** | **147 pts** |
| P75 | 217 pts |
| **P90** | **310 pts** |
| P95 | 384 pts |

> P75 ≈ 217 pts → SL de 220 pts cobre 75% dos candles (não é stopado por ruído intracandle)
> P90 ≈ 310 pts → SL de 310 pts é muito conservador mas raramente é stopado por volatilidade normal

---

## 8. Implicações Práticas para os Robôs

### 8.1 Recalibrar parâmetros para o mercado 2024_26

| Parâmetro | Valor antigo (skill_WIN) | Valor real (2024_26) |
|---|---|---|
| SL conservador 5min | 150 pts | **205 pts** |
| SL conservador 15min | 250 pts | **355 pts** |
| ATR(14) médio 5min | ~146 pts | **172 pts** |
| ATR(14) médio 60min | ~492 pts | **597 pts** |

### 8.2 Filtro de hora adaptativo

```pascal
// De manhã (09h15-12h): mercado ruidoso → threshold mais alto
// À tarde (13h-16h30): mercado mais direcional → threshold menor

if Time() >= 90000 and Time() < 120000 then
  fForcaMinima := 70.0   // manhã: mais exigente
else if Time() >= 130000 and Time() < 163000 then
  fForcaMinima := 58.0;  // tarde: follow-through melhor
```

### 8.3 Usar ATR dinâmico nos robôs

```pascal
// Em vez de hardcoded:
fSL := BuyPrice - 150 * MinPriceIncrement;

// Usar ATR calculado em tempo real:
fATR := ATR(14);
fSL  := BuyPrice - fATR * 1.2;
if fSL < BuyPrice - 350 * MinPriceIncrement then  // cap máximo
  fSL := BuyPrice - 350 * MinPriceIncrement;
```

### 8.4 Walk-Forward por período disponível

```
Treino: 2020_22 (15min/30min/60min) → Teste: 2022_24
Treino: 2022_24 (15min/30min/60min) → Teste: 2024_26
Resultado teste ≥ 60% do treino = aprovado (ver skill_probabilidade_operacional.md)
```

### 8.5 Faixa de SL por período histórico (para robustez cross-period)

Se o robô deve funcionar em diferentes regimes de volatilidade:
```
SL mínimo válido  = ATR(14) × 0.8   (cobre 50% dos candles sem ruído)
SL recomendado    = ATR(14) × 1.2   (cobre 75% dos candles)
SL máximo útil    = ATR(14) × 1.8   (cobre ~90% dos candles)
```
Robô com SL = ATR × 1.2 funcionará automaticamente em qualquer período
pois o ATR se adapta — não precisa recalibrar manualmente.

---

## 9. Resumo Executivo — O Que Fazer Diferente

| # | Ação | Impacto |
|---|---|---|
| 1 | Substituir SL fixo por `ATR(14) × 1.2` nos robôs | Alto — adapta à compressão de vol |
| 2 | Usar F ≥ 70 de manhã, F ≥ 58 à tarde | Médio — melhora qualidade dos sinais |
| 3 | Evitar entradas novas após 16h (saídas apenas) | Médio — volume e follow-through ruins |
| 4 | Walk-Forward obrigatório antes de conta real | Alto — detecta overfitting |
| 5 | SL mínimo = 205 pts no 5min (não 150) | Alto — evita stop por ruído |
| 6 | Tripletas: 30/15/5 e 60/30/15 têm mais dados históricos | Médio — mais confiança estatística |
| 7 | Nunca calibrar sobre 2020_22 isolado — vol 100% maior | Alto — overfitting a regime anormal |
