//+------------------------------------------------------------------+
//|  mar_MT5_PPV01_exemplo.mq5                                       |
//|  Grupo: POUCOSPONTOSVENCEDORES — Versao MT5                      |
//|  Descricao: IFR reversao + trailing ATR agressivo + break-even   |
//|             Projeto de EXEMPLO para testar configuracao e        |
//|             rodar o primeiro backtest antes do simulador.        |
//|  Ativo sugerido: XAUUSD (Ouro) ou US30 (Dow Jones)              |
//|  Timeframe: M15 ou M30                                           |
//|  Versao: 1.0 — marco/2026                                        |
//+------------------------------------------------------------------+

#property copyright "Wesley — RepoRobos"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//--- Objeto de trade (encapsula ordens)
CTrade trade;

//+------------------------------------------------------------------+
//| Parametros de entrada (aparecem no Strategy Tester)              |
//+------------------------------------------------------------------+

// ── IFR entry ─────────────────────────────────────────────────────
input int    PeriodoIFR           = 9;     // Periodo do IFR
input double IFRExtremoCompra     = 30.0;  // IFR atinge sobrevenda
input double IFREtornoCompra      = 35.0;  // IFR sobe → sinal de compra
input double IFRExtremoVenda      = 70.0;  // IFR atinge sobrecompra
input double IFREtornoVenda       = 65.0;  // IFR cai → sinal de venda

// ── ATR gestao ────────────────────────────────────────────────────
input int    PeriodoATR           = 14;    // Periodo do ATR
input double FatorStopInicial     = 0.8;   // stop = 0.8 x ATR
input double FatorAlvo            = 1.2;   // alvo = 1.2 x ATR
input double FatorTrailing        = 0.5;   // trailing = 0.5 x ATR

// ── Break-even ────────────────────────────────────────────────────
input double BreakEvenTrigger     = 50.0;  // ativar be apos X pontos favoraveis
input double BreakEvenOffset      = 5.0;   // be = entrada + X pontos

// ── Filtro MME200 ─────────────────────────────────────────────────
input bool   UsarFiltroMME200     = true;  // filtro de tendencia
input int    PeriodoMME200        = 200;

// ── Gestao de risco ───────────────────────────────────────────────
input bool   UsarGestaoRisco      = true;  // false = testar sem gestao
input bool   UsarHardLock         = true;
input double RiscoDiaPct          = 1.5;   // 1.5% do saldo = limite/dia
input double RiscoSemanaPct       = 3.0;
input int    MaxStopsConsecutivos = 2;     // 2 stops = trava o dia

// ── Tamanho da posicao ────────────────────────────────────────────
input double VolumeLote           = 0.01;  // SEMPRE 0.01 para conta $5000 demo

// ── Tempo maximo em posicao ───────────────────────────────────────
input int    MaxBarrasPosicao     = 4;

//+------------------------------------------------------------------+
//| Variaveis globais                                                |
//+------------------------------------------------------------------+
int    hIFR;                    // handle do indicador IFR (RSI)
int    hATR;                    // handle do ATR
int    hMME200;                 // handle da MME200

double fPrecoEntrada;           // preco de entrada da posicao corrente
double fStop;                   // stop atual
double fAlvo;                   // alvo atual
double fMelhorPreco;            // melhor preco desde a entrada
bool   bBreakEvenAtivo;         // be ja foi ativado?
int    iDirecaoPosicao;         // 1=compra, -1=venda, 0=sem posicao
int    iBarrasPosicao;          // barras em posicao

double fResultadoDia;
double fResultadoSemana;
int    iStopsConsec;
bool   bBloqueioDia;
bool   bBloqueioSemana;

datetime dtUltimoBar;           // controle de nova barra
datetime dtUltimoDia;           // controle de novo dia

