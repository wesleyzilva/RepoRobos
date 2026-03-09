# Teoria de Backtest — Assertividade e Fricções de Mercado

> Referência operacional para construção e avaliação de robôs WIN (minicontrato de índice).

---

## 1. Backtest Tick a Tick

### O que é
Simulação da estratégia processando **cada negócio registrado** na fita de mercado, em vez de usar apenas o OHLCV (abertura, máxima, mínima, fechamento e volume) da barra.

### Por que importa
| Modo | Resolução | Problema |
|---|---|---|
| OHLCV (barra fechada) | 1 barra = 1 evento | Ordem de max/min desconhecida; stop e alvo disputam o mesmo candle |
| Tick a tick | 1 negócio = 1 evento | Simula a sequência real de preços dentro da barra |

- Um candle que tem máx 1000pts e mín 500pts **não informa qual veio primeiro**. No backtest de barra o robô pode "acertar" stop e alvo no mesmo candle — resultado irreal.
- O tick a tick resolve isso porque cada preço é processado na ordem cronológica exata.

### Neologica Profit
- Na janela de backtest, selecionar **"Tick a Tick"** em vez de "Por candle".
- Exige arquivo de ticks históricos carregado; consome mais tempo de processamento.
- Para timeframes curtos (1min, 5min) a diferença de resultado pode ser significativa (5–15 pts de diferença no preço de execução).

### Quando usar obrigatoriamente
- Stops curtos (≤ 150 pts no WIN)
- Entradas com ordem limitada (não a mercado)
- Qualquer estratégia que dependa da sequência intracandle (ex.: rompimento de máxima)

---

## 2. Book de Ofertas (Profundidade de Mercado)

### O que é
Lista ordenada de todas as ordens de compra e venda pendentes em determinado momento, com **preço** e **quantidade** em cada nível.

```
VENDA (Ask)         COMPRA (Bid)
Qtd  | Preço        Preço | Qtd
-----|--------      ------|-----
 30  | 130.500      130.450 |  45
 15  | 130.550      130.400 |  20
  8  | 130.600      130.350 |  60
```

### Conceitos-chave
| Termo | Significado |
|---|---|
| **Bid** | Melhor preço de compra disponível (topo do livro de compras) |
| **Ask** | Melhor preço de venda disponível (topo do livro de vendas) |
| **Spread** | Diferença entre Ask e Bid (ver seção 3) |
| **Aggressor** | Quem cruza o spread e aceita o preço do lado oposto |
| **Liquidez** | Quantidade total disponível em cada nível de preço |

### Impacto no backtest
Backtests **não têm acesso ao book histórico** na maioria das plataformas. Isso cria viés otimista porque o modelo assume que a ordem sempre seria executada ao preço desejado, sem fila de prioridade.

---

## 3. Spread

### Definição
```
Spread = Ask − Bid
```
No WIN, o spread mínimo é **50 pontos** (1 tick = 5 pts, mas a diferença entre compra e venda costuma ser 1 tick = 5 pts em mercado líquido, podendo abrir para 10–25 pts fora do horário principal).

### Por que o spread prejudica o backtest
- O backtest assume execução no **preço de fechamento** ou no preço do sinal.
- Na prática, uma compra a mercado executa no **Ask** (preço mais caro), e uma venda no **Bid** (preço mais barato).
- Ignorar o spread infla o resultado: cada trade "ganha" meio spread que não existe na vida real.

### Regra prática — WIN
| Horário | Spread típico | Ajuste no backtest |
|---|---|---|
| 09:00–17:55 (leilão aberto) | 5–10 pts | Penalizar 5 pts por side |
| Abertura (09:00–09:15) | 15–50 pts | Evitar entradas ou penalizar 25 pts |
| Fechamento (17:45–18:00) | 15–30 pts | Idem |

**Regra mínima:** desconte **10 pontos** de spread total (5 pts entrada + 5 pts saída) em todo trade simulado. Em stops curtos (≤ 100 pts) isso pode eliminar 10% do resultado.

---

## 4. Slippage Fictício — O que é e como aplicar

### Definição
**Slippage** é a diferença entre o preço esperado da ordem e o preço efetivamente executado. Ocorre porque:
1. Há latência entre o sinal e o envio da ordem
2. O mercado move entre o sinal e a execução
3. A liquidez no preço desejado pode ter esgotado

**Slippage fictício** é o valor que se **subtrai artificialmente** do resultado no backtest para simular esse efeito real.

### Tipos de slippage no WIN

