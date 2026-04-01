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

## Tripletas Disponíveis — ATR Real (WINFUT, 2024_26)

| Tripleta | Perfil | ATR Gatilho | SL recomendado | SG (RRR 2.0) | Trades/dia est. |
|---|---|---|---|---|---|
| **60 / 30 / 15** | Estrutural / Swing intraday | 249 pts | 250 pts | 500 pts | 1–3 |
| **30 / 15 / 5** | Day trade clássico ⭐ | 146 pts | 150 pts | 300 pts | 3–6 |
| **15 / 5 / 1** | Scalping | 67 pts | 80 pts | 160 pts | 8–15 |
| **30 / 10 / 5** | Day trade alternativo | 146 pts | 150 pts | 300 pts | 3–6 |
| **60 / 20 / 5** | Híbrido (longo contexto) | 146 pts | 150 pts | 300 pts | 2–5 |

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

Vantagem:  menos sinais, maior qualidade, SL mais amplo aceita mais ruído
Desvantagem: SL de 250pts no WIN = R$ 50/contrato → precisa de capital maior
Ideal para: traders com capital > R$ 15k e tolerância a risco maior
```

### 30 / 15 / 5 — Day Trade Clássico ⭐ (recomendada)
```
Contexto (30min): define o viés da manhã/tarde
Direção (15min): confirma que o preço está respeitando o viés
Gatilho (5min): candle de força com volume na zona de confluência

Vantagem:  melhor equilíbrio entre frequência e qualidade de sinais
           SL de 150pts WIN = R$ 30/contrato — capital acessível
Desvantagem: exige monitoramento constante
Ideal para: day trade WIN e WDO — perfil padrão do projeto
```

### 15 / 5 / 1 — Scalping
```
Contexto (15min): micro-tendência
Direção (5min): confirma micro-direção
Gatilho (1min): entrada precisa

Vantagem:  SL pequeno (80pts WIN = R$ 16/contrato), muitas oportunidades
Desvantagem: alto ruído, exige execução muito rápida, spread pesa mais
             backtest em 1min exige Tick a Tick obrigatoriamente
Ideal para: traders experientes com execução automatizada robusta
```

### 30 / 10 / 5 — Alternativa
```
Contexto (30min): viés do meio período
Direção (10min): confirmação intermediária
Gatilho (5min): mesmo gatilho da tripleta 30/15/5

Vantagem:  10min filtra mais ruído que o 5min direto
Desvantagem: 10min menos popular — menos confluências identificáveis
Ideal para: testes comparativos com 30/15/5
```

---

## Implementação NTSL — Semáforo de Tripletas

```pascal
// Para simular multi-TF dentro de um único robô no Profit,
// usa-se janelas de média como proxy dos TFs maiores.
// TF maior real requer dois robôs/indicadores ou parâmetros externos.

// Proxy do TF2 (Direção) dentro do robô de TF3 (Gatilho):
// Se robô roda em 5min e o TF2 é 15min → janela = 3 barras (15/5)
// Se robô roda em 5min e o TF1 é 30min → janela = 6 barras (30/5)

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
