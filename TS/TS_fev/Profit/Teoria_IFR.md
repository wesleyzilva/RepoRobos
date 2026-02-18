# Teoria Operacional: IFR (Índice de Força Relativa)

## 1. O Conceito (O Velocímetro)
O IFR (RSI em inglês) não mede o preço, mede a **velocidade** e a **mudança** do movimento. Imagine um carro subindo uma ladeira: ele pode continuar subindo (preço fazendo topos mais altos), mas se tirar o pé do acelerador (IFR caindo), logo ele vai parar e descer.

*   **Configuração Padrão:** 14 Períodos.
*   **Natureza:** Oscilador de Momentum (varia de 0 a 100).

## 2. Zonas de Operação (Sobrecompra e Sobrevenda)

### A Zona de Exagero (70 e 30)
*   **Sobrecompra (> 70):** O mercado subiu rápido demais. A probabilidade de uma correção ou pausa aumenta.
    *   *Atenção:* Em tendências muito fortes (Super Trends), o IFR pode ficar acima de 70 por muito tempo. Não venda apenas porque tocou no 70.
*   **Sobrevenda (< 30):** O mercado caiu rápido demais. Pode haver um repique ("Dead Cat Bounce") ou reversão.

### A Zona de Tendência (Nível 50)
*   **Acima de 50:** Território dos Compradores. Procure compras.
*   **Abaixo de 50:** Território dos Vendedores. Procure vendas.
*   **O Cruzamento do 50:** Muitas vezes antecipa a virada da Média de 20.

## 3. Divergências (O Sinal de Ouro do IFR)
É aqui que o IFR brilha no nosso Trade System. A divergência é quando o Preço e o IFR discordam. É um sinal poderoso de **Exaustão**.

### Divergência de Baixa (Topo)
*   **Cenário:** O Preço faz um **Topo Mais Alto**, mas o IFR faz um **Topo Mais Baixo**.
*   **Significado:** O preço subiu por inércia, mas a força compradora acabou. É como o carro subindo a ladeira no ponto morto.
*   **Ação:**
    *   **Não Comprar Rompimentos.**
    *   Apertar o Stop Loss de compras.
    *   Preparar para vender se aparecer um gatilho (Upthrust/Engolfo de Baixa).
    *   *No Código:* PlotText **"DIV BAIXA"** (Laranja).

### Divergência de Alta (Fundo)
*   **Cenário:** O Preço faz um **Fundo Mais Baixo**, mas o IFR faz um **Fundo Mais Alto**.
*   **Significado:** Os vendedores estão cansados. A pressão de venda diminuiu mesmo com o preço caindo.
*   **Ação:**
    *   **Não Vender Rompimentos de Fundo.**
    *   Procurar sinais de compra (Martelo/Gold Signal).
    *   *No Código:* PlotText **"DIV ALTA"** (Ciano).

## 4. Reversão Positiva/Negativa (Hidden Divergence)
Diferente da divergência clássica (que indica reversão), esta indica **continuação**.

*   **Reversão Positiva (Continuação de Alta):** O Preço faz um fundo mais alto (correção saudável), mas o IFR cai muito e faz um fundo mais baixo (ficou "barato" rápido). É um setup de compra de pullback.
*   **Reversão Negativa (Continuação de Baixa):** O Preço faz um topo mais baixo, mas o IFR sobe muito. É oportunidade de venda.

## 5. Integração com o Trade System

O IFR funciona como um **Veto (Filtro de Qualidade)**.

| Cenário | IFR | Decisão |
| :--- | :--- | :--- |
| **Gold Signal de Compra** | IFR subindo, rompendo 50 ou 60 | **Aprovado (Força)** |
| **Gold Signal de Compra** | IFR acima de 80 (Esticado) | **Cuidado (Reduzir Mão)** |
| **Rompimento de Topo** | Divergência de Baixa (Topo IFR menor) | **VETO (Falso Rompimento)** |
| **Pullback na Média 20** | IFR tocando 40-50 e virando para cima | **Entrada Perfeita** |

---

### Resumo Prático
1.  Use o IFR para validar a força do rompimento.
2.  Se o preço rompeu topo e o IFR não, é armadilha.
3.  Nunca opere contra uma Divergência em timeframes maiores (15m/60m).