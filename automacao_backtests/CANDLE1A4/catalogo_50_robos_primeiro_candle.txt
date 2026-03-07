CATÁLOGO — 50 VARIAÇÕES DE ROBÔS: PRIMEIRO CANDLE DO DIA
Criado em: março/2026

Objetivo
- Listar 50 variacoes de estrategia baseadas na leitura do primeiro candle do dia (WIN).
- Fatores analisados: Gap, VWAP, Range do dia anterior, Price Action (corpo/pavio).
- Estrutura: contexto -> filtro -> gatilho -> entrada -> saída padrao.
- Este catalogo prioriza a fase de conceituação antes da implementação NTSL.

Prefixo de nomenclatura dos scripts: mar_PC_NN_descricao.ntsl.txt
Timeframe padrão de referência: 15min ou 30min (primeiro candle = barra 1 do dia).

================================================================================
1) GAP: POSIÇÃO E TAMANHO (1-10)
================================================================================

1. Gap externo para cima + corpo >70% + volume >1.5x média
   → Compra no rompimento da máxima do 1º candle no 2º candle.
   → Saída: alvo = 1.5x range do 1º candle. Stop: mínima do 1º candle.

2. Gap externo para baixo + corpo >70% + volume >1.5x médias
   → Venda no rompimento da mínima do 1º candle no 2º candle.
   → Saída: alvo = 1.5x range do 1º candle. Stop: máxima do 1º candle.

3. Gap externo para cima + pavio superior >50% do range (exaustão)
   → Venda reversão: entrada abaixo da mínima do 1º candle no 2º candle.
   → Filtro: fechamento do 1º candle abaixo da abertura.
   → Saída: alvo = fechamento anterior. Stop: máxima do 1º candle.

4. Gap externo para baixo + pavio inferior >50% do range (exaustão)
   → Compra reversão: entrada acima da máxima do 1º candle no 2º candle.
   → Filtro: fechamento do 1º candle acima da abertura.
   → Saída: alvo = fechamento anterior. Stop: mínima do 1º candle.

5. Gap interno (abertura dentro do range anterior) + corpo forte para cima
   → Compra no fechamento do 1º candle com stop na abertura do dia.
   → Filtro: preço acima da VWAP diária.

6. Gap interno + corpo forte para baixo
   → Venda no fechamento do 1º candle com stop na abertura do dia.
   → Filtro: preço abaixo da VWAP diária.

7. Gap externo + candle doji (corpo <20% do range) + volume alto (absorção)
   → Aguarda 2º candle para rompimento da máxima ou mínima do 1º.
   → Operar direção do rompimento com stop no lado oposto.

8. Gap para cima + abertura abaixo da máxima do dia anterior (gap parcial)
   → Compra se 1º candle fecha acima da máxima do dia anterior.
   → Stop: mínima do 1º candle. Alvo: 1.0x ATR.

9. Gap para baixo + abertura acima da mínima do dia anterior (gap parcial)
   → Venda se 1º candle fecha abaixo da mínima do dia anterior.
   → Stop: máxima do 1º candle. Alvo: 1.0x ATR.

10. Gap grande (>1.0x ATR) em qualquer direção + sem volume climático
    → Não operar o 1º candle (risco de violino por gap falso).
    → Aguardar 3º candle com confirmação de direção. Entrada após pullback.

================================================================================
2) VWAP: POSIÇÃO E ALINHAMENTO (11-20)
================================================================================

11. Abertura acima VWAP diária + acima VWAP semanal + corpo de alta >60%
    → Compra rompimento máxima do 1º candle. Stop mínima. Filtro: sem pavio >40%.

12. Abertura abaixo VWAP diária + abaixo VWAP semanal + corpo de baixa >60%
    → Venda rompimento mínima do 1º candle. Stop máxima. Filtro: sem pavio >40%.

13. Abertura abaixo VWAP diária + 1º candle fecha acima da VWAP
    → Compra retorno: entrada na próxima barra. Sinal de inversão de polo.
    → Stop: mínima do 1º candle. Alvo: máxima do dia anterior.

14. Abertura acima VWAP diária + 1º candle fecha abaixo da VWAP
    → Venda retorno: entrada na próxima barra. Sinal de inversão de polo.
    → Stop: máxima do 1º candle. Alvo: mínima do dia anterior.

15. 1º candle toca a VWAP diária e reverte (pavio sobre VWAP)
    → Venda se o pavio toca VWAP e candle fecha abaixo.
    → Filtro: VWAP como resistência (preço abaixo dela no dia anterior).

