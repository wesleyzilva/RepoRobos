# Sistema de Tripletas de Timeframes

## Conceito: Contexto → Direção → Gatilho

Cada operação usa sempre **3 timeframes em cadeia decrescente**:

| Posição | Nome | Papel |
|---|---|---|
| TF1 (maior) | **Contexto** | Define o viés dominante do dia — onde o mercado quer ir |
| TF2 (médio) | **Direção** | Confirma que o preço está se movendo no viés do contexto |
| TF3 (menor) | **Gatilho** | Fornece o sinal preciso de entrada — define o SL e SG |

**Regra cardinal:** Só operar quando TF1 **e** TF2 estão na mesma direção. TF3 dá o momento de entrar.

---

## Tabela Verdade (válida para todas as tripletas)

| TF1 (Contexto) | TF2 (Direção) | TF3 (Gatilho) | Opera? | Motivo |
|---|---|---|---|---|
| opera | opera | opera | ✅ **SIM** | Alinhamento total |
| opera | opera | neutro | ✅ **SIM** | Aguardar gatilho — contexto confirmado |
| opera | neutro | opera | ❌ não | Direção não confirmada |
| opera | neutro | neutro | ❌ não | Apenas contexto, sem direção |
| neutro | opera | opera | ❌ não | Sem contexto |
| neutro | opera | neutro | ❌ não | Sem contexto |
| neutro | neutro | opera | ❌ não | Sinal isolado sem base |
| neutro | neutro | neutro | ❌ não | Mercado indefinido |

> **Resumo:** Opera **somente** quando `TF1 = opera` E `TF2 = opera`. TF3 é o gatilho preciso.

---

## Grau de Confiança por Combinação — Hierarquia de Peso

> **Princípio:** TF maior = maior peso. O TF1 (60min) representa o fluxo institucional.
> Sem ele alinhado, o sinal pode ser apenas ruído ou correção dentro de um movimento oposto maior.

| Combinação | TF1 (60min) | TF2 (30min) | TF3 (15min) | Confiança | Ação recomendada |
|---|:---:|:---:|:---:|---|---|
| 3/3 alinhados | ✅ | ✅ | ✅ | **Alta** | Entra com tamanho cheio |
| 60+30 sem 15 | ✅ | ✅ | ❌ | **Média-Alta** | Contexto e direção ok — aguarda gatilho |
| 60+15 sem 30 | ✅ | ❌ | ✅ | **Média** | Contexto ok, direção intermediária ausente |
| 30+15 sem 60 | ❌ | ✅ | ✅ | **Baixa** | **Bloqueado** — sem contexto institucional |

### Por que 30+15 sem 60 é o pior cenário

O 60min representa o fluxo institucional. Sem ele, o sinal pode ser apenas uma correção
dentro de um movimento oposto maior — você entra "a favor do ruído", não da tendência.

---

## Sistema de Score com Veto do TF1

```
60min ❌  → BLOQUEIA a entrada independente dos outros dois (veto absoluto)
60min ✅ + 30min ✅          → Entra com tamanho reduzido (1 contrato) aguardando TF3
60min ✅ + 30min ✅ + 15min ✅ → Entra com tamanho cheio (3 contratos)
```

> **Implementação NTSL:** usar `Contratos` variável — `ContratosBase(1)` e `ContratosMaximo(3)`,
> passando `ContratosBase` quando TF3 ainda não confirmou e `ContratosMaximo` com 3/3 alinhados.

---

## Regra matemática das Tripletas

> `iJanelaDir = TF2 ÷ TF3` e `iJanelaCtx = TF1 ÷ TF3` devem ser **inteiros exatos**.
> Tripletas com divisão não-inteira são **inválidas** (ex: 30/15/10 → 15÷10=1,5 ❌ PROIBIDO).

