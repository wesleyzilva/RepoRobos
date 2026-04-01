# GitHub Copilot — Instruções do Projeto RepoRobos

---

## ⚡ PROTOCOLO ECONOMIA DE REQUESTS — Ler Primeiro

**Antes de qualquer geração**, percorrer esta sequência do mais barato ao mais caro:

```
1. 🟢 SKILL LOCAL (custo zero)
   → Verificar se a resposta já existe em skills/:
     • Dúvida sobre WIN?         → skills/skill_WIN_caracteristicas.md
     • Dúvida sobre WDO?         → skills/skill_WDO_caracteristicas.md
     • Dúvida de sintaxe NTSL?   → skills/skill_ntsl_syntax.md
     • Dúvida de risco/RRR?      → skills/skill_gestao_risco.md
     • Dúvida de confluência?    → skills/skill_confluencia_geometrica.md
     • Dúvida de price action?   → skills/skill_price_action.md
     • Dúvida de backtest?       → skills/skill_estatisticas_backtest.md

2. 🟡 TEMPLATE (custo baixo — só ajustar parâmetros)
   → Robô de confluência?        → templates/template_robo_confluencia.ntsl
   → Indicador visual?           → templates/template_indicador_areas.ntfl
   → Semáforo multi-TF?          → templates/template_semaforo_multiTF.ntsl

3. 🟡 PROMPT ESTRUTURADO (custo médio)
   → .github/prompts/*.prompt.md — preencher variáveis e executar

4. 🟠 AGENTE ESPECIALISTA (custo médio — responde com base nas skills)
   → agents/agent_WIN_especialista.md  (WIN específico)
   → agents/agent_WDO_especialista.md  (WDO específico)
   → agents/agent_gerador_robo.md      (código NTSL)
   → agents/agent_analisador_candles.md (Python + CSV)
   → agents/agent_backtest_stats.md    (métricas)

5. 🔴 GERAÇÃO PREMIUM (custo alto — só se 1-4 falharam)
   → Criar lógica genuinamente nova que não existe em nenhum template/skill
```

**Orquestrador:** consultar `agents/agent_orquestrador.md` para roteamento completo.

---

## 🤖 Guia de Modelo por Tarefa (decisão manual do usuário)

> ⚠️ A troca de modelo é feita **manualmente no seletor do Copilot Chat** antes de abrir cada conversa.
> Este guia é para o **usuário** — a IA ativa não consegue se autosubstituir por outro modelo.

**Regra:** custo do modelo ∝ complexidade da saída. Não usar Claude Sonnet para o que GPT-4o-mini resolve.

```
VOCÊ SELECIONA MANUALMENTE:

o3-mini        → pensar / decidir estratégia (reasoning > tokens brutos)
Claude Sonnet  → gerar robô NTSL completo do zero (contexto longo + código)
GPT-4o         → ajustar template existente (edição pontual com contexto dado)
GPT-4o-mini    → análise CSV Python / editar docs / debugar sintaxe NTSL
Copilot Inline → organizar arquivos/pastas (Ctrl+I, sem abrir Chat)
qualquer       → perguntas WIN/WDO/ATR (resposta já está nas skills locais)
```

| Etapa do Workflow | Selecionar antes de abrir o Chat |
|---|---|
| 1. Design da hipótese / estratégia | **o3-mini** |
| 2. Análise dos dados CSV | **GPT-4o-mini** |
| 3. Indicador visual `.ntfl` | **GPT-4o** (com template como contexto) |
| 4. Robô `.ntsl` completo do zero | **Claude Sonnet** |
| 5. Avaliação estatística do backtest | **o3-mini** |
| 6. Documentar / atualizar README | **GPT-4o-mini** |
| 7. 🔍 Revisar / corrigir sintaxe NTSL | **GPT-4o-mini** + anexar `skills/skill_ntsl_syntax.md` |

---

## 🏦 Ativos Principais