| Tipo | Causa | Magnitude típica |
|---|---|---|
| Latência de rede | Tempo entre sinal e envio | 5–15 pts |
| Fila de book | Ordens à frente na mesma fila | 5–20 pts |
| Gap de abertura | Mercado abre longe do fechamento | 50–300 pts (imprevisível) |
| Liquidez rasa | Execução em múltiplos níveis | 10–50 pts |

### Como aplicar no NTSL

#### Método 1 — Input de penalização direta
```ntsl
input
  SlippageEntrada(10.0);   { pontos penalizados na entrada }
  SlippageSaida(10.0);     { pontos penalizados na saida }

var
  fPrecoEntrada : float;
  fPrecoSaida   : float;

begin
  { Entrada comprada: penaliza subindo o preco de referencia }
  if CondicaoEntrada then
  begin
    fPrecoEntrada := Close + SlippageEntrada;
    BuyAtMarket;
    { registrar fPrecoEntrada para calculo correto do resultado }
  end;

  { Saida: penaliza abaixando o preco de referencia }
  if IsBought and CondicaoSaida then
  begin
    fPrecoSaida := Close - SlippageSaida;
    ClosePosition;
  end;
end;
```

#### Método 2 — Ajuste nos alvos e stops
Mais simples e prático:
```ntsl
input
  StopPontos(200.0);
  AlvoPontos(400.0);
  SlippageTotal(20.0);       { spread + slippage combinados }

begin
  { Ao calcular o alvo liquido, descontar o slippage }
  { Alvo real = AlvoPontos - SlippageTotal }
  { Stop real = StopPontos + SlippageTotal (stop fica mais proximo) }
end;
```

### Valor recomendado para o WIN
```
Slippage mínimo conservador : 10 pts (só spread)
Slippage realista           : 20–30 pts (spread + latência)
Slippage pessimista         : 50 pts (stress test)
```

**Regra de ouro:** se o robô é lucrativo com 50 pts de slippage, ele tem robustez real. Se depende de < 10 pts, provavelmente está sobreajustado.

---

## 5. Como Melhorar a Assertividade do Backtest

### 5.1 Checklist de qualidade antes de aprovar um robô

| # | Verificação | Por quê |
|---|---|---|
| 1 | Rodou tick a tick? | Elimina viés de sequência intracandle |
| 2 | Incluiu spread (≥ 10 pts)? | Reflete custo real de execução |
| 3 | Incluiu slippage (≥ 20 pts)? | Reflete latência e liquidez |
| 4 | Incluiu corretagem? | WIN: ~R$1,50–R$2,50 por contrato/lado |
| 5 | Período ≥ 2 anos? | Cobre diferentes regimes de mercado |
| 6 | Validou em amostra fora do período otimizado? | Evita overfitting |
| 7 | Taxa de acerto ≥ 60% com RR ≥ 1:2? | Padrão mínimo do projeto |
| 8 | Drawdown máximo ≤ 20% do capital? | Limite de risco aceitável |

### 5.2 Separação de amostras (Walk-Forward)

```
Período total disponível
├── 70% → Otimização (ajustar parâmetros)
└── 30% → Validação fora da amostra (nunca tocar antes)

Se aprovado na validação → candidato a paper trade
Se reprovado           → revisar lógica (não ajustar parâmetros)
```

### 5.3 Parâmetros mais sensíveis a slippage (WIN)

- **Stop curto (≤ 150 pts):** 20 pts de slippage representa 13% do stop — crítico
- **Alvo pequeno (≤ 200 pts):** slippage pode eliminar metade do ganho
- **Entradas na abertura (09:00–09:15):** spread amplo frequente — usar `Date <> Date[1]` para filtrar

### 5.4 Comparação: backtest vs. resultado real típico

| Métrica | Backtest puro | Com ajustes realistas | Resultado real (estimado) |
|---|---|---|---|
| Taxa de acerto | 68% | 63% | 58–62% |
| Resultado médio/trade | +120 pts | +85 pts | +70–90 pts |
| Drawdown máximo | 800 pts | 1.100 pts | 1.000–1.400 pts |

> Ajustes realistas = tick a tick + spread 10 pts + slippage 20 pts + corretagem.

### 5.5 Custo total por trade (WIN — 1 contrato)

```
Spread        :  10 pts × R$0,20 =  R$ 2,00
Slippage      :  20 pts × R$0,20 =  R$ 4,00
Corretagem    :  ~R$1,80 (entrada + saída)
───────────────────────────────────────────
Custo total   :                     R$ 7,80 por trade
Em pontos     :  39 pts equivalentes
```

