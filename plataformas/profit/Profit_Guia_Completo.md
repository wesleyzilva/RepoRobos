# Guia Completo — Neologica Profit Pro

> Plataforma principal para mercado **nacional (B3)** — WIN (minicontrato de índice), WDO, ações.  
> Corretoras suportadas: **XP Investimentos**, **Toro Investimentos**, Rico, Clear, BTG.

---

## 1. Instalação

### 1.1 Download
1. Acesse: https://www.neologica.com.br/profit
2. Baixe o **Profit Pro** (versão completa) ou **Profit Chart** (versão leve)
3. Execute o instalador como Administrador
4. Instale na pasta padrão: `C:\Neologica\`

### 1.2 Requisitos mínimos
| Item | Mínimo | Recomendado |
|------|--------|-------------|
| OS | Windows 10 | Windows 11 |
| RAM | 4 GB | 8 GB+ |
| Processador | Dual-core 2GHz | Quad-core 3GHz+ |
| Internet | 10 Mbps | 50 Mbps+ fibra |

---

## 2. Conexão com Conta Demo

### 2.1 XP Investimentos
1. Abra o Profit Pro
2. No login, clique em **"Acessar com XP"**
3. Entre com seu login XP (CPF + senha)
4. Na tela de seleção de conta, escolha **"Simulador"** ou **"Conta Demo"**
5. Confirme o aceite dos termos de simulação

### 2.2 Toro Investimentos
1. Na tela de login, selecione **"Toro"** na lista de corretoras
2. Use login Toro (e-mail + senha)
3. Selecione a conta com sufixo **"-SIM"** (simulação)

### 2.3 Verificando a conexão demo
- Na barra inferior do Profit deve aparecer: `SIMULADOR` em laranja/amarelo
- O saldo exibido será fictício (geralmente R$100.000 ou configurável)
- **Atenção:** ordens no simulador NÃO chegam à B3

---

## 3. Configuração da Plataforma para Day Trade no WIN

### 3.1 Ativo padrão
- Código do minicontrato de índice: `WINM26` (vencimento março/2026)
- Código genérico (rola automaticamente): `WIN@N` (contrato futuro do mês mais próximo)

### 3.2 Configurar gráfico para backtest NTSL
1. Clique em **"Arquivo → Novo Gráfico"**
2. Insira o ativo: `WIN@N`
3. Selecione o timeframe desejado (15min ou 30min para os robôs PC_XX)
4. Clique com o botão direito → **"Propriedades do Gráfico"**:
   - Quantidade de candles: **100.000** (máximo para 5 anos em 15min)
   - Carregar histório: **Sim**

### 3.3 Configurar Simulador de Estratégias (Backtest)
1. Menu **"Ferramentas → Simulador → Configurações"**
2. Marque: **"Usar dados históricos reais"**
3. Configure horário: 09:00 às 17:55 (pregão WIN)
4. Habilite: **"Slippage"** e defina 1-2 pontos (realismo)
5. Corretagem: R$1,15 por contrato (média mercado) ou zero para gross

---

## 4. Criando Robô NTSL no Editor

### 4.1 Abrir o Editor NTSL
- Menu **"Ferramentas → Editor de Estratégias"** ou `F12`
- Clique em **"Novo"** → selecione **"Robô de Execução"**

### 4.2 Importar código dos robôs
1. Abra o arquivo `.ntsl` da pasta `automacao_backtests/GRUPO/ntsl/`
2. **Ctrl+A** → **Ctrl+C** para copiar todo o código
3. No editor do Profit, cole com **Ctrl+V**
4. Clique em **"Compilar"** (`F7`)
5. Se sem erros: clique em **"Salvar"** com o nome do robô (ex: `mar_PC_01_candle_gap_vwap_5min`)

### 4.3 Erros comuns de compilação NTSL
| Erro | Causa | Solução |
|------|-------|---------|
| `Variable not declared` | Variável fora do bloco `var` | Mover para seção `var` |
| `Incompatible types` | Float atribuído a integer | Usar `Round()` ou declarar float |
| `Undeclared identifier` | Função não existe nessa versão | Verificar versão do Profit |
| `Expected ;` | Falta ponto e vírgula | Revisar linha indicada |

### 4.4 Referência de Sintaxe NTSL

#### Estrutura completa de um robô

```ntsl
{
  Estrategia: nome_do_robo
  Descricao:  o que faz, timeframe, taxa de acerto
}

input
  Parametro1(valorPadrao);    { descricao }
  FlagBooleana(true);
  ValorFloat(100.0);
  ValorInteiro(9);

var
  fPreco      : float;
  bSinal      : boolean;
  iContador   : integer;

begin
  { logica principal }
