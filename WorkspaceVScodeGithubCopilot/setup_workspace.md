# Setup Workspace VS Code para Robôs Traders

## Passo a passo

1. **Instale o VS Code**
   - Baixe em https://code.visualstudio.com/

2. **Instale o GitHub Copilot**
   - Abra o VS Code
   - Extensions (Ctrl+Shift+X)
   - Procure por "GitHub Copilot" e instale

3. **Faça login no GitHub**
   - Clique no ícone do Copilot
   - Faça login com sua conta GitHub

4. **Configuração do workspace**
   - Crie uma pasta para seus robôs
   - Organize subpastas por estratégia, resultados, logs

5. **Instale extensões úteis**
   - Python (Microsoft)
   - Jupyter
   - GitLens
   - Prettier
   - VSCode-icons

6. **Configuração do ambiente**
   - Configure o Python (Ctrl+Shift+P > Python: Select Interpreter)
   - Instale bibliotecas (pandas, numpy, matplotlib)

7. **Otimize o Copilot**
   - Use comentários claros para pedir sugestões
   - Ative o Copilot Chat
   - Use snippets/templates

8. **Integre com o GitHub**
   - Configure o Git (Ctrl+Shift+P > Git: Clone)
   - Faça commits e pushes

9. **Dicas de produtividade**
   - Use atalhos (Ctrl+P, Ctrl+Shift+F)
   - Use terminal integrado
   - Use Copilot Chat para dúvidas e exemplos

---

## Sugestão de estrutura de pastas

- automacao_backtests/
  - IFR_RSI/
  - CANDLE1A4/
  - MEDIAS_9_20_50_200/
- estudo_teorias/
- profit_estudos_cores/

---

## Checklist para robôs traders

- [ ] Stop-loss implementado
- [ ] Drawdown diário/semanal
- [ ] Perda máxima da carteira
- [ ] Log padronizado
- [ ] Controle de contratos
- [ ] Versionamento Git
- [ ] Testes e simulações

---

## Como pedir sugestões ao Copilot

- Comente: `// Gerar função de stop-loss`
- Use Copilot Chat: "Explique o cálculo de payoff"
- Peça refatoração: "Refatore para Python"

---

## Links úteis

- [VS Code](https://code.visualstudio.com/)
- [GitHub Copilot](https://github.com/features/copilot)
- [Python Extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)

---

> Este arquivo foi gerado automaticamente com base nas recomendações do chat.
