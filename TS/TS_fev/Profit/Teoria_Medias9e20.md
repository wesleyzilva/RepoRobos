# Teoria Operacional: MME 9 e MME 20 (Day Trade)

## 1. Objetivo
Este material define como usar apenas as médias de 9 e 20 períodos para classificar o mercado em:
- Compra (fluxo comprador válido)
- Lateralização (sem vantagem estatística)
- Venda (fluxo vendedor válido)

A lógica central é simples: a MME 9 representa velocidade de curto prazo e a MME 20 representa direção base do movimento intraday.

---

## 2. Função de cada média

### MME 9 (curto prazo)
- É a média mais rápida.
- Mostra aceleração imediata do preço.
- Reage primeiro às mudanças de momentum.

### MME 20 (estrutura intraday)
- É a média de referência para tendência no day trade.
- Filtra ruído da 9.
- Funciona como eixo de "valor" do pregão: quando o preço afasta demais da 20, aumenta chance de correção.

---

## 3. Leitura correta da dupla 9/20
A leitura não deve usar só cruzamento. Deve combinar 3 fatores ao mesmo tempo:

1. Ordem entre médias (9 acima ou abaixo da 20)
2. Inclinação da 20 (subindo, caindo ou reta)
3. Posição do preço (acima/abaixo das duas)

Sem essa combinação, o sinal fica frágil e gera entradas em lateralidade.

---

## 4. Estado de COMPRA (habilitar compra)
Considere compra habilitada quando houver confluência:

- MME 9 acima da MME 20
- MME 20 inclinada para cima
- Preço acima da MME 9 e da MME 20

### Interpretação
- Fluxo comprador dominante
- Pullbacks na região da 9/20 podem ser oportunidades de continuidade

### Invalidar compra (desabilitar)
- Preço perde a MME 9 com sequência de fraqueza
- MME 9 cruza para baixo da 20
- MME 20 perde inclinação e fica reta

---

## 5. Estado de VENDA (habilitar venda)
Considere venda habilitada quando houver confluência:

- MME 9 abaixo da MME 20
- MME 20 inclinada para baixo
- Preço abaixo da MME 9 e da MME 20

### Interpretação
- Fluxo vendedor dominante
- Repique até 9/20 pode ser ponto de continuação de baixa

### Invalidar venda (desabilitar)
- Preço recupera a MME 9 com força
- MME 9 cruza para cima da 20
- MME 20 perde inclinação e fica reta

---

## 6. Estado de LATERALIZAÇÃO (não habilitar compra nem venda)
Trate como lateral quando houver qualquer um destes cenários:

- MME 9 cruzando a 20 repetidamente em poucos candles
- MME 20 com baixa inclinação (reta)
- Preço alternando acima/abaixo das médias sem continuidade
- Distância entre 9 e 20 muito curta e sem expansão

### Regra prática
Quando lateralizar, a melhor decisão é reduzir agressividade ou não operar tendência.

---

## 7. Regras objetivas para semáforo operacional
Você pode usar a classificação abaixo como padrão visual:

- Verde: compra habilitada (confluência completa)
- Vermelho: venda habilitada (confluência completa)
- Cinza: lateralização/indefinição (sem habilitação)
- Dourado: continuação após pivô já validado

Obs.: Dourado não substitui direção. Ele reforça continuidade depois que compra/venda já foi validada pelas médias e estrutura.

---

## 8. Erros comuns com MME 9 e 20

1. Operar só porque houve cruzamento da 9 na 20.
2. Ignorar inclinação da MME 20.
3. Comprar/vender com preço esticado muito longe da 20.
4. Forçar operação em período de abertura com volatilidade desorganizada.
5. Não separar cenário de tendência de cenário de lateralização.

---

## 9. Checklist pré-operação (rápido)
Antes de cada entrada, validar:

1. 9 está do lado correto da 20?
2. 20 está inclinada na direção da operação?
3. Preço está do mesmo lado das duas médias?
4. Existe estrutura (rompimento/pivô) confirmando a direção?
5. Não é lateralização?

Se qualquer item falhar, não habilitar operação.

---

## 10. Resumo executivo
- MME 9 = velocidade
- MME 20 = direção
- Compra: 9 > 20, 20 sobe, preço acima das duas
- Venda: 9 < 20, 20 cai, preço abaixo das duas
- Lateralização: cruzamentos frequentes + 20 reta + preço sem continuidade

A consistência no day trade vem mais de filtrar operações ruins do que de aumentar quantidade de entradas.