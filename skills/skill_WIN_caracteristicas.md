# Skill: WIN — Mini Índice Bovespa (WINFUT / WINJ26)

> Referência técnica completa do ativo WIN B3 com dados estatísticos reais extraídos dos CSVs históricos (2024_26).

---

## Especificações do Contrato

| Item | Valor |
|---|---|
| Código Profit | WINJ26 (vencimento junho/26), WINFUT (contínuo) |
| Ativo subjacente | Índice Bovespa (IBOV) |
| Multiplicador | **R$ 0,20 por ponto** |
| Tick mínimo | **5 pontos = R$ 1,00** |
| Garantia mínima | ~R$ 1.500–2.000 por contrato |
| Vencimento | 3ª segunda-feira dos meses pares (fev, abr, jun, ago, out, dez) |
| Código de vencimento | W (win) + mês + ano: WING25, WINJ25, WINK25... |
| Liquidação | Financeira — diferença com IBOV no vencimento |

---

## Sessão de Negociação

| Período | Horário | Observação |
|---|---|---|
| Pré-abertura | 09:00 | Leilão de abertura |
| **Abertura** | **09:00** | Spread e volatilidade máximos |
| Horário principal | **09:15–17:40** | Operar neste intervalo |
| Pré-fechamento | 17:40–17:55 | Volume caindo, realizar posições |
| Fechamento (leilão) | 17:55–18:00 | Não operar |
| After market | Não existe para WIN | — |

**Regra de código:**
```pascal
// Iniciar: 09:15 | Encerrar: 17:45
if (Hour < 9) or ((Hour = 9) and (Minute < 15)) then Exit;
if (Hour >= 17) and (Minute >= 45) then begin ClosePosition; Exit; end;
```

---

## Estatísticas Reais — Dados 2024_26 (WINFUT, n=36–43k candles)

### Range e ATR por Timeframe (todos os TFs das tripletas)

| Timeframe | ATR mediano | Range P90 | SL recomendado | SG (RRR 2.0) |
|---|---|---|---|---|
| **1 min** | 67 pts | 146 pts | 80 pts | 160 pts |
| **5 min** | 146 pts | 305 pts | 150 pts | 300 pts |
| **10 min** | 203 pts | 424 pts | 200 pts | 400 pts |
| **15 min** | 249 pts | 524 pts | 250 pts | 500 pts |
| **20 min** | 283 pts | 597 pts | 280 pts | 560 pts |
| **30 min** | 355 pts | 744 pts | 350 pts | 700 pts |
| **60 min** | 492 pts | 1.045 pts | 500 pts | 1.000 pts |

> **P90** = 90% dos candles têm range abaixo deste valor (referência para stop conservador)

---

## Sistema de Tripletas para WIN

> Referência completa: `docs/tabela_verdade_timeframes.md`

Cada operação usa 3 TFs em cadeia: **Contexto → Direção → Gatilho**.
Opera SOMENTE quando TF1 (Contexto) **e** TF2 (Direção) estão alinhados.
TF3 (Gatilho) define o momento de entrar, o SL e o SG.

### Regra matemática obrigatória

> `iJanelaDir = TF2 ÷ TF3` e `iJanelaCtx = TF1 ÷ TF3` devem ser **inteiros exatos**.
> `30/15/10` é **inválida** (15÷10=1,5). Use `30/15/5` ou `30/20/10` no lugar.

### Tripletas disponíveis para WIN

| Tripleta | TF3 | iJanelaDir | iJanelaCtx | Perfil | SL | SG | R$/ctto |
|---|---|---|---|---|---|---|---|
| **60 / 30 / 15** | 15min | 2 | 4 | Estrutural | 250 pts | 500 pts | R$ 50 |
| **30 / 15 / 5** ⭐ | 5min | 3 | 6 | Day trade (padrão) | 150 pts | 300 pts | R$ 30 |
| **15 / 10 / 5** | 5min | 2 | 3 | Day trade alternativo | 150 pts | 300 pts | R$ 30 |
| **30 / 10 / 5** | 5min | 2 | 6 | Day trade alternativo | 150 pts | 300 pts | R$ 30 |
| **60 / 20 / 5** | 5min | 4 | 12 | Híbrido | 150 pts | 300 pts | R$ 30 |
| **15 / 5 / 1** | 1min | 5 | 15 | Scalping | 80 pts | 160 pts | R$ 16 |

### Proxy multi-TF em NTSL (janelas para tripleta 30/15/5 rodando em 5min)
```pascal
// TF2 (15min) em 5min = 3 barras → iJanelaDir = 3
// TF1 (30min) em 5min = 6 barras → iJanelaCtx = 6
iJanelaDir := 3;
iJanelaCtx := 6;
fMediaDir  := Media(iJanelaDir, Close);
fMediaCtx  := Media(iJanelaCtx, Close);
bContextoAlta := (Close > fMediaCtx) and (fMediaCtx > fMediaCtx[iJanelaCtx]);
bDirecaoAlta  := (Close > fMediaDir) and (fMediaDir > fMediaDir[iJanelaDir]);
// Opera apenas com bContextoAlta AND bDirecaoAlta
```