Todo robô que apresenta resultado bruto de backtest deve ter **39 pts descontados por trade** para estimar o resultado líquido real.

---

## 6. Resumo Rápido

```
Spread         → diferença entre Ask e Bid (custo de execução)
Slippage       → desvio do preço esperado ao executado (latência + liquidez)
Tick a tick    → simula sequência real intracandle (obrigatório para stops curtos)
Book de ofertas → mostra liquidez e fila; não disponível em backtests históricos

Custo mínimo a considerar no WIN por trade:
  Spread 10 pts + Slippage 20 pts + Corretagem 9 pts ≈ 39 pts totais
```

---

## 7. Implementação nos Robôs — Bloco Padrão de Validação de Backtest

### 7.1 Bloco completo de inputs de fricção (NTSL)

Adicionar em **todo robô** antes dos inputs de estratégia:

```ntsl
{
  Bloco de Validacao de Backtest
  Ativar UsarFricao = true ao rodar backtest realista
  Ativar UsarFricao = false para testar logica pura
}
input
  { --- Gestao de risco --- }
  UsarGestaoRisco(true);
  UsarHardLock(true);
  SaldoConta(10000.0);
  RiscoDiaPct(1.5);
  RiscoSemanaPct(3.0);
  MaxStopsConsecutivos(2);
  ValorPorPonto(0.20);
  DiaSemanaReset(2);

  { --- Validacao de backtest realista --- }
  UsarFricao(true);           { false = backtest puro sem penalizacao }
  SpreadPontos(10.0);         { spread medio em pontos (5 entrada + 5 saida) }
  SlippagePontos(20.0);       { slippage estimado por trade (entrada + saida) }
  Corretagempeg(9.0);         { corretagem em pontos equivalentes }
  FricaoTotal(39.0);          { calculado: Spread + Slippage + Corretagem }

  { --- Parametros de qualidade minima --- }
  TaxaAcertoMinPct(60.0);     { % minima para aprovar }
  RRMinimo(2.0);              { relacao risco/retorno minima (RR 1:X) }
```

### 7.2 Variáveis de controle de fricção

```ntsl
var
  fAlvoBruto      : float;    { alvo calculado pela logica }
  fAlvoLiquido    : float;    { alvo apos descontar fricao }
  fStopBruto      : float;    { stop calculado pela logica }
  fStopAjustado   : float;    { stop apos adicionar fricao (fica mais proximo) }
  fFricaoAtiva    : float;    { valor de fricao aplicado (0 se UsarFricao=false) }
```

### 7.3 Lógica de aplicação da fricção

```ntsl
begin
  { Definir fricao conforme parametro }
  if UsarFricao then
    fFricaoAtiva := FricaoTotal
  else
    fFricaoAtiva := 0.0;

  { Calcular alvos e stops liquidos }
  fAlvoBruto    := AlvoPontos;
  fAlvoLiquido  := fAlvoBruto  - fFricaoAtiva;   { alvo liquido menor }
  fStopBruto    := StopPontos;
  fStopAjustado := fStopBruto  + fFricaoAtiva;   { stop efetivo maior }

  { Validar se o trade ainda faz sentido com fricao }
  { RR liquido = fAlvoLiquido / fStopAjustado }
  { Se RR liquido < RRMinimo, nao entrar }

  if (fAlvoLiquido / fStopAjustado) >= RRMinimo then
  begin
    { executar logica de entrada }
  end;
end;
```

### 7.4 Como usar os dois modos no Profit

| Modo | `UsarFricao` | `UsarGestaoRisco` | Objetivo |
|---|---|---|---|
| Backtest puro | `false` | `false` | Testar apenas a lógica do sinal |
| Backtest realista | `true` | `false` | Estimar resultado real esperado |
| Paper trade / live | `false` | `true` | A corretora já aplica as fricções reais |

> **Atenção:** no paper trade/live as fricções happen organicamente (a ordem executa no Ask/Bid real). Não duplicar a penalização.

### 7.5 Critério de aprovação — fluxo de decisão

