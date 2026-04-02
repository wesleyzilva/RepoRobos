# Skill: WDO — Mini Dólar (WDOFUT / WDOJ26)

> Referência técnica completa do ativo WDO B3 com dados estatísticos reais extraídos dos CSVs históricos (2024_26).

---

## Especificações do Contrato

| Item | Valor |
|---|---|
| Código Profit | WDOJ26 (vencimento junho/26), WDOFUT (contínuo) |
| Ativo subjacente | Taxa de câmbio USD/BRL |
| Multiplicador | **R$ 10,00 por ponto** |
| Tick mínimo | **0,5 ponto = R$ 5,00** |
| Garantia mínima | ~R$ 800–1.200 por contrato |
| Vencimento | 1º dia útil dos meses pares (fev, abr, jun, ago, out, dez) |
| Código de vencimento | WDO + mês + ano: WDOG25, WDOJ25, WDOM25... |
| Liquidação | Financeira — PTAX do dia anterior ao vencimento |
| Cotação | R$ por USD × 1.000 (ex: 5.738 = R$5.738/USD ou R$5,738/USD) |

> **Atenção:** No Profit, preços WDO aparecem como inteiro (ex: 5738 = R$ 5,738/USD). 1 ponto = R$ 0,001/USD. Logo, 100 pts = R$ 0,10/USD × 1.000 = R$ 100 por contrato.

---

## Sessão de Negociação

| Período | Horário | Observação |
|---|---|---|
| Pré-abertura | 09:00 | Leilão de abertura |
| **Abertura** | **09:00** | Spread alto — evitar |
| Horário principal | **09:15–17:55** | Operar neste intervalo |
| Pré-fechamento | 17:50–18:00 | Reduzir posições |
| After market | 18:00–21:50 | Existe — volume muito baixo |

> WDO tem sessão até 18:00 (vs WIN que vai até ~17:55). Atenção: após NYSE fechar (17:00 BRT) o volume WDO cai significativamente.

**Regra de código:**
```pascal
// Iniciar: 09:15 | Encerrar: 17:50
if (Hour < 9) or ((Hour = 9) and (Minute < 15)) then Exit;
if (Hour >= 17) and (Minute >= 50) then begin ClosePosition; Exit; end;
```

---

## Estatísticas Reais — Dados 2024_26 (WDOFUT, n=5–43k candles)

### Range e ATR por Timeframe (todos os TFs das tripletas)

| Timeframe | ATR mediano | Range P90 | SL recomendado | SG (RRR 2.0) | Em R$/ctto |
|---|---|---|---|---|---|
| **1 min** | 2,0 pts | 4,1 pts | 3 pts | 6 pts | R$ 30 risco |
| **5 min** | 5,0 pts | 11,1 pts | 6 pts | 12 pts | R$ 60 risco |
| **10 min** | 6,7 pts | 14,6 pts | 8 pts | 16 pts | R$ 80 risco |
| **15 min** | 8,1 pts | 17,9 pts | 10 pts | 20 pts | R$ 100 risco |
| **20 min** | 9,2 pts | 20,5 pts | 11 pts | 22 pts | R$ 110 risco |
| **30 min** | 11,5 pts | 25,3 pts | 13 pts | 26 pts | R$ 130 risco |
| **60 min** | 15,6 pts | 35,4 pts | 18 pts | 36 pts | R$ 180 risco |

> Valores em pontos WDO (1 pt = R$ 10,00)

---

## Sistema de Tripletas para WDO

> Referência completa: `docs/tabela_verdade_timeframes.md`

### Regra matemática obrigatória

> `iJanelaDir = TF2 ÷ TF3` e `iJanelaCtx = TF1 ÷ TF3` devem ser **inteiros exatos**.
> `30/15/10` é **inválida** (15÷10=1,5). Use `30/15/5` ou `30/20/10` no lugar.

### Tripletas disponíveis para WDO

| Tripleta | TF3 | iJanelaDir | iJanelaCtx | Perfil | SL | SG | R$/ctto |
|---|---|---|---|---|---|---|---|
| **60 / 30 / 15** | 15min | 2 | 4 | Estrutural | 10 pts | 20 pts | R$ 100 |
| **30 / 15 / 5** ⭐ | 5min | 3 | 6 | Day trade (padrão) | 6 pts | 12 pts | R$ 60 |
| **15 / 10 / 5** | 5min | 2 | 3 | Day trade alternativo | 6 pts | 12 pts | R$ 60 |
| **15 / 5 / 1** | 1min | 5 | 15 | Scalping | 3 pts | 6 pts | R$ 30 |

### Atenção: Horários PTAX afetam todas as tripletas

Independente da tripleta usada, **pausar operações**:
- 12:55–13:05 (PTAX1)
- 15:55–16:05 (PTAX2)

```pascal
bHorarioPTAX := ((Hour=12)and(Minute>=55)) or ((Hour=13)and(Minute<=5)) or
                ((Hour=15)and(Minute>=55)) or ((Hour=16)and(Minute<=5));
if bHorarioPTAX then Exit;
```

