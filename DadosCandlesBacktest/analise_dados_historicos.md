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

## 9. Foco 2025 — Análise Específica (Base de Calibração para 2026)

### 9.1 ATR 2025 vs 2024 — volatilidade cresceu levemente

| TF | ATR 2024 | ATR 2025 | Variação |
|---|---:|---:|---:|
| 5min | 164 pts | **176 pts** | +7.3% |
| 15min | 292 pts | **304 pts** | +4.3% |
| 30min | 418 pts | **444 pts** | +6.2% |
| 60min | 580 pts | **613 pts** | +5.7% |

> 2025 foi ligeiramente mais volátil que 2024 em todos os TFs.
> A volatilidade foi estável ao longo do ano (Q1 ≈ Q4: +0.7% de variação).
> **Não houve regime anormal em 2025** — base confiável para projetar 2026.

### 9.2 Evolução Mensal ATR 15min — 2025

| Mês | ATR mediano | Observação |
|---|---:|---|
| Jan | 280 pts | baseline |
| Fev | 288 pts | estável |
| Mar | 328 pts | leve alta (fim de trimestre) |
| **Abr** | **423 pts** | pico anual (máximo) |
| Mai | 328 pts | normaliza |
| Jun–Set | 253–305 pts | período mais calmo do ano |
| Out–Nov | 266–271 pts | mínimos anuais |
| Dez | 365 pts | volatilidade sazonal de final de ano |

> **Implicação para SL:** Abril tende a ser o mês mais volátil — ATR 40% acima da média.
> Usar SL mais largo ou reduzir tamanho de posição em Abril.

### 9.3 Follow-Through 2025 por Hora

| Hora | Follow-Through | Qualidade |
|---|---:|---|
| 09h–11h | 48–49% | ❌ Ruído (abaixo de aleatório) |
| 12h–13h | 53–54% | ⚠ Marginal |
| 14h | 57.0% | 🟡 Médio |
| **15h** | **61.3%** | ✅ Bom |
| **16h** | **61.5%** | ✅ Bom |
| **17h** | **64.2%** | ✅ Melhor do dia |

> O follow-through de manhã (48–49%) é **pior que aleatório** em 2025.
> Isso significa: sinais F=MA entre 9h e 11h tendem a reverter no próximo candle.
> A janela de qualidade real começa às **14h** e melhora progressivamente.

### 9.4 Range de Operação Proposto — 2026

> **Metodologia:** ATR mediano 2025 × 1.2 = SL. Projeção estável pois Q1≈Q4 em 2025.
> Sem dados de 2026 ainda — usar 2025 como referência direta.

| TF | ATR ref. | SL 2026 | TP RRR 2.0 | TP RRR 2.5 | Range P50 candle |
|---|---:|---:|---:|---:|---:|
| **5min** | 176 pts | **210 pts** | **420 pts** | **525 pts** | 152 pts |
| **15min** | 304 pts | **365 pts** | **730 pts** | **910 pts** | 261 pts |
| **30min** | 444 pts | **535 pts** | **1.070 pts** | **1.340 pts** | 377 pts |
| **60min** | 613 pts | **735 pts** | **1.470 pts** | **1.840 pts** | 538 pts |

> O **Range P50** é o range mediano de um candle — útil para checar se o alvo é realista.
> Ex no 15min: range mediano = 261 pts. TP de 730 pts = ~2.8 candles de movimento médio.
> Isso é alcançável dentro de uma sessão.

---

## 10. Análise 3TF Confluência — SL e SG Mínimos (2025, simulação barra a barra)

> Método: para cada sinal F≥60 + Vol×1.5 + confluência 3TF (proxy de médias),
> simulação barra a barra identificando qual nível é tocado primeiro — SL ou SG.
> Filtro horário: **apenas tarde 14h–17h** (follow-through real confirmado).
> Fonte: WINFUT 2025 real, `DadosCandlesBacktest/2024_26`.

