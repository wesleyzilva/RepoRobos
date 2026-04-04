# Dicionario de Cores RGB — NTSL/Profit

> Referencia completa de cores para PaintBar(), PlotText() e Alert() nos robos e indicadores.
> Sintaxe: RGB(R, G, B) — valores inteiros de 0 a 255.

---

## 1. Sistema de 3 Niveis de Forca — Regra Operacional

> **Regra:** operar APENAS com sinal MÉDIO ou FORTE (F >= ForcaMedia = 60).
> Abaixo disso: visivel no gráfico mas fora da zona operacional.

```
CINZA  → Indecisão     corpo < 10% do range   (nao opera — mercado indefinido)
BRANCO → Abaixo do fraco  F < ForcaFraca (40)  (nao opera — ruido puro)
FRACO  → Sinal fraco      F 40–60             (nao opera — monitorar apenas)
MEDIO  → Zona operacional F 60–80             (OPERA com confluencia 3TF)
FORTE  → Plena confianca  F >= 80             (OPERA com tamanho cheio)
```

### Tabela Visual Completa

| Estado     | Condicao                | RGB (LONG — verde)   | RGB (SHORT — vermelho) | Opera? |
|------------|-------------------------|----------------------|------------------------|--------|
| Cinza      | corpo < 10% range       | (128, 128, 128)      | (128, 128, 128)        | NAO    |
| Branco     | F < 40                  | (255, 255, 255)      | (255, 255, 255)        | NAO    |
| Fraco      | F 40–60                 | (100, 210, 100)      | (210, 100, 100)        | NAO    |
| **Médio**  | **F 60–80**             | **(0, 180, 0)**      | **(180, 0, 0)**        | **SIM**|
| **Forte**  | **F >= 80**             | **(0, 255, 0)**      | **(255, 0, 0)**        | **SIM**|

> A linha divisória entre nao-opera e opera é **F = 60 (ForcaMedia)**.
> Fraco aparece no gráfico para alertar sobre possivel desenvolvimento, mas sem entrada.

---

## 2. Thresholds Nomeados — Parametros NTSL

```pascal
// Declarar como parametros Input do indicador/robo:
ForcaFraca  : float := 40.0;  // abaixo = branco (ruido)
ForcaMedia  : float := 60.0;  // inicio da zona operacional
ForcaForte  : float := 80.0;  // forca plena — tamanho cheio

// Usar na logica:
// bOperaLong  := (fForca >= ForcaMedia);  // sinal valido para entrada
// bTamanhoMax := (fForca >= ForcaForte);  // tamanho cheio
```

---

## 3. Bloco de Cores — 3 Niveis + Indecisao (Pronto para NTFL)

```pascal
var
  iCorR, iCorG, iCorB : integer;
  fCorpo, fRange       : float;

begin
  fCorpo := Close - Open;
  fRange := High - Low;

  // Inicializar: cinza padrao
  iCorR := 128; iCorG := 128; iCorB := 128;

  if (fRange > 0) and (Abs(fCorpo) < 0.10 * fRange) then
  begin
    // CINZA — indecisao: doji ou corpo minimo
    iCorR := 128; iCorG := 128; iCorB := 128;
  end
  else if Abs(fForca) < ForcaFraca then
  begin
    // BRANCO — abaixo do fraco: ruido, nao opera
    iCorR := 255; iCorG := 255; iCorB := 255;
  end
  else if fForca >= ForcaForte then
  begin
    // VERDE FORTE — forca maxima, opera tamanho cheio
    iCorR := 0; iCorG := 255; iCorB := 0;
  end
  else if fForca >= ForcaMedia then
  begin
    // VERDE MÉDIO — zona operacional com confluencia 3TF
    iCorR := 0; iCorG := 180; iCorB := 0;
  end
  else if fForca >= ForcaFraca then
  begin
    // VERDE CLARO — fraco: monitorar, nao entra
    iCorR := 100; iCorG := 210; iCorB := 100;
  end
  else if fForca <= -ForcaForte then
  begin
    // VERMELHO FORTE — venda forca maxima
    iCorR := 255; iCorG := 0; iCorB := 0;
  end
  else if fForca <= -ForcaMedia then
  begin
    // VERMELHO MÉDIO — zona operacional short
    iCorR := 180; iCorG := 0; iCorB := 0;
  end
  else if fForca <= -ForcaFraca then
  begin
    // VERMELHO CLARO — fraco short: monitorar
    iCorR := 210; iCorG := 100; iCorB := 100;
  end;

  PaintBar(RGB(iCorR, iCorG, iCorB));
end;
```

---

## 4. Degrade Opcional Dentro de Cada Zona

> Usar se quiser granularidade visual dentro de cada banda (ex: distinguir F=61 de F=79).
> O bloco da secao 3 (bandas discretas) e suficiente para a maioria dos casos.