| Ativo | Arquivo de referência | Timeframe padrão |
|---|---|---|
| **WIN** (Mini Índice) | `skills/skill_WIN_caracteristicas.md` | 5min + 60min |
| **WDO** (Mini Dólar) | `skills/skill_WDO_caracteristicas.md` | 5min + 60min |

---

## 🎯 Objetivo Principal
Desenvolver **robôs NTSL/NTFL para Neologica Profit** que identificam **áreas de confluência geométrica** como zonas de gatilho de alta probabilidade, buscando sempre:
- **SG (Stop Gain) máximo** — aproveitar o momentum confirmado
- **SL (Stop Loss) mínimo** — posicionar o stop abaixo/acima da estrutura mais próxima
- **RRR (Razão Risco/Recompensa) ≥ 2.0** como critério mínimo de entrada

O trader é **especialista em matemática, geometria e Python**, com dados históricos de candles de 1 minuto desde 2012 disponíveis localmente para backtesting.

---

## 🗂️ Estrutura do Workspace

```
RepoRobos/
├── .github/
│   ├── copilot-instructions.md   ← este arquivo
│   ├── prompts/                  ← prompts reutilizáveis para Copilot
│   └── ISSUE_TEMPLATE/           ← templates de issues
├── skills/                       ← conhecimento especializado por domínio
├── agents/                       ← definições de agentes especializados
├── templates/                    ← templates NTSL prontos para uso
├── robos/                        ← robôs e indicadores aprovados — subpastas por indicador
│   ├── IFR/ | MACD/ | MEDIA20200/   ← exemplos de subpastas já existentes
│   └── ATR/ | ADX/ | VWAP/ | OBV/ | VOLUME/ | FORCA/ | PADROES/ | CONFLUENCIA/
│   Nomear: {mes}_{indicador}_{descricaoCurta}_v{NNN}.ntfl|ntsl
│   Exemplo: abril_ifr_divergencia_v001.ntfl  →  robos/IFR/
├── scripts/                      ← scripts Python de análise e backtest
├── DadosCandlesBacktest/         ← dados históricos OHLCV em CSV
│   ├── 2012_14/ ... 2024_26/    ← pastas por biênio
│   └── analiseCandles.md         ← documentação dos dados
└── docs/                         ← referências e documentação
    ├── tabela_verdade_timeframes.md  ← tripletas TF1/TF2/TF3
    ├── cores_candles_degrade.md      ← gradiente RGB
    ├── exemplos_codigo_pascal.md     ← exemplos NTSL
    ├── regras_semaforo_operacao.md
    ├── opcao1_definicao_areas_operacao_corpoCandle.md
    ├── opcao2_definicao_areas_operacao_maxima_minima.md
    └── README_MCP.md                 ← guia MCP
```

---

## 🏗️ Dados de Candles Disponíveis

**Localização:** `DadosCandlesBacktest/2024_26/`
**Ativos:** WINJ26, WDOJ26, WINFUT, WDOFUT
**Timeframes:** 1min, 5min, 10min, 15min, 20min, 30min, 60min, Diário, Semanal

**Formato CSV (separador `;`):**
```
Ativo;Data;Hora;Abertura;Máximo;Mínimo;Fechamento;Volume;Quantidade
WINJ26;30/12/2025;18:24:00;167.090;167.090;167.080;167.080;300.752,00;9
```
- Data: `dd/mm/aaaa` | Hora: `HH:MM:SS`
- Preços: 3 casas decimais, ponto como separador decimal
- Volume: padrão brasileiro (`.` milhar, `,` decimal)
- Ordenação: **descendente** (mais recente primeiro)

---

## 📐 Conceito Central: Confluência Geométrica

### O que é
Zona onde **múltiplas referências geométricas** convergem em um mesmo nível de preço. Quanto maior a sobreposição, maior a pressão institucional esperada naquela região.

### Tipos de referências válidas
| Referência | Descrição |
|---|---|
| Corpo do candle | Abertura/fechamento de candles relevantes |
| Máxima/Mínima | Extremos de candles de força ou volume |
| Áreas sobrepostas | Dois ou mais retângulos de operação com intersecção |
| Multi-timeframe | Mesma zona visível em TF maior E menor |
| Volume dominante | VWAP, POC ou clusters de volume elevado |
| Fibonacci | Retrações 38.2%, 50%, 61.8% do swing atual |