### Tabela de janelas por tripleta (rodando no TF3)

| Tripleta | TF3 robô | Janela TF2 | Janela TF1 |
|---|---|---|---|
| 60/30/15 | 15min | 2 barras (30÷15) | 4 barras (60÷15) |
| 30/15/5  | 5min  | 3 barras (15÷5)  | 6 barras (30÷5)  |
| 15/10/5  | 5min  | 2 barras (10÷5)  | 3 barras (15÷5)  |
| 30/10/5  | 5min  | 2 barras (10÷5)  | 6 barras (30÷5)  |
| 60/20/5  | 5min  | 4 barras (20÷5)  | 12 barras (60÷5) |
| 15/5/1   | 1min  | 5 barras (5÷1)   | 15 barras (15÷1) |

---

## Custos Reais por Trade (WIN)

| Custo | Valor | Observação |
|---|---|---|
| Spread horário principal | 5 pts | Bid-Ask mínimo em mercado líquido |
| Spread abertura/fechamento | 15–50 pts | 09:00–09:15 e 17:45–18:00 |
| Slippage típico | 5–15 pts | A mercado em condição normal |
| Corretagem média | 5–10 pts equivalente | Variável por corretora |
| **Total conservador** | **25 pts/trade** | Desconto mínimo no backtest |
| **Total abertura** | **40–60 pts/trade** | Se operar na abertura |

---

## Correlações Externas

| Índice | Correlação | Horário crítico |
|---|---|---|
| S&P 500 (SPX) | Alta positiva | NYSE abre 14:30 BRT — muito impacto |
| Dólar (USDBRL/WDO) | Negativa moderada | WDO sobe → WIN tende a cair |
| Petróleo (WTI) | Moderada positiva | Via PETR3/PETR4 (~12% do IBOV) |
| Juros (DI1 futuro) | Negativa | Juros sobem → IBOV cai |
| VALE3 | Alta positiva | ~10% do IBOV |

**Regra prática:** Se WDO subir > 0.5% na abertura → cautela em operações long no WIN.

---

## Perfil de Volatilidade Intraday

| Horário | Vol relativa | Estratégia ideal |
|---|---|---|
| 09:00–09:15 | 🔴 Extrema | Não operar — aguardar definição |
| 09:15–10:30 | 🟡 Alta | ✅ Tendências fortes da manhã |
| 10:30–12:00 | 🟢 Moderada | ✅ Setups de confluência |
| 12:00–13:30 | ⚪ Baixa | Scalps somente — liquidez reduzida |
| 13:30–14:30 | 🟢 Moderada | ✅ Retomada pré-NYSE |
| 14:30–16:00 | 🟡 Alta | ✅ NYSE aberta — momentum externo |
| 16:00–17:40 | 🟢 Moderada | Trailing e saídas parciais |
| 17:40–18:00 | 🟡 Crescente | Não abrir posições |

---

## Parâmetros Recomendados para Robôs WIN

### 5 min (setup padrão)
```pascal
ForcaMinimaEntrada  = 60
VolumeMultiplicador = 1.5
SL_conservador      = 150  // pts
RRR_minimo          = 2.0
StopHorario_H       = 17
StopHorario_M       = 45
MaxBarrasEmPosicao  = 8
```

### 1 min (scalping)
```pascal
ForcaMinimaEntrada  = 70  // mais restritivo
VolumeMultiplicador = 2.0 // exigir mais confirmação
SL_conservador      = 80  // pts
RRR_minimo          = 2.0
StopHorario_H       = 17
StopHorario_M       = 30  // sair mais cedo
MaxBarrasEmPosicao  = 5
```

### 15 min (day trade estrutural)
```pascal
ForcaMinimaEntrada  = 55
VolumeMultiplicador = 1.3
SL_conservador      = 250  // pts
RRR_minimo          = 2.0
StopHorario_H       = 17
StopHorario_M       = 45
MaxBarrasEmPosicao  = 6
```

---

## Cálculo de Resultado Financeiro

```pascal
// Por contrato WIN:
resultado_pts     := Close_saida - Close_entrada;     // para long
resultado_reais   := resultado_pts * 0.20;             // R$ por contrato

// Dimensionamento:
risco_reais       := capital * (risco_pct / 100);
risco_pts         := abs(entrada - stop_loss);
qtd_contratos     := Floor(risco_reais / (risco_pts * 0.20));

// Exemplo:
// Capital R$ 10.000, risco 2% = R$ 200, SL = 150 pts
// qtd = Floor(200 / (150 * 0.20)) = Floor(200/30) = 6 contratos
```

---

## Checklist Rápido — WIN

Antes de entrar no trade responder:
- [ ] Horário entre 09:15 e 17:40?
- [ ] WDO estável ou a favor do viés?
- [ ] S&P futuro confirmando o viés (se NYSE já aberta)?
- [ ] Candle de força com F ≥ 60?
- [ ] Volume ≥ 1.5× média 20?
- [ ] SL identificado abaixo/acima de estrutura?
- [ ] RRR calculado ≥ 2.0?
- [ ] Próxima resistência/suporte antes do SG?