16. 1º candle toca a VWAP diária e reverte para cima (pavio abaixo VWAP)
    → Compra se o pavio toca VWAP e candle fecha acima.
    → Filtro: VWAP como suporte (preço acima dela no dia anterior).

17. Abertura exatamente na VWAP semanal (tolerância: 0.1% do preço)
    → Aguardar direção do 1º candle. Compra se fechar acima, venda se fechar abaixo.
    → Stop: abertura do dia. Alvo: 1.0x ATR.

18. Abertura acima VWAP diária + abaixo VWAP semanal (conflito)
    → Reduzir tamanho. Entrada apenas se 1º candle for força excepcional (corpo >80%).
    → Direção ditada pela VWAP semanal (resistência acima = viés vendedor).

19. Abertura abaixo VWAP diária + acima VWAP semanal (conflito)
    → Reduzir tamanho. Entrada apenas se 1º candle for força excepcional (corpo >80%).
    → Direção ditada pela VWAP semanal (suporte abaixo = viés comprador).

20. 1º candle entre VWAP diária e VWAP semanal + corpo pequeno (<30%)
    → Não operar. Zona de indecisão institucional. Aguardar 3º candle.

================================================================================
3) RANGE DO DIA ANTERIOR: SUPORTE E RESISTÊNCIA (21-30)
================================================================================

21. Abertura acima máxima do dia anterior + corpo de alta >60%
    → Compra no 2º candle. Máxima do dia anterior vira suporte.
    → Stop: máxima do dia anterior. Alvo: 1.5x range do dia anterior.

22. Abertura abaixo mínima do dia anterior + corpo de baixa >60%
    → Venda no 2º candle. Mínima do dia anterior vira resistência.
    → Stop: mínima do dia anterior. Alvo: 1.5x range do dia anterior.

23. Abertura dentro do range + 1º candle rompe máxima do dia anterior
    → Compra no fechamento acima. Stop: abertura do dia.
    → Filtro: VWAP diária favorável (preço acima).

24. Abertura dentro do range + 1º candle rompe mínima do dia anterior
    → Venda no fechamento abaixo. Stop: abertura do dia.
    → Filtro: VWAP diária favorável (preço abaixo).

25. 1º candle testa máxima do dia anterior e fecha abaixo (rejeição)
    → Venda no 2º candle. Stop: máxima do 1º candle.
    → Filtro: volume baixo na tentativa de rompimento.

26. 1º candle testa mínima do dia anterior e fecha acima (suporte)
    → Compra no 2º candle. Stop: mínima do 1º candle.
    → Filtro: volume baixo na tentativa de rompimento.

27. Abertura no meio do range anterior + candle doji
    → Não operar. Aguardar 3 candles para definição de range local.

28. 1º candle inteiramente acima do range do dia anterior (gap + força)
    → Compra apenas em pullback para a máxima do dia anterior.
    → Stop: fechamento abaixo da máxima D-1. Alvo: 2.0x range D-1.

29. 1º candle inteiramente abaixo do range do dia anterior (gap + fraqueza)
    → Venda apenas em pullback para a mínima do dia anterior.
    → Stop: fechamento acima da mínima D-1. Alvo: 2.0x range D-1.

30. Abertura dentro do range + 1º candle fecha no centro (entre max e min D-1)
    → Não operar no 1º candle. Marcar max/min D-1 como níveis do dia.

================================================================================
4) PRICE ACTION: CORPO, PAVIO E PADRÃO (31-40)
================================================================================

31. Candle Marubozu de alta (corpo >90%, sem pavios)
    → Compra imediata no 2º candle. Stop: mínima do 1º candle.
    → Filtro obrigatório: volume >2x média.

32. Candle Marubozu de baixa (corpo >90%, sem pavios)
    → Venda imediata no 2º candle. Stop: máxima do 1º candle.
    → Filtro obrigatório: volume >2x média.

33. Candle com pavio inferior longo >60% + fechamento na metade superior (martelo)
    → Compra no 2º candle. Stop: mínima do pavio. Filtro: volume acima da média.

34. Candle com pavio superior longo >60% + fechamento na metade inferior (estrela cadente)
    → Venda no 2º candle. Stop: máxima do pavio. Filtro: volume acima da média.

35. Corpo de alta entre 40%-70% + pavio superior e inferior equilibrados
    → Compra moderada somente com alinhamento de VWAP + range D-1.
    → Tamanho reduzido (0.5x padrão).