### Critério de entrada (gatilho)
```
CONFLUÊNCIA GEOMÉTRICA (≥ 2 referências) + CANDLE DE FORÇA + CONFIRMAÇÃO MULTI-TF
→ Zona de Gatilho de Alta Probabilidade
```

---

## ⚡ Sistema de Força F = M × A

A base de todos os robôs deste projeto é o cálculo de força direcional:

```pascal
fCorpoCandle := Close - Open;
fRangeCandle := High - Low;
if fRangeCandle < 0.01 then fRangeCandle := 0.01;

fMassa       := fCorpoCandle / fRangeCandle;          // -1.0 a +1.0
fVolumeMedio := Media(20, Volume);
fAceleracao  := Volume / fVolumeMedio;                // ratio vs média 20

fForca := fMassa * fAceleracao * 100;                 // -100 a +100
if fForca >  100 then fForca :=  100;
if fForca < -100 then fForca := -100;
```

**Limiares operacionais:**
| Faixa | Significado |
|---|---|
| `fForca >= +60` | Compra forte — considerar entrada long |
| `+20 <= fForca < +60` | Tendência de alta moderada |
| `-20 < fForca < +20` | Indecisão — candle branco |
| `-60 < fForca <= -20` | Tendência de baixa moderada |
| `fForca <= -60` | Venda forte — considerar entrada short |

---

## 🎨 Sistema de Cores (Gradiente RGB)

```pascal
// Gradiente Verde (compra)
iCorG := 128 + Round((fForca / 100) * 127);   // 128..255
iCorR := 128 - Round((fForca / 100) * 128);   // 128..0
iCorB := 128 - Round((fForca / 100) * 128);   // 128..0

// Gradiente Vermelho (venda)
iCorR := 128 + Round((-fForca / 100) * 127);  // 128..255
iCorG := 128 - Round((-fForca / 100) * 128);  // 128..0
iCorB := 128 - Round((-fForca / 100) * 128);  // 128..0

// Branco = indecisão (corpo < 10% do range)
// Cinza  = RGB(128, 128, 128) — padrão
```

**Cores especiais:**
| Cor | Condição |
|---|---|
| Laranja `RGB(255,165,0)` | Rejeição forte (pavio > 60% do range) |
| Amarelo `RGB(255,215,0)` | Anomalia de volume (> 3× média) |
| Azul `RGB(0,128,255)` | Confirmação multi-timeframe |

---

## 🚦 Sistema de Tripletas de Timeframes

Toda operação usa **3 TFs em cadeia**: `Contexto → Direção → Gatilho`

| Posição | Papel | Regra |
|---|---|---|
| TF1 — Contexto (maior) | Define o viés do dia | Deve estar "operando" |
| TF2 — Direção (médio) | Confirma o viés | Deve estar "operando" |
| TF3 — Gatilho (menor) | Sinal de entrada | Define SL e SG |

**Opera SOMENTE quando TF1 + TF2 estão alinhados. TF3 executa.**

### Tripletas padrão (ver `docs/tabela_verdade_timeframes.md`)

| Tripleta | Perfil | SL Gatilho WIN | SL Gatilho WDO |
|---|---|---|---|
| 60 / 30 / 15 | Estrutural | 250 pts | 10 pts |
| **30 / 15 / 5** ⭐ | Day trade (padrão) | 150 pts | 6 pts |
| 15 / 5 / 1 | Scalping | 80 pts | 3 pts |

**Tripleta padrão do projeto: 30/15/5** para WIN e WDO.

