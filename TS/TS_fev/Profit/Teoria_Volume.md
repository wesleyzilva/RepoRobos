# Teoria Operacional: Volume Avançado (Além do VSA)

## 1. As Duas Dimensões do Volume
Enquanto o VSA analisa o volume no **Tempo** (barra a barra), existem outras formas de ler a liquidez que revelam onde os grandes players estão posicionados.

1.  **Volume no Tempo (Vertical):** "Quanto" foi negociado naquele horário. (Foco do VSA).
2.  **Volume no Preço (Horizontal):** "Onde" foi negociado o maior lote. (Foco do Volume Profile).

---

## 2. VWAP (O Preço Justo Institucional)
A **VWAP (Volume Weighted Average Price)** não é uma média móvel comum. É a média de preço ponderada pelo volume financeiro de todos os negócios do dia.

*   **Por que importa?** Tesourarias e Robôs de execução usam a VWAP como benchmark. Se eles compram abaixo da VWAP, fizeram um bom negócio. Se compram acima, pagaram caro.
*   **A Regra do Ímã:** O preço tende a voltar para a VWAP durante o dia, pois é o "valor justo" da sessão.
*   **A Regra da Tendência:**
    *   Preço **ACIMA** da VWAP = Viés Comprador (Institucionais defendendo preço médio).
    *   Preço **ABAIXO** da VWAP = Viés Vendedor.

### Setup: Pullback na VWAP
1.  O preço rompe a VWAP com força (Barra de Ignição).
2.  Volta suavemente para testar a linha da VWAP.
3.  Deixa um gatilho de Price Action (Martelo/Engolfo) exatamente na VWAP.
4.  **Entrada:** Na superação da máxima.

---

## 3. Volume Profile (O Mapa de Liquidez)
Ferramenta que plota o volume no eixo vertical (preço), criando um histograma lateral.

### Conceitos Chave:
*   **POC (Point of Control):** A linha vermelha no Profile. É o nível de preço exato onde houve o maior volume de negociação do dia.
    *   **Função:** Atua como o suporte/resistência mais forte do dia. O preço costuma travar ali.
*   **Value Area (VA):** A região onde ocorreram 70% dos negócios. É a zona de aceitação.
*   **Vazios de Volume (Low Volume Nodes):** Regiões do gráfico onde o histograma é fino.
    *   **Efeito Escorregadio:** O preço passa muito rápido por essas zonas porque não há liquidez (barreiras) para segurá-lo.

### Como Operar:
*   **Defesa de POC:** Se o preço volta para a POC após se afastar, espere uma defesa (rejeição).
*   **Fuga de Caixote:** Se o preço sai da Área de Valor (Value Area), ele tende a acelerar (entrou em descoberta de preço).

---

## 4. OBV (On Balance Volume) - O Detector de Mentiras
O OBV soma o volume em dias de alta e subtrai em dias de baixa. Ele mostra o saldo acumulado da pressão.

### A Divergência (O Grande Sinal)
O preço pode mentir, o volume não.

*   **Divergência de Alta:** O Preço está caindo ou lateral (fazendo fundos mais baixos), mas o OBV já começou a subir (fazendo fundos mais altos).
    *   *Tradução:* Estão acumulando silenciosamente na queda. A explosão para cima é iminente.
*   **Divergência de Baixa:** O Preço continua subindo (fazendo topos mais altos), mas o OBV já começou a cair (fazendo topos mais baixos).
    *   *Tradução:* Estão distribuindo no topo. A alta é falsa (sem combustível).

---

## 5. Delta e Agressão (Visão de Fluxo/Tape Reading)
Se você usa ferramentas de fluxo no Profit (como o indicador "Saldo de Agressão" ou "Weis Wave"):

*   **Volume Total** = Agressão de Compra + Agressão de Venda.
*   **Delta** = Agressão de Compra - Agressão de Venda.

### O Fenômeno da Absorção (Iceberg)
É uma das anomalias mais lucrativas.

*   **Cenário:** O preço chega em um suporte.
*   **Delta:** Mostra **Delta Vendedor Forte** (vermelho intenso). Muita gente batendo na venda.
*   **Preço:** O candle **NÃO DESLOCA** para baixo. Fica parado ou deixa pavio.
*   **Interpretação:** Tem um "Iceberg" (Lote Escondido) de compra absorvendo todas as vendas a mercado. Quando os vendedores cansarem, o preço vai explodir para cima.

---

## 6. Resumo: Qual Ferramenta Usar?

| Ferramenta | Pergunta que ela responde | Melhor Uso |
| :--- | :--- | :--- |
| **VSA (Candles)** | "Houve esforço vs resultado nesta barra?" | Gatilho de Entrada (Timing). |
| **VWAP** | "Quem está ganhando o dia: Touros ou Ursos?" | Direção e Alvo de Pullback. |
| **Volume Profile** | "Onde está a barreira de concreto?" | Definir Alvos e Suportes Fortes. |
| **OBV** | "O movimento é verdadeiro ou falso?" | Antecipar Reversões (Divergência). |

## 7. Integração com Trade System Wesley

*   **Regra de Ouro:** Nunca opere contra a VWAP em tendência forte.
*   **Confluência:** Um **Shakeout (VSA Verde)** que ocorre exatamente em cima da **VWAP** ou da **POC** é um trade de probabilidade extrema (Rank S).
*   **Alvo:** Se você comprou no fundo, a POC do dia anterior é um excelente alvo de saída, pois a liquidez costuma travar lá.