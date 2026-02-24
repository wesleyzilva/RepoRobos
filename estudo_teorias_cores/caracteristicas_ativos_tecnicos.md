# Ativos com Melhor Resposta à Análise Técnica

Para que a Análise Técnica (Price Action, Chartismo, Elliott) funcione bem, o ativo precisa de **Liquidez** (para evitar manipulação) e **Volatilidade** (para gerar movimento).

## 1. Mercado Internacional (Os "Reis" da Técnica)

Estes são os ativos mais técnicos do mundo. Se você traçar um Fibonacci ou um Suporte neles, o mundo inteiro está vendo a mesma linha.

| Ativo | Código Futuro | Por que é técnico? |
| :--- | :--- | :--- |
| **S&P 500** | `ES` | **O Padrão Ouro.** É o ativo mais líquido do mundo. Respeita milimetricamente suportes, resistências e médias móveis. Menos "ruído" que o Nasdaq. |
| **Euro vs Dólar** | `6E` (Futuro) / `EURUSD` | O par de moedas mais negociado. Movimentos lentos, cadenciados e extremamente técnicos. Ótimo para iniciantes em mercado global. |
| **Petróleo WTI** | `CL` | Segue tendências longas e duradouras. Quando engata uma direção, dificilmente volta sem um padrão de reversão claro. |
| **Ouro** | `GC` | Respeita muito zonas de oferta e demanda antigas (suportes/resistências de anos atrás). |
| **Bitcoin** | `BTC` | Por ter muita participação de varejo e algoritmos (e nenhum Banco Central controlando), é um dos ativos que mais respeita padrões gráficos puros (Bandeiras, Triângulos). |

## 2. Mercado Brasileiro (B3)

No Brasil, a liquidez é concentrada. Fora destes ativos, a análise técnica perde eficiência e o gráfico fica "sujo".

| Ativo | Código | Características Técnicas |
| :--- | :--- | :--- |
| **Mini Índice** | `WIN` | Respeita bem Price Action intraday (pivôs, pullbacks), mas tem muito "ruído" (violinos) nos 5 minutos. Requer filtros de horário (09:00 - 17:00). |
| **Mini Dólar** | `WDO` | Extremamente técnico, mas muito agressivo. Respeita muito "Pontos de Ajuste", Vwap e máximas/mínimas do dia anterior. |
| **Petrobras** | `PETR4` | A ação mais técnica do Brasil. Alta liquidez permite day trade confiável. Segue muito o petróleo lá fora. |
| **Vale** | `VALE3` | Respeita suportes e resistências, mas costuma abrir com Gaps enormes devido ao minério na China. |
| **Itaú** | `ITUB4` | Movimentos mais "quadrados" e lentos. Bom para Swing Trade, difícil para Day Trade curto. |

## 3. O que EVITAR (Onde a Análise Técnica falha)

*   **Small Caps sem volume:** Ações que negociam pouco (ex: algumas construtoras menores ou empresas em recuperação judicial). Um único player move o preço, invalidando o gráfico.
*   **Horários de baixa liquidez:** Operar o WIN na hora do almoço (12:00 - 13:00) ou depois das 17:30 costuma gerar muitos sinais falsos.
*   **Moedas Exóticas:** Pares como USD/TRY (Lira Turca) ou USD/ZAR (Rand) são erráticos e movidos a política, ignorando gráficos.

### Dica de Ouro
Se você está começando a estudar padrões gráficos clássicos (Oco, Bandeira, Topo Duplo), treine no **S&P 500 (ES)** ou **EUR/USD**. Eles são os "livros didáticos" do mercado. O **WIN** é mais "sujo" e exige mais malícia.

## 4. Técnicas Operacionais por Ativo (Resumo Prático)

| Ativo | Técnica que tende a funcionar melhor | O que evitar |
| :--- | :--- | :--- |
| **WINFUT** | **Estrutura de preço** (pivô, rompimento com reteste, pullback em tendência). | Operar rompimento seco sem confirmação de fechamento e sem filtro de horário. |
| **WDOFUT** | **Níveis institucionais** (VWAP, ajuste, máxima/mínima anterior, janelas PTAX). | Operar contra VWAP dominante e ignorar horário de fluxo forte. |
| **WSPFUT/WSFUT** | **Correlação e direção macro** (ES/US500 + abertura americana). | Operar sem checar contexto dos futuros americanos. |
| **BITFUT** | **Momentum/tendência com volume** (continuação após compressão/rompimento). | Forçar operação em lateral curta com volatilidade errática. |
| **PETR4/VALE3/ITUB4** | **Suporte/Resistência + Pullback** em zonas claras, com leitura do contexto setorial. | Ignorar gap de abertura e notícia setorial/global correlata. |

---

## 5. Setups-Chave e Quando Usar

### 5.1 Rompimento de 2 Falhas (Reversão)
**Ideia:** o preço tenta romper um nível 2 vezes, falha nas duas e depois perde o fundo (ou rompe topo) de defesa.

**Melhor uso:**
- Em região de resistência/suporte importante.
- Quando aparece exaustão (pavio, perda de força, volume de absorção).

**Confirmação mínima:**
- Quebra da estrutura de defesa após a segunda falha.
- Fechamento do candle de confirmação fora da micro-estrutura.

### 5.2 Retração de 50% (Zona de Valor)
**Ideia:** após impulso forte, o preço corrige até metade do movimento para buscar continuidade.

**Melhor uso:**
- Em tendência já definida (não em lateral).
- Com confluência de média (20/50), VWAP ou suporte/resistência.

**Confirmação mínima:**
- Candle de reação no 50% (martelo, engolfo, rejeição).
- Entrada na superação/perda do candle gatilho.

### 5.3 Outros Setups de Alta Probabilidade
- **Rompimento + Reteste:** rompe nível, volta para testar e continua.
- **Pullback na MME 20:** tendência clara com retorno controlado à média.
- **Pivô 1-2-3:** mudança de estrutura com confirmação de continuidade.
- **VWAP Reclaim/Reject:** recuperação ou rejeição da VWAP em contexto direcional.

---

## 6. Características que Você Precisa Observar Antes de Operar

1. **Regime do mercado:** tendência ou lateralização?
2. **Liquidez do horário:** está em janela boa ou em horário "morto"?
3. **Distância do preço para média/VWAP:** está esticado ou em zona de valor?
4. **Inclinação das médias:** 20 e 50 confirmam direção?
5. **Estrutura válida:** houve rompimento real ou só violino?
6. **Volume:** confirma movimento ou mostra absorção?
7. **Contexto externo:** notícia, abertura EUA, correlação com ativo líder.

### Regra de decisão rápida
- **Confluência completa:** operar.
- **Confluência parcial:** reduzir mão.
- **Sem confluência:** não operar.