```pascal
// Normaliza fForca dentro da zona para calcular intensidade 0.0 a 1.0
var fIntensidade : float;

if fForca >= ForcaForte then
begin
  // FORTE: interpolacao interna 80–100
  fIntensidade := (fForca - ForcaForte) / (100.0 - ForcaForte);
  iCorG := 180 + Round(fIntensidade * 75);  // 180 -> 255
  iCorR := Round((1.0 - fIntensidade) * 30);  // 30 -> 0
  iCorB := 0;
end
else if fForca >= ForcaMedia then
begin
  // MÉDIO: interpolacao interna 60–80
  fIntensidade := (fForca - ForcaMedia) / (ForcaForte - ForcaMedia);
  iCorG := 130 + Round(fIntensidade * 50);  // 130 -> 180
  iCorR := Round((1.0 - fIntensidade) * 60);  // 60 -> 0
  iCorB := Round((1.0 - fIntensidade) * 20);  // 20 -> 0
end
else if fForca >= ForcaFraca then
begin
  // FRACO: interpolacao interna 40–60
  fIntensidade := (fForca - ForcaFraca) / (ForcaMedia - ForcaFraca);
  iCorG := 180 + Round(fIntensidade * 30);  // 180 -> 210
  iCorR := 100 - Round(fIntensidade * 30);  // 100 -> 70
  iCorB := 100 - Round(fIntensidade * 30);  // 100 -> 70
end;
```

| fForca | Zona   | R   | G   | B   | Cor visual          |
|--------|--------|-----|-----|-----|---------------------|
| < 40   | Ruido  | 255 | 255 | 255 | Branco              |
| 40     | Fraco  | 100 | 180 | 100 | Verde pastel claro  |
| 55     | Fraco  |  70 | 195 |  70 | Verde pastel medio  |
| 60     | Médio  |  60 | 130 |  20 | Verde medio escuro  |
| 70     | Médio  |  30 | 155 |  10 | Verde medio         |
| 80     | Forte  |  30 | 180 |   0 | Verde forte         |
| 90     | Forte  |  15 | 218 |   0 | Verde vivo          |
| 100    | Forte  |   0 | 255 |   0 | Verde puro          |

---

## 5. Alert() — Cor do Alarme Sonoro (so .ntfl)

```pascal
// Alertas mapeados aos 3 niveis
if fForca >= ForcaForte then
  Alert(RGB(0, 255, 0))        // verde puro — forca maxima compra
else if fForca >= ForcaMedia then
  Alert(RGB(0, 180, 0))        // verde medio — sinal operacional
else if fForca <= -ForcaForte then
  Alert(RGB(255, 0, 0))        // vermelho puro — forca maxima venda
else if fForca <= -ForcaMedia then
  Alert(RGB(180, 0, 0));       // vermelho medio — sinal operacional short
// Fraco e ruido: sem alerta
```

---

## 6. PlotText() — Cores de Texto (so .ntfl)

```pascal
// FORTE — texto de maxima confianca
PlotText("FORTE+", RGB(0, 255,   0), 9, 1, Low  * 0.993);
PlotText("FORTE-", RGB(255,  0,   0), 9, 1, High * 1.007);

// MÉDIO — zona operacional
PlotText("MED+",   RGB(0, 180,   0), 8, 1, Low  * 0.995);
PlotText("MED-",   RGB(180,  0,   0), 8, 1, High * 1.005);

// FRACO — apenas monitorar (opcional, pode omitir para nao poluir)
PlotText("F+",     RGB(100, 210, 100), 7, 0, Low  * 0.997);
PlotText("F-",     RGB(210, 100, 100), 7, 0, High * 1.003);

// ATENCAO: PlotText() aceita apenas string literal no 1o argumento.
// NAO usar variaveis nem funcoes (IntToStr() FALHA em compilacao).
```

---

## 7. Regras de Uso

| Funcao       | Robo (.ntsl) | Indicador (.ntfl) | Aceita variavel como cor? |
|--------------|:------------:|:-----------------:|:-------------------------:|
| PaintBar()   | SIM          | SIM               | SIM — RGB(iR, iG, iB)    |
| Alert()      | NAO          | SIM               | SIM — RGB(r, g, b)        |
| PlotText()   | NAO          | SIM               | SIM (cor) / NAO (texto)   |

---

## 8. Mapa Visual Rapido — 3 Niveis

```
CINZA      (128, 128, 128)  → indecisao / doji (corpo < 10% range)
BRANCO     (255, 255, 255)  → ruido / F < 40 (nao opera)
                                          ↑ limite de visibilidade
VERDE  +   (100, 210, 100)  → FRACO  F 40–60  (nao opera, apenas monitora)
VERDE  ++  (  0, 180,   0)  → MÉDIO  F 60–80  ← INICIO DA ZONA OPERACIONAL
VERDE  +++ (  0, 255,   0)  → FORTE  F >= 80  (opera com tamanho cheio)
                                          ↑ limite da zona de plena confianca
VERMELHO + (210, 100, 100)  → FRACO  F -40–-60 (nao opera)
VERMELHO++ (180,   0,   0)  → MÉDIO  F -60–-80 ← INICIO DA ZONA OPERACIONAL SHORT
VERMELHO++ (255,   0,   0)  → FORTE  F <= -80  (opera short tamanho cheio)
```

---

## 9. Cores Especiais — Situacoes de Mercado

| Nome         | RGB               | Uso                                         |
|--------------|-------------------|---------------------------------------------|
| Laranja      | (255, 165,   0)   | Rejeicao forte (pavios > 60% do range)      |
| Amarelo ouro | (255, 215,   0)   | Anomalia de volume (volume > 3x media)      |
| Azul claro   | (  0, 191, 255)   | Informativo / contexto neutro               |
| Roxo         | (148,   0, 211)   | Divergencia / sinal especial                |
| Ciano        | (  0, 255, 255)   | Zona de suporte/resistencia                 |
| Preto        | (  0,   0,   0)   | Fundo / invisivel em fundo escuro           |


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
