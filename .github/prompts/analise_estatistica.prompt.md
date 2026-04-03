# Prompt: Análise Estatística de Backtest

> **Como usar:** rodar o script Python primeiro, depois preencher as variáveis abaixo
> e colar este bloco no chat. Isso evita colar o CSV completo e economiza tokens.
>
> ```bash
> python scripts/analisa_backtest_profit.py backtest_resultados/NOME_DA_PASTA/
> ```

---

## Variáveis para preencher (copiar o resultado do script)

```
ROBO:           {nome do robô}
TIMEFRAME:      {ex: 60min}
PERIODO:        {ex: 22/08/2025 → 03/04/2026}
ATIVO:          {ex: WINJ26}

TOTAL_TRADES:   {n}
WIN_RATE:       {ex: 34%}
MEDIA_GANHO:    {ex: 146 pts}
MEDIA_PERDA:    {ex: 53 pts}
RRR_REALIZADO:  {ex: 2.75}
PROFIT_FACTOR:  {ex: 1.38}
ESPERANCA:      {ex: +14.6 pts/trade}
RESULTADO_TOTAL:{ex: +1.924 pts}
DRAWDOWN_MAX:   {ex: 580 pts}
RESULTADO_RS:   {ex: +R$9.620}

KELLY:          {calcular: win_rate - (1-win_rate)/rrr}
IC_PF_95_INF:   {calcular: PF - 1.96*PF/√n}
IC_PF_95_SUP:   {calcular: PF + 1.96*PF/√n}
```

---

## Pergunta ao Copilot (colar junto com as variáveis acima)

```
Com base nos dados acima:

1. Este sistema passa nos critérios mínimos para conta real?
   (Esperança > 0, PF > 1.3, IC inferior > 1.0, Kelly > 0%)

2. Qual o tamanho de posição recomendado (Half-Kelly)?
   Capital: R${capital_conta}

3. Qual o drawdown máximo esperado (Monte Carlo 95%)?

4. Este sistema precisa de mais trades para ser confiável?
   Quantos trades faltam para o IC inferior do PF ser > 1.15?

5. Pontos fracos identificados e o que testar a seguir?

Resposta em linguagem simples, sem jargão excessivo.
Consultar: skills/skill_probabilidade_operacional.md
```

---

## Checklist de aprovação (preencher antes de commitar)

```
[ ] Esperança matemática > 0            → E = {valor}
[ ] Profit Factor > 1.3                 → PF = {valor}
[ ] IC 95% inferior do PF > 1.0         → IC = [{inf}, {sup}]
[ ] Teste t significativo (t > 1.645)   → t = {valor}
[ ] Kelly calculado > 0%                → K = {valor}%  Half-K = {valor/2}%
[ ] Drawdown máximo ≤ 15% do capital    → DD = {pts} = {%} do capital
[ ] Walk-Forward ok (se aplicável)      → {sim/não/pendente}
[ ] Bug stop horário verificado         → {sim/não}

STATUS: [ ] APROVADO  [ ] CONDICIONAL  [ ] REPROVADO
Restrições: {ex: só operar das 10h às 14h}
```

---

## Regra de ouro: nunca colar CSV no chat

| ❌ Errado (gasta ~500 tokens) | ✅ Correto (gasta ~50 tokens) |
|---|---|
| Colar o CSV completo no chat | Rodar o script e colar só o sumário |
| Pedir análise linha por linha | Preencher as variáveis acima |
| Várias perguntas separadas | Uma pergunta com todas as variáveis |
