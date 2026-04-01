# Estratégias de Stop no WIN (Mini-Índice)

## Trailing Stop
O Trailing Stop é um stop móvel que acompanha o preço a favor da operação. Ele só se move quando o preço vai a favor, protegendo parte do lucro. Se o preço voltar, a posição é encerrada automaticamente.

**Como usar no WIN:**
- Cada tick no WIN equivale a 5 pontos.
- Exemplo: trailing de 120 pontos = 24 ticks.
- Ajuste o trailing conforme a volatilidade:
  - Baixa volatilidade: trailing menor (ex: 80-120 pts = 16-24 ticks)
  - Alta volatilidade: trailing maior (ex: 150-250 pts = 30-50 ticks)

## AutoBreakEven
O AutoBreakEven move o stop para o preço de entrada (ou levemente positivo) após o preço andar a favor um certo número de pontos/ticks. Assim, se o mercado voltar, você não perde.

**Como usar:**
- Exemplo: após +100 pontos (20 ticks) de ganho, mova o stop para o preço de entrada.
- Pode ser configurado para ativar junto com o trailing.

## Objetivo de 300 pontos (60 ticks)
- Defina o alvo fixo de 300 pontos (60 ticks).
- O trailing pode ser ativado após +100 ou +150 pontos (20 ou 30 ticks), protegendo parte do lucro.
- O AutoBreakEven pode ser ativado após +80 ou +100 pontos (16 ou 20 ticks).

## OCO (One Cancels Other)
O OCO permite definir automaticamente stop loss, alvo e trailing. Quando um dos alvos é atingido, o outro é cancelado.

**Exemplo de configuração OCO para WIN:**
- Alvo: 60 ticks (300 pts)
- Stop loss: 30 ticks (150 pts)
- Trailing stop: 24 ticks (120 pts)
- AutoBreakEven: mova o stop para o preço de entrada após 20 ticks (100 pts) de ganho

**Como ajustar:**
- Teste diferentes valores de trailing e break even no simulador.
- Prefira trailing menor em mercados laterais e maior em tendências.
- Sempre alinhe o stop ao seu perfil de risco e à volatilidade do dia.

---

## Resumo prático
- 1 tick = 5 pontos
- 300 pontos = 60 ticks
- 100 pontos = 20 ticks
- 150 pontos = 30 ticks

**Configuração sugerida para OCO no WIN:**
- Alvo: 60 ticks
- Stop: 30 ticks
- Trailing: 24 ticks
- BreakEven: 20 ticks

Essas estratégias ajudam a proteger seu capital e a potencializar ganhos de forma automatizada no Profit.