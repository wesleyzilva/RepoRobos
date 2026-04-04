# Regra de Cores dos Candles — Sistema 3 Níveis

## Lógica Geral — 5 Estados

```
CINZA   → indecisão        corpo < 10% do range (doji)
BRANCO  → abaixo do fraco  F < ForcaFraca (40)   ← ruído, NÃO opera
FRACO   → sinal fraco      F 40–60               ← monitora, NÃO entra
MÉDIO   → zona operacional F 60–80               ← OPERA com 3TF confirmado
FORTE   → plena confiança  F >= 80               ← OPERA tamanho cheio
```

> **Regra de operação:** APENAS MÉDIO (F ≥ 60) e FORTE (F ≥ 80).
> BRANCO = indecisão com movimento (diferente de CINZA = doji sem direção).

## Detalhamento das Cores — 3 Níveis

| Estado   | Condição               | RGB (LONG verde)    | RGB (SHORT vermelho) | Opera? |
|----------|------------------------|---------------------|----------------------|--------|
| Cinza    | corpo < 10% range      | (128, 128, 128)     | (128, 128, 128)      | NÃO    |
| Branco   | F < 40                 | (255, 255, 255)     | (255, 255, 255)      | NÃO    |
| Fraco    | F 40–60               | (100, 210, 100)     | (210, 100, 100)      | NÃO    |
| **Médio**| **F 60–80**           | **(0, 180, 0)**     | **(180, 0, 0)**      | **SIM**|
| **Forte**| **F >= 80**           | **(0, 255, 0)**     | **(255, 0, 0)**      | **SIM**|

### Thresholds configuráveis (parâmetros Input)
- `ForcaFraca = 40`  → abaixo = BRANCO (ruído)
- `ForcaMedia = 60`  → acima = MÉDIO (início da zona operacional)
- `ForcaForte = 80`  → acima = FORTE (tamanho cheio)

---

## Código Completo — PaintBar 3 Níveis (pronto para NTFL)

```pascal
// INDICADOR DE CORES — 3 NÍVEIS DE FORÇA F=MA
// Usar em .ntfl (indicador de pintura de candles)
// Thresholds configuráveis: ForcaFraca=40, ForcaMedia=60, ForcaForte=80

var
  iCorR, iCorG, iCorB : integer;
  fCorpo, fRange       : float;

begin
  fCorpo := Close - Open;
  fRange := High - Low;

  // fForca deve ser calculado externamente (F = |corpo/range| * vol/volmedia * 100)
  // com sinal: positivo = alta, negativo = baixa

  // Inicializar: cinza padrão
  iCorR := 128; iCorG := 128; iCorB := 128;

  if (fRange > 0) and (Abs(fCorpo) < 0.10 * fRange) then
  begin
    // CINZA — indecisão: doji / corpo mínimo (mercado indefinido)
    iCorR := 128; iCorG := 128; iCorB := 128;
  end
  else if Abs(fForca) < ForcaFraca then
  begin
    // BRANCO — abaixo do fraco: ruído puro, não opera
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  // --- LADO COMPRA (fForca positivo) ---
  else if fForca >= ForcaForte then
  begin
    // VERDE FORTE — forca máxima, opera tamanho cheio
    iCorR :=   0; iCorG := 255; iCorB :=   0;
  end
  else if fForca >= ForcaMedia then
  begin
    // VERDE MÉDIO — zona operacional, exige confluência 3TF
    iCorR :=   0; iCorG := 180; iCorB :=   0;
  end
  else if fForca >= ForcaFraca then
  begin
    // VERDE CLARO — fraco: mercado se movendo, mas sem entrada
    iCorR := 100; iCorG := 210; iCorB := 100;
  end
  // --- LADO VENDA (fForca negativo) ---
  else if fForca <= -ForcaForte then
  begin
    // VERMELHO FORTE — venda máxima, opera short tamanho cheio
    iCorR := 255; iCorG :=   0; iCorB :=   0;
  end
  else if fForca <= -ForcaMedia then
  begin
    // VERMELHO MÉDIO — zona operacional short
    iCorR := 180; iCorG :=   0; iCorB :=   0;
  end
  else if fForca <= -ForcaFraca then
  begin
    // VERMELHO CLARO — fraco short: monitora, não entra
    iCorR := 210; iCorG := 100; iCorB := 100;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));
end;
```

---

## Versão com Degradê Interno (granularidade dentro de cada zona)

```pascal
// Usar em substituição ao bloco anterior quando quiser ver
// a variação de 61 → 79 dentro da faixa média, por exemplo.

var fInt : float;

if fForca >= ForcaForte then
begin
  fInt  := (fForca - ForcaForte) / (100.0 - ForcaForte); // 0.0 → 1.0
  iCorG := 180 + Round(fInt * 75);    // 180 → 255
  iCorR := Round((1.0 - fInt) * 30);  //  30 → 0
  iCorB := 0;
end
else if fForca >= ForcaMedia then
begin
  fInt  := (fForca - ForcaMedia) / (ForcaForte - ForcaMedia);
  iCorG := 130 + Round(fInt * 50);    // 130 → 180
  iCorR := Round((1.0 - fInt) * 60);  //  60 → 0
  iCorB := Round((1.0 - fInt) * 20);  //  20 → 0
end
else if fForca >= ForcaFraca then
begin
  fInt  := (fForca - ForcaFraca) / (ForcaMedia - ForcaFraca);
  iCorG := 180 + Round(fInt * 30);    // 180 → 210
  iCorR := 100 - Round(fInt * 30);    // 100 → 70
  iCorB := 100 - Round(fInt * 30);    // 100 → 70
end;
// Repetir simetricamente para o lado SHORT (fForca negativo)
```

---

## Observações Importantes

- **CINZA ≠ BRANCO:** cinza = doji (sem corpo). Branco = tem corpo mas força insuficiente.
  Os dois significam "não opera", mas por razões diferentes.
- Os limites de RGB garantem que as cores não ultrapassem 0–255.
- `ForcaMedia = 60` é o threshold alinhado com os dados reais 2025 (follow-through 61–64% à tarde).
- Para usar no robô (.ntsl): extrair a lógica de cor para um indicador separado (.ntfl).
  O robô usa as mesmas condições boolenas (`fForca >= ForcaMedia`) mas sem `PaintBar()`.
































- Os limites de RGB garantem que as cores não ultrapassem o intervalo 0-255.- Candles de indecisão ficam brancos para fácil identificação.- O degradê permite visualizar a intensidade da força de compra/venda.## Observações```// ...existing code...PaintBar(RGB(r, g, b));// Senão, permanece cinzaend  if b < 0 then b := 0;  if g < 0 then g := 0;  if r > 255 then r := 255;  b := 128 - round((-fForca/100) * 128); // 128 a 0  g := 128 - round((-fForca/100) * 128); // 128 a 0  r := 128 + round((-fForca/100) * 127); // 128 a 255  // Vermelho degradê: quanto menor a força, mais forte o vermelhobeginelse if (fForca <= -ForcaMinimaEntrada) then// Venda: força negativaend  if b < 0 then b := 0;  if r < 0 then r := 0;  if g > 255 then g := 255;  b := 128 - round((fForca/100) * 128); // 128 a 0  r := 128 - round((fForca/100) * 128); // 128 a 0  g := 128 + round((fForca/100) * 127); // 128 a 255  // Verde degradê: quanto maior a força, mais forte o verdebeginelse if (fForca >= ForcaMinimaEntrada) then