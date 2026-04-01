---
description: Converte dados CSV de candles em análise Python estruturada para identificação de padrões
---

# Prompt: Análise de Padrões de Candles em Python

## Contexto
Você é especialista em análise de dados financeiros com Python/Pandas. Use os dados históricos disponíveis localmente.

## Tarefa
Analise os padrões de candles do ativo **${input:ativo:WINJ26}** para o período **${input:periodo:2024_26}** e timeframe **${input:timeframe:1min}**.

## Código base de leitura

```python
import pandas as pd
import numpy as np
from pathlib import Path

BASE = Path(r'C:\repositorio_wes\RepoRobos\DadosCandlesBacktest')
ATIVO = '${input:ativo:WINJ26}'
TF    = '${input:timeframe:1min}'
PERIODO = '${input:periodo:2024_26}'

def ler_candles(ativo: str, tf: str, periodo: str) -> pd.DataFrame:
    """Lê arquivo CSV de candles e retorna DataFrame normalizado."""
    caminho = BASE / periodo / f'{ativo}_F_0_{tf}.csv'
    df = pd.read_csv(caminho, sep=';', encoding='latin1')
    df.columns = ['Ativo','Data','Hora','Abertura','Maximo','Minimo','Fechamento','Volume','Quantidade']
    df['DateTime'] = pd.to_datetime(df['Data'] + ' ' + df['Hora'], format='%d/%m/%Y %H:%M:%S')
    for col in ['Abertura','Maximo','Minimo','Fechamento']:
        df[col] = df[col].astype(str).str.replace('.','',regex=False).str.replace(',','.',regex=False).astype(float)
    df['Volume'] = df['Volume'].astype(str).str.replace('.','',regex=False).str.replace(',','.',regex=False).astype(float)
    df = df.sort_values('DateTime').reset_index(drop=True)
    return df

df = ler_candles(ATIVO, TF, PERIODO)
```

## Indicadores a calcular

```python
# Força direcional F = M × A
df['Corpo']      = df['Fechamento'] - df['Abertura']
df['Range']      = df['Maximo'] - df['Minimo']
df['Massa']      = df['Corpo'] / df['Range'].replace(0, 0.01)
df['VolMedia20'] = df['Volume'].rolling(20).mean()
df['Aceleracao'] = df['Volume'] / df['VolMedia20']
df['Forca']      = (df['Massa'] * df['Aceleracao'] * 100).clip(-100, 100)

# Classificação do candle
df['Tipo'] = 'neutro'
df.loc[df['Forca'] >= 60,  'Tipo'] = 'forca_alta'
df.loc[df['Forca'] <= -60, 'Tipo'] = 'forca_baixa'
df.loc[df['Corpo'].abs() / df['Range'].replace(0, 0.01) < 0.10, 'Tipo'] = 'indecisao'

# Pavios (shadow)
df['PavioSup'] = df['Maximo'] - df[['Abertura','Fechamento']].max(axis=1)
df['PavioInf'] = df[['Abertura','Fechamento']].min(axis=1) - df['Minimo']
df['RejeicaoForte'] = (df['PavioSup'] + df['PavioInf']) / df['Range'].replace(0, 0.01) > 0.60
```

## Análises solicitadas

1. **Distribuição de força** por hora do dia
2. **Padrões de reversão** — força alta seguida de rejeição forte
3. **Confluência de corpos** — quantos candles têm abertura/fechamento próximos (± 50 pts)
4. **Volume vs acerto direcional** — trades com volume > 2× média têm maior acerto?
5. **Melhores horários de entrada** por taxa de acerto histórica

## Formato de saída esperado
- DataFrames resumidos com groupby por hora
- Heatmap de acerto × hora × dia_semana
- Top 10 zonas de confluência com coordenadas de preço