end;
```

#### Tipos de dados
| Tipo | Uso |
|------|-----|
| `float` | Preços, percentuais, valores financeiros |
| `integer` | Contadores, períodos, índices |
| `boolean` | Flags `true` / `false` |

#### Séries nativas — barra atual `[0]`, barra anterior `[1]`
| Série | Significado |
|-------|-------------|
| `Open` / `Open[1]` | Abertura barra atual / anterior |
| `High`, `Low`, `Close` | Máxima, mínima, fechamento |
| `Volume` | Volume da barra |
| `Date` | Data (`Date <> Date[1]` = nova sessão) |

#### Funções nativas
```ntsl
IFR(periodo)               { Indice de Forca Relativa }
Media(periodo, serie)      { Media aritmetica simples }
MME(periodo)               { Media Movel Exponencial }
MMS(periodo)               { Media Movel Simples }
Max(a, b)                  { Maior valor }
Min(a, b)                  { Menor valor }
Abs(valor)                 { Valor absoluto }
Round(valor)               { Arredondamento }
DayOfWeek(Date)            { Dia da semana: 1=Dom 2=Seg ... 7=Sab }
```

#### Funções de posição
```ntsl
IsBought                   { true se posicionado comprado }
IsSold                     { true se posicionado vendido }
BuyAtMarket                { compra a mercado }
SellShortAtMarket          { venda a mercado }
ClosePosition              { fecha posicao aberta }
BuyLimit(preco, qtd)       { ordem limitada de compra }
SellLimit(preco, qtd)      { ordem limitada de venda }
BuyStop(preco, qtd)        { ordem stop de compra }
SellStop(preco, qtd)       { ordem stop de venda }
```

#### Operadores e comentários
```ntsl
and  or  not               { booleanos }
=  <>  <  >  <=  >=        { comparacao }
+  -  *  /                 { aritmeticos }
{ isto e um comentario }   { NTSL usa { } - nunca // nem /* */ }
```

> **ATENÇÃO — armadilhas de sintaxe:**
> - `input` usa `NomeParam(valor);` com **parênteses** — não `=`
> - Comentários usam `{ }` — não `//`
> - Não há tipo explícito no `input` (ao contrário do MQL5)
> - `var` usa `nome : tipo;` com **dois pontos** antes do tipo

---

## 5. Executando Backtest de 5 Anos

### 5.1 Configurar período
1. Com o robô compilado, vá em **"Ferramentas → Simulador de Estratégias"**
2. Selecione o robô compilado na lista
3. Configure:
   - **Ativo:** `WIN@N`
   - **Timeframe:** 15min (ou 30min)
   - **Data Início:** 01/01/2020
   - **Data Fim:** 07/03/2026 (data atual)
   - **Quantidade:** 1 contrato
   - **Capital inicial:** R$ 10.000

### 5.2 Parâmetros de realismo
```
Slippage:       2 pontos (por ordem)
Corretagem:     R$ 1,15/contrato
Margem WIN:     Verificar na B3 (~R$ 590 por contrato)
Horário:        09:00 - 17:45 (evitar leilão)
```

### 5.3 Rodar backtest
1. Clique em **"Iniciar Simulação"**
2. Aguarde o processamento (pode demorar 1-5 min para 5 anos)
3. Resultados aparecem em 3 abas:
   - **Resumo:** resultado financeiro total
   - **Operações:** lista de cada trade
   - **Gráfico:** curva de capital (equity curve)

---

## 6. Analisando Resultados

### 6.1 Métricas principais a observar

| Métrica | Mínimo aceitável | Ideal |
|---------|-----------------|-------|
| Taxa de acerto | > 55% | > 65% |
| Fator de lucro (PF) | > 1.3 | > 1.8 |
| Drawdown máximo | < 20% capital | < 10% |
| Resultado líquido | Positivo após custos | |
| Nº de operações | > 100 (significância) | > 300 |
| Resultado médio/trade | Positivo | > 2x custo |

### 6.2 Exportar resultados
1. Na aba **"Operações"**, clique em **"Exportar"** → CSV
2. Salvar em: `automacao_backtests/GRUPO/resultsBackTestTimeframe/mar_GRUPO_NN_descricao_timeframe.csv`
3. Para análise em Python: use o script em `automacao_backtests/`

### 6.3 Curva de capital saudável
- Subida consistente, sem quedas abruptas
- Drawdown recuperado em < 30 dias úteis
- Sem período de estagnação > 3 meses
- Desvio padrão dos retornos diários baixo

---

## 7. Otimização de Parâmetros

### 7.1 Acessar otimizador
1. Na janela do Simulador, marque **"Otimização"**
2. Selecione os parâmetros a variar (ex: `PctCorpoMinimo`, `MultiplicadorAlvo`)
3. Defina faixa:
   ```
   PctCorpoMinimo:   0.40 até 0.80, passo 0.05
   MultiplicadorAlvo: 1.0 até 3.0, passo 0.25
   ```
4. Clique **"Otimizar"** — gera tabela com todas combinações

### 7.2 Cuidados com over-fitting
- **NÃO** escolher os melhores parâmetros por lucro bruto
- Preferir combinações com **estabilidade** (lucro consistente numa faixa)
- Testar o parâmetro otimizado em período **fora da amostra** (walk-forward):
  - Otimizar em: 2020–2023
  - Validar em: 2024–2026

### 7.3 Critério de aprovação
```
Critério WFT (Walk-Forward Threshold):
  Resultado fora da amostra >= 50% do resultado dentro da amostra
  → Se 100 pts dentro, precisa >= 50 pts fora
```

---

## 8. Colocando o Robô em Produção (Conta Real)

### 8.1 Ativar o robô no gráfico
1. Abra o gráfico do ativo (`WIN@N`, 15min)
2. Arraste o robô da lista para o gráfico
3. Configure os parâmetros aprovados no backtest
4. Clique em **"Habilitar Negociação"**
5. Confirme: ícone verde na barra do robô

### 8.2 Monitoramento diário
- Verificar conexão antes das 09:00
- Checar ordens abertas após 09:05 (robô deve ter mandado ordem no 1º candle)
- Verificar stop configurado corretamente
- **NÃO** interferir nas operações do robô durante o pregão

### 8.3 Gestão de risco operacional — 1 contrato WIN

> **Sempre operar com 1 contrato.** O robô executa sozinho via simulador.  
> Monitoramento é **externo** — você observa e decide quando desligar manualmente.

#### Como acompanhar os stops no Profit
1. Aba **"Terminal → Histórico de Ordens"**: cada ordem encerrada com prejuízo = 1 stop
2. Aba **"Operações"** no resultado do dia: coluna "Resultado" com valor negativo
3. O robô já imprime no log: `[LOCK] Risco diário atingido` quando trava sozinho

#### Tabela de critérios de desligamento manual

| Horizonte | Gatilho | Ação |
|-----------|---------|------|
| **No dia** | 2 stops consecutivos com perda | Observar 3º operação; se stop → desligar o dia |
| **No dia** | Risco diário atingido (log do robô) | Robô já bloqueia — confirmar que parou |
| **Na semana** | 5 stops no total (win ou loss) com saldo negativo | Desligar robô na sexta, revisar parâmetros |
| **Na semana** | Perda acumulada > R$ 150 na semana | Desligar e avaliar |
| **No mês** | 15 stops no mês com resultado negativo | Pausar 1 semana, rever filtros |
| **No mês** | Drawdown do mês > R$ 500 | Pausar robô, não re-otimizar no mesmo mês |

#### Referência de valores com 1 contrato WIN (R$ 0,20/ponto)

| Stop típico | Pontos | Perda em R$ |
|-------------|--------|-------------|
| Stop curto | 100 pts | R$ 20 |
| Stop médio | 200 pts | R$ 40 |
| Stop largo | 400 pts | R$ 80 |
| Stop grande | 600 pts | R$ 120 |

> **Dica:** Configure `RiscoDiaPct = 1.5` com `SaldoConta = 10000` → o robô trava sozinho ao atingir **R$ 150 de perda no dia**. Você só precisa checar se ele travou corretamente.

---

## 9. Melhores Robôs para Iniciar

### 9.1 Recomendação de ordem de teste (Tier 1 prioritário)

| Robô | Setup | Expectativa | Ordem de teste |
|------|-------|-------------|----------------|
| PC_01 | Gap + corpo + VWAP — compra | Alta | 1º |
| PC_02 | Gap + corpo + VWAP — venda | Alta | 1º |
| PC_05 | Rejeição maxD1 corpo forte | Alta | 2º |
| PC_06 | Rejeição minD1 corpo forte | Alta | 2º |
| PC_17 | Martelo — compra | Média-alta | 3º |
| PC_18 | Estrela cadente — venda | Média-alta | 3º |

### 9.2 Configuração inicial conservadora — 1 contrato
```
SaldoConta:         10000         (capital de referência — R$ 10.000)
Quantidade:         1             (FIXO — sempre 1 contrato)
RiscoDiaPct:        1.5           (R$150 de perda máxima/dia)
RiscoSemanaPct:     3.0           (R$300 máximo/semana)
UsarHardLock:       true          (trava automática ao atingir limite)
MultiplicadorAlvo:  1.5           (padrão)
MaxBarrasPosicao:   8
```

**O que acontece quando o HardLock dispara:**
- O robô encerra a posição aberta imediatamente
- Bloqueia novas entradas pelo restante do dia
- Imprime no log: `[LOCK] Risco diário atingido — bloqueando entradas`
- Você **não precisa fazer nada** — apenas verificar no final do pregão que o log está correto

**Verificação rápida diária (2 minutos às 18h):**
1. Abrir Profit → aba Terminal → Histórico
2. Contar operações do dia: quantas positivas, quantas negativas
3. Checar resultado líquido do dia (coluna Total)
4. Se > 3 stops no dia → anotar no diário de bordo para análise semanal

---

## 10. Troubleshooting

| Problema | Solução |
|---------|---------|
| Robô não entra — "0 operações" | Verificar filtro MME200, ajustar `PctCorpoMinimo` para baixo |
| Muitas operações com perda | Ativar `UsarFiltroMME200 = true`, revisar direção |
| Backtest muito lento | Reduzir janela para 3 anos ou aumentar timeframe |
| Erro "Insufficient margin" | Aumentar `SaldoConta` ou reduzir contratos |
| Robô para de operar no pregão | Verificar `bBloqueioDia` — risco diário foi atingido |
| Histório insuficiente | Ferramentas → Histório → Baixar tudo para WIN@N |
