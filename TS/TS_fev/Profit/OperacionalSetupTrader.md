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

---

## 4. Configuração de Tela (Layout Profit)

Organize o ProfitChart em 3 abas ou janelas para seguir o fluxo de decisão:

1.  **ABA 1: MACRO (O Porteiro)**
    *   **Indicador:** `fev_VWAPsemanalDiario.ntfl`
    *   **Função:** Define a permissão.
    *   *Regra:* Se estiver **Cinza**, proibido operar. Se **Verde**, só compra. Se **Vermelho**, só venda.

2.  **ABA 2: ESTRUTURA (O Mapa)**
    *   **Indicador:** `fevTendenciaPivoTeste.ntsl`
    *   **Função:** Valida o rompimento.
    *   *Regra:* O preço precisa romper a máxima/mínima dos últimos 5 candles (ficar colorido) para confirmar que o mercado está andando.

3.  **ABA 3: EXECUÇÃO (O Gatilho)**
    *   **Indicador:** `fev_PriceActionCorpoSombraExecucao.ntsl` (ou `fev_PriceAction.ntsl`)
    *   **Auxiliar:** `fev_MediasSetupDiario.ntsl` (Médias 9, 14, 20, 50, 200).
    *   **Função:** Onde você clica.

---

## 5. O Algoritmo de Decisão (Checklist de Entrada)

**Siga a ordem exata. Se um passo falhar, ABORTE.**

### PASSO 1: Validação Institucional
*   Olhe para a **Aba Macro**.
*   O preço está alinhado com a VWAP Diária e Semanal? (Cor Verde ou Vermelha).
    *   *Sim:* Avance.
    *   *Não:* Espere.

### PASSO 2: Validação de Estrutura
*   Olhe para a **Aba Estrutura**.
*   O preço rompeu a congestão recente (> 5 candles)?
    *   *Sim:* Avance.

### PASSO 3: O Gatilho (Price Action)
*   Olhe para a **Aba Execução**. Qual o sinal?
    *   **🥇 Gold Signal (Amarelo):** Entrada de Alta Convicção (Mão Cheia). *Confluência de Força + Tendência + Continuidade.*
    *   **🥈 Força (Ciano/Fuchsia):** Entrada de Momentum (Mão Normal).
    *   **🥉 Técnico (Verde/Vermelho):** Entrada Técnica (Mão Leve).

### PASSO 4: O Veto (Refino)
*   **Veto de Candle:** Olhe para o indicador `fev_PriceActionAnaliseSombra` ou `fev_VSAassinaturaInstitucional`.
*   Existe pavio gigante contra? Existe volume de reversão (Upthrust/Shakeout contra)?
    *   *Sim:* Cancele ou espere confirmação.
    *   *Não:* Avance para o Veto Final.

### PASSO 5: O Veto de Fluxo (OBV)
*   **Veto de Fluxo:** Olhe para o indicador `fev_OBVvolumeVerdadeiro`.
*   **Para uma COMPRA:** A linha do OBV está **Verde** (acima da sua média)?
    *   *Sim:* **CLICK (Executar).**
    *   *Não (Vermelha):* **VETO.** O fluxo de volume não confirma a alta. Risco de armadilha.
*   **Para uma VENDA:** A linha do OBV está **Vermelha** (abaixo da sua média)?
    *   *Sim:* **CLICK (Executar).**
    *   *Não (Verde):* **VETO.** O fluxo de volume não confirma a baixa.

---

## 6. Gestão de Atenção e Alarmes

Não olhe para o gráfico o tempo todo. Deixe o sistema trabalhar.

*   **Alarme 1 (Prioridade Máxima):** `fev_PainelDecisao`. Se tocar, significa que VWAP + Estrutura + Gatilho alinharam. Olhe imediatamente.
    *   *Nota:* O indicador `fev_PainelDecisao` foi criado para automatizar os Passos 1, 2 e 5 do checklist. Ele mostra "COMPRA/VENDA AUTORIZADA" e toca um alarme apenas quando os filtros macro (VWAP, Estrutura e OBV) estão alinhados, liberando você para procurar o gatilho de entrada.
*   **Alarme 2 (Oportunidade):** `fev_PriceAction` (Gold Signal). Se tocar, verifique se o Painel autoriza.
*   **Alarme 3 (Tendência):** `fev_MediasSetup` (Ciano/Fuchsia). Indica início de fluxo forte. Prepare-se para pullbacks.
*   **Silêncio:** Se não houver alarmes, o mercado está em "Ruído" (Cinza). Vá estudar ou fazer outra coisa.

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
*   **Trava de Segurança:** Não podemos mudar a estrutura operacional até ser validada pelos resultados em `resultado2026.csv`.

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