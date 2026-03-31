# Regra de Cores dos Candles (FORCA_SEMAFORO_CORES_55)

## Lógica Geral
- Todo candle começa cinza (RGB 128,128,128).
- Se for candle de indecisão (corpo < 10% do range): branco (RGB 255,255,255).
- Se for compra (força >= ForcaMinimaEntrada): verde em degradê (quanto maior a força, mais verde).
- Se for venda (força <= -ForcaMinimaEntrada): vermelho em degradê (quanto menor a força, mais vermelho).

## Detalhamento das Cores
| Situação         | Condição                                      | Cor (RGB)                       |
|------------------|-----------------------------------------------|---------------------------------|
| Cinza (padrão)   | Sempre inicia                                 | (128, 128, 128)                 |
| Branco           | abs(fCorpo) < 10% do fRange                   | (255, 255, 255)                 |
| Verde degradê    | fForca >= ForcaMinimaEntrada                  | (r, g, b) → mais verde com força|
| Vermelho degradê | fForca <= -ForcaMinimaEntrada                 | (r, g, b) → mais vermelho com força|

### Fórmulas para o degradê
- **Verde:**
  - g = 128 + round((fForca/100) * 127)   // 128 a 255
  - r = 128 - round((fForca/100) * 128)   // 128 a 0
  - b = 128 - round((fForca/100) * 128)   // 128 a 0
- **Vermelho:**
  - r = 128 + round((-fForca/100) * 127)  // 128 a 255
  - g = 128 - round((-fForca/100) * 128)  // 128 a 0
  - b = 128 - round((-fForca/100) * 128)  // 128 a 0

## Exemplo de Código
```pascal
// ...existing code...
// --- LÓGICA DE CORES (DEGRADE RGB) ---
var r, g, b: integer;
r := 128; g := 128; b := 128; // Cinza padrão

// Indecisão: corpo pequeno (ex: < 10% do range)
if (abs(fCorpo) < 0.1 * fRange) then
begin
  r := 255; g := 255; b := 255; // Branco
end
// Compra: força positiva































- Os limites de RGB garantem que as cores não ultrapassem o intervalo 0-255.- Candles de indecisão ficam brancos para fácil identificação.- O degradê permite visualizar a intensidade da força de compra/venda.## Observações```// ...existing code...PaintBar(RGB(r, g, b));// Senão, permanece cinzaend  if b < 0 then b := 0;  if g < 0 then g := 0;  if r > 255 then r := 255;  b := 128 - round((-fForca/100) * 128); // 128 a 0  g := 128 - round((-fForca/100) * 128); // 128 a 0  r := 128 + round((-fForca/100) * 127); // 128 a 255  // Vermelho degradê: quanto menor a força, mais forte o vermelhobeginelse if (fForca <= -ForcaMinimaEntrada) then// Venda: força negativaend  if b < 0 then b := 0;  if r < 0 then r := 0;  if g > 255 then g := 255;  b := 128 - round((fForca/100) * 128); // 128 a 0  r := 128 - round((fForca/100) * 128); // 128 a 0  g := 128 + round((fForca/100) * 127); // 128 a 255  // Verde degradê: quanto maior a força, mais forte o verdebeginelse if (fForca >= ForcaMinimaEntrada) then