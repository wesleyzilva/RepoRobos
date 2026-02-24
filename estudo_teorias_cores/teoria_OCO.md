# Teoria Operacional: OCO (WIN) 

## 1. Objetivo
Este material define como configurar OCO no WIN com foco em consistência, controle de risco e execução objetiva.

**OCO = Ordem com ganho (alvo) + perda (stop) já definidos na entrada.**

---

## 2. Conversão prática (WIN)
Para mini índice (WIN), regra prática operacional:

- **1 contrato = ~R$ 0,20 por ponto**
- **5 contratos = ~R$ 1,00 por ponto**

### Fórmulas rápidas
- **Risco (R$)** = Stop (pts) × Quantidade × 0,20
- **Alvo (R$)** = Alvo (pts) × Quantidade × 0,20

Para 5 contratos, fica simples:
- **Risco (R$) ≈ Stop (pts)**
- **Alvo (R$) ≈ Alvo (pts)**

---

## 3. Presets OCO para 5 contratos

### Tabela pronta (5 contratos)

| Preset | Stop (pts) | Alvo (pts) | Risco aprox (R$) | Alvo aprox (R$) | R:R | Quando usar |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Conservador** | 140 | 240 | 140 | 240 | 1:1,71 | Mercado mais travado/irregular |
| **Equilibrado (Padrão)** | 100 | 160 | 100 | 160 | 1:1,60 | Dia normal de operação |
| **Agressivo (Scalp)** | 70 | 110 | 70 | 110 | 1:1,57 | Contexto muito limpo e rápido |

**Configuração padrão sugerida para começar:** `Stop 100 pts / Alvo 160 pts / 5 contratos`.

## 3.1 Preset Equilibrado (padrão recomendado)
- **Stop:** 100 pts
- **Alvo:** 160 pts
- **R:R:** 1:1,6
- **Leitura:** bom para maioria dos dias normais.

## 3.2 Preset Conservador
- **Stop:** 140 pts
- **Alvo:** 240 pts
- **R:R:** 1:1,7
- **Leitura:** menos operações, mais seletivo, melhor para mercado irregular.

## 3.3 Preset Agressivo (scalp)
- **Stop:** 70 pts
- **Alvo:** 110 pts
- **R:R:** 1:1,57
- **Leitura:** exige timing fino e contexto muito limpo.

---

## 4. Preset por horário (WIN intraday)

| Janela | Condição comum | Stop (pts) | Alvo (pts) | R:R |
| :--- | :--- | :---: | :---: | :---: |
| **09:00–11:00** | Alta volatilidade e fluxo forte | 110 | 180 | 1:1,64 |
| **12:00–13:00** | Liquidez menor, mais ruído | 80 | 130 | 1:1,62 |
| **14:00–17:00** | Movimento mais direcional | 100 | 160 | 1:1,60 |

---

## 5. Regras de uso (obrigatórias)

1. **Não entrar sem contexto** (VWAP + estrutura + direção 20/50).
2. **Não usar OCO fixo em notícia relevante** (evitar ficar posicionado).
3. **Não aumentar lote para “recuperar” stop.**
4. **Manter R:R mínimo de 1:1,5.**
5. **Se o mercado estiver lateral/comprimido, reduzir agressividade ou não operar.**

---

## 6. Gestão após entrada

### Breakeven (proteção)
Mover para 0x0 quando:
- preço andar cerca de **60% a 70%** do alvo, **ou**
- romper nova estrutura a favor.

### Parcial (opcional)
- Realizar 30% a 50% da posição no primeiro impulso.
- Deixar restante buscar alvo cheio com stop protegido.

---

## 7. Erros comuns com OCO

1. Definir stop/alvo só por “valor em R$” sem olhar estrutura.
2. Operar com stop curto demais em horário volátil.
3. Operar com alvo muito longo em horário morto.
4. Alterar OCO emocionalmente no meio do trade.
5. Ignorar custos operacionais e slippage.

---

## 8. Checklist de execução (1 minuto)

Antes de clicar:
1. Contexto está favorável (nível + estrutura + direção)?
2. Horário está limpo (fora da zona de notícia)?
3. Preset correto para o horário/regime?
4. R:R está >= 1:1,5?
5. Perda diária já foi respeitada?

Se qualquer resposta for “não”, **não entrar**.

---

## 9. Resumo de bolso

- **Padrão 5 contratos:** `Stop 100 / Alvo 160`
- **R:R mínimo:** `1:1,5`
- **Sem confluência:** `sem trade`
- **Sem disciplina de risco:** `OCO não salva operação ruim`

---

## 10. Três Estratégias OCO por Timeframe (Day Trade)

As estratégias abaixo seguem seus tetos de alvo:
- **2 min:** máximo de **80 a 200 pontos**
- **5 min:** máximo de **150 a 350 pontos**
- **15 min:** máximo de **300 a 700 pontos**

### Estratégia 1 — OCO 2 min (Scalp Estruturado)
**Objetivo:** capturar impulsos curtos com execução rápida e risco controlado.

**Preset (5 contratos):**
- Stop: **70 pontos**
- Alvo: **130 pontos**
- R:R: **1:1,86**

**Gestão:**
- Breakeven em **+70 a +85 pontos** (≈ 55% a 65% do alvo)
- Parcial opcional de 30% a 50% em **+80 a +100 pontos**
- Não estender além de **200 pontos** no 2m

**Quando usar:**
- Abertura com fluxo, rompimento limpo, pullback curto em tendência.

---

### Estratégia 2 — OCO 5 min (Padrão Operacional)
**Objetivo:** operar continuidade com menos ruído que o 2m.

**Preset (5 contratos):**
- Stop: **120 pontos**
- Alvo: **220 pontos**
- R:R: **1:1,83**

**Gestão:**
- Breakeven em **+120 a +145 pontos**
- Parcial opcional em **+150 a +180 pontos**
- Evitar alvo acima de **350 pontos** sem contexto de tendência forte

**Quando usar:**
- Contexto direcional com 20/50 alinhadas e pullback validado.

---

### Estratégia 3 — OCO 15 min (Tendência / Continuação)
**Objetivo:** capturar perna maior com menos frequência e maior qualidade.

**Preset (5 contratos):**
- Stop: **220 pontos**
- Alvo: **420 pontos**
- R:R: **1:1,91**

**Gestão:**
- Breakeven em **+220 a +270 pontos**
- Parcial opcional em **+300 pontos**
- Alvo entre **500 e 700 pontos** somente com tendência muito limpa

**Quando usar:**
- Tendência estabelecida no intraday, rompimento de estrutura com sustentação.

---

## 11. Regra de Seleção Rápida

1. Se o mercado está rápido e com volatilidade curta: **Estratégia 1 (2m)**.
2. Se o mercado está direcional e com pullbacks limpos: **Estratégia 2 (5m)**.
3. Se o mercado está em tendência mais madura e limpa: **Estratégia 3 (15m)**.

Se houver lateralidade/compressão, reduzir alvo para o piso da faixa ou não operar.