| Tripleta | TF3 | iJanelaDir | iJanelaCtx | Válida? |
|---|---|---|---|---|
| 60/30/15 | 15min | 30÷15=**2** | 60÷15=**4** | ✅ |
| 30/15/5  | 5min  | 15÷5=**3**  | 30÷5=**6**  | ✅ |
| 15/10/5  | 5min  | 10÷5=**2**  | 15÷5=**3**  | ✅ |
| 30/10/5  | 5min  | 10÷5=**2**  | 30÷5=**6**  | ✅ |
| 60/20/5  | 5min  | 20÷5=**4**  | 60÷5=**12** | ✅ |
| 15/5/1   | 1min  | 5÷1=**5**   | 15÷1=**15** | ✅ |
| 30/15/10 | 10min | 15÷10=**1,5** | 30÷10=**3** | ❌ INVÁLIDA |

---

## Tripletas Disponíveis — Calibração Real 2025 (WINFUT, 14h–17h, F≥60 + Vol×1.5 + 3TF)

> Fonte: análise barra a barra sobre 2025 real. **Apenas tarde** (follow-through 61–64%).
> Assertividade medida = % de trades que atingem SG antes de SL no período de teste.

| Tripleta | Perfil | ATR Gatilho | SL mínimo¹ | SL recomendado | SG ótimo | RRR | Assertividade | Esperança |
|---|---|---|---|---|---|---|---|---|
| **60 / 30 / 15** | Estrutural / Swing | 285 pts | 228 pts (ATR×0.8) | **285 pts** (ATR×1.0) | **427 pts** | 1.5× | 50% | +71 pts/op |
| **30 / 15 / 5** | Day trade clássico ⭐ | 145 pts | 115 pts (ATR×0.8) | **145 pts** (ATR×1.0) | **290 pts** | 2.0× | 42% | +38 pts/op |
| **15 / 10 / 5** | Day trade alternativo | 140 pts | 112 pts (ATR×0.8) | **140 pts** (ATR×1.0) | **350 pts** | 2.5× | 37% | +40 pts/op |
| **30 / 10 / 5** | Day trade alternativo | 145 pts | 115 pts | **145 pts** | **290 pts** | 2.0× | ~42% | ~+38 pts/op |
| **60 / 20 / 5** | Híbrido contexto longo | 145 pts | 115 pts | **145 pts** | **290 pts** | 2.0× | ~42% | ~+38 pts/op |
| **15 / 5 / 1** | Scalping | ~67 pts | 50 pts | **67 pts** | **134 pts** | 2.0× | ~42% | estimado |

> ¹ **SL mínimo** = ATR×0.8 — aceita mais stops por ruído, mas mantém esperança positiva.
> O SL **nunca deve ser menor** que ATR×0.8, pois abaixo disso a esperança matemática fica negativa.

### SL mínimo estrutural — Close-to-Low do candle gatilho (ruído de entrada)

> O candle gatilho (F≥60) tem uma sombra inferior. Se o SL for colocado dentro dessa sombra,
> qualquer reteste do Low dispara o stop antes de o trade se desenvolver.

| TF gatilho | Close-Low P25 | Close-Low P50 | Close-Low P75 | Implicação |
|---|---|---|---|---|
| **5min** | 155 pts | **196 pts** | 261 pts | SL < 196 = stop frequente pelo próprio candle |
| **15min** | 401 pts | **537 pts** | 750 pts | SL < 400 = quase certo de ser parado no candle |

> **Conclusão:** com SL = ATR×1.0 (145pts para 5min), você estará dentro do ruído do candle gatilho
> em ~50% dos casos — é um **stop apertado intencional**. O RRR≥2.0 compensa estatisticamente.
> Para operar com SL **seguro estruturalmente** (fora do ruído), use SL ≥ 261pts (5min) ou 750pts (15min).

---

## Tripletas Disponíveis — ATR Real (WDOFUT, 2024_26)

