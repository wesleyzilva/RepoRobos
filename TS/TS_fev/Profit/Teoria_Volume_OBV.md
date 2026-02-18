# Teoria Operacional: OBV (On Balance Volume) - O Detector de Mentiras

## 1. O Conceito Fundamental
O OBV (On Balance Volume) foi desenvolvido por Joe Granville na década de 60 com uma premissa simples e poderosa: **"O Volume precede o Preço"**.

Imagine o volume como o combustível e o preço como o carro. Se você pisa no acelerador (volume sobe), o carro eventualmente vai acelerar. Se você tira o pé (volume cai), o carro vai parar, mesmo que continue andando um pouco por inércia.

### Como é calculado?
*   Se o candle fecha **positivo** (acima do fechamento anterior), todo o volume do dia é **somado** ao OBV.
*   Se o candle fecha **negativo** (abaixo do fechamento anterior), todo o volume do dia é **subtraído** do OBV.
*   O resultado é uma linha acumulativa que mostra o saldo real da pressão de compra vs. venda.

---

## 2. A Lógica do "Smart Money"
Grandes instituições não conseguem esconder o volume. Para montar uma posição gigante, eles precisam comprar muitos lotes.
*   O preço pode ficar lateral (escondido) enquanto eles acumulam.
*   Mas o OBV vai subir, pois o volume nos dias de alta será maior que nos dias de baixa.
*   **Conclusão:** O OBV revela a "pegada" dos grandes players antes do movimento acontecer no gráfico de preço.

---

## 3. Sinais Operacionais Clássicos

### A. Confirmação de Tendência (Sinal de Saúde)
*   **Tendência de Alta Saudável:** O Preço faz Topos e Fundos ascendentes E o OBV também faz Topos e Fundos ascendentes.
*   **Tendência de Baixa Saudável:** O Preço cai E o OBV cai.
*   **Ação:** Mantenha a operação. O fluxo está confirmando o movimento.

### B. Divergência (O Grande Alerta)
É o sinal mais lucrativo do OBV. Ocorre quando o Preço e o Volume discordam.

1.  **Divergência de Baixa (Topo):**
    *   O Preço faz um **Topo Mais Alto** (rompe resistência).
    *   O OBV faz um **Topo Mais Baixo** (não consegue romper).
    *   **Tradução:** O preço subiu por inércia ou manipulação, mas não tem combustível (dinheiro novo) sustentando. A queda é iminente.
    *   **Ação:** Não compre rompimentos. Prepare vendas.

2.  **Divergência de Alta (Fundo):**
    *   O Preço faz um **Fundo Mais Baixo** (perde suporte).
    *   O OBV faz um **Fundo Mais Alto**.
    *   **Tradução:** Os vendedores pararam de agredir. Estão acumulando silenciosamente na queda.
    *   **Ação:** Não venda rompimentos. Prepare compras.

### C. Breakout Antecipado
Muitas vezes, o OBV rompe uma resistência (LTB do OBV ou Topo do OBV) **antes** do preço romper a resistência no gráfico.
*   **Sinal:** Se o OBV rompeu, o preço tende a seguir logo depois. É um sinal de antecipação de rompimento.

---

## 4. O Indicador `fev_OBVvolumeVerdadeiro`

No nosso Trade System atual, utilizamos o **OBV Puro** com comparação barra a barra para identificar o fluxo imediato.

### Regra de Coloração e Interpretação

#### 🟢 VERDE = PRESSÃO COMPRADORA
*   **Condição:** O OBV atual é **MAIOR** que o OBV do candle anterior.
*   **Significado:** Entrou volume comprador neste candle.
*   **Operacional:**
    *   **Permissão:** Autoriza compras imediatas.
    *   **Atenção:** Se o preço cair mas o OBV subir (ficar verde), é divergência de alta (acumulação).

#### 🔴 VERMELHO = PRESSÃO VENDEDORA
*   **Condição:** O OBV atual é **MENOR** que o OBV do candle anterior.
*   **Significado:** Saiu volume (venda) neste candle.
*   **Operacional:**
    *   **Permissão:** Autoriza vendas imediatas.
    *   **Atenção:** Se o preço subir mas o OBV cair (ficar vermelho), é divergência de baixa (distribuição).

---

## 5. Estratégia de "Veto de Fluxo" (Passo 5 do Setup)

O OBV não serve para dar o "clique" de entrada (timing), ele serve para **evitar entradas ruins**.

| Cenário Gráfico | Status do OBV | Decisão |
| :--- | :--- | :--- |
| **Pivô de Alta (Compra)** | **Verde (Subindo)** | **✅ APROVADO** |
| **Pivô de Alta (Compra)** | **Vermelho (Caindo)** | **❌ VETADO (Sem fluxo)** |
| **Pivô de Baixa (Venda)** | **Vermelho (Caindo)** | **✅ APROVADO** |
| **Pivô de Baixa (Venda)** | **Verde (Subindo)** | **❌ VETADO (Absorção)** |

### Dica de Ouro:
Se o preço está lateral (consolidado), o OBV costuma ficar "trançando" a média (mudando de cor toda hora). Nesse caso, ignore o OBV e espere o preço sair da lateralidade com força (Barra de Ignição) E o OBV confirmar a cor.