### Proxy em NTSL (robot rodando no TF3 = 5min, tripleta 30/15/5)
```pascal
iJanelaDir := 3;  // 15min = 3 × 5min
iJanelaCtx := 6;  // 30min = 6 × 5min
fMediaDir  := Media(iJanelaDir, Close);
fMediaCtx  := Media(iJanelaCtx, Close);
bContextoAlta := (Close > fMediaCtx) and (fMediaCtx > fMediaCtx[iJanelaCtx]);
bDirecaoAlta  := (Close > fMediaDir) and (fMediaDir > fMediaDir[iJanelaDir]);
// Opera long apenas: bContextoAlta AND bDirecaoAlta AND fForca >= ForcaMinima
```

**Filtro de robustez (semáforo):**
- Sinal deve persistir por **≥ 2 candles consecutivos** no mesmo lado
- Reversão rápida para cinza/branco → não opera
- Candle de indecisão no TF2 → suspende novas entradas

---

## 🛡️ Gestão de Risco

```
SL = Extremo da estrutura mais próxima (mín/máx do padrão)
SG = SL × RRR_minimo  (onde RRR_minimo = 2.0)

Exemplo (WIN):
  SL = 80 pts → SG mínimo = 160 pts
  SL = 120 pts → SG mínimo = 240 pts
```

**Regras adicionais:**
- Stop horário: fechar posição antes das 17:45
- Máximo de barras em posição: 8 candles (evitar travar capital)
- Não operar abertura (09:00–09:15) e fechamento (17:45–18:00)
- Spread mínimo a descontar: 10 pts por trade (5 entrada + 5 saída)
- Slippage fictício mínimo: 15 pts por trade

---

## 💻 Regras NTSL/NTFL

### ⚠️ ERROS CRÍTICOS DE COMPILAÇÃO — confirmados em produção

| ❌ ERRADO | ✅ CORRETO | Motivo |
|---|---|---|
| `Hour`, `Minute`, `Second` | `Time() div 10000` / `(Time() mod 10000) div 100` | Não existem em NTSL |
| `Exit;` | `bDeveOperar := false` + wrapper `if bDeveOperar then` | Não existe em NTSL |
| `'texto single quotes'` | `"texto double quotes"` | NTSL exige aspas duplas |
| `bAcelerando Alta` (espaço) | `bAcelerandoAlta` (camelCase) | Espaço invalida identificador |
| `Format('%.0f', [x])` | `IntToStr(Round(x))` | Format() não existe em NTSL |
| `Floor(x)` | `x := x; if x < 1 then x := 1;` | Floor() não existe em NTSL |
| `DrawArrow(...)` em `.ntfl` | `PaintBar(RGB(...))` + `PlotText(...)` | DrawArrow inválido |
| Multi-line `and` sem `()` | Envolver condição inteira em `(...)` | "Deve vir ;" parse error |

**`Time()` retorna HHMMSS como inteiro** — ex: `091500` = 09:15:00:
```pascal
iHoraAtual   := Time() div 10000;            // extrai HH
iMinutoAtual := (Time() mod 10000) div 100;  // extrai MM
```

**Padrão OBRIGATÓRIO para stop de horário** (NUNCA usar Hour/Exit):
```pascal
// Na seção var: adicionar estas 3 variáveis
iHoraAtual   : integer;
iMinutoAtual : integer;
bDeveOperar  : boolean;

// No begin:
iHoraAtual   := Time() div 10000;
iMinutoAtual := (Time() mod 10000) div 100;

if (iHoraAtual > StopHorario_H) or
   ((iHoraAtual = StopHorario_H) and (iMinutoAtual >= StopHorario_M)) then
begin
  if IsBought or IsSold then ClosePosition;
  bDeveOperar := false;
end
else
  bDeveOperar := (iHoraAtual > HoraInicioH) or
                 ((iHoraAtual = HoraInicioH) and (iMinutoAtual >= HoraInicioM));

// Toda a lógica de barras + entradas DENTRO do if bDeveOperar:
if bDeveOperar then
begin
  // controle de barras e entradas aqui
end;
```

---

### Em ROBÔS (`.ntsl`) — permitido:
```pascal
PaintBar(RGB(r, g, b));      // colorir candle
BuyAtMarket;                  // comprar a mercado
SellShortAtMarket;            // vender a mercado
ClosePosition;                // fechar posição
BuyLimit(preco, quantidade);  // compra limitada
SellLimit(preco, quantidade); // venda limitada
```

