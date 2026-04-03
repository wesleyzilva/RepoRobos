# Skill: Padrões Geométricos — Identificação e Gatilho

> Catálogo de padrões de price action usados como gatilho de entrada.
> Cada padrão inclui: o que é, o que indica, como detectar em NTSL e score de probabilidade.

---

## Como usar esta skill

1. **Identifique o padrão** na tabela de scores abaixo
2. **Confirme com F=MA** — padrão válido requer fForca acima de ForcaMinimaEntrada
3. **Confirme com multi-TF** — contexto (TF1) e direção (TF2) devem alinhar
4. **Use a zona como referência de SL** — ver `skill_gestao_risco.md` (Stop Mínimo)

---

## Tabela de Score por Padrão

| Padrão | Direção | Score Base | Confirmação necessária |
|---|---|---|---|
| Order Block | Ambos | ⭐⭐⭐⭐⭐ | Volume + multi-TF |
| Inside Bar Breakout | Ambos | ⭐⭐⭐⭐ | Volume acima da média |
| Flag / Bandeira | Ambos | ⭐⭐⭐⭐ | Tendência prévia clara |
| Fair Value Gap (FVG) | Ambos | ⭐⭐⭐⭐ | Sem preenchimento anterior |
| Engolfo (Engulfing) | Ambos | ⭐⭐⭐ | Corpo > 70% + volume |
| Pin Bar (Rejeição) | Reversão | ⭐⭐⭐ | Zona de suporte/resistência |
| Duplo Fundo / Duplo Topo | Reversão | ⭐⭐⭐ | Segundo toque + volume menor |
| Cunha (Wedge) | Reversão | ⭐⭐ | Rompimento com volume |
| Triângulo Simétrico | Expansão | ⭐⭐ | Aguardar lado do breakout |

---

## 1. Order Block (Bloco Institucional)

**O que é:** Candle antes de um movimento forte, no qual uma instituição ficou comprando ou vendendo.
**Sinal:** O preço retorna àquela região e rejeita novamente — indica defesa institucional.

```pascal
// NTSL: detectar Order Block de COMPRA
// Condição: candle atual forte de ALTA (Massa > 70%)
//           candle anterior foi de BAIXA (corpo negativo)
// A zona do Order Block é [Low[1], High[1]] do candle anterior (o bearish antes do impulso)

fCorpoAtual    := Close - Open;
fRangeAtual    := High - Low;
fMassaAtual    := fCorpoAtual / fRangeAtual;        // >0 = candle de alta

fCorpoAnterior := Close[1] - Open[1];
fRangeAnterior := High[1] - Low[1];
fMassaAnterior := fCorpoAnterior / fRangeAnterior;  // <0 = candle de baixa

// Order Block de Compra: candle anterior bearish + candle atual bullish forte
bOrderBlockCompra := (fMassaAtual >= 0.70)          // impulso forte
                  and (fMassaAnterior < -0.40)       // candle anterior era bearish
                  and (fForca >= ForcaMinimaEntrada) // confirmação F=MA
                  and (Volume >= fVolumeMedio * 1.5); // volume acima da média

// Zona do Order Block = [Low[1], High[1]] do candle anterior ao impulso
fZonaOBMin := Low[1];
fZonaOBMax := High[1];

// Entrada: preço retorna à zona e fecha DENTRO dela com força
bEntradaOB := bOrderBlockCompra
           and (Close >= fZonaOBMin)
           and (Close <= fZonaOBMax + (fZonaOBMax - fZonaOBMin) * 0.2);  // tolerância 20%
```

---

## 2. Fair Value Gap / FVG (Desequilíbrio)

**O que é:** Lacuna entre o pavio do candle -2 e o pavio do candle 0 (ignorando o candle do meio).
**Sinal:** O preço deixou uma região sem negociação — tende a retornar para preencher.

```pascal
// NTSL: detectar FVG de ALTA (gap bullish)
// Condição: Low do candle atual > High do candle -2
//           Significa que o candle do meio pulou completamente

fFVG_BullishMin := High[2];   // topo do candle 2 períodos atrás
fFVG_BullishMax := Low[0];    // fundo do candle atual

bFVG_Bullish := (Low > High[2])        // gap entre candle[0] e candle[2]
             and (fForca >= ForcaMinimaEntrada)
             and (Volume >= fVolumeMedio);

// FVG de Baixa (bearish gap):
fFVG_BearishMin := Low[0];    // fundo do candle atual
fFVG_BearishMax := High[2];   // topo do candle 2 períodos atrás

bFVG_Bearish := (High < Low[2])        // gap bearish
             and (fForca <= -ForcaMinimaEntrada)
             and (Volume >= fVolumeMedio);

// Stop: ao lado oposto do FVG
// SL Long  = fFVG_BullishMin - BufferStop
// SL Short = fFVG_BearishMax + BufferStop
```

