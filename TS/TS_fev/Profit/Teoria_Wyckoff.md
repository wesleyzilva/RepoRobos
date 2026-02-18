# Teoria Operacional: O Método Wyckoff (O Jogo dos Grandes)

## 1. O "Composite Man" (O Homem Composto)
Richard Wyckoff propôs que o mercado deve ser visto como se fosse controlado por uma única entidade mestre: o "Composite Man" (Institucional).
*   **A Regra:** Ele senta nos bastidores e manipula o preço para desvantagem do público.
*   **O Objetivo:** Comprar barato do público em pânico (Acumulação) e vender caro para o público eufórico (Distribuição).
*   **A Lição:** Não tente vencer o mercado. Tente identificar as pegadas desse gigante e andar na sombra dele.

## 2. As 3 Leis de Wyckoff

### Lei 1: Oferta e Demanda
Determina a direção do preço.
*   **Demanda > Oferta:** Preço sobe.
*   **Oferta > Demanda:** Preço cai.
*   **Oferta = Demanda:** Preço lateraliza (preparação).
*   *No Gráfico:* Olhe para os candles de força e o deslocamento.

### Lei 2: Causa e Efeito
Para todo movimento grande (Efeito), deve haver uma preparação proporcional (Causa).
*   **Causa:** A lateralidade (Acumulação/Distribuição). Quanto mais tempo o preço fica lateral, maior será a explosão.
*   **Efeito:** A tendência subsequente.
*   *Aplicação:* Não espere um alvo de 1000 pontos se a acumulação durou apenas 5 candles.

### Lei 3: Esforço vs Resultado
A lei da divergência (VSA).
*   **Convergência:** Volume alto (Esforço) gera candle grande (Resultado). Normal.
*   **Divergência:** Volume alto (Esforço) gera candle pequeno ou com muito pavio (Pouco Resultado).
*   *Sinal:* Se o "Composite Man" aplicou muita força e o preço não andou, há uma barreira oculta (Absorção). Reversão iminente.

## 3. Anatomia da Acumulação (O Fundo)
O processo de tirar ativos das "Mãos Fracas" para as "Mãos Fortes".

### Fase A: Parar a Queda
1.  **PS (Preliminary Support):** Primeira tentativa de parar a queda. Volume aumenta.
2.  **SC (Selling Climax):** Pânico total. Volume extremo, spreads largos. O público vende tudo.
3.  **AR (Automatic Rally):** Repique natural por falta de vendedores. Define o teto da lateralidade.
4.  **ST (Secondary Test):** Teste da mínima do SC com volume menor.

### Fase B: Construção da Causa
*   O preço oscila dentro do range. O "Composite Man" absorve a oferta silenciosamente.

### Fase C: O Teste Final (A Armadilha)
*   **Spring (Mola):** O preço perde o suporte do range (SC/ST) para estopar quem comprou cedo e induzir venda.
*   **Shakeout:** Versão violenta do Spring.
*   **Test:** O preço volta para testar o Spring com volume baixo (Ninguém mais quer vender). **PONTO DE ENTRADA 1.**

### Fase D: O Salto (Markup dentro do Range)
*   **SOS (Sign of Strength):** Candle de força que rompe resistências internas.
*   **LPS (Last Point of Support):** Pullback raso após o SOS. **PONTO DE ENTRADA 2.**

### Fase E: A Tendência
*   O preço rompe o range definitivamente. Ocorre o **Back Up (BU)** ou Pullback no topo do range. **PONTO DE ENTRADA 3.**

## 4. Anatomia da Distribuição (O Topo)
O processo de desovar ativos para o público eufórico.

### Fase A: Parar a Alta
1.  **PSY (Preliminary Supply):** Primeira venda forte.
2.  **BC (Buying Climax):** Euforia máxima. Notícias boas. Volume extremo.
3.  **AR (Automatic Reaction):** Queda natural. Define o piso do range.
4.  **ST (Secondary Test):** Teste do topo do BC.

### Fase B: Construção
*   O preço lateraliza. Institucionais vendem lotes fracionados para não derrubar o preço.

### Fase C: A Armadilha (Upthrust)
*   **UT (Upthrust):** Rompimento falso do topo. Captura stops dos vendidos e atrai compradores de rompimento.
*   **UTAD (Upthrust After Distribution):** O último suspiro. Um rompimento maior que falha miseravelmente.

### Fase D: O Declínio
*   **MSOW (Major Sign of Weakness):** Candle vermelho forte que quebra a estrutura.
*   **LPSY (Last Point of Supply):** Pullback de venda fraco. **PONTO DE VENDA.**

## 5. Resumo Operacional (Setup Wyckoff)

Como conectar essa teoria com nossos arquivos `.ntsl`:

| Evento Wyckoff | O que procurar no Gráfico? | Arquivo de Validação |
| :--- | :--- | :--- |
| **Spring / Shakeout** | Rompimento de suporte + Retorno rápido + Volume Alto na queda e Baixo no retorno. | `Gatilhos.md` (Armadilha de Fundo) <br> `fev_VSAassinaturaInstitucional.ntsl` (Cor Verde) |
| **Upthrust (UT)** | Rompimento de resistência + Pavio superior longo + Fechamento baixo. | `fev_PriceActionAnaliseSombra.ntsl` (Cor Azul Royal) <br> `fev_VSAassinaturaInstitucional.ntsl` (Cor Vermelha) |
| **Teste (No Supply)** | Candle pequeno (Inside Bar/Doji) na região do suporte com volume ridículo. | `fev_PriceAction_Tipos.ntsl` |
| **SOS / SOW** | Barra de Força (Ciano/Fuchsia) rompendo estrutura ou pivô. | `fev_PriceActionCorpoSombraExecucao.ntsl` <br> `fevTendenciaPivoTeste.ntsl` |

### Roteiro de Decisão
1.  **Identifique a Fase:** Use o `fev_DetectorFasesMercado.ntsl`.
    *   Se estiver em "Acumulação" (Fase 1), procure por **Springs**.
    *   Se estiver em "Distribuição" (Fase 3), procure por **Upthrusts**.
2.  **Valide com Volume:**
    *   Um rompimento de topo sem volume (Lei Esforço vs Resultado) é um provável Upthrust.
    *   Um rompimento de fundo com volume climático que não continua caindo é um provável Spring.

---
*Nota: Wyckoff não é um setup mecânico, é um mapa de contexto. Ele diz ONDE procurar o trade, o Price Action diz QUANDO entrar.*