### Em INDICADORES (`.ntfl`) — permitido adicionalmente:
```pascal
PlotText("texto", cor, tamanho, estilo, preco);  // aspas DUPLAS obrigatório
Alert(cor);
// DrawArrow — NÃO usar, identificador inválido
DrawLine(preco1, preco2, cor, espessura);
```

### ❌ NUNCA em robôs:
```
PlotText(), Alert(), DrawArrow(), DrawLine()
```

### Cabeçalho padrão obrigatório:
```pascal
{
  Robo: NOME_DO_ROBO
  Descricao: objetivo em uma linha
  Ativo: WIN B3 / WDOB3
  Timeframe: Xmin
  Versao: 1.0
  RRR_minimo: 2.0
  SL_referencia: estrutura / ATR / range
}
```

---

## 📊 Métricas de Avaliação de Backtest

Ao analisar resultados, sempre reportar:

| Métrica | Definição | Alvo |
|---|---|---|
| **Taxa de acerto** | trades vencedores / total | ≥ 45% |
| **RRR médio** | SG médio / SL médio | ≥ 2.0 |
| **Fator de lucro** | soma ganhos / soma perdas | ≥ 1.5 |
| **Drawdown máximo** | pior sequência de perdas | ≤ 15% capital |
| **Esperança matemática** | (acerto × SG) - (perda × SL) | > 0 |
| **Sharpe Ratio** | retorno / desvio padrão | ≥ 1.0 |

**Descontar sempre:** spread (10 pts) + slippage (15 pts) = **25 pts por trade**

---

## 🔄 Workflow de Desenvolvimento

```
1. HIPÓTESE    → definir padrão/confluência alvo
2. INDICADOR   → criar .ntfl para visualização + validação visual
3. DADOS       → analisar CSV DadosCandlesBacktest/ para confirmar padrão
4. ROBÔ        → converter lógica validada para .ntsl
5. BACKTEST    → executar Tick a Tick no Profit (com spread/slippage)
6. ESTATÍSTICA → calcular métricas acima; descartar se fator < 1.5
7. OTIMIZAR    → ajustar parâmetros; evitar overfitting
8. COMMIT      → salvar em robos/ com métricas no cabeçalho
```

---

## 🤖 Instruções para o Copilot

1. **Ao gerar código NTSL**: sempre incluir cabeçalho padrão, validar RRR antes de entrar, aplicar stop horário às 17:45, descontar spread/slippage nos comentários
2. **Ao analisar dados CSV**: usar pandas/Python, separador `;`, encoding `latin1`, formato de data `%d/%m/%Y %H:%M:%S`
3. **Ao sugerir entradas**: sempre indicar onde colocar o SL baseado na estrutura geométrica mais próxima, calcular SG mínimo como SL × 2.0
4. **Ao criar indicadores**: usar `.ntfl`, pode usar PlotText/Alert para visualização (DrawArrow inválido)
5. **Ao falar de confluência**: citar quantas referências geométricas se sobrepõem e de que tipo
6. **Ao otimizar**: advertir sobre overfitting se o período de teste < 90 dias ou < 100 trades
7. **Idioma**: sempre responder em **português brasileiro**

### 📋 Regra do Plano (OBRIGATÓRIO antes de criar qualquer robô)
> Antes de gerar código NTSL, **sempre apresentar o plano** usando o template de `.github/prompts/plano_pre_robo.prompt.md` e **aguardar aprovação**.
> O plano é uma tabela estruturada sem código que responde: hipótese, tripleta, SL, RRR, nome do arquivo.
> Só gerar o código após o usuário dizer **"ok, gera"** ou equivalente.

### ✅ Regra do TODO (rastreamento de progressão)
> A cada atividade iniciada ou concluída, **atualizar o TODO** com os estados `in-progress` → `completed`.
> Ao receber uma nova tarefa multi-etapa, criar o TODO antes de iniciar qualquer trabalho.
> O TODO é o contrato de progresso com o usuário.
