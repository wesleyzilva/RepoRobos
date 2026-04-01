---
description: Analisa áreas de confluência geométrica em dados históricos de candles CSV
---

# Prompt: Análise de Confluência Geométrica

## Contexto
Você é especialista em geometria de mercado e price action. Analise os dados históricos disponíveis em `DadosCandlesBacktest/` para identificar zonas de confluência.

## Tarefa
Analise os dados do ativo **${input:ativo:WINJ26}** no timeframe **${input:timeframe:5min}** e identifique as principais zonas de confluência geométrica.

## Passos de análise

### 1. Leitura dos dados
```python
import pandas as pd

df = pd.read_csv(
    'DadosCandlesBacktest/2024_26/{ativo}_F_0_{timeframe}.csv',
    sep=';',
    encoding='latin1',
    decimal=',',
    thousands='.'
)
df['DateTime'] = pd.to_datetime(df['Data'] + ' ' + df['Hora'], format='%d/%m/%Y %H:%M:%S')
df = df.sort_values('DateTime').reset_index(drop=True)
```

### 2. Identificar candles relevantes
- Corpo > 60% do range (candles de força)
- Volume > 2× média 20 períodos
- Candles de reversão (padrão de rejeição: pavio > 60% do range)

### 3. Mapear áreas
Para cada candle relevante, criar área de operação:
- **Opção 1 (corpo):** `[min(Open,Close), max(Open,Close)]`
- **Opção 2 (range):** `[Low, High]`

### 4. Calcular sobreposição (confluência)
```python
# Para cada par de áreas, verificar intersecção
def calcula_confluencia(areas):
    contagem = {}
    for i, area1 in enumerate(areas):
        for j, area2 in enumerate(areas):
            if i != j:
                # Intersecção entre [a1_min, a1_max] e [a2_min, a2_max]
                intersect_min = max(area1['min'], area2['min'])
                intersect_max = min(area1['max'], area2['max'])
                if intersect_min <= intersect_max:
                    nivel = (intersect_min + intersect_max) / 2
                    contagem[nivel] = contagem.get(nivel, 0) + 1
    return contagem
```

### 5. Ranquear zonas
Ordenar por número de confluências (maior = maior prioridade operacional).

## Saída esperada

Retorne uma tabela com:
| Nível (pts) | Confluências | Tipos | Última validação | Viés |
|---|---|---|---|---|
| 167.250 | 4 | corpo + range + vol | 15/12/2025 | COMPRA |
| 166.800 | 3 | corpo × 3 | 10/12/2025 | VENDA |

E os parâmetros recomendados:
- Força mínima de entrada
- SL baseado na estrutura mais próxima
- SG calculado com RRR ≥ 2.0