//+------------------------------------------------------------------+
//| Inicializacao                                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   // Criar handles dos indicadores
   hIFR   = iRSI(_Symbol, PERIOD_CURRENT, PeriodoIFR, PRICE_CLOSE);
   hATR   = iATR(_Symbol, PERIOD_CURRENT, PeriodoATR);
   hMME200 = iMA(_Symbol, PERIOD_CURRENT, PeriodoMME200, 0, MODE_EMA, PRICE_CLOSE);

   if(hIFR == INVALID_HANDLE || hATR == INVALID_HANDLE || hMME200 == INVALID_HANDLE)
   {
      Print("[ERRO] Falha ao criar indicadores. Verifique o ativo e timeframe.");
      return INIT_FAILED;
   }

   // Configurar objeto de trade
   trade.SetExpertMagicNumber(202601);     // ID unico deste EA
   trade.SetDeviationInPoints(10);         // slippage max 10 pontos
   trade.SetTypeFilling(ORDER_FILLING_IOC);

   // Reset variaveis
   fPrecoEntrada   = 0;
   fStop           = 0;
   fAlvo           = 0;
   bBreakEvenAtivo = false;
   iDirecaoPosicao = 0;
   iBarrasPosicao  = 0;
   fResultadoDia   = 0;
   fResultadoSemana = 0;
   iStopsConsec    = 0;
   bBloqueioDia    = false;
   bBloqueioSemana = false;
   dtUltimoBar     = 0;
   dtUltimoDia     = 0;

   Print("[INIT] mar_MT5_PPV01 carregado — Ativo: ", _Symbol, " TF: ", EnumToString(Period()));
   Print("EA iniciado: " + MQLInfoString(MQL_PROGRAM_NAME) + " | " + _Symbol + " | " + EnumToString(Period()));
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Desinicializacao                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(hIFR);
   IndicatorRelease(hATR);
   IndicatorRelease(hMME200);
   Print("[DEINIT] EA finalizado.");
}

//+------------------------------------------------------------------+
//| Funcao auxiliar: verifica se ha posicao aberta deste EA          |
//+------------------------------------------------------------------+
bool TemPosicao()
{
   return PositionSelectByTicket(trade.RequestOrder()) ||
          PositionSelect(_Symbol);
}

bool EstaComprado()
{
   if(!PositionSelect(_Symbol)) return false;
   return PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY
       && PositionGetInteger(POSITION_MAGIC) == 202601;
}

bool EstaVendido()
{
   if(!PositionSelect(_Symbol)) return false;
   return PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL
       && PositionGetInteger(POSITION_MAGIC) == 202601;
}

