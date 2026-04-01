# Exemplos de Sintaxe Profit (Nelogica)

Exemplos extraídos diretamente da documentação oficial da plataforma Profit.
Servem como referência de sintaxe NTSL/NTFL para criação de novos robôs e indicadores.

> Cada arquivo pode conter múltiplos blocos independentes (cada `begin...end;` é um script separado).
> Para compilar no Profit, copie o bloco desejado em um novo script.

---

## Arquivos

| Arquivo | Tipo Profit | O que demonstra |
|---------|-------------|-----------------|
| [execucao.ntsl](execucao.ntsl) | Robô | BuyLimit, SellShortLimit, SellToCoverStop, BuyToCoverStop, múltiplos ativos, MinPriceIncrement |
| [alarme.ntfl](alarme.ntfl) | Alarme | Alert(), RSI, múltiplos ativos |
| [coloracao.ntfl](coloracao.ntfl) | Coloração | PaintBar(), múltiplos ativos, const Asset |
| [escrita.ntfl](escrita.ntfl) | Escrita | PlotText(), múltiplos ativos |
| [estudo.ntfl](estudo.ntfl) | Estudo | HorizontalLineCustom, VerticalLineCustom, LineSegment, HighW/LowW, CalcDate, DayOfWeek |
| [indicador.ntfl](indicador.ntfl) | Indicador | Plot, Plot2, SetPlotColor, procedures, functions, const, Asset com interval |
| [screening.ntfl](screening.ntfl) | Screening | Select(), múltiplos ativos |

---

## Padrões importantes de sintaxe

### Múltiplos ativos
```pascal
const
  A1 = Asset("WINFUT", feedBMF);   // ativo constante
input
  A2("DOLFUT", feedBMF);           // ativo como parâmetro editável
```

### Ordens com preço específico
```pascal
BuyLimit(preco);
SellShortLimit(preco);
SellToCoverLimit(preco, BuyPosition);
SellToCoverStop(stop, stopLimit, BuyPosition);
```

### Indicadores customizados
```pascal
Plot(valor);               // linha principal
Plot2(valor);              // segunda linha
SetPlotColor(1, clGreen);  // cor dinâmica da linha 1
```

### Linhas e anotações em estudos
```pascal
HorizontalLineCustom(preco, cor, largura, estilo, "label", fontSize, posicao, offsetX, offsetY, variacao);
VerticalLineCustom(cor, largura, estilo, "label");
LineSegment(precoInicio, precoFim, dataInicio, dataFim, extrapolar, "label", cor, largura, estilo, fontSize, posicao, horaInicio, horaFim);
```

### Procedures e functions
```pascal
procedure NomeProcedure(parametro : Float);
begin
  // ...
end;

function NomeFuncao(p1, p2 : Float): Float;
begin
  Result := p1 - p2;
end;
```