36. Corpo de baixa entre 40%-70% + pavio superior e inferior equilibrados
    → Venda moderada somente com alinhamento de VWAP + range D-1.
    → Tamanho reduzido (0.5x padrão).

37. Candle doji de alta (abertura = fechamento ± 0.1%) + volume baixo
    → Não operar. Mercado sem decisão.

38. Candle spinning top (corpo <25%, pavios longos equilibrados) + volume alto
    → Aguardar rompimento. Compra acima da máxima, venda abaixo da mínima do 1º candle.
    → Volume alto indica luta: rompimento deve ser rápido e limpo.

39. Corpo de alta >60% com fechamento exatamente na máxima (força pura)
    → Compra agressiva: entrada no fechamento do 1º candle.
    → Stop: mínima do 1º candle. Filtro: gap interno + acima VWAP.

40. Corpo de baixa >60% com fechamento exatamente na mínima (fraqueza pura)
    → Venda agressiva: entrada no fechamento do 1º candle.
    → Stop: máxima do 1º candle. Filtro: gap interno + abaixo VWAP.

================================================================================
5) COMBINAÇÕES E CONFLUÊNCIAS (41-50)
================================================================================

41. Gap externo para cima + acima VWAP semanal + corpo >70% + volume climático
    → Compra de continuação no 2º candle. Stop: mínima do 1º candle.
    → Maior confluência possível — maior tamanho permitido.

42. Gap externo para baixo + abaixo VWAP semanal + corpo >70% + volume climático
    → Venda de continuação no 2º candle. Stop: máxima do 1º candle.
    → Maior confluência possível — maior tamanho permitido.

43. Gap interno + acima VWAP + corpo de alta + rompimento máxima D-1 no fechamento
    → 3 confirmações: compra no fechamento do 1º candle. Alvo: 1.5x ATR.

44. Gap interno + abaixo VWAP + corpo de baixa + rompimento mínima D-1 no fechamento
    → 3 confirmações: venda no fechamento do 1º candle. Alvo: 1.5x ATR.

45. Gap exaustão para cima (>1.5x ATR) + rejeição da máxima D-1 + pavio longo
    → Venda reversão com alvo no fechamento do dia anterior.
    → Stop: máxima do 1º candle. Só operar se volume for climático.

46. Gap exaustão para baixo (>1.5x ATR) + suporte na mínima D-1 + pavio longo
    → Compra reversão com alvo no fechamento do dia anterior.
    → Stop: mínima do 1º candle. Só operar se volume for climático.

47. Conflito VWAP (entre diária e semanal) + candle pequeno + gap interno
    → Não operar. Três indícios de indecisão simultâneos.

48. Abertura na mínima D-1 + VWAP como resistência + corpo de baixa + gap para baixo
    → Short de confirmação de colapso. Alvo: 2.0x range D-1 abaixo.
    → Stop: fechamento acima da mínima D-1.

49. Abertura na máxima D-1 + VWAP como suporte + corpo de alta + gap para cima
    → Long de confirmação de breakout. Alvo: 2.0x range D-1 acima.
    → Stop: fechamento abaixo da máxima D-1.

50. Volume do 1º candle <0.5x média histórica dos primeiros candles
    → Independente de qualquer outro fator: NÃO OPERAR o 1º candle.
    → Volume baixo = liquidez ruim = risco de deslizamento sem vantagem estatística.

================================================================================
6) VOLUME COMO FATOR DECISIVO — não apenas filtro (51-56)
================================================================================

51. Volume do 1º candle >3x média histórica dos primeiros candles + corpo qualquer
    → INICIATIVA REAL independente de tamanho do corpo.
    → Operar direção do fechamento no 2º candle. Stop: abertura do dia.
    → Não cancelar por corpo pequeno: volume alto já revela o lado vencedor.

52. Volume do 1º candle >3x média + corpo >70% (confluência máxima)
    → Máxima certeza de iniciativa profissional. Tamanho padrão completo.
    → Entrada no 2º candle na direção do corpo. Stop: mínima/máxima do 1º candle.

53. Volume do 1º candle <0.3x média histórica dos primeiros candles
    → VETO TOTAL: não operar independente de qualquer outro sinal.
    → Mercado dormindo = liquidez ruim + spread alto + risco de violino sem barreira.

54. Volume decrescente vs. dia anterior na abertura (D0 < 0.6x volume abertura D-1)
    → Perda de força institucional. Reduzir tamanho para 0.5x padrão em qualquer setup.
    → Sinal de que o movimento do dia anterior não terá continuidade.