### Proxy multi-TF em NTSL (janelas para tripleta 30/15/5 rodando em 5min)
```pascal
// Idêntico ao WIN — mesma lógica, valores de SL diferentes
iJanelaDir := 3;  // 15min = 3 barras de 5min
iJanelaCtx := 6;  // 30min = 6 barras de 5min
```

---

## Custos Reais por Trade (WDO)

| Custo | Valor | Observação |
|---|---|---|
| Spread horário principal | 0,5–1 pt | 1 tick = 0,5 pt em mercado líquido |
| Spread abertura/fechamento | 2–5 pts | Evitar |
| Slippage típico | 0,5–2 pts | A mercado em condição normal |
| Corretagem média | 0,5–1 pt equivalente | Variável por corretora |
| **Total conservador** | **2 pts/trade** | Desconto mínimo no backtest |
| **Total abertura** | **5–8 pts/trade** | Se operar na abertura |

---

## Correlações e Drivers do WDO

| Driver | Impacto | Observação |
|---|---|---|
| PTAX (Banco Central) | 🔴 Muito alto | Fixing oficial às 13h e 16h |
| Fed (taxa de juros EUA) | 🔴 Muito alto | Decisões FOMC movem 50–200 pts |
| COPOM (Selic) | 🟡 Alto | Decisões afetam carry trade |
| Risco Brasil (CDS) | 🟡 Alto | Aversão a risco global |
| Petróleo | 🟢 Moderado | Brasil exportador — câmbio correlato |
| S&P 500 | 🟢 Moderado | Risco off → dólar sobe |
| WIN (IBOV) | 🟢 Inverso | WIN cai → WDO tende a subir |

**Horários críticos para WDO:**
```
09:00 → Abertura: spread alto, evitar
13:00 → PTAX1: Banco Central divulga primeira taxa do dia — movimento brusco possível
14:30 → NYSE abre: impacto direto no câmbio
16:00 → PTAX2: segundo fixing do Banco Central
16:30 → Fechar posições se intraday
```

---

## Parâmetros Recomendados para Robôs WDO

### 5 min (setup padrão)
```pascal
ForcaMinimaEntrada  = 60
VolumeMultiplicador = 1.5
SL_conservador      = 12   // pts WDO
RRR_minimo          = 2.0
StopHorario_H       = 17
StopHorario_M       = 50
MaxBarrasEmPosicao  = 8
```

### 1 min (scalping)
```pascal
ForcaMinimaEntrada  = 70
VolumeMultiplicador = 2.0
SL_conservador      = 6    // pts WDO
RRR_minimo          = 2.0
StopHorario_H       = 17
StopHorario_M       = 30
MaxBarrasEmPosicao  = 5
```

---

## Diferenças Chave: WDO vs WIN

| Aspecto | WIN | WDO |
|---|---|---|
| Tick mínimo | 5 pts = R$ 1,00 | 0,5 pt = R$ 5,00 |
| Valor por ponto | R$ 0,20 | R$ 10,00 |
| ATR típico (5min) | ~146 pts | ~5 pts |
| Spread em ticks | 1 tick (5 pts) | 1 tick (0,5 pt) |
| Garantia | ~R$ 1.500 | ~R$ 800 |
| Correlação externa | IBOV, S&P | USDBRL, PTAX, Fed |
| SL em R$ (5min) | ~R$ 30/contrato | ~R$ 80–120/contrato |
| Overnight | Não recomendado | Possível (risco de gap) |

---

## Cálculo de Resultado Financeiro WDO

```pascal
// Por contrato WDO:
resultado_pts     := Close_saida - Close_entrada;     // para long
resultado_reais   := resultado_pts * 10.00;            // R$ por contrato

// Dimensionamento:
risco_reais       := capital * (risco_pct / 100);
risco_pts         := abs(entrada - stop_loss);
qtd_contratos     := Floor(risco_reais / (risco_pts * 10.00));

// Exemplo:
// Capital R$ 10.000, risco 2% = R$ 200, SL = 10 pts
// qtd = Floor(200 / (10 * 10)) = Floor(200/100) = 2 contratos
```

---

## Atenção: Evitar Horários PTAX

Durante o fixing PTAX (próximo às 13h e 16h) o WDO pode ter movimentos bruscos e manipulados. Estratégia recomendada:

```pascal
// Pausar operações próximo ao PTAX
bHorarioPTAX := ((Hour = 12) and (Minute >= 55)) or
                ((Hour = 13) and (Minute <= 5))  or
                ((Hour = 15) and (Minute >= 55)) or
                ((Hour = 16) and (Minute <= 5));

if bHorarioPTAX then begin
  // Não abrir novas posições
  if IsBought or IsSold then
    // manter posição, mas não entrar nova
  Exit;
end;
```

---

## Checklist Rápido — WDO

Antes de entrar no trade responder:
- [ ] Horário entre 09:15 e 17:45?
- [ ] Não é horário PTAX (13h ±5min ou 16h ±5min)?
- [ ] Sem evento macroeconômico iminente (Fed, COPOM, PIB)?
- [ ] Candle de força com F ≥ 60?
- [ ] Volume ≥ 1.5× média 20?
- [ ] SL identificado abaixo/acima de estrutura?
- [ ] RRR ≥ 2.0 calculado?
