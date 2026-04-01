# MCP — Model Context Protocol

## Visão geral

O servidor MCP `filesystem-candles` expõe os dados históricos de candles e os arquivos de conhecimento do projeto para ferramentas de IA (Copilot, Claude, etc.), permitindo análise contextual direta sem necessidade de copiar dados manualmente.

## Configuração

O arquivo `.vscode/mcp.json` define o servidor MCP com acesso às seguintes pastas:

| Pasta | Conteúdo |
|---|---|
| `DadosCandlesBacktest/` | CSVs de OHLCV históricos |
| `skills/` | Base de conhecimento especializado |
| `agents/` | Definições de agentes |
| `templates/` | Templates NTSL prontos |
| `robos/` | Robôs finalizados e testados |
| `PriceAction_Fisica/` | Teorias e guides de referência |

## Pré-requisitos

```bash
# Node.js 18+ instalado
node --version  # deve ser >= 18

# Instalar o servidor MCP de filesystem (uma vez)
npx -y @modelcontextprotocol/server-filesystem --help
```

## Como usar no Copilot Chat

Com o MCP ativo, o Copilot Chat pode:
- Ler diretamente os arquivos CSV de candles para análise
- Consultar skills e agentes automaticamente
- Criar novos robôs baseados nos templates existentes

## Verificar se está funcionando

1. Abrir VS Code com este workspace
2. Abrir Copilot Chat
3. Perguntar: "Liste os arquivos disponíveis em DadosCandlesBacktest/2024_26/"
4. O Copilot deve listar os CSVs diretamente

## Adicionando novos caminhos

Edite `.vscode/mcp.json` e adicione o caminho no array `args`:
```json
"args": [
  "-y",
  "@modelcontextprotocol/server-filesystem",
  "C:\\novo\\caminho\\aqui",
  ...
]
```
