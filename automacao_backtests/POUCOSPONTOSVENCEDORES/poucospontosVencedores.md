# Grupo POUCOSPONTOSVENCEDORES (PPV)

## Objetivo
Capturar **pontos vencedores rápidos** durante o dia e **não devolver ao mercado**.  
A filosofia é: entrada precisa, lucro pequeno garantido, saída imediata na inversão.

---

## Filosofia do Grupo

| Característica | Abordagem PPV |
|----------------|---------------|
| Alvo por trade | 80–150 pontos (R$16–R$30) |
| Stop máximo | 60–100 pontos |
| Break-even | Ativar com 50–80 pts favoráveis |
| Trailing stop | Agressivo: 30–50 pts |
| Max trades/dia | 3 (evitar overtrading) |
| Taxa de acerto esperada | > 65% |
| Risco/retorno | 1:1 ou 1:1.5 (compensado pelo acerto alto) |

> **Princípio:** vale mais ganhar menos se tiver quase certeza de não devolver.

---

## Indicadores Explorados

### 1. ATR (Average True Range)
- **Função:** mede volatilidade instantânea
- **Uso PPV:** definir alvo e stop dinamicamente (ex: alvo = 0.8×ATR, stop = 0.6×ATR)
- **Trailing:** atualizar stop a cada barra: `preço - 0.5×ATR` para compradas
- **Vantagem:** se adapta ao mercado (dias agitados = alvos maiores, dias calmos = menores)

### 2. IFR/RSI
- **Uso PPV:** entrada em extremos (IFR<30 compra / IFR>70 venda), saída no IFR=50 (não esperar IFR extremo oposto)
- **Combinação:** IFR entry + trailing stop por ATR → não depende do IFR para sair

### 3. Estocástico Rápido (5,3)
- **Uso PPV:** crossover rápido do %K e %D em zonas extremas (<20 / >80)
- **Vantagem:** mais sensível que IFR, captura movimentos de 2-3 candles
- **Saída:** sair quando %K cruza %D no sentido contrário (não esperar extremo)

### 4. MACD (momentum)
- **Uso PPV:** entrada no cruzamento do MACD com signal em direção da tendência
- **Saída imediata:** fechar quando MACD cruza signal de volta (não aguardar divergência)
- **Filtro:** usar apenas quando histograma cresce (momentum acelerando)

### 5. Parabolic SAR
- **Uso PPV:** trailing stop nativo — o SAR se aproxima do preço conforme trade avança
- **Característica:** força saída automática sem definir alvo fixo
- **Ideal para:** mercados em movimento direcional claro

### 6. Bollinger Bands (squeeze)
- **Uso PPV:** entrada no rompimento das bandas após compressão (squeeze)
- **Saída:** fechar na banda oposta ou na banda média (não aguardar extremo reverso)
- **Vantagem:** captura movimentos explosivos com saída rápida

### 7. Break-Even Automático
- **Não é indicador, é mecanismo:** ao atingir X pontos favoráveis, mover stop para entrada
- **PPV padrão:** break-even em 60 pts, trailing de 40 pts após isso
- **Resultado:** impede loss total, garante pelo menos zero no pior caso

### 8. Price Action (corpo + sombra)
- **Uso PPV:** entrar apenas em candles de alta qualidade (corpo >60% do range)
- **Saída:** fechar em candle de reversão (sombra longa contra a posição)

---

## Estrutura dos Robôs PPV

```
PPV_01 — ATR trailing agressivo (IFR entry)
PPV_02 — Break-even rápido + alvo ATR fixo
PPV_03 — Estocástico rápido + trailing
PPV_04 — MACD momentum + saída no cruzamento
PPV_05 — Parabolic SAR trailing nativo
PPV_06 — Bollinger squeeze saída rápida
PPV_07 — IFR extremo + alvo fixo pequeno
PPV_08 — Price action força + break-even imediato
```

---

## Diferença do PPV vs outros grupos

| | IFR_RSI | CANDLE1 | MEDIAS | **PPV** |
|--|---------|---------|--------|--------|
| Duração do trade | 4–14 barras | 2–8 barras | 5–20 barras | **1–4 barras** |
| Alvo | IFR 50 | 1.5×range C1 | MME cruzamento | **Fixo pequeno** |
| Trailing | Não | Opcional | Não | **Sim — obrigatório** |
| Break-even | Não | Opcional | Não | **Sim — obrigatório** |
| Foco | Reversão | 1º candle | Tendência | **Não devolver** |
