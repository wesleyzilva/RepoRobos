# Dicionario de Cores RGB — NTSL/Profit

> Referencia completa de cores para PaintBar(), PlotText() e Alert() nos robos e indicadores.
> Sintaxe: RGB(R, G, B) — valores inteiros de 0 a 255.

---

## 1. Cores Fixas — Uso Semantico

| Nome           | RGB                    | Uso no sistema                                      |
|----------------|------------------------|-----------------------------------------------------|
| Cinza padrao   | RGB(128, 128, 128)     | Candle neutro / sem sinal                           |
| Branco         | RGB(255, 255, 255)     | Indecisao (corpo < 10% do range)                    |
| Verde puro     | RGB(0, 255, 0)         | Sinal de compra forte / Alert compra                |
| Verde medio    | RGB(0, 200, 0)         | PlotText "COMPRA" / texto de forca positiva         |
| Verde escuro   | RGB(0, 128, 0)         | Confirmacao fraca de alta                           |
| Verde sinal    | RGB(0, 255, 100)       | PaintBar sinal de compra com confluencia            |
| Vermelho puro  | RGB(255, 0, 0)         | Sinal de venda forte / Alert venda                  |
| Vermelho medio | RGB(200, 0, 0)         | PlotText "VENDA" / texto de forca negativa          |
| Vermelho sinal | RGB(255, 50, 0)        | PaintBar sinal de venda com confluencia             |
| Laranja        | RGB(255, 165, 0)       | Rejeicao forte (pavios > 60% do range)              |
| Amarelo ouro   | RGB(255, 215, 0)       | Anomalia de volume (volume > 3x media)              |
| Azul claro     | RGB(0, 191, 255)       | Informativo / contexto neutro                       |
| Roxo           | RGB(148, 0, 211)       | Divergencia / sinal especial                        |
| Ciano          | RGB(0, 255, 255)       | Zona de suporte/resistencia                         |
| Preto          | RGB(0, 0, 0)           | Fundo / invisivel em fundo escuro                   |

---

## 2. Degrade Dinamico — Forca F = M x A

O degrade e calculado a partir de `fForca` (valor entre -100 e +100).

### Verde Degrade (Compra — fForca >= ForcaMinimaEntrada)

```pascal
iCorG := 128 + Round((fForca / 100) * 127);  // 128 -> 255
iCorR := 128 - Round((fForca / 100) * 128);  // 128 -> 0
iCorB := 128 - Round((fForca / 100) * 128);  // 128 -> 0
if iCorG > 255 then iCorG := 255;
if iCorR < 0   then iCorR := 0;
if iCorB < 0   then iCorB := 0;
```

| fForca | R   | G   | B   | Cor visual       |
|--------|-----|-----|-----|------------------|
| 60     | 51  | 204 | 51  | Verde medio      |
| 80     | 26  | 230 | 26  | Verde forte      |
| 100    | 0   | 255 | 0   | Verde puro       |

### Vermelho Degrade (Venda — fForca <= -ForcaMinimaEntrada)

```pascal
iCorR := 128 + Round((-fForca / 100) * 127); // 128 -> 255
iCorG := 128 - Round((-fForca / 100) * 128); // 128 -> 0
iCorB := 128 - Round((-fForca / 100) * 128); // 128 -> 0
if iCorR > 255 then iCorR := 255;
if iCorG < 0   then iCorG := 0;
if iCorB < 0   then iCorB := 0;
```

| fForca | R   | G   | B   | Cor visual       |
|--------|-----|-----|-----|------------------|
| -60    | 204 | 51  | 51  | Vermelho medio   |
| -80    | 230 | 26  | 26  | Vermelho forte   |
| -100   | 255 | 0   | 0   | Vermelho puro    |

---

## 3. Bloco Completo — Gradiente + Cores Especiais

```pascal
// Inicializar: cinza padrao
iCorR := 128; iCorG := 128; iCorB := 128;

if bRejeicaoForte then
begin
  // Laranja = pavios > 60% do range
  iCorR := 255; iCorG := 165; iCorB := 0;
end
else if bAnomaliaVolume then
begin
  // Amarelo = volume > 3x media
  iCorR := 255; iCorG := 215; iCorB := 0;
end
else if abs(fCorpoCandle) < 0.10 * fRangeCandle then
begin
  // Branco = indecisao
  iCorR := 255; iCorG := 255; iCorB := 255;
end
else if fForca >= ForcaMinimaEntrada then
begin
  // Verde degradê
  iCorG := 128 + Round((fForca / 100) * 127);
  iCorR := 128 - Round((fForca / 100) * 128);
  iCorB := 128 - Round((fForca / 100) * 128);
  if iCorG > 255 then iCorG := 255;
  if iCorR < 0   then iCorR := 0;
  if iCorB < 0   then iCorB := 0;
end
else if fForca <= -ForcaMinimaEntrada then
begin
  // Vermelho degradê
  iCorR := 128 + Round((-fForca / 100) * 127);
  iCorG := 128 - Round((-fForca / 100) * 128);
  iCorB := 128 - Round((-fForca / 100) * 128);
  if iCorR > 255 then iCorR := 255;
  if iCorG < 0   then iCorG := 0;
  if iCorB < 0   then iCorB := 0;
end;

PaintBar(RGB(iCorR, iCorG, iCorB));
```

---

## 4. Alert() — Cor do Alarme Sonoro (so .ntfl)

```pascal
Alert(RGB(0, 255, 0));    // alarme verde = sinal de compra
Alert(RGB(255, 0, 0));    // alarme vermelho = sinal de venda
Alert(RGB(255, 165, 0));  // alarme laranja = rejeicao / atencao
Alert(RGB(255, 215, 0));  // alarme amarelo = anomalia de volume
```

> A cor do Alert() e visual no painel de alertas do Profit — nao interfere no som.

---

## 5. PlotText() — Cores de Texto (so .ntfl)

```pascal
// Compra
PlotText("COMPRA", RGB(0, 200, 0), 9, 1, Low * 0.993);

// Venda
PlotText("VENDA", RGB(200, 0, 0), 9, 1, High * 1.007);

// Label de forca positiva
PlotText("F+", RGB(0, 200, 0), 8, 0, Low * 0.998);

// Label de forca negativa
PlotText("F-", RGB(200, 0, 0), 8, 0, High * 1.002);
```

> ATENCAO: PlotText() aceita apenas string literal como 1o argumento.
> Nao usar variaveis nem funcoes (ex: IntToStr(...) FALHA em compilacao).

---

## 6. Regras de Uso

| Funcao       | Robo (.ntsl) | Indicador (.ntfl) | Aceita variavel como cor? |
|--------------|:------------:|:-----------------:|:-------------------------:|
| PaintBar()   | SIM          | SIM               | SIM — RGB(iR, iG, iB)    |
| Alert()      | NAO          | SIM               | SIM — RGB(r, g, b)        |
| PlotText()   | NAO          | SIM               | SIM (cor) / NAO (texto)   |

---

## 7. Mapa Visual Rapido

```
CINZA      (128,128,128)  → sem sinal
BRANCO     (255,255,255)  → indecisao / doji
LARANJA    (255,165,  0)  → rejeicao com pavio
AMARELO    (255,215,  0)  → volume anormal
VERDE +++  (  0,255,  0)  → forca maxima compra
VERDE  ++  (  0,200, 50)  → forca media compra
VERDE   +  ( 50,160, 50)  → forca minima compra
VERMELHO + (255,  0,  0)  → forca maxima venda
VERMELHO   (200, 50, 50)  → forca media venda
VERMELHO-  (160, 50, 50)  → forca minima venda
```
