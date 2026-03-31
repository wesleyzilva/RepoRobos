
# Regras para Robustez do Sinal de Operação (Semáforo)

1. **Confirmação do Sinal:**
	- Só operar se o sinal de compra/venda aparecer por pelo menos 2 candles consecutivos, ou se o sinal se mantiver por um tempo mínimo (ex: X segundos ou X candles).
	- Se o sinal reverter rapidamente para neutro (cinza) após aparecer, não operar. Isso evita entradas em sinais instáveis.

2. **Filtro de Indecisão:**
	- Se houver sinal de indecisão (candle branco/cinza) no timeframe médio ou menor, não operar, mesmo que o timeframe maior esteja em operação.

3. **Persistência:**
	- Se o sinal de operação voltar para neutro e depois retornar para o mesmo lado (compra/venda), só operar se houver nova confirmação (ex: 2 candles consecutivos novamente).

4. **Saúde da Operação:**
	- Essas regras garantem que só operaremos em sinais mais robustos, evitando entradas em movimentos falsos ou ruídos de mercado.

---

**Exemplo prático:**
- Sinal verde aparece, mas no candle seguinte volta para cinza: não operar.
- Sinal verde aparece e permanece por 2 candles: permitido operar.
- Sinal verde aparece, volta para cinza, depois verde de novo: só operar se novamente houver confirmação de 2 candles.