| Tripleta | Perfil | ATR Gatilho | SL recomendado | SG (RRR 2.0) | Em R$/contrato |
|---|---|---|---|---|---|
| **60 / 30 / 15** | Estrutural | 8,1 pts | 10 pts | 20 pts | R$100 risco |
| **30 / 15 / 5** | Day trade clássico ⭐ | 5,0 pts | 6 pts | 12 pts | R$60 risco |
| **15 / 5 / 1** | Scalping | 2,0 pts | 3 pts | 6 pts | R$30 risco |

---

## Análise das Tripletas

### 60 / 30 / 15 — Estrutural
```
Contexto (60min): identifica tendência macro do dia
Direção (30min): confirma que estamos em pullback ou rompimento válido
Gatilho (15min): candle de força na zona de confluência

Dados reais 2025 (tarde):
  ATR gatilho = 285pts | 11 sinais/ano (baixa frequência)
  SL ótimo    = 285pts (ATR×1.0)
  SG ótimo    = 427pts (RRR 1.5×) — ATENÇÃO: RRR ótimo é 1.5x, não 2.0x!
  Assertividade = 50% | Esperança = +71pts/op
  AVISO: Close-Low P50 = 537pts — SL de 285pts fica DENTRO do candle gatilho
         Usa stop apertado intencionalmente; estrutura pede >537pts para ser seguro

Vantagem:  menos sinais, maior qualidade, esperança mais alta por operação
Desvantagem: SL de 285pts = R$57/contrato; candle gatilho frequentemente > SL
Ideal para: traders com capital > R$20k, foco em qualidade sobre quantidade
```

### 30 / 15 / 5 — Day Trade Clássico ⭐ (recomendada)
```
Contexto (30min): define o viés da tarde (usar APENAS 14h-17h)
Direção (15min): confirma que o preço está respeitando o viés
Gatilho (5min): candle de força com volume na zona de confluência

Dados reais 2025 (tarde 14h-17h):
  ATR gatilho = 145pts | 130 sinais/ano (boa frequência)
  SL ótimo    = 145pts (ATR×1.0) — SL mínimo=115pts (ATR×0.8)
  SG ótimo    = 290pts (RRR 2.0×)
  Assertividade = 42% | Esperança = +38pts/op
  ALERTA: Close-Low P50 = 196pts > SL = 145pts
          SL apertado intencional — ~50% parados por ruído de candle
          RRR 2.0x compensa matematicamente: 0.42×290 - 0.58×145 = +38pts OK

Vantagem:  melhor equilíbrio frequência/qualidade; 130 ops/ano
           SL 145pts = R$29/contrato (acessível)
Desvantagem: stop apertado = muitas saidas por ruído; exige disciplina
Ideal para: day trade WIN e WDO — perfil padrão do projeto
```

### 15 / 5 / 1 — Scalping
```
Contexto (15min): micro-tendência
Direção (5min): confirma micro-direção
Gatilho (1min): entrada precisa

Estimativas 2025 (não simulado em barra a barra por falta de 1min data longa):
  ATR gatilho 1min ~ 67pts | SL ótimo ~ 67pts (ATR×1.0)
  SG ótimo ~ 134pts (RRR 2.0×)
  Assertividade estimada ~ 40-42% (por analogia com 5min)
  Esperança estimada ~ +15-20pts/op

Vantagem:  SL pequeno (~67pts = R$13/contrato), muitas oportunidades
Desvantagem: alto ruído, exige execução muito rápida, spread pesa mais
             backtest em 1min exige Tick a Tick obrigatoriamente
Ideal para: traders experientes com execução automatizada robusta
```