//+------------------------------------------------------------------+
//| Funcao principal — rodada a cada tick                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // ── SÓ PROCESSA EM NOVA BARRA ────────────────────────────────
   datetime dtBarAtual = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(dtBarAtual == dtUltimoBar) return;
   dtUltimoBar = dtBarAtual;

   // ── BUFFERS DOS INDICADORES ───────────────────────────────────
   double arrIFR[3], arrATR[2], arrMME200[2];
   if(CopyBuffer(hIFR,    0, 0, 3, arrIFR)    < 3) return;
   if(CopyBuffer(hATR,    0, 0, 2, arrATR)    < 2) return;
   if(CopyBuffer(hMME200, 0, 0, 2, arrMME200) < 2) return;

   // Barra [1] = barra fechada mais recente (usada para sinais)
   double fIFR0    = arrIFR[1];      // barra atual fechada
   double fIFR1    = arrIFR[2];      // barra anterior
   double fATRval  = arrATR[1];
   double fMME200v = arrMME200[1];

   // Precos da barra fechada
   double fOpen1  = iOpen (_Symbol, PERIOD_CURRENT, 1);
   double fHigh1  = iHigh (_Symbol, PERIOD_CURRENT, 1);
   double fLow1   = iLow  (_Symbol, PERIOD_CURRENT, 1);
   double fClose1 = iClose(_Symbol, PERIOD_CURRENT, 1);

   // ── NOVO DIA: RESET ───────────────────────────────────────────
   MqlDateTime dt; TimeToStruct(dtBarAtual, dt);
   MqlDateTime dtAnterior; TimeToStruct(dtUltimoDia, dtAnterior);

   if(dt.day != dtAnterior.day)
   {
      dtUltimoDia      = dtBarAtual;
      fResultadoDia    = 0;
      bBloqueioDia     = false;

      // Reset semanal na segunda-feira
      if(dt.day_of_week == 1)
      {
         fResultadoSemana = 0;
         bBloqueioSemana  = false;
         iStopsConsec     = 0;
      }
      Print("[DIA] Novo dia — resultado resetado.");
   }

   // ── DETECTA FECHAMENTO DE POSICAO ────────────────────────────
   if(UsarGestaoRisco)
   {
      if(iDirecaoPosicao == 1 && !EstaComprado() && fPrecoEntrada > 0)
      {
         double resultado = (fClose1 - fPrecoEntrada) * VolumeLote * 
                            SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) /
                            SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
         fResultadoDia    += resultado;
         fResultadoSemana += resultado;
         if(resultado < 0) iStopsConsec++; else iStopsConsec = 0;
         Print("[FECHOU COMPRA] Resultado: $", DoubleToString(resultado, 2),
               " | Dia: $", DoubleToString(fResultadoDia, 2));
         fPrecoEntrada = 0; iDirecaoPosicao = 0; bBreakEvenAtivo = false;
      }
      if(iDirecaoPosicao == -1 && !EstaVendido() && fPrecoEntrada > 0)
      {
         double resultado = (fPrecoEntrada - fClose1) * VolumeLote *
                            SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) /
                            SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
         fResultadoDia    += resultado;
         fResultadoSemana += resultado;
         if(resultado < 0) iStopsConsec++; else iStopsConsec = 0;
         Print("[FECHOU VENDA] Resultado: $", DoubleToString(resultado, 2),
               " | Dia: $", DoubleToString(fResultadoDia, 2));
         fPrecoEntrada = 0; iDirecaoPosicao = 0; bBreakEvenAtivo = false;
      }

      // Verificar limites
      double saldo      = AccountInfoDouble(ACCOUNT_BALANCE);
      double limiteDia  = saldo * (RiscoDiaPct / 100.0);
      double limiteSem  = saldo * (RiscoSemanaPct / 100.0);

      if(UsarHardLock)
      {
         if(fResultadoDia <= -limiteDia)
         { bBloqueioDia = true; Print("[LOCK] Limite do dia atingido: $", DoubleToString(fResultadoDia, 2)); }
         if(fResultadoSemana <= -limiteSem)
         { bBloqueioSemana = true; Print("[LOCK] Limite da semana atingido."); }
         if(iStopsConsec >= MaxStopsConsecutivos)
         { bBloqueioDia = true; Print("[LOCK] ", MaxStopsConsecutivos, " stops consecutivos — bloqueado."); }
      }
   }

   // ── GESTAO DA POSICAO ABERTA ─────────────────────────────────
   if(EstaComprado())
   {
      iBarrasPosicao++;

      // Preco atual para gestao
      double fAtual = fClose1;
      if(fAtual > fMelhorPreco) fMelhorPreco = fAtual;

      // Break-even
      if(!bBreakEvenAtivo && (fMelhorPreco >= fPrecoEntrada + BreakEvenTrigger))
      {
         fStop = fPrecoEntrada + BreakEvenOffset;
         bBreakEvenAtivo = true;
         trade.PositionModify(_Symbol, fStop, fAlvo);
         Print("[BE] Break-even ativado em ", DoubleToString(fStop, _Digits));
      }

      // Trailing apos be
      if(bBreakEvenAtivo)
      {
         double novoStop = fMelhorPreco - (fATRval * FatorTrailing);
         if(novoStop > fStop)
         {
            fStop = novoStop;
            trade.PositionModify(_Symbol, fStop, fAlvo);
         }
      }

      // Saida por tempo
      if(iBarrasPosicao >= MaxBarrasPosicao)
      {
         trade.PositionClose(_Symbol);
         Print("[SAIDA TEMPO] ", MaxBarrasPosicao, " barras — fechando.");
         iBarrasPosicao = 0;
      }
   }
   else if(EstaVendido())
   {
      iBarrasPosicao++;
      double fAtual = fClose1;
      if(fAtual < fMelhorPreco) fMelhorPreco = fAtual;

      if(!bBreakEvenAtivo && (fMelhorPreco <= fPrecoEntrada - BreakEvenTrigger))
      {
         fStop = fPrecoEntrada - BreakEvenOffset;
         bBreakEvenAtivo = true;
         trade.PositionModify(_Symbol, fStop, fAlvo);
         Print("[BE] Break-even ativado em ", DoubleToString(fStop, _Digits));
      }

      if(bBreakEvenAtivo)
      {
         double novoStop = fMelhorPreco + (fATRval * FatorTrailing);
         if(novoStop < fStop)
         {
            fStop = novoStop;
            trade.PositionModify(_Symbol, fStop, fAlvo);
         }
      }

      if(iBarrasPosicao >= MaxBarrasPosicao)
      {
         trade.PositionClose(_Symbol);
         Print("[SAIDA TEMPO] ", MaxBarrasPosicao, " barras — fechando.");
         iBarrasPosicao = 0;
      }
   }
   else
   {
      iBarrasPosicao = 0;
   }

   // ── ENTRADA — SO SE NAO TIVER POSICAO ────────────────────────
   if(!EstaComprado() && !EstaVendido()
   && !(UsarGestaoRisco && (bBloqueioDia || bBloqueioSemana)))
   {
      bool bContextoCompra = !UsarFiltroMME200 || (fClose1 > fMME200v);
      bool bContextoVenda  = !UsarFiltroMME200 || (fClose1 < fMME200v);

      // Sinal de COMPRA: IFR estava em sobrevenda e subiu de volta
      if(bContextoCompra && (fIFR1 <= IFRExtremoCompra) && (fIFR0 >= IFREtornoCompra))
      {
         double sl = iLow(_Symbol, PERIOD_CURRENT, 1) - (fATRval * FatorStopInicial);
         double tp = iClose(_Symbol, PERIOD_CURRENT, 0) + (fATRval * FatorAlvo);

         // Normalizar precos para o ativo
         sl = NormalizeDouble(sl, _Digits);
         tp = NormalizeDouble(tp, _Digits);

         if(trade.Buy(VolumeLote, _Symbol, 0, sl, tp, "mar_MT5_PPV01_exemplo"))
         {
            fPrecoEntrada   = trade.ResultPrice();
            fStop           = sl;
            fAlvo           = tp;
            fMelhorPreco    = fPrecoEntrada;
            bBreakEvenAtivo = false;
            iDirecaoPosicao = 1;
            iBarrasPosicao  = 0;
            Print("[ENTRADA COMPRA] IFR=", DoubleToString(fIFR0, 1),
                  " Preco=", DoubleToString(fPrecoEntrada, _Digits),
                  " SL=", DoubleToString(sl, _Digits),
                  " TP=", DoubleToString(tp, _Digits));
         }
      }
      // Sinal de VENDA: IFR estava em sobrecompra e caiu de volta
      else if(bContextoVenda && (fIFR1 >= IFRExtremoVenda) && (fIFR0 <= IFREtornoVenda))
      {
         double sl = iHigh(_Symbol, PERIOD_CURRENT, 1) + (fATRval * FatorStopInicial);
         double tp = iClose(_Symbol, PERIOD_CURRENT, 0) - (fATRval * FatorAlvo);

         sl = NormalizeDouble(sl, _Digits);
         tp = NormalizeDouble(tp, _Digits);

         if(trade.Sell(VolumeLote, _Symbol, 0, sl, tp, "mar_MT5_PPV01_exemplo"))
         {
            fPrecoEntrada   = trade.ResultPrice();
            fStop           = sl;
            fAlvo           = tp;
            fMelhorPreco    = fPrecoEntrada;
            bBreakEvenAtivo = false;
            iDirecaoPosicao = -1;
            iBarrasPosicao  = 0;
            Print("[ENTRADA VENDA] IFR=", DoubleToString(fIFR0, 1),
                  " Preco=", DoubleToString(fPrecoEntrada, _Digits),
                  " SL=", DoubleToString(sl, _Digits),
                  " TP=", DoubleToString(tp, _Digits));
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Evento de trade (log de cada operacao executada)                 |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      Print("[TRADE] Deal executado — Tipo: ", EnumToString((ENUM_DEAL_TYPE)trans.deal_type),
            " | Volume: ", DoubleToString(trans.volume, 2),
            " | Price: ", DoubleToString(trans.price, _Digits));
   }
}
//+------------------------------------------------------------------+
