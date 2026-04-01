---
description: Gera o PLANO de um robô NTSL antes de qualquer código — para o usuário aprovar a estrutura
---

# Prompt: Plano Pré-Robô — Aprovação Antes de Codar

> **Usar antes de `gerar_robo_ntsl.prompt.md`.**
> Nunca gerar código sem o usuário ter aprovado o plano.

---

## 🤖 Modelo recomendado por etapa (economizar request premium)

| Etapa | Modelo | Motivo |
|---|---|---|
| **Este plano** (descrever + aprovar) | **GPT-4o-mini** | Texto estruturado simples, sem código |
| **Gerar o robô completo** (após "ok, gera") | **Claude Sonnet** | Contexto longo + código complexo |
| **Corrigir erro de sintaxe pontual** | **GPT-4o-mini** + anexar `skill_ntsl_syntax.md` | Correção local, barata |
| **Ajustar template existente** | **GPT-4o** | Edição média com contexto dado |
| **Avaliar resultado do backtest** | **o3-mini** | Raciocínio estatístico |

> ⚠️ Troca de modelo é **manual** no seletor do Copilot Chat — o Copilot ativo não se autosubstitui.

---

## Instruções

Apresente o plano abaixo em formato de tabela e checklist **sem escrever nenhuma linha de código**.
Aguarde o usuário dizer **"ok, gera"** ou pedir ajustes antes de continuar.

---

## Template de Plano

### 🎯 PLANO DO ROBÔ — ${input:nomeRobo:nome_do_robo}

#### 1. Identidade
| Campo | Valor |
|---|---|
| **Ativo** | ${input:ativo:WIN B3} |
| **Timeframe** | ${input:timeframe:5min} |
| **Indicador principal** | ${input:indicador:OBV / IFR / MACD / ATR...} |
| **Pasta destino** | `robos/${input:pasta:INDICADOR}/` |
| **Nome do arquivo** | `${input:mes:abril}_${input:nomeArquivo:indicador_descricao}_v001.ntsl` |

---

#### 2. Hipótese de Trade
> Em 1 ou 2 frases: qual padrão ou sinal gera a entrada?

${input:hipotese:Ex.: OBV acelerando + candle de força no TF gatilho, com contexto alinhado no TF superior}

---

#### 3. Tripleta de Timeframes
| Papel | Timeframe | Condição |
|---|---|---|
| **Contexto (TF1)** | ${input:tf1:30min} | ${input:cond1:OBV / MA / tendência} |
| **Direção (TF2)** | ${input:tf2:15min} | ${input:cond2:OBV / MM alinhada} |
| **Gatilho (TF3)** | ${input:tf3:5min} | ${input:cond3:candle de força + volume} |

Parâmetros proxy: `iJanelaDir = ${input:janelaDir:3}`, `iJanelaCtx = ${input:janelaCtx:6}`

---

#### 4. Regras de Entrada
| Lado | Condição resumida |
|---|---|
| **COMPRA** | ${input:entradaCompra:Ex.: bContextoAlta AND bDirecaoAlta AND fForca >= 60 AND Volume >= MediaVol*1.5} |
| **VENDA** | ${input:entradaVenda:Ex.: bContextoBaixa AND bDirecaoBaixa AND fForca <= -60 AND Volume >= MediaVol*1.5} |

---

#### 5. Gestão de Risco
| Campo | Valor |
|---|---|
| **Stop Loss (SL)** | ${input:sl:Ex.: Mínima do swing / ATR×1.5 / buffer de 5pts na estrutura} |
| **Take Profit (TP)** | `SL × RRR_Minimo` |
| **RRR mínimo** | `${input:rrr:2.0}` |
| **Stop horário** | `17:45` (padrão) |
| **Máx. barras em posição** | `${input:maxBarras:8}` |
| **Volume mínimo** | `Média(20, Volume) × ${input:volMult:1.5}` |

---

#### 6. Gradiente de Cores
| Candle | Cor |
|---|---|
| Alta forte + contexto alinhado | 🔵 Azul |
| Alta forte sem contexto | 🟢 Verde degradê |
| Indecisão (corpo < 10% range) | ⬜ Branco |
| Baixa forte sem contexto | 🔴 Vermelho degradê |
| Baixa forte + contexto alinhado | 🟣 Roxo/Violeta |

---

#### 7. Checklist de Compilação (auto-revisão antes de entregar)
- [ ] **`Hour`/`Minute`/`Exit` NÃO usados** → `Time() >= (H * 10000 + M * 100)` + `bDeveOperar`
- [ ] **`div`/`mod` NÃO usados** → comparar `Time()` diretamente com HHMMSS calculado
- [ ] **Aspas duplas** `"texto"` em todas as strings
- [ ] **Nomes de variáveis sem espaço** (camelCase)
- [ ] **`Format()`/`Floor()` NÃO usados** → `IntToStr(Round())` / truncamento manual
- [ ] **Multi-line `and`** sempre envolvido em `(...)`
- [ ] **Divisão por zero** prevenida (`if fRange < 0.01 then fRange := 0.01`)
- [ ] **RGB clampado** 0–255
- [ ] **`PlotText`/`Alert`/`DrawArrow`** apenas em `.ntfl`, NUNCA em `.ntsl`
- [ ] **RRR verificado** antes de `BuyAtMarket` / `SellShortAtMarket`
- [ ] **Cabeçalho** completo com ativo, TF, versão, RRR, SL referência

---

#### 8. Parâmetros Inputs padrão
```
ForcaMinimaEntrada  = 60.0
RRR_Minimo          = 2.0
VolumeMultiplicador = 1.5
StopHorario_H       = 17  / StopHorario_M = 45
HoraInicioH         = 9   / HoraInicioM   = 15
MaxBarrasEmPosicao  = 8
```

---

**⏸️ AGUARDANDO APROVAÇÃO DO USUÁRIO**
> Responda **"ok, gera"** para receber o código completo, ou indique o que ajustar.
