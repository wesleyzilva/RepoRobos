# Instrução Geral para Robôs e Estratégias — RepoRobos

## Estrutura Obrigatória

### Cabeçalho

```ntsl
{
  Robo:       mar_NOMEGRUPO_NN_nome
  Grupo:      [nome do grupo] — Tier X (#NN)
  Descricao:  [Descrição do setup]
  Timeframe:  [Ex: 60min, 30min]
  Ativo:      WIN (minicontrato de índice)
  Versao:     1.0 — [mês/ano]
}
```

### Inputs (parametrização)

- Todos os parâmetros de risco, filtros, períodos e flags devem ser declarados como input.
- Nunca hardcode valores de risco ou filtros no corpo do código.

#### Bloco padrão de inputs (NTSL)

```ntsl
input
  UsarGestaoRisco(true);
  UsarHardLock(true);
  SaldoConta(10000.0);
  RiscoDiaPct(1.5);
  RiscoSemanaPct(3.0);
  MaxStopsConsecutivos(2);
  ValorPorPonto(0.2);
  DiaSemanaReset(2);
  // Adicione inputs específicos do setup
```

### Variáveis

- Declare todas as variáveis usadas na lógica, incluindo controle de posição, resultado, filtros, etc.

### Lógica Operacional

- Reset diário e semanal das variáveis de resultado e bloqueio.
- Gestão de risco sempre parametrizável.
- Cálculo de sinais (IFR, médias, price action, volume, etc).
- Entrada: apenas se não posicionado e não bloqueado.
- Saída: por critério técnico, tempo, trailing ou ambos.

### Exemplo de Bloco de Entrada

```ntsl
if (not IsBought) and (not IsSold)
  and (not (UsarGestaoRisco and (bBloqueioDia or bBloqueioSemana))) then
begin
  // Sinal de compra/venda
  if bSinalCompra then
    BuyAtMarket;
  else if bSinalVenda then
    SellShortAtMarket;
end;
```

### Exemplo de Bloco de Saída

```ntsl
if IsBought and (criterio_saida) then
  ClosePosition;
if IsSold and (criterio_saida) then
  ClosePosition;
```

## Regras de Qualidade

- Inputs de risco obrigatórios.
- Estrutura de bloco begin/end correta.
- Comentários sempre com { }.
- Timeframe no nome do arquivo.
- Não operar sem stop definido.
- Filtros de contexto (MME, VWAP, price action) recomendados.

## Referência

- Veja exemplos em IFR, Price Action, médias, volume.
- Consulte WorkspaceRobosTrade/instrucao_robos.md para padronização.
