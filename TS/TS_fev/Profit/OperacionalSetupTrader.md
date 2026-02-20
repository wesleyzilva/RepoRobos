# Setup Operacional: O Sistema Integrado (Wesley)

## 1. Filosofia
Operar a favor do fluxo institucional (VWAP), validado pela estrutura de preço (Pivôs) e confirmado pelo momentum do candle (Price Action). Não adivinhar topos ou fundos, mas reagir a sinais claros de confluência.

---

## 2. Modos de Operação (Estratégia Situacional)

**Importante:** A escolha do modo altera as regras do Checklist (Seção 5). Defina seu modo antes de começar o dia ou ao identificar mudança de mercado.

### A. Modo "Sniper" (Assertividade Máxima)
*   **Quando usar:** Dias travados, horário de almoço ou quando você já bateu a meta e quer arriscar pouco.
*   **Filosofia:** "Só atiro no alvo perfeito".
*   **Impacto no Operacional:**
    *   **Gatilho:** Aceita APENAS **Gold Signal**.
    *   **Filtros:** Todos obrigatórios (VWAP + OBV + Volume).

### B. Modo "Seguidor de Tendência" (Padrão)
*   **Quando usar:** Dias normais, abertura de mercado (09:00 - 11:00) ou quando o ADX/Tendência está forte.
*   **Filosofia:** "Onde a boiada for, eu vou".
*   **Impacto no Operacional:**
    *   **Gatilho:** Aceita Gold Signal, Ciano e Verde.
    *   **Filtros:** VWAP e Estrutura são mandatórios. OBV é recomendável.

### C. Modo "Reversão / Retorno à Média" (Risco Maior)
*   **Quando usar:** Fim de festa (após as 16:00), dias de lateralidade ampla ou quando o preço esticou demais (longe da média).
*   **Filosofia:** "Comprar o pânico e vender a euforia".
*   **Impacto no Operacional:**
    *   **Gatilho:** Aceita padrões de reversão (Martelo/Estrela) mesmo contra a Média de 20.
    *   **Filtros:** Ignora Média de 20. **OBV é Obrigatório** (Divergência).

---

## 3. Rotina e Ativos (O Turno)

### Horários Nobres (Prime Time)
*   **09:00 - 10:00:** Abertura Futuros B3. Tendência inicial.
*   **10:00 - 10:15:** **Zona de Turbulência.** Abertura das Ações (Ibovespa) e Ptax. Evitar operar rompimentos aqui.
*   **10:30 - 12:00:** Abertura NY (Cash). **Melhor horário de liquidez.** Operar B3 e Tickmill simultaneamente.
*   **12:00 - 13:00:** Almoço. Reduzir mão ou encerrar.

### Carteira de Ativos
*   **B3 (Toro):** WIN, WDO, PETR4, VALE3.
*   **Internacional (Tickmill):** XAUUSD (Ouro), EURUSD, US500 (S&P).

### Correlações (A Bússola)
*   **S&P 500 (US500) Caindo Forte** -> Venda WIN.
*   **Dólar Global (DXY) Subindo** -> Compra WDO / Venda EURUSD.

### Notícias e Indicadores (Zona de Exclusão)
*   **Regra:** NÃO estar posicionado durante notícias de Alta Relevância (3 Estrelas/Touros).
*   **Ação:** Zerar operações 5 minutos antes do horário da notícia.
*   **Retorno:** Aguardar 15 minutos após a divulgação para a volatilidade baixar e o spread normalizar.
*   **Principais Eventos:** Payroll (1ª Sexta do mês), CPI (Inflação EUA), FOMC (Juros EUA), PIB.

#### Indicadores para não ficar posicionado (foco B3)

Use este bloco como regra fixa para `WIN` e `WDO`:

- **Janela padrão de proteção:** `-5 min / +15 min` do horário da divulgação.
- **Janela ampliada (evento crítico):** `-10 min / +20 min`.

| Indicador / Evento | Mercado | Horário típico (Brasília) | Janela recomendada sem posição |
| :--- | :--- | :--- | :--- |
| **IPCA / IPCA-15** | Brasil | 09:00 | -5 min até +15 min |
| **IBC-Br / Produção Industrial / Varejo (IBGE)** | Brasil | 09:00 | -5 min até +15 min |
| **Ata/Decisão Copom + coletiva** | Brasil | Fim de tarde/noite (varia) | -10 min até +20 min |
| **Payroll (NFP)** | EUA | 09:30 | -10 min até +20 min |
| **CPI / PPI (EUA)** | EUA | 09:30 | -10 min até +20 min |
| **FOMC (taxa e comunicado)** | EUA | 15:00 | -10 min até +20 min |
| **Coletiva do Fed (Powell)** | EUA | 15:30 | -10 min até +20 min |
| **PIB EUA / ISM / Confiança Michigan (alto impacto)** | EUA | 09:30 ou 11:00 | -5 min até +15 min |