55. Volume do 1º candle entre 1.5x e 3x média + corpo <30% (absorção)
    → Muita briga sem resultado. Aguardar rompimento da máxima ou mínima do 1º candle.
    → Compra acima da máxima, venda abaixo da mínima. Stop no lado oposto.

56. Volume do 1º candle >3x média + fechamento exatamente no centro do range (indecisão)
    → Não operar diretamente. Marcar como zona de absorção explosiva.
    → Aguardar 2º candle: o rompimento que vier vai ter força. Operar na confirmação.

================================================================================
7) ATR: QUANTO DO DIA JÁ FOI CONSUMIDO (57-61)
================================================================================

57. Range do 1º candle >70% do ATR diário (14 períodos no diário)
    → FILTRO DE RISCO: relação risco/retorno comprometida para o restante do pregão.
    → Reduzir tamanho para 0.5x ou não operar stops baseados no range total do dia.
    → Alvo máximo = diferença entre ATR e range já consumido pelo 1º candle.

58. Range do 1º candle >100% do ATR diário
    → VETO: o dia já se moveu mais do que o esperado. Stops viáveis não existem.
    → Não operar nenhum setup derivado do 1º candle. Aguardar contexto do 2º dia.

59. Range do 1º candle <20% do ATR diário + volume baixo (<0.7x média)
    → Compressão. Operar apenas rompimento da máxima ou mínima com stop apertado.
    → Potencial expansão de volatilidade nos candles seguintes.

60. Range do 1º candle <20% do ATR diário + volume alto (>1.5x média)
    → Absorção intensa. Rompimento iminente com força. Aguardar 2º candle.
    → Stop: máxima ou mínima do 1º candle (dependendo da direção do rompimento).

61. Range do 1º candle entre 40%-70% do ATR diário (zona saudável)
    → Condição ideal para operar. Há espaço técnico suficiente para stop + alvo 1:2.
    → Não requer ajuste de tamanho. Usar setup de confluência normalmente.

================================================================================
8) MME200: FILTRO DE CONTEXTO OBRIGATÓRIO (62-65)
================================================================================

62. Abertura acima da MME200 diária + corpo de alta no 1º candle
    → Contexto de longo prazo comprador confirmado. Compras têm prioridade.
    → Aumentar tamanho para 1.2x padrão se houver confluência de VWAP e Gap.

63. Abertura abaixo da MME200 diária + corpo de baixa no 1º candle
    → Contexto de longo prazo vendedor confirmado. Vendas têm prioridade.
    → Aumentar tamanho para 1.2x padrão se houver confluência de VWAP e Gap.

64. Abertura cruzando a MME200 diária (preço passa de abaixo para acima ou vice-versa)
    → Zona de máximo conflito. Reduzir tamanho para 0.5x e exigir 3+ confluências.
    → Não operar reversão. Só operar continuação se o 2º candle confirmar o lado.

65. Abertura abaixo da MME200 + sinal de compra do 1º candle (contra tendência)
    → VETO: não comprar contra MME200. Mesmo que VWAP e Gap favoreçam compra.
    → Exceção única: volume >3x média + corpo >80% + gap externo de alta inequívoco.
    → (Regra idêntica no sentido inverso: acima MME200 + sinal de venda → VETO).

================================================================================
PRIORIDADE PARA IMPLEMENTAÇÃO
================================================================================

TIER 1 — Alta probabilidade / maior confluência (começar por aqui):
  #41, #42, #43, #44, #31, #32, #21, #22, #51, #52
  (todos requerem confirmação de MME200 como pré-condição — ver #62, #63)

TIER 2 — Boa relação risco/retorno com confirmação adicional:
  #13, #14, #23, #24, #28, #29, #33, #34, #39, #40, #61

TIER 3 — Situações específicas / menor frequência:
  #3, #4, #45, #46, #48, #49, #8, #9, #25, #26, #55, #60

FILTROS GLOBAIS OBRIGATÓRIOS (aplicar ANTES de qualquer setup acima):
  #53 — Volume <0.3x: veto total
  #58 — ATR >100% consumido: veto total
  #65 — Contra MME200 sem confluência excepcional: veto
  #64 — Cruzando MME200: tamanho reduzido obrigatório

DESCARTAR OU NO-TRADE (para filtrar antes de backtesting):
  #10, #20, #27, #30, #37, #47, #50, #54 (como setup — usar só como redutor)