### 15 / 10 / 5 — Day Trade Alternativo
```
Contexto (15min): identifica micro-tendência
Direção (10min): confirma que o preço respeita a micro-tendência
Gatilho (5min): candle de força no momento correto

iJanelaDir = 10÷5 = 2  (inteiro)
iJanelaCtx = 15÷5 = 3  (inteiro)

Dados reais 2025 (tarde 14h-17h):
  ATR gatilho = 140pts | 164 sinais/ano (maior frequência que 30/15/5)
  SL ótimo    = 140pts (ATR×1.0) — SL mínimo=112pts (ATR×0.8)
  SG ótimo    = 350pts (RRR 2.5×) — DIFERENTE: RRR ótimo é 2.5x!
  Assertividade = 37% | Esperança = +40pts/op
  Close-Low P50 = 190pts > SL = 140pts (mesmo padrão da 30/15/5)

Vantagem:  mais sinais (164 vs 130/ano), boa esperança por operação
           janelas curtas reagem mais rápido; RRR 2.5x = alvo maior
Desvantagem: RRR 2.5x = alvos mais difíceis de atingir; 37% wins
             SL apertado intencional — mesmas considerações da 30/15/5
Ideal para: traders que preferem mais operações e aceitem 37% assertividade
```

### 30 / 10 / 5 — Alternativa
```
Contexto (30min): viés do meio período
Direção (10min): confirmação intermediária
Gatilho (5min): mesmo gatilho da tripleta 30/15/5

iJanelaDir = 10÷5 = 2  (inteiro ✅)
iJanelaCtx = 30÷5 = 6  (inteiro ✅)

Vantagem:  10min filtra mais ruído que o 5min direto
Desvantagem: 10min menos popular — menos confluências identificáveis
Ideal para: testes comparativos com 30/15/5
```

---

## Implementação NTSL — Semáforo de Tripletas

```pascal
// REGRA: iJanelaDir = TF2 ÷ TF3 e iJanelaCtx = TF1 ÷ TF3 — ambos devem ser inteiros!
// Tripleta inválida: 30/15/10 → 15÷10=1,5 (não-inteiro) → NUNCA usar.
//
// Tabela de janelas por tripleta:
//   60/30/15 rodando em 15min: iJanelaDir=2, iJanelaCtx=4
//   30/15/5  rodando em 5min : iJanelaDir=3, iJanelaCtx=6
//   15/10/5  rodando em 5min : iJanelaDir=2, iJanelaCtx=3
//   30/10/5  rodando em 5min : iJanelaDir=2, iJanelaCtx=6
//   60/20/5  rodando em 5min : iJanelaDir=4, iJanelaCtx=12
//   15/5/1   rodando em 1min : iJanelaDir=5, iJanelaCtx=15

var
  iJanelaDir    : integer;  // barras do TF2 expressas em TF3
  iJanelaCtx    : integer;  // barras do TF1 expressas em TF3
  fMediaDir     : float;    // proxy de direção
  fMediaCtx     : float;    // proxy de contexto
  bContextoAlta : boolean;
  bDirecaoAlta  : boolean;

begin
  // Tripleta 30/15/5: rodando em 5min
  // TF2 (15min) = 3 barras de 5min → iJanelaDir = 3
  // TF1 (30min) = 6 barras de 5min → iJanelaCtx = 6
  iJanelaDir := 3;
  iJanelaCtx := 6;

  fMediaDir := Media(iJanelaDir, Close);
  fMediaCtx := Media(iJanelaCtx, Close);

  bContextoAlta := (Close > fMediaCtx) and (fMediaCtx > fMediaCtx[iJanelaCtx]);
  bDirecaoAlta  := (Close > fMediaDir) and (fMediaDir > fMediaDir[iJanelaDir]);

  // Opera long apenas com contexto + direção confirmados
  if bContextoAlta and bDirecaoAlta and (fForca >= ForcaMinimaEntrada) then
    BuyAtMarket;
end;
```

---

## Recomendação por Perfil Operacional

| Perfil | WIN | WDO | Justificativa |
|---|---|---|---|
| Iniciante / Capital < R$10k | 30/15/5 | 30/15/5 | SL acessível, frequência boa |
| Intermediário | 30/15/5 ou 60/30/15 | 30/15/5 | Qualidade superior |
| Avançado / Scalp | 15/5/1 | 15/5/1 | Alta frequência, risco controlado |
| Swing intraday | 60/30/15 | 60/30/15 | Menos operações, mais assertividade |

> **Prioridade do projeto:** tripleta **30/15/5** como padrão para WIN e WDO.