```
Rodar backtest PURO (UsarFricao=false)
    ↓
Taxa acerto ≥ 60% e RR ≥ 1:2?  NÃO → descartar lógica
    ↓ SIM
Rodar backtest REALISTA (UsarFricao=true, SlippagePontos=20)
    ↓
Ainda lucrativo?  NÃO → lógica frágil (slippage-dependent) → descartar
    ↓ SIM
Rodar STRESS TEST (SlippagePontos=50)
    ↓
Ainda positivo?  NÃO → aprovar com ressalva (monitorar em paper trade)
    ↓ SIM
Candidato robusto → avançar para walk-forward e paper trade
```

---

## 8. Tipos de Operação — Adequação às Fricções

### 8.1 Custo de fricção vs. tamanho da operação

O custo fixo de **~39 pts** por trade impacta diferente conforme a amplitude da operação:

| Tipo de operação | Alvo típico (pts) | Stop típico (pts) | Fricção como % do alvo | Viabilidade |
|---|---|---|---|---|
| Scalping agressivo | 50–80 | 30–50 | 49–78% | Inviável — fricção devora o resultado |
| Scalping moderado | 100–150 | 60–100 | 26–39% | Muito arriscado — exige acerto > 70% |
| Day trade curto | 200–300 | 100–150 | 13–20% | Marginal — exige RR ≥ 1:2,5 real |
| Day trade padrão | 300–500 | 150–250 | 8–13% | **Viável** — padrão do projeto |
| Day trade amplo | 500–800 | 250–400 | 5–8% | **Ideal** — fricção pouco relevante |
| Swing (overnight) | 800–2000 | 300–600 | 2–5% | Excelente — mas exige gestão de gap |

> **Conclusão:** operações com alvo < 200 pts no WIN são estruturalmente desfavorecidas pela fricção. O ponto de equilíbrio real está em **alvo ≥ 300 pts**.

### 8.2 Tipos de entrada — sensibilidade ao slippage

| Tipo de entrada | Slippage esperado | Por quê |
|---|---|---|
| Mercado no fechamento da barra | 5–10 pts | Barras fechadas têm spread próximo do mínimo |
| Mercado na abertura da sessão | 20–80 pts | Spread largo + liquidez rasa + gap overnight |
| Stop de compra (BuyStop) | 10–30 pts | Executa quando preço já está subindo (aggressor) |
| Limite de compra (BuyLimit) | 0–5 pts | Fica na fila; pode não executar em movimentos rápidos |
| Rompimento de máxima/mínima anterior | 15–40 pts | Corrida de ordens no mesmo nível |

**Recomendação:** entradas por `BuyLimit`/`SellLimit` reduzem o slippage mas aumentam o risco de **não execução** em movimentos de impulso — risco de ficar de fora da operação mais lucrativa.

### 8.3 Tipos de saída — impacto na fricção

| Tipo de saída | Slippage | Observação |
|---|---|---|
| Alvo fixo (limit order) | ≈ 0 pts | Aguarda o preço chegar — zero slippage na saída |
| Stop loss (stop order) | 10–30 pts | Executa em queda/alta rápida — slippage alto |
| Trailing stop | 15–40 pts | Desloca junto com o mercado; slippage em reversões |
| `ClosePosition` por sinal | 5–15 pts | Mercado na barra de sinal; risco de slippage moderado |

**Combinação mais eficiente:** entrada a mercado no fechamento + alvo fixo (limit) + stop fixo. Maximiza a execução do alvo sem slippage e limita o de stop.

### 8.4 Estratégias por custo-benefício de fricção

| Grupo do projeto | Alvo típico | Adequação às fricções | Ajuste necessário |
|---|---|---|---|
| SCALPING | 50–150 pts | Baixa | Elevar alvo mínimo para 200 pts ou eliminar |
| CANDLE1 / 50MAIS1 | 100–200 pts | Baixa–Média | Filtrar só setups de maior amplitude |
| IFR_RSI (extremos) | 200–500 pts | **Alta** | Adequado — manter como está |
| REVERSAO_MEDIA | 250–500 pts | **Alta** | Adequado |
| BREAKOUT | 300–800 pts | **Excelente** | Ideal para fricções |
| TENDENCIA_SEGUIR | 400–1000 pts | **Excelente** | Trailing stop compensa bem |
| VWAP_INSTITUCIONAL | 200–500 pts | Alta | Entradas limit reduzem slippage |

---

## 9. Timeframes — Comportamento e Adequação às Fricções

### 9.1 Tabela comparativa de timeframes