**Regra de ouro:** se o calendário marcar alta relevância, priorize proteção. Primeiro sobreviver, depois performar.
**Observação:** horários podem mudar por calendário oficial, horário de verão e evento extraordinário. Confirmar diariamente no calendário econômico antes da abertura.

---

## 4. Configuração de Tela (Layout Profit)

Organize o ProfitChart em 3 abas principais:

1.  **ABA 1: CONFLUÊNCIA DE DIREÇÃO + TENDÊNCIA (5min)**
    *   **Indicadores:** `fev_direcaoDoDia.ntfl` + `3fev_TendenciaPivoTeste.ntfl`
    *   **Função:** Define viés do dia e confirma direção da tendência para entrada.
    *   *Regra:* Só considerar operação quando direção inicial e tendência em 5min estiverem alinhadas.

2.  **ABA 2: REVERSÃO COM VOLUME (2min)**
    *   **Indicador:** `fev_2minReversaoComVolume.ntsl`
    *   **Função:** Gestão de saída e veto de continuidade.
    *   *Regra:* Se surgir reversão clara com volume, encerrar operação e aguardar novo ciclo de entrada.

3.  **ABA 3: LEITURA FINA DE FLUXO E CANDLE**
    *   **Indicadores:** `fev_PriceActionVSA_OBV.ntsl` + `fev_PriceActionTiposCandlesLeitura.ntfl`
    *   **Função:** Refino de contexto (fluxo/OBV + leitura do tipo de candle).
    *   *Regra:* Usar como confirmação qualitativa antes de clicar e durante o gerenciamento.

**Abas adicionais (apoio):** `0fev_backtestWINFUT_30m.ntsl` e `fev_PriceActionCorpoSombraExecucao.ntsl`.

---

## 5. O Algoritmo de Decisão (Checklist Operacional - 3 Abas)

**Siga a ordem exata. Se um passo falhar, ABORTE.**

### PASSO 1: Viés Inicial + Tendência (ABA 1)
*   Olhe `fev_direcaoDoDia.ntfl` e `3fev_TendenciaPivoTeste.ntfl` na mesma aba.
*   Defina o viés pelo primeiro candle do dia (compra/venda).
*   Só avance se a leitura de tendência em 5min estiver alinhada com esse viés.

### PASSO 2: Entrada por Estrutura (ABA 1)
*   Aguarde no `3fev_TendenciaPivoTeste.ntfl`:
    *   candle direcional de confirmação (verde/vermelho);
    *   seguido do candle **dourado**.
*   Sem dourado, sem entrada.

### PASSO 3: Refino de Qualidade (ABA 3)
*   Confirmar contexto com `fev_PriceActionVSA_OBV.ntsl` e `fev_PriceActionTiposCandlesLeitura.ntfl`.
*   Se houver leitura conflitante (exaustão/rejeição forte contra), cancelar ou reduzir risco.

### PASSO 4: Gestão da Operação (ABA 2)
*   Monitorar `fev_2minReversaoComVolume.ntsl` durante toda a posição.
*   Se aparecer reversão clara com volume, **encerrar a operação**.

### PASSO 5: Reentrada
*   Após saída por reversão, aguardar preço sair da zona de reversão.
*   Reentrar apenas em novo ciclo completo (Passos 1 a 4).

---

## 6. Gestão de Atenção e Alarmes

Não olhe para o gráfico o tempo todo. Deixe o sistema trabalhar.

*   **Alarme 1 (Entrada):** Candle **dourado** no `3fev_TendenciaPivoTeste.ntfl` (ABA 1).
*   **Alarme 2 (Saída):** Reversão com volume no `fev_2minReversaoComVolume.ntsl` (ABA 2).
*   **Alarme 3 (Refino):** Conflito de leitura em `fev_PriceActionVSA_OBV.ntsl` / `fev_PriceActionTiposCandlesLeitura.ntfl` (ABA 3).
*   **Silêncio operacional:** Sem dourado ou com reversão ativa, não operar.

## 7. Gestão de Risco e Alvos

*   **Stop Loss:** Técnico.
    *   Atrás do candle de sinal (agressivo) ou atrás do último pivô/média (conservador).
*   **Alvo Mínimo:** 1.5 para 1.
    *   *Exemplo:* Se o risco é R$ 50, o alvo é R$ 75. Isso cobre taxas e IR.