---

## 3. Inside Bar Breakout (IB)

**O que é:** Candle cujo High e Low estão dentro do range do candle anterior (compressão).
**Sinal:** Rompimento do candle pai → liberação de energia acumulada.

```pascal
// NTSL: detectar Inside Bar e rompimento
bInsideBar := (High[1] <= High[2]) and (Low[1] >= Low[2]);

// Rompimento de alta do Inside Bar: fecha acima do High do candle pai
bRompeAlta  := bInsideBar
            and (Close > High[2])
            and (fForca >= ForcaMinimaEntrada)
            and (Volume >= fVolumeMedio * 1.3);

// Rompimento de baixa do Inside Bar: fecha abaixo do Low do candle pai
bRompeBaixa := bInsideBar[1]           // IB foi identificado no candle anterior
            and (Close < Low[2])        // fecha abaixo do candle pai
            and (fForca <= -ForcaMinimaEntrada)
            and (Volume >= fVolumeMedio * 1.3);

// SL: ao lado oposto do candle pai
// SL Long  = Low[2] - BufferStop
// SL Short = High[2] + BufferStop
```

---

## 4. Engolfo (Bullish / Bearish Engulfing)

**O que é:** Candle que "engole" completamente o corpo do candle anterior.
**Sinal:** Inversão de força — lado vencedor absorveu o lado perdedor.

```pascal
// NTSL: detectar Engolfo Bullish (reversão de baixa para alta)
fCorpoAtual    := Close - Open;
fCorpoAnterior := Close[1] - Open[1];

// Engolfo Bullish: candle atual HIGH e WIDE, engloba o corpo bearish anterior
bEngolfoBullish := (fCorpoAtual > 0)           // fechamento de alta
               and (fCorpoAnterior < 0)         // candle anterior era de baixa
               and (Close > Open[1])            // fecha acima da abertura anterior
               and (Open < Close[1])            // abre abaixo do fechamento anterior
               and (fForca >= ForcaMinimaEntrada)
               and (Volume >= fVolumeMedio * 1.5);

// Engolfo Bearish (reversão de alta para baixa):
bEngolfoBearish := (fCorpoAtual < 0)           // fechamento de baixa
               and (fCorpoAnterior > 0)         // candle anterior era de alta
               and (Close < Open[1])            // fecha abaixo da abertura anterior
               and (Open > Close[1])            // abre acima do fechamento anterior
               and (fForca <= -ForcaMinimaEntrada)
               and (Volume >= fVolumeMedio * 1.5);

// SL: abaixo/acima do Low/High do candle engolfado
// SL Long  = Low[1] - BufferStop
// SL Short = High[1] + BufferStop
```

---

## 5. Pin Bar (Rejeição / Cauda Longa)

**O que é:** Candle com cauda longa e corpo pequeno — rejeição forte de um nível de preço.
**Sinal:** O mercado tentou subir/cair mas foi rejeitado violentamente.

```pascal
// NTSL: detectar Pin Bar de Alta (cauda inferior longa — rejeição de suporte)
fCorpo      := abs(Close - Open);
fRange      := High - Low;
if fRange < 0.01 then fRange := 0.01;

fPavioInf   := (Low < Open) * (Open - Low) + (Low < Close) * (Close - Low);  // aproximação
fPavioInf   := Low - (Open + Close) * 0.5;  // distância entre Low e meio do corpo
if fPavioInf < 0 then fPavioInf := -fPavioInf;

fPavioSup   := High - (Open + Close) * 0.5;
if fPavioSup < 0 then fPavioSup := -fPavioSup;

// Pin Bar de Alta: cauda inferior >= 60% do range, corpo <= 30% do range
bPinBarAlta  := (fPavioInf >= fRange * 0.60)  // cauda grande em baixo
             and (fCorpo    <= fRange * 0.30)  // corpo pequeno
             and (Close > Open);               // fechamento de alta

// Pin Bar de Baixa: cauda superior >= 60%, fechamento de baixa
bPinBarBaixa := (fPavioSup >= fRange * 0.60)
             and (fCorpo    <= fRange * 0.30)
             and (Close < Open);

// SL: na ponta da cauda
// SL Long  = Low  - BufferStop
// SL Short = High + BufferStop
```

---

## 6. Flag / Bandeira (Continuação de Tendência)

