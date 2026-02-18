# Teoria Operacional: Análise Top-Down (Do Macro ao Micro)

## 1. O Conceito
O mercado é fractal. O que acontece no Mensal domina o Semanal, que domina o Diário. Operar no intraday sem saber onde você está no mapa macro é como dirigir olhando apenas para o para-choque do carro da frente.

## 2. Mensal (M1) - O Clima (Visão de Águia)
*   **Horizonte de Tempo:** Olhar os últimos **2 a 5 anos**.
*   **O que marcar:**
    *   **Topo Histórico e Fundo Histórico:** São ímãs de liquidez. O mercado sempre lembra deles.
    *   **Números Redondos (Psicológicos):** Ex: 100.000, 130.000 no Índice; 5.00, 6.00 no Dólar.
    *   **Grandes Zonas de Rejeição:** Procure por pavios longos onde o preço tocou e voltou violentamente. Essas regiões são "zonas de choque".
*   **Objetivo:** Saber se estamos no "Verão" (Bull Market Secular) ou "Inverno" (Bear Market).

## 3. Semanal (W1) - A Maré (Tendência Primária)
*   **Horizonte de Tempo:** Olhar os últimos **1 a 2 anos**.
*   **O que marcar:**
    *   **Pivôs Principais (Zig-Zag):** Marque o último Topo e o último Fundo confirmados.
    *   **Média de 200 (Branca):** Onde ela está? Se o preço está longe dela, cuidado com exaustão.
    *   **LTA / LTB Primária:** A linha diagonal que segura a tendência do ano.
*   **Objetivo:** Definir a **Tendência Primária**.
    *   *Regra:* Se o Semanal está subindo, suas vendas no Day Trade serão curtas (contra-tendência/correção). Seus trades longos serão de compra.

## 4. Diário (D1) - A Onda (Viés do Dia)
*   **Horizonte de Tempo:** Olhar os últimos **3 a 6 meses**.
*   **O que marcar:**
    *   **Gaps Abertos:** O mercado odeia vazios e tende a fechá-los. Marque o início e fim do gap.
    *   **Médias (20 e 50):** O preço está acima ou abaixo? Está "esticado" (longe) ou "no valor" (perto)?
    VER: Teoria_Afastamento.md
    *   **Inside Bars / Engolfos Recentes:** Marque a máxima e mínima do candle de ontem e anteontem.
*   **Objetivo:** Definir o **Viés Imediato**. "Hoje eu procuro compra ou venda?".

## 5. Intraday (60m / 15m) - O Momento (Execução)
*   **Horizonte de Tempo:** Olhar as últimas **1 a 2 semanas**.
*   **O que marcar:**
    *   **Pontos do Dia Anterior:** Máxima, Mínima, Fechamento e Ajuste.
    *   **VWAP Semanal:** Onde está o preço médio da semana atual?
    *   **Pivôs Intraday:** A estrutura de alta/baixa imediata.
*   **Objetivo:** **Timing.** É aqui que você aplica o `fev_PriceAction` e clica.
    *   **Regra de Horário:** Aguardar 10:00 AM (formação do primeiro canal de 15m).
    *   **Timing de Candles (Janelas de Fluxo):**
        *   *5m:* Candle 20 (Início), Candle 50 (Meio), Candle 80 (Fim).
        *   *15m:* Candle 10 (Início), Candle 25 (Fim).
    *   **Alvos:** Projetar Fibonacci do pivô ou candle de força. Parciais em 50% e 61.8%. Alvo final em 100%.

## 6. Tabela de Validade das Linhas

| Timeframe | Tipo de Linha | Cor Sugerida | Validade |
| :--- | :--- | :--- | :--- |
| **Mensal** | Suporte/Resistência Histórico | Vermelho Espesso | Anos |
| **Semanal** | LTA/LTB, Pivôs | Amarelo | Meses |
| **Diário** | Gaps, Máximas/Mínimas | Branco | Semanas |
| **60m/15m** | Ajuste, VWAP, Pivô Micro | Ciano/Verde | Dias (1-3 dias) |

## 7. Regra de Ouro da Confluência

1.  **Alinhamento Total:** Se Mensal, Semanal e Diário apontam para cima -> **Mão Cheia na Compra.**
2.  **Correção:** Se Semanal sobe, mas Diário cai -> **Mão Leve ou Aguardar** (Você está operando um pullback do semanal).
3.  **O Muro:** Nunca opere um rompimento de pivô no 15m (compra) se logo acima tiver uma Resistência Mensal marcada. A chance de falhar é de 80%.