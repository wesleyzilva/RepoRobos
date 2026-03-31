
# Definição e Estruturação das Áreas de Operação (Abertura e Fechamento)

## Conceito
Áreas de operação são regiões retangulares traçadas a partir da abertura e fechamento do candle de referência, formando o chamado "corpo do candle". Essas áreas se estendem para a direita do gráfico e destacam zonas onde o preço pode encontrar confluência ou reagir.

## Como a Área é Definida
- **Base:** A área é construída entre a abertura e o fechamento do candle (corpo do candle).
- **Extensão:** O retângulo se projeta horizontalmente para a direita, acompanhando o tempo, até que uma nova área relevante seja formada.
- **Tamanho Vertical:** O tamanho da área é igual ao valor absoluto do corpo do candle (|fechamento - abertura|), podendo ser multiplicado por um fator de ajuste (exemplo: 1.5x) para ampliar a zona.
	- Exemplo: Se o corpo do candle for 120 pontos e o fator for 1.5, a área terá 180 pontos de altura.
- **Ajuste Dinâmico:** O fator pode ser ajustado conforme o ativo ou volatilidade. Futuramente, pode-se testar outras métricas como ATR, range ou percentual do preço.

## Critério de Confluência
- Quando uma nova área de operação (baseada em corpo) tem sua abertura ou fechamento dentro dos limites de uma área anterior, considera-se que há uma confluência.
- Quanto mais áreas sobrepostas (confluências) em uma mesma região, maior a probabilidade de reação forte do preço naquele ponto.

## Resumo Visual
```
|----------| ← Área 1 (abertura/fechamento do candle 1)
		 |----------| ← Área 2 (sobreposta à anterior)
```

## Observações
- O método é simples, visual e adaptável.
- Permite rápida identificação de zonas de interesse para trade.
- A abordagem pode ser refinada conforme a necessidade do setup ou ativo.