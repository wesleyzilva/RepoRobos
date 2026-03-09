//+------------------------------------------------------------------+
//| mar_REV_01_v1_pullback_mme21.mq5                                 |
//| Grupo: REVERSAO_MEDIA                                            |
//| Versao: v1 | Timeframe: M15 / M30                               |
//| Descricao: Em tendencia (MME9>MME21>MME200), aguarda pullback    |
//|            ate a MME21 e opera a favor da tendencia de volta.    |
//|            Stop: MME21 - ATR x0.5. Alvo: 1:2.                   |
//+------------------------------------------------------------------+
#property copyright "mar_REV_01_v1_pullback_mme21"
#property version   "1.00"
#include <Trade\Trade.mqh>

//--- Gestao de Risco
input bool   UsarGestaoRisco      = true;
input bool   UsarHardLock         = true;
input double SaldoConta           = 10000.0;
input double RiscoDiaPct          = 1.5;
input double RiscoSemanaPct       = 3.0;
input int    MaxStopsConsecutivos = 2;
input double ValorPorPonto        = 0.20;
input int    DiaSemanaReset       = 1;   // 0=Dom 1=Seg 2=Ter ...

//--- Estrategia
input int    PeriodoMME9    = 9;
input int    PeriodoMME21   = 21;
input int    PeriodoMME200  = 200;
input double ToleranciaMME  = 30.0;   // pts tolerancia para toque na MME21
input int    PeriodoATR     = 14;
input double MultATRStop    = 0.5;
input double RelacaoRR      = 2.0;
input int    HoraIni        = 9;
input int    MinIni         = 30;
input int    HoraFim        = 17;
input int    MinFim         = 0;
input double LotePadrao     = 1.0;

//--- Globals
CTrade trade;
int    hMME9, hMME21, hMME200, hATR;
double PerdaDia, PerdaSemana;
int    StopsConsec, UltimoDia;

//+------------------------------------------------------------------+
int OnInit(){
   hMME9   = iMA(NULL,0,PeriodoMME9,  0,MODE_EMA,PRICE_CLOSE);
   hMME21  = iMA(NULL,0,PeriodoMME21, 0,MODE_EMA,PRICE_CLOSE);
   hMME200 = iMA(NULL,0,PeriodoMME200,0,MODE_EMA,PRICE_CLOSE);
   hATR    = iATR(NULL,0,PeriodoATR);
   if(hMME9==INVALID_HANDLE || hMME21==INVALID_HANDLE ||
      hMME200==INVALID_HANDLE || hATR==INVALID_HANDLE)
     { Print("Erro ao criar handles."); return INIT_FAILED; }
   UltimoDia = -1;
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason){
   IndicatorRelease(hMME9);
   IndicatorRelease(hMME21);
   IndicatorRelease(hMME200);
   IndicatorRelease(hATR);
}

double CalculaPerdaDia(){
   double perda=0;
   MqlDateTime dn; TimeToStruct(TimeCurrent(),dn);
   datetime ini=StringToTime(StringFormat("%04d.%02d.%02d 00:00",dn.year,dn.mon,dn.day));
   HistorySelect(ini,TimeCurrent());
   for(int i=0;i<HistoryDealsTotal();i++){
      ulong tkt=HistoryDealGetTicket(i);
      if(HistoryDealGetString(tkt,DEAL_SYMBOL)==Symbol() &&
         HistoryDealGetInteger(tkt,DEAL_ENTRY)==DEAL_ENTRY_OUT){
         double prf=HistoryDealGetDouble(tkt,DEAL_PROFIT);
         if(prf<0) perda+=-prf;
      }
   }
   return perda;
}

void OnTick(){
   // Executa apenas no fechamento de nova barra
   static datetime ultimaBarra=0;
   datetime barraAtual=iTime(NULL,0,0);
   if(barraAtual==ultimaBarra) return;
   ultimaBarra=barraAtual;

   // Reset diario
   MqlDateTime dt; TimeToStruct(TimeCurrent(),dt);
   if(dt.day!=UltimoDia){
      if(UsarGestaoRisco){
         PerdaDia=0;
         if(dt.day_of_week==DiaSemanaReset){ PerdaSemana=0; StopsConsec=0; }
      }
      UltimoDia=dt.day;
   }

   // Verifica limites de risco
   if(UsarGestaoRisco){
      PerdaDia=CalculaPerdaDia();
      if(PerdaDia    >= SaldoConta*RiscoDiaPct/100.0  ||
         PerdaSemana >= SaldoConta*RiscoSemanaPct/100.0||
         StopsConsec >= MaxStopsConsecutivos){
         if(UsarHardLock && PositionSelect(Symbol())) trade.PositionClose(Symbol());
         return;
      }
   }

   // Indicadores (barra fechada = indice 1)
   double arrMME9[1],arrMME21[1],arrMME200[1],arrATR[1];
   ArraySetAsSeries(arrMME9,true);   CopyBuffer(hMME9,  0,1,1,arrMME9);
   ArraySetAsSeries(arrMME21,true);  CopyBuffer(hMME21, 0,1,1,arrMME21);
   ArraySetAsSeries(arrMME200,true); CopyBuffer(hMME200,0,1,1,arrMME200);
   ArraySetAsSeries(arrATR,true);    CopyBuffer(hATR,   0,1,1,arrATR);

   double mme9=arrMME9[0], mme21=arrMME21[0], mme200=arrMME200[0], atr=arrATR[0];
   double fechar=iClose(NULL,0,1);

   // Filtro de horario
   MqlDateTime dtBar; TimeToStruct(iTime(NULL,0,1),dtBar);
   int hhmm=dtBar.hour*100+dtBar.min;
   if(hhmm<HoraIni*100+MinIni || hhmm>HoraFim*100+MinFim) return;

   if(PositionSelect(Symbol())) return;   // ja tem posicao aberta

   // LONG: tendencia altista + pullback ate MME21
   if(mme9>mme21 && mme21>mme200 &&
      MathAbs(fechar-mme21)<=ToleranciaMME && fechar>mme21){
      double sl=mme21-atr*MultATRStop;
      double tp=fechar+(fechar-sl)*RelacaoRR;
      if(trade.Buy(LotePadrao,Symbol(),0,sl,tp) && UsarGestaoRisco) StopsConsec=0;
   }
   // SHORT: tendencia baixista + pullback ate MME21
   else if(mme9<mme21 && mme21<mme200 &&
           MathAbs(fechar-mme21)<=ToleranciaMME && fechar<mme21){
      double sl=mme21+atr*MultATRStop;
      double tp=fechar-(sl-fechar)*RelacaoRR;
      if(trade.Sell(LotePadrao,Symbol(),0,sl,tp) && UsarGestaoRisco) StopsConsec=0;
   }
}