### 10.1 Resultados por Tripleta

| Tripleta | Sinais/ano | ATR gatilho | SL ótimo | SG ótimo | RRR | Assert. | Esperança |
|---|---:|---:|---:|---:|---:|---:|---:|
| **60 / 30 / 15** | 11 | 285 pts | **285 pts** (×1.0) | **427 pts** | 1.5× | 50% | **+71 pts/op** |
| **30 / 15 / 5** ⭐ | 130 | 145 pts | **145 pts** (×1.0) | **290 pts** | 2.0× | 42% | **+38 pts/op** |
| **15 / 10 / 5** | 164 | 140 pts | **140 pts** (×1.0) | **350 pts** | 2.5× | 37% | **+40 pts/op** |

> ⭐ Tripleta recomendada para o projeto: melhor equilíbrio frequência × assertividade.

### 10.2 SL Mínimo Candle — Distância Close→Low do Gatilho

> O candle F≥60 tem uma sombra inferior. Se o SL estiver dentro dela,
> o reteste do Low dispara o stop antes do trade se desenvolver.

| TF gatilho | Close-Low P25 | Close-Low P50 | Close-Low P75 | Implicação |
|---|---:|---:|---:|---|
| **5min** | 155 pts | **196 pts** | 261 pts | SL < 196 = stop frequente pelo próprio candle |
| **15min** | 401 pts | **537 pts** | 750 pts | SL < 400 = quase certo de ser parado no candle |

### 10.3 Dois modos de SL — Apertado vs Estrutural

```
MODO 1 — SL APERTADO (padrão recomendado):
  SL = ATR × 1.0 (145pts no 5min)
  Aceita que ~50% dos trades sejam parados por ruído do candle
  O RRR 2.0× compensa: 0.42 × 290 - 0.58 × 145 = +38pts matematicamente positivo
  Vantagem: menos capital em risco por trade

MODO 2 — SL ESTRUTURAL (fora do ruído do candle):
  SL = Close - Low do candle gatilho + buffer 10pts
  Equivale a ~200-265pts no 5min (P50 a P75)
  Nunca stopado pelo próprio candle; exige SG ≥ 500pts que o mercado alcança menos
  Vantagem: quase zero stops prematuros; desvantagem: risco maior por trade
```

### 10.4 Tabela SL × Assertividade × Esperança (30/15/5, tarde 2025)

| SL | RRR 1.5× (SG=SL×1.5) | RRR 2.0× (SG=SL×2.0) | RRR 2.5× (SG=SL×2.5) | RRR 3.0× (SG=SL×3.0) |
|---|---|---|---|---|
| **115 pts** (ATR×0.8) | 48% / **+24 pts** | 39% / +21 pts | 35% / +27 pts | 31% / +26 pts |
| **145 pts** (ATR×1.0) ⭐ | 50% / +35 pts | **42% / +38 pts** ⭐ | 36% / +36 pts | 30% / +30 pts |
| **175 pts** (ATR×1.2) | 46% / +27 pts | 39% / +29 pts | 31% / +16 pts | 27% / +12 pts |
| **216 pts** (ATR×1.5) | 45% / +28 pts | 36% / +15 pts | 29% / +0 pts | 23% / -14 pts |

> ⭐ **Ponto ótimo:** SL=145 / SG=290 / RRR 2.0× — maior esperança matemática (+38 pts/op).
> SL menor que ATR×0.8 (115 pts) → esperança ainda positiva, mas margem muito estreita.
> SL maior que ATR×1.5 (216 pts) → assertividade não sobe o suficiente para compensar.

---

## 11. Guia Operacional 2026 — Síntese Completa

> Todas as recomendações abaixo derivam da análise de dados reais 2024–2025.
> Nenhum dado de 2026 disponível ainda — usar 2025 como proxy direto.

### 11.1 Parâmetros de Entrada

