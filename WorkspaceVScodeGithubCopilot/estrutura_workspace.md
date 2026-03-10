# Estrutura e Organização do Workspace

## Caminhos principais
- E:\repos\RepoRobos-marco_Tradeoperador\automacao_backtests\   // Robôs separados por temas (IFR, Candle, Médias)
- E:\repos\RepoRobos-marco_Tradeoperador\automacao_backtests\resultados_aprovados_por_timeframe\   // Resultados de backtest aprovados
- E:\repos\RepoRobos-marco_Tradeoperador\automacao_backtests\top10\   // Robôs aprovados para simulação
- E:\repos\RepoRobos-marco_Tradeoperador\profit_estudos_cores\   // Teorias convertidas em .ntfl
- E:\repos\RepoRobos-marco_Tradeoperador\estudo_teorias\   // Teorias em .md
- c:\dev\   // Configurações, scripts auxiliares, templates

## Fluxo de trabalho
0. Analisar as teorias
1. Gerar NTFL para a teoria que estamos abordando para termos uma visualização do tema.
2. Gerar robôs (50+) em automacao_backtests, separados por tema das teorias
3. Testar todos em backtest, salvar resultados em resultados_aprovados_por_timeframe
4. Reprovar/descartar os que não passaram. Preciso dos robos que tenham a maior taxa de ações operacoes  vencedoras e que não me façam quebrar.
5. Selecionar top 10 para simulação (pasta top10)
6. Registrar logs, teorias e estudos em profit_estudos_cores e estudo_teorias

## Regras de organização
- Cada robô deve ter um arquivo e um log de teste
- Resultados aprovados ficam em resultados_aprovados_por_timeframe
- Teorias e estudos devem ser salvos em .md ou .ntfl conforme o tipo
- Configurações e scripts auxiliares ficam em c:\dev

## Checklist de boas práticas
- [ ] Workspace VS Code configurado (.vscode/settings.json)
- [ ] Estrutura de pastas conforme modelo
- [ ] Robôs versionados no Git
- [ ] Logs e resultados organizados
- [ ] Teorias documentadas

## Orientações rápidas
- Sempre abra o workspace pela pasta raiz (E:\repos\RepoRobos-marco_Tradeoperador)
- Use o arquivo estrutura_workspace.md como referência
- Utilize o Copilot para dúvidas complexas e refatorações
- Mantenha o top10 atualizado com os melhores robôs

---

> Este arquivo serve como referência para organização, fluxo e boas práticas do workspace.
