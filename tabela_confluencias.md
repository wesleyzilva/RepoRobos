# Tabela Mestra de Confluências e Prioridades

Este documento centraliza a hierarquia de decisão do Trade System. Ele deve ser atualizado sempre que uma nova teoria for estudada.

**Regra Fundamental:** Sinais de hierarquia superior (Peso 5) **anulam** ou **validam** sinais de hierarquia inferior. Nunca opere contra um Peso 5.

## Ranking de Importância (Atualizado: Fev/2026)

| Rank | Peso | Categoria | Script / Arquivo | O que observar? (O Sinal) | Ação Prática |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | 🟥 **5** | **Institucional** | `fev_VWAPsemanalDiario.ntfl` | O candle está Verde (Compra) ou Vermelho (Venda)? | **Filtro de Permissão.** Se estiver Cinza ou contra a cor, NÃO FAÇA NADA. |
| **2** | 🟧 **4** | **Estrutura** | `fevTendenciaPivoTeste.ntsl` | O preço rompeu a estrutura de 5-12 candles (Verde/Vermelho)? | **Confirmação de Fluxo.** Garante que não é um falso rompimento. |
| **3** | 🟨 **3** | **Gatilho** | `fev_PriceAction.ntsl` | Apareceu o **Gold Signal (Amarelo)** ou Barra de Força (Ciano/Fuchsia)? | **Sinal de Entrada.** É o momento do clique. |
| **4** | 🟦 **2** | **Refino** | `fev_PriceActionAnaliseSombra.ntsl` | Existe pavio contra a operação (Azul/Marrom)? | **Veto.** Se tiver muita sombra contra, aborte ou reduza a mão. |
| **5** | 🟪 **2** | **Fluxo (OBV)**| `fev_OBVvolumeVerdadeiro.ntsl` | O OBV está a favor do movimento (Verde/Vermelho)? | **Veto de Fluxo.** Se o OBV divergir, o movimento é falso. |
| **6** | ⬜ **1** | **Leitura** | `fev_PriceAction_Tipos.ntsl` | Qual o nome do padrão? (Engolfo, Martelo, Inside Bar) | **Contexto.** Ajuda a entender a psicologia. |

---

## O Algoritmo de Execução (Ordem Exata)

Siga esta sequência lógica de arquivos para cada operação. Se falhar em um passo, não avance para o próximo.

### PASSO 0: Calendário Econômico (Segurança)
*   **Verificação:** Há notícia de alto impacto (3 estrelas) nos próximos 10 minutos?
    *   *Sim:* **PARE.** Zere posições e aguarde.
    *   *Não:* Prossiga.

### PASSO 1: O Porteiro (Institucional)
*   **Arquivo:** `fev_VWAPsemanalDiario.ntfl`
*   **Contexto:** `fev_MediasSetupSemana.ntsl` (no Diário).
*   **Validação:** O preço está alinhado com a VWAP Diária e Semanal?
    *   *Sim (Verde/Vermelho):* Vá para o Passo 2.
    *   *Não (Cinza):* **PARE.** O mercado está indeciso.

### PASSO 2: O Mapa (Estrutura)
*   **Arquivo:** `fevTendenciaPivoTeste.ntsl`
*   **Validação:** O preço rompeu uma estrutura de acumulação recente (> 5 candles)?
    *   *Sim (Mudou de Cinza para Cor):* O caminho está livre. Vá para o Passo 3.
    *   *Não (Ainda Cinza):* Você está dentro de uma lateralidade. Cuidado.

### PASSO 3: O Gatilho (Execução)
*   **Arquivo:** `fev_PriceActionCorpoSombraExecucao.ntsl` (Principal)
*   **Validação:** Tenho um sinal claro?
    *   **🟡 Gold Signal (Amarelo):** Entrada de Alta Convicção (Mão Cheia).
    *   **🔵 Ciano / 🟣 Fuchsia:** Entrada de Momentum (Mão Normal).
    *   **🟢 Verde / 🔴 Vermelho:** Entrada Técnica (Mão Leve).

### PASSO 4: O Detector de Mentiras (VSA + OBV)
*   **VSA (Intensidade):** O volume do candle é maior que a média? (Evita rompimento sem força).
*   **OBV (Direção):** O OBV está apontando para a mesma direção do trade?
    *   *Sim:* **CLIQUE.**
    *   *Não:* **ABORTAR.** Divergência de fluxo.

---

## Matriz de Decisão (Exemplos Práticos)

### Cenário A: O "Falso" Gold Signal
- **Passo 1 (VWAP):** Gráfico está Cinza (Preço entre VWAP Diária e Semanal).
- **Passo 3 (Gatilho):** Aparece um candle Amarelo (Gold Signal).
- **Decisão:** **NÃO OPERAR.** O sinal é bonito, mas o contexto institucional (Rank 1) não autorizou. Risco de violino.

### Cenário B: A Entrada de Livro
- **Passo 1 (VWAP):** Gráfico Verde (Acima das duas VWAPs).
- **Passo 2 (Estrutura):** `fevTendenciaPivoTeste` ficou Verde (Rompeu máxima de 5 candles).
- **Passo 3 (Gatilho):** Candle Ciano (Barra de Força).
- **Decisão:** **COMPRA.** Alinhamento total de fluxo e momentum.

### Cenário C: A Rejeição (Salvo pelo Gongo)
- **Passo 1 e 2:** Ok (Favoráveis).
- **Passo 3:** Candle Verde (Engolfo de Alta).
- **Passo 4 (Sombra):** O `AnaliseSombra` mostra uma cor Azul Royal (Pavio superior longo).
- **Decisão:** **CANCELAR.** O mercado tentou subir e foi rejeitado no mesmo candle.