```
FILTRO DE FORÇA (F=MA):
  Tarde 14h–17h: F ≥ 60 + Vol ≥ 1.5× média20
  Manhã 09h–12h: F ≥ 70 + Vol ≥ 2.0× média20  ← mais exigente, follow-through ruim de manhã
  Nunca operar F < 60 sem confluência 3TF

CONFLUÊNCIA 3TF OBRIGATÓRIA:
  TF1 (Contexto): preço acima da média(janela_ctx) E média subindo
  TF2 (Direção) : preço acima da média(janela_dir) E média subindo
  TF3 (Gatilho) : candle F≥60 + volume confirmado
  Sem TF1 confirmado → BLOQUEIO ABSOLUTO (veto)

JANELAS NTSL POR TRIPLETA:
  60/30/15 rodando em 15min: iJanelaDir=2, iJanelaCtx=4
  30/15/5  rodando em 5min : iJanelaDir=3, iJanelaCtx=6   ← padrão
  15/10/5  rodando em 5min : iJanelaDir=2, iJanelaCtx=3
```

### 11.2 Parâmetros de Stop e Alvo

```
TRIPLETA 30/15/5 (padrão — WIN 5min):
  SL  = ATR(14) × 1.0  → ~145 pts em 2025 (mínimo viável: ATR×0.8=115pts)
  SG  = ATR(14) × 2.0  → ~290 pts (RRR 2.0×)
  SL em pontos 2026: ~145-160 pts  (projeta +7% de crescimento da vol)
  SG em pontos 2026: ~290-320 pts

TRIPLETA 60/30/15 (estrutural — WIN 15min):
  SL  = ATR(14) × 1.0  → ~285 pts em 2025
  SG  = ATR(14) × 1.5  → ~427 pts (RRR ótimo é 1.5x, não 2.0x!)
  Atenção: apenas 11 sinais/ano — low frequency, high quality

TRIPLETA 15/10/5 (alta frequência — WIN 5min):
  SL  = ATR(14) × 1.0  → ~140 pts em 2025
  SG  = ATR(14) × 2.5  → ~350 pts (RRR ótimo é 2.5x!)
  164 sinais/ano → maior frequência das 3 tripletas

REFERÊNCIA DIRETA EM PONTOS (projeção 2026):
  5min  SL≈145-160pts  TP≈290-320pts
  15min SL≈285-310pts  TP≈430-465pts
  30min SL≈535pts      TP≈1.070pts
  60min SL≈735pts      TP≈1.470pts
```

### 11.3 Gestão de Horários

```
JANELA PROIBIDA:    09h00–09h14  → abertura, spread alto, dados de candle incompletos
JANELA RUÍDO:       09h15–12h00  → follow-through 48–49% (pior que aleatório!)
                                   operar APENAS com F≥70 e confluência perfeita
JANELA MARGINAL:    12h00–13h59  → follow-through 53–54%, volume abaixo da média
JANELA PRIME:       14h00–17h30  → follow-through 61–64%, JANELA PRINCIPAL
JANELA ENCERRAMENTO: 17h30+      → fechar posições abertas; sem novas entradas
```

### 11.4 Sazonalidade Mensal — Ajuste de Risco

```
ABRIL (histórico 2025 e recorrente):
  ATR 15min = 423pts (+40% acima da média anual de 298pts)
  Ação: reduzir tamanho de posição ÷2, ou ampliar SL × 1.4
  Fórmula: SL_abril = ATR(14) × 1.0 × 1.4

JUNHO–SETEMBRO (período mais calmo):
  ATR 15min = 253–305pts (15–30% abaixo da média)
  Ação: SL padrão ATR×1.0 funciona bem; evitar RRR > 2.5× (alvos irreais)

DEZEMBRO (sazonalidade de encerramento):
  ATR 15min = 365pts (levemente acima da média)
  Ação: atenção ao rollover de contratos; usar WINFUT (contínuo) não WINZ25 etc.
```

