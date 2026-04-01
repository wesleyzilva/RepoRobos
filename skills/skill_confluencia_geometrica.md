# Skill: Confluência Geométrica — Zonas de Alta Probabilidade

> Como identificar, construir e validar zonas de confluência geométrica para gatilhos de entrada com máxima eficiência estatística.

---

## O que é Confluência Geométrica

Uma **zona de confluência geométrica** é uma região de preço onde **múltiplas referências independentes** se sobrepõem, indicando que o mercado reconheceu aquele nível como relevante em diferentes momentos e escalas de tempo.

> **Lei da confluência:** quanto mais referências convergem para o mesmo nível, maior a probabilidade de reação forte do preço naquele ponto.

---

## Tipos de Referências Geométricas

### 1. Corpo do Candle (Opção 1)
- Área: `[min(Open, Close), max(Open, Close)]`
- Relevante quando: corpo > 60% do range (candle direcional)
- Projeção: estende-se horizontalmente para a direita até ser "preenchida"

### 2. Range Total (Opção 2)
- Área: `[Low, High]`
- Relevante quando: candle com rejeição forte (pavio > 60% do range)
- Marca o território testado e rejeitado

### 3. Multi-Timeframe
- A mesma zona identificada em TF maior E TF menor = confluência extra
- Regra: zona visível em 3 TFs = **zona premium**
- Tabela de operação (ver `docs/tabela_verdade_timeframes.md`):
  - Opera só quando TF maior + TF médio confirmam mesma direção

### 4. Volume Dominante
- VWAP do dia: zona de equilíbrio volumétrico
- POC (Point of Control): preço com maior volume negociado
- Cluster de volume: região com volume > 3× a média dos vizinhos

### 5. Fibonacci
| Retração | Significado |
|---|---|
| 38.2% | Primeira retração — continuação de tendência |
| 50.0% | Nível psicológico — zona de equilíbrio |
| 61.8% | Retração "de ouro" — maior convergência institucional |
| 78.6% | Última defesa da tendência |

---

## Construção das Áreas Operacionais

### Algoritmo de construção

```python
def construir_areas(df, forca_minima=60, vol_mult=2.0):
    """Retorna lista de áreas com nível, tipo e força."""
    areas = []
    vol_media = df['Volume'].rolling(20).mean()

    for i, row in df.iterrows():
        forca = calcular_forca(row)
        volume_ok = row['Volume'] >= vol_media.iloc[i] * vol_mult

        if abs(forca) >= forca_minima or volume_ok:
            corpo_min = min(row['Abertura'], row['Fechamento'])
            corpo_max = max(row['Abertura'], row['Fechamento'])
            range_min = row['Minimo']
            range_max = row['Maximo']

            areas.append({
                'datetime'  : row['DateTime'],
                'corpo_min' : corpo_min,
                'corpo_max' : corpo_max,
                'range_min' : range_min,
                'range_max' : range_max,
                'forca'     : forca,
                'vies'      : 'compra' if forca > 0 else 'venda',
                'tipo'      : 'forca' if abs(forca) >= forca_minima else 'volume',
            })
    return areas
```

### Critério de sobreposição (confluência)

```python
def calcular_confluencias(areas, tolerancia=50):
    """
    Para cada par de áreas, verifica se há intersecção de corpo.
    tolerancia: buffer em pontos para considerar "próximo"
    """
    zonas = {}

    for i, a1 in enumerate(areas):
        for j, a2 in enumerate(areas):
            if i >= j:
                continue
            # Intersecção entre [corpo_min, corpo_max] de a1 e a2
            intersect_min = max(a1['corpo_min'], a2['corpo_min']) - tolerancia
            intersect_max = min(a1['corpo_max'], a2['corpo_max']) + tolerancia

            if intersect_min <= intersect_max:
                nivel = round((intersect_min + intersect_max) / 2 / 5) * 5  # arredondar para tick
                chave = nivel
                if chave not in zonas:
                    zonas[chave] = {'nivel': nivel, 'confluencias': 0, 'vies': []}
                zonas[chave]['confluencias'] += 1
                zonas[chave]['vies'].append(a1['vies'])

    # Ordenar por número de confluências
    return sorted(zonas.values(), key=lambda z: z['confluencias'], reverse=True)
```

---

## Critérios de Qualidade da Zona

| Confluências | Qualidade | Ação |
|---|---|---|
| 5+ | 🔴 Premium | Entrada com tamanho máximo |
| 3–4 | 🟡 Alta | Entrada padrão |
| 2 | 🟢 Moderada | Entrada com confirmação extra |
| 1 | ⚪ Baixa | Não operar |

---

## Gatilho de Entrada em Zona de Confluência

```
Condição de entrada LONG:
  1. Preço retorna para zona de confluência de COMPRA (vies = compra)
  2. Candle de força aparece: fForca >= ForcaMinimaEntrada
  3. Volume confirmado: Volume >= Media(20) × 1.5
  4. TF maior e médio em tendência de alta (semáforo verde)
  5. RRR calculado: (próximo alvo) / (SL da estrutura) >= 2.0
  → BuyAtMarket

Condição de entrada SHORT:
  Simétrico para venda.
```

---

## Definição do Stop Loss

O SL é sempre posicionado **fora da estrutura geométrica que define a zona**:

```
SL_Long  = Mínimo da zona de confluência - buffer (5 pts)
SL_Short = Máximo da zona de confluência + buffer (5 pts)

Exemplo:
  Zona: [167.100, 167.250]
  Entrada Long @ 167.200
  SL = 167.100 - 5 = 167.095  →  SL de 105 pts
  SG mínimo (RRR 2.0) = 167.200 + 210 = 167.410
```

---

## Invalidação de Zona

Uma zona de confluência é invalidada quando:
1. O preço **fecha além dos limites** da zona (não apenas toca)
2. O preço permanece do outro lado por **≥ 3 candles consecutivos**
3. Uma nova zona com **mais confluências** se forma no mesmo nível com viés oposto
