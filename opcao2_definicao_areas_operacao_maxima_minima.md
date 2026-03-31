
# Definição e Estruturação das Áreas de Operação

## Conceito
Áreas de operação são regiões retangulares traçadas a partir de candles relevantes, que se estendem para a direita do gráfico. Elas servem para destacar zonas onde o preço pode encontrar resistência, suporte ou confluência de movimentos.

## Como a Área é Definida
- **Base:** A área é construída a partir da máxima e mínima do candle de referência.
- **Extensão:** O retângulo se projeta horizontalmente para a direita, acompanhando o tempo, até que uma nova área relevante seja formada.
- **Tamanho Vertical:** Inicialmente, o tamanho da área será definido pelo corpo do candle (|fechamento - abertura|) multiplicado por um fator de ajuste (exemplo: 1.5x).
	- Exemplo: Se o corpo do candle for 120 pontos e o fator for 1.5, a área terá 180 pontos de altura.
- **Ajuste Dinâmico:** O fator pode ser ajustado conforme o ativo ou volatilidade. Futuramente, pode-se testar outras métricas como ATR, range ou percentual do preço.

## Critério de Confluência
- Quando uma nova área de operação tem sua máxima ou mínima dentro dos limites de uma área anterior, considera-se que há uma confluência.
- Quanto mais áreas sobrepostas (confluências) em uma mesma região, maior a probabilidade de reação forte do preço naquele ponto.

## Resumo Visual
```
|----------------------| ← Área 1 (máxima/mínima do candle 1)
				 |----------------------| ← Área 2 (sobreposta à anterior)
```

## Observações
- O método é simples, visual e adaptável.
- Permite rápida identificação de zonas de interesse para trade.
- A abordagem pode ser refinada conforme a necessidade do setup ou ativo.