*   **Breakeven (Proteção):**
    *   Mover para o 0x0 quando o preço andar 70% do caminho ou romper uma nova estrutura a favor.
*   **Custo Operacional:**
    *   WIN: 1 tick (5 pts) paga os custos.
    *   WDO: 1 tick (0,5 pts) paga os custos.

---

## 8. Eficiência Tributária (Resumo)

*   **Brasil (Toro):**
    *   Pagar DARF mensal (20% sobre lucro Day Trade).
    *   Anotar prejuízos para compensar.
*   **Internacional (Tickmill):**
    *   Conta em Seychelles (Sem retenção na fonte).
    *   Imposto anual de 15% sobre lucro (Lei 14.754).

---

## 9. Validação e Disciplina
*   **Trava de Segurança:** Lógica principal **congelada até março** para validação estatística.
*   **Permitido até março:** apenas ajustes críticos de segurança e consistência (sem alterar gatilho principal).
*   **Condição para destravar ajustes:** melhora consistente dos resultados em `resultado2026.csv`.

---

## 10. Guia Técnico: Importação e Execução (.psf)

### Passo 1: Importar a Estratégia
1.  Vá no menu **Estratégias** > **Gerenciador de Estratégias**.
2.  Clique em **Importar**.
3.  Selecione o arquivo `.psf` no seu computador (ex: `Robo_Wesley_Execucao.psf`).
4.  Clique na seta para mover para a direita ("Selecionadas") e confirme em **Importar**.

### Passo 2: Configurar o Robô (Automação)
1.  Vá no menu **Estratégias** > **Automação de Estratégias**.
2.  Clique em **Nova Automação**.
3.  **Estratégia:** Selecione `Robo_Wesley_Execucao`.
4.  **Ativo:** `WINFUT` (Índice) ou `WDOFUT` (Dólar).
5.  **Periodicidade:** `30` minutos (conforme backtest).
6.  **Quantidade:** Defina os contratos (ex: 1).

### Passo 3: Parâmetros e Segurança (Crucial)
Antes de salvar, verifique as abas:
1.  **Parâmetros:** Confira se `HoraInicio` (0905) e `HoraZeragem` (1730) estão corretos.
2.  **Entrada/Saída:** Configure a zeragem compulsória da corretora para 17:40 (segurança extra).
3.  **Risco:** Ative a **Perda Máxima Diária** (ex: R$ 300,00) para travar o robô em dias ruins.

### Passo 4: Executar
1.  Clique em **Criar** / **Salvar**.
2.  Na lista de automações, clique no botão **Executar** (Play).
3.  O status deve mudar para "Executando" (Verde).

---

## 11. Parâmetros Técnicos do Robô (Inputs)

Estes são os parâmetros configuráveis na janela de propriedades do Robô (`0fev_backtestWINFUT_30m`).

| Parâmetro | Padrão | Descrição |
| :--- | :--- | :--- |
| **PeriodoMedia** | `20` | Período da Média Exponencial Mestra (Tendência). |
| **PeriodoEstrutura** | `5` | Quantidade de candles para definir o rompimento de topo/fundo. |
| **FatorAlvo** | `2.0` | Relação Risco/Retorno para o alvo final (2x o risco). |
| **AtivarBreakeven** | `True` | Move o Stop para o 0x0 quando o preço anda a favor. |
| **AtivarTrailingStop** | `False` | Se True, move o Stop seguindo a Média de 9. |
| **UsarFiltroVWAP** | `True` | Só opera a favor da VWAP Diária (Filtro Macro). |
| **UsarFiltroTendencia** | `True` | Só opera a favor da inclinação da Média de 20. |
| **UsarFiltroEstrutura** | `True` | Exige rompimento de máxima/mínima de 5 candles. |
| **UsarFiltroVeto** | `True` | Evita entrar se houver pavio contra (Rejeição). |
| **UsarFiltroOBV** | `True` | Exige que o OBV esteja a favor da operação. |
| **SomenteGoldSignal** | `True` | Se True, ignora sinais normais e só pega Gold Signal (Sniper). |
| **UsarFiltroInclinacao**| `True` | Evita operar se a Média 20 estiver flat (lateral). |
| **LimiarInclinacao** | `15` | Pontos mínimos de inclinação (WIN). Ajustar para 0.5 no WDO. |
| **UsarFiltroCaixote** | `False` | Evita operar se o preço estiver preso entre M50 e M200. |
| **UsarFiltroVolume** | `True` | Exige volume acima da média no candle de sinal. |