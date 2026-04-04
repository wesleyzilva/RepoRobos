# WESQUAD — Estratégia de Referência

> Fonte original: `PriceAction_Fisica/WESQUAD/wesquad.txt`  
> Robô implementado: `robos/WESQUAD/wesquad_v001.ntsl`  
> Última atualização: 04/04/2026

---

## 1. Conceito Central

Zonas retangulares **±200pts** ao redor do fechamento de candles de referência em 15min e 5min.  
A entrada é confirmada quando o preço **rompe as duas zonas** no mesmo sentido, com gatilho de 2 candles consecutivos com F=MA significante.

**Alvo fixo:** até 150pts  
**Stop:** menor possível — corpo do candle de gatilho  
**Filtro macro:** semáforo 60/30/15 com pelo menos 2 dos 3 TFs no mesmo sentido

---

## 2. Lógica em 3 Camadas

### Camada 1 — Semáforo 60/30/15
- Observar TFs 60min, 30min e 15min simultaneamente
- **Mínimo 2 dos 3 com o mesmo sinal** (verde = compra / vermelho = venda)
- Se apenas 1 TF sinalizar: **não opera**
- Proxy no código (5min): médias de janelas `iJanela15=3`, `iJanela30=6`, `iJanela60=12`

### Camada 2 — Zonas Retangulares
| TF | Seleção do candle | Largura da zona | Cor compra | Cor venda |
|----|-----------------|-----------------|------------|-----------|
| **15min** | Não-esticado: `corpo ≤ 60% range` | `Close ± 200pts` | Ciano | Laranja |
| **5min** | F=MA significante + volume acima da média | `Close ± 200pts` | Verde | Vermelho |

**Regra crítica:** As zonas de compra e venda não podem se tocar — o espaço entre elas é onde o preço se movimenta.

### Camada 3 — Gatilho (2min ou 5min)
- **2 candles consecutivos** com F=MA significante no mesmo sentido (os mais próximos)
- Verde Lima → compra
- Fúcsia → venda
- O preço deve ter **rompido a zona 5min** na direção do trade

---

## 3. SL e SG

| Parâmetro | Valor | Observação |
|-----------|-------|------------|
| **SG** | 150pts fixo | Alvo máximo WESQUAD |
| **SL** | Corpo do candle de gatilho + 5pts buffer | Menor possível |
| **RRR esperado** | ~1.2 a 1.8× | Depende do SL real no backtest |

---

## 4. Regras Operacionais Importantes

1. **Candle de 15min não-esticado obrigatório** — trabalha nos extremos do candle
2. **Candle matador (esticado):** se o preço romper ou devolver todos os TFs, a análise recomeça a partir daquele candle
3. **Zona de venda 15min:** se o preço entrar nessa zona, o risco de SL aumenta — atenção
4. **IFR:** cuidado com sobrecompra/sobrevenda + sinais de reversão com volume considerável
5. **Volume Profile:** pode indicar alvos de SG nas colunas mais evidentes
6. **MME20:** sempre reajustar para os TFs 5, 15, 30, 60

---

## 5. Diferenças vs Estratégia OPCAO1/OPCAO2 (Confluência)

| Aspecto | **WESQUAD** | **OPCAO1/OPCAO2** |
|---------|-------------|------------------|
| Definição de zona | `Close ± 200pts fixo` | Corpo [O/C] ou Range [L/H] do candle |
| SG | **150pts fixo** | ~290pts (ATR×2.0) |
| SL | Corpo do gatilho (~80-120pts) | ATR×1.0 (~145pts) |
| TF de gatilho | **2min/5min** | 5min |
| Padrão de gatilho | **2 candles mesma cor** | 1 barra com F≥60 |
| Semáforo | 60/30/15 — **2 de 3** TFs | Proxy por médias (30/15/5) |
| Filtro esticamento | Sim (corpo ≤ 60% range) | Não |
| SG/SL variável? | Não (fixo) | Sim (ATR adaptativo) |

---

## 6. Parâmetros do Robô `wesquad_v001.ntsl`

| Input | Default | Descrição |
|-------|---------|-----------|
| `ForcaMedia` | 60.0 | Força mínima para sinal operacional |
| `ForcaFraca` | 40.0 | Força mínima para monitorar |
| `ForcaForte` | 80.0 | Força plena (tamanho cheio) |
| `VolumeMultiplicador` | 1.5 | Volume mínimo = média20 × 1.5 |
| `iJanela15min` | 3 | Proxy 15min (3 barras de 5min) |
| `iJanela30min` | 6 | Proxy 30min |
| `iJanela60min` | 12 | Proxy 60min |
| `ZonaPts` | 200.0 | Raio da zona (±200pts ao redor do Close) |
| `MaxCorpoRatio` | 0.60 | Candle não-esticado: corpo ≤ 60% range |
| `SG_Pts` | 150.0 | Take profit fixo |
| `BufferStop` | 5.0 | Buffer adicional no SL |
| `HoraInicio` | 14 | Janela prime (14h-17h30) |
| `ModoBacktestInicial` | true | Relaxa filtros para gerar amostra |

---

## 7. Métricas Alvo (Pendente Backtest)

| Métrica | Hipótese | Base |
|---------|----------|------|
| Sinais/ano | ~80-120 | Filtro 2/3 TFs restringe muito |
| Assertividade | ≥ 50% | Semáforo 2/3 + 2 candles filtram bem |
| SL médio | ~80-120pts | Corpo do candle de gatilho |
| SG | 150pts fixo | WESQUAD hardcoded |
| RRR | ~1.2-1.8× | Depende do SL real |
| Esperança (E) | +15 a +30pts/op | Estimativa inicial |

> **Próximo passo:** rodar backtest no Profit e comparar E (esperança matemática) com OPCAO1 e OPCAO2.

---

## 8. Hipóteses a Validar no Backtest

1. A zona de 200pts fixo é adequada para diferentes regimes de volatilidade do WINFUT?
2. O gatilho de 2 candles consecutivos reduz falsos sinais vs 1 candle?
3. O SG de 150pts é atingido com maior frequência do que o SG de 290pts da OPCAO1?
4. O filtro de candle não-esticado (15min) aumenta a assertividade?
5. O semáforo 2/3 com TFs 60/30/15 é mais conservador ou mais eficiente que o proxy 30/15/5?