**O que é:** Após um movimento forte (mastro), o preço faz uma retração limitada em canal — depois rompe na mesma direção.
**Sinal:** Continuação com momentum acumulado.

```pascal
// NTSL: detectar Mastro (impulso inicial)
// Mastro = variação >= N * ATR nos últimos M candles

fATR := ATR(14);
fMastro := Close - Close[5];          // variação nos últimos 5 candles
if fMastro < 0 then fMastro := -fMastro;
bMastroAlta  := (Close[0] - Close[5]) >= fATR * 2;   // impulso de alta
bMastroBaixa := (Close[5] - Close[0]) >= fATR * 2;   // impulso de baixa

// Bandeira = retração máxima de 50% do mastro, preço acima da MM9
fMediaDir    := Media(9, Close);
bBandeiraAlta  := bMastroAlta
               and (Close > fMediaDir)          // acima da MM9 (não perdeu direção)
               and (Low  >= Close[5])           // não retraiu mais que o ponto de partida
               and (fForca >= ForcaMinimaEntrada);

bBandeiraBaixa := bMastroBaixa
               and (Close < fMediaDir)
               and (High  <= Close[5])
               and (fForca <= -ForcaMinimaEntrada);

// SL: abaixo da mínima da bandeira (último swing low)
// SL Long  = Low  - BufferStop  (mínima da retração)
// SL Short = High + BufferStop  (máxima da retração)
```

---

## 7. Duplo Fundo / Duplo Topo (W e M)

**O que é:** Dois toques em mesmo nível de preço com volume decrescente no 2° toque.
**Sinal:** O nível foi testado duas vezes e rejeitado — defesa forte → reversão.

```pascal
// NTSL: detectar Duplo Fundo
// Procurar Low[N1] ≈ Low[N2] com volume menor no 2° toque
// Simplificado: Low atual ≈ Low[5..10] com tolerância de ATR * 0.3

fATR := ATR(14);
fTolerancia := fATR * 0.30;

// Variante: verificar Low[0] próximo de Low dos últimos 5–15 candles
fMinAnterior := Low[5];
if Low[6]  < fMinAnterior then fMinAnterior := Low[6];
if Low[7]  < fMinAnterior then fMinAnterior := Low[7];
if Low[8]  < fMinAnterior then fMinAnterior := Low[8];
if Low[9]  < fMinAnterior then fMinAnterior := Low[9];
if Low[10] < fMinAnterior then fMinAnterior := Low[10];

bDuploFundo := (abs(Low - fMinAnterior) <= fTolerancia)   // 2° toque próximo do 1°
            and (Volume < Volume[5])                        // volume menor no 2° toque
            and (fForca >= ForcaMinimaEntrada)              // F=MA confirmando alta
            and (Close > Open);                             // fechamento de alta

// SL: abaixo do Duplo Fundo
// SL = Low - BufferStop
```

---

## 8. Como Ranquear Zonas por Probabilidade

Somar o score de cada elemento que confirma a zona:

| Elemento | Score |
|---|---|
| Padrão geométrico válido (tabela acima) | +2 |
| F=MA ≥ 70 (força alta) | +2 |
| Volume ≥ 2× média | +2 |
| Alinhamento 3 timeframes | +3 |
| Zona testada 2+ vezes sem ser rompida | +2 |
| Fibonacci 61.8% ou 50% na zona | +1 |
| VWAP do dia na zona | +1 |
| **Total ≥ 8** | **Zona Premium — alta prioridade** |
| **Total 5–7** | **Zona Válida — operar com confirmação** |
| **Total < 5** | **Zona Fraca — ignorar ou reduzir tamanho** |

```pascal
// NTSL: Score de zona (versão simplificada)
iScore := 0;
if bPadrao              then iScore := iScore + 2;   // padrão detectado
if fForca >= 70         then iScore := iScore + 2;   // força alta
if Volume >= fVolumeMedio * 2 then iScore := iScore + 2;   // volume 2×
if bContextoAlta and bDirecaoAlta then iScore := iScore + 3; // 3 TFs alinhados

// iScore >= 8 → BuyAtMarket
// iScore 5–7 → BuyAtMarket somente se ForcaMinimaEntrada > 60
// iScore < 5 → nao operar
```

---

## Referência cruzada

- `skill_confluencia_geometrica.md` → construção das zonas em Python
- `skill_gestao_risco.md` → Stop Loss mínimo por tipo de padrão
- `skill_ntsl_syntax.md` → funções built-in disponíveis em NTSL
- `template_robo_padrao.ntsl` → estrutura base segura para implementar