### 11.5 Walk-Forward — Validação Obrigatória

```
APROVADO se: resultado_teste ≥ 60% × resultado_treino  (PF e Esperança)
REPROVADO  : resultado_teste < 60% → rever parâmetros ou não operar live

Histórico WF do projeto:
  WF1 (2020→2022): PARCIAL (esperança 23%, PF 78%) — regime pandemia não generalizável
  WF2 (2022→2024): APROVADO (esperança 97%, PF 106%) ← estratégia tem lógica real
  WF3 (combined→2024): REPROVADO (esperança 51%, PF 97%) — overfitting detectado

Próximo passo WF: rodar com F=65, Vol×2.0 para tentar aprovação no WF3:
  python scripts/walk_forward_win.py --forca 65 --vol-mult 2.0
```

### 11.6 Gestão de Posição por Número de TFs Confirmados

```pascal
// Score de confiança por alinhamento dos 3 TFs
// Implementar no NTSL como variável de contratos

if bContextoAlta AND bDirecaoAlta AND bGatilhoAlta then
  nContratos := ContratosMaximo   // 3/3 — tamanho cheio
else if bContextoAlta AND bDirecaoAlta then
  nContratos := ContratosBase     // 2/3 — aguardando gatilho (reduzir tamanho)
else
  nContratos := 0;                // TF1 não confirmado → NÃO OPERAR
```

### 11.7 Checklist Pré-Entrada (manual ou automático)

```
[ ] TF1 (Contexto) confirmado na direção? → SEM ISSO: bloqueio
[ ] TF2 (Direção)  confirmado na direção? → SEM ISSO: bloqueio
[ ] Horário entre 14h e 17h30?            → manhã: exige F≥70
[ ] F ≥ 60 (ou ≥ 70 se manhã)?           → → sinal válido
[ ] Volume ≥ 1.5× média 20 (tarde)?       → confirma institucional
[ ] Não é Abril? (volatilidade +40%)      → se Abril: SL × 1.4 ou ÷2 contratos
[ ] SL = ATR(14) × 1.0 definido?          → nunca menor que ATR×0.8
[ ] SG = SL × RRR_ótimo_da_tripleta?      → 30/15/5→2.0x | 15/10/5→2.5x | 60/30/15→1.5x
[ ] WF aprovado para o período atual?     → sem WF: só paper trading
```

---

## 12. Resumo Executivo — O Que Fazer Diferente em 2026

| # | Ação | Impacto | Fonte |
|---|---|---|---|
| 1 | SL = `ATR(14) × 1.0` (não hardcoded) — valor mínimo viável | 🔴 Alto | Seção 10.4 |
| 2 | Operar APENAS tarde 14h–17h como regra principal | 🔴 Alto | Seção 9.3, 11.3 |
| 3 | Confluência 3TF obrigatória — TF1 veto absoluto | 🔴 Alto | Seção 11.1 |
| 4 | RRR 2.0× para 30/15/5 — não 1.5× nem 3.0× | 🟠 Médio-alto | Seção 10.4 |
| 5 | Abril: reduzir contratos ÷2 ou SL × 1.4 | 🟠 Médio-alto | Seção 9.2, 11.4 |
| 6 | Walk-Forward antes de qualquer conta real | 🔴 Alto | Seção 11.5 |
| 7 | Manhã (09–12h): F ≥ 70, Vol ≥ 2.0× — muito mais exigente | 🟠 Médio-alto | Seção 9.3 |
| 8 | 15/10/5 usa RRR 2.5×, não 2.0× (ótimo diferente) | 🟡 Médio | Seção 10.1 |
| 9 | Nunca calibrar em 2020_22 isolado — vol 100% maior | 🔴 Alto | Seção 2 |
| 10 | Gestão de contratos por score 3TF (1-2-3 contratos) | 🟡 Médio | Seção 11.6 |
