# Teoria Operacional: MACD (Moving Average Convergence Divergence)

## 1. O que é o MACD?
O **MACD** é um indicador de **momentum e tendência**. Ele mede a diferença entre duas médias móveis exponenciais para mostrar se a força do movimento está acelerando ou perdendo intensidade.

### Estrutura do indicador
- **Linha MACD:** diferença entre EMA rápida e EMA lenta.
- **Linha de Sinal:** média da linha MACD (suavização).
- **Histograma:** distância entre MACD e Linha de Sinal (força do impulso).

Configuração mais usada:
- **Rápida:** 12
- **Lenta:** 26
- **Sinal:** 9

---

## 2. Para que serve?
O MACD serve para responder 3 perguntas principais:

1. **O movimento tem força real?**
   - Histograma aumentando = impulso ganhando força.
   - Histograma diminuindo = impulso perdendo força.

2. **Há possível mudança de direção?**
   - Cruzamento MACD acima da linha de sinal = viés de alta.
   - Cruzamento MACD abaixo da linha de sinal = viés de baixa.

3. **A tendência está saudável ou cansada?**
   - MACD acima de zero = ambiente comprador.
   - MACD abaixo de zero = ambiente vendedor.
   - Divergência preço vs MACD = alerta de exaustão.

---

## 3. Leitura prática (sem complicar)

### A. Cruzamento de linhas
- **Compra:** MACD cruza para cima da linha de sinal.
- **Venda:** MACD cruza para baixo da linha de sinal.

> Uso correto: cruzamento com contexto (tendência, estrutura, volume). Sozinho gera ruído.

### B. Linha zero
- **Acima de zero:** força compradora predominante.
- **Abaixo de zero:** força vendedora predominante.

> O cruzamento da linha zero costuma ser mais atrasado, porém mais confiável para confirmar regime.

### C. Histograma
- Barras crescendo: aceleração do movimento.
- Barras encolhendo: desaceleração (cansaço).

> Muito útil para evitar entrada tardia no “fim da perna”.

---

## 4. Sinais de atenção (erros comuns)
- Operar todo cruzamento em mercado lateral.
- Ignorar direção de contexto (VWAP, médias, estrutura).
- Comprar com histograma enfraquecendo forte perto de resistência.
- Vender com histograma enfraquecendo perto de suporte.

---

## 5. Divergência no MACD (sinal de exaustão)

### Divergência de baixa
- Preço faz topo mais alto, mas MACD/histograma faz topo mais baixo.
- Indica perda de força da alta.

### Divergência de alta
- Preço faz fundo mais baixo, mas MACD/histograma faz fundo mais alto.
- Indica perda de força da baixa.

> Divergência é **alerta**, não entrada automática. Precisa confirmação por price action/estrutura.

---

## 6. Integração com seu Trade System
Use o MACD como **filtro de qualidade**, não como gatilho isolado:

- **Contexto:** tendência + fase do mercado + VWAP.
- **Gatilho:** price action (rejeição, engolfo, rompimento válido).
- **Confirmação:** MACD alinhado (cruzamento + histograma favorável).
- **Veto:** se MACD divergir fortemente do movimento, reduzir mão ou evitar entrada.

Fluxo simples:
1. Ver contexto (estrutura + VWAP)
2. Ver gatilho no candle
3. Confirmar força no MACD
4. Executar com risco definido

---

## 7. Resumo direto
- **O que é:** indicador de tendência + momentum.
- **Para que serve:** confirmar direção, medir força e detectar cansaço.
- **Como usar melhor:** em confluência com price action, volume e estrutura.

O MACD melhora a assertividade quando atua como “validador de força” do seu setup, e não como único motivo da entrada.