| Timeframe | Barras/dia (WIN) | Trades/dia típico | Alvo médio (pts) | Custo fricção/resultado | Modo obrigatório |
|---|---|---|---|---|---|
| 1 min | 540 | 10–30 | 50–100 | 39–78% | Tick a tick + SlippageTotal ≥ 50 pts |
| 5 min | 108 | 3–10 | 100–200 | 20–39% | Tick a tick + SlippageTotal ≥ 30 pts |
| 15 min | 36 | 2–5 | 200–400 | 10–20% | Tick a tick recomendado |
| 30 min | 18 | 1–3 | 300–600 | 7–13% | Tick a tick ou barra — diferença pequena |
| 60 min | 9 | 1–2 | 400–800 | 5–10% | **Barra suficiente** |
| Diário | 1 | 0–1 | 500–2000 | 2–8% | Barra suficiente |

### 9.2 Análise por timeframe

#### 1 minuto
- **Alta frequência de trades:** a fricção se acumula rapidamente
- **Resultado bruto x líquido:** diferença de 30–50% é comum
- **Overfit risk:** alto — curvas de capital "bonitas" desaparecem no realista
- **Recomendação:** evitar para robôs automáticos no WIN; usar apenas para leitura manual

#### 5 minutos
- **Transição:** começa a ser viável se alvo > 150 pts e acerto > 65%
- **Slippage dominante:** entradas e saídas na abertura de barras ainda sofrem
- **Adequado para:** CANDLE1, 50MAIS1 com filtro de amplitude mínima
- **Recomendação:** exige backtest tick a tick obrigatório

#### 15 minutos
- **Ponto de equilíbrio:** fricção já representa < 20% do alvo em setups normais
- **Barras mais representativas:** menos ruído que 5min
- **Adequado para:** IFR_RSI reversão, VWAP, BREAKOUT moderado
- **Recomendação:** **timeframe mínimo recomendado** para robôs automáticos do projeto

#### 30 minutos ⭐
- **Melhor equilíbrio** entre frequência de trades e custo de fricção
- Alvo de 300–600 pts = fricção representa apenas 7–13%
- Barras capturam movimentos intraday completos
- Filtros de tendência (MME9/21) funcionam bem
- **Adequado para:** todos os grupos — especialmente IFR_RSI, REVERSAO_MEDIA, TENDENCIA_SEGUIR
- **Recomendação:** **timeframe principal** do projeto

#### 60 minutos ⭐
- **Fricção irrelevante:** 39 pts sobre alvo de 500–800 pts = < 8%
- Menos trades por dia (1–2) → menor acúmulo de custo
- Movimentos mais limpos, menos whipsaw
- Backtest por barra já é suficientemente preciso neste TF
- **Adequado para:** todos os grupos — resultados históricos mais estáveis
- **Recomendação:** **timeframe de maior confiabilidade** para backtests do projeto

#### Diário
- Fricção praticamente desprezível
- Número reduzidíssimo de operações dificulta validação estatística
- Gap overnight pode ser significativo (300–1000 pts)
- **Recomendação:** usar apenas para contexto e filtro, não para entrada automática

### 9.3 Regra de ouro — timeframe vs. stop/alvo mínimo

Para que a fricção de 39 pts represente **no máximo 10% do alvo**:

$$\text{Alvo mínimo} = \frac{39}{0{,}10} = 390 \text{ pts}$$

Para que a fricção represente **no máximo 15% do alvo**:

$$\text{Alvo mínimo} = \frac{39}{0{,}15} = 260 \text{ pts}$$

| Meta de impacto da fricção | Alvo mínimo necessário | Timeframe mínimo |
|---|---|---|
| ≤ 5% do alvo | 780 pts | 60 min |
| ≤ 10% do alvo | 390 pts | 30 min |
| ≤ 15% do alvo | 260 pts | 15–30 min |
| ≤ 20% do alvo | 195 pts | 15 min (com filtro) |
| > 20% do alvo | < 195 pts | Estruturalmente desfavorável |

### 9.4 Mapa de decisão — timeframe + tipo de operação

```
Qual timeframe usar?

  Frequência alta de trades desejada?
  ├── SIM → 15min (mínimo viável) com alvo > 250 pts
  └── NÃO → 30min ou 60min (recomendados)

  Tipo de estratégia?
  ├── Reversão (IFR extremo, REVERSAO_MEDIA) → 30min ou 60min
  ├── Tendência / breakout                   → 60min (trailing funciona melhor)
  ├── VWAP / institucional                   → 15min ou 30min
  └── Scalping                               → NÃO recomendado para robôs auto

  Stop curto (< 150 pts)?
  └── Obrigatório: tick a tick + SlippageTotal = 50 pts no backtest
```