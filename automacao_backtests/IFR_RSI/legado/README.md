# IFR_RSI — Código Legado

Esta pasta contém os robôs da **geração anterior** (nomenclatura `robo_ifr_vXX`), mantidos apenas como **referência histórica**.

## Por que manter?

- Referência de lógica que funcionou (alguns chegaram a 90% de acerto em backtest)
- Base para recriar na nova nomenclatura `mar_IFR_NN` com gestão de risco parametrizável
- Consulta quando precisar entender a origem de um setup

## Regra de uso

> **NÃO usar estes arquivos diretamente no Profit.**
> Todos carecem do bloco de gestão de risco via `input` obrigatório.
> Use os arquivos em `../codigo_fonte/mar_IFR_*.ntsl.txt`.

## Mapeamento legado → novo

| Arquivo legado | Taxa backtest | Novo equivalente |
|----------------|--------------|-----------------|
| `robo_ifr_v4_divergencia_confirmada60min90%.ntsl.txt` | 90% / 60min | `mar_IFR_01` |
| `robo_ifr_v31_reversao_volume_relativo60min72%.ntsl.txt` | 72% / 60min | `mar_IFR_02` |
| `robo_ifr_v25_ifr_mme200_contexto2min69%.ntsl.txt` | 69% / 2min | `mar_IFR_03` |
| `robo_ifr_v18_bandas_dinamicas60min60%.ntsl.txt` | 60% / 60min | `mar_IFR_04` (pendente) |
| `robo_ifr_v24_controle_risco_diario1min67%.ntsl.txt` | 67% / 1min | `mar_IFR_05` (pendente) |
| `robo_ifr_v27_um_trade_por_direcao60min54%.ntsl.txt` | 54% / 60min | `mar_IFR_06` (pendente) |
| `robo_ifr_v28_ifr_adx_filtro30min57%.ntsl.txt` | 57% / 30min | `mar_IFR_07` (pendente) |
| `robo_ifr_v36_divergencia_regular_pivo60min62%.ntsl.txt` | 62% / 60min | `mar_IFR_08` (pendente) |
| `robo_ifr_v33_pullback_mme20060min67%.ntsl.txt` | 67% / 60min | `mar_IFR_09` (pendente) |
| `robo_ifr_v10_balanceado_regime60min63%.ntsl.txt` | 63% / 60min | `mar_IFR_10` (pendente) |
