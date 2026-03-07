//+------------------------------------------------------------------+
//| mar_REV_03_v1_bb_retorno_media.mq5                               |
//| Grupo: REVERSAO_MEDIA                                            |
//| Versao: v1 | Timeframe: M15 / M30                               |
//| Descricao: BB (20,2). Preco fecha fora da banda -> aguarda barra |
//|            retornar para dentro. Entrada no 1o candle que volta. |
//|            Alvo: media BB. Stop: 1 ATR alem do extremo.         |
//+------------------------------------------------------------------+
#property copyright "mar_REV_03_v1_bb_retorno_media"
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
input int    DiaSemanaReset       = 1;

//--- Estrategia
input int    PeriodoBB    = 20;
input double DesvBB       = 2.0;
input int    PeriodoATR   = 14;
input double MultATRStop  = 1.0;
input int    HoraIni      = 9;
input int    MinIni       = 30;
input int    HoraFim      = 17;
input int    MinFim       = 0;
input double LotePadrao   = 1.0;

//--- Globals
CTrade trade;
int    hBB, hATR;
double PerdaDia, PerdaSemana;
int    StopsConsec, UltimoDia;

//+------------------------------------------------------------------+
int OnInit(){
   hBB  = iBands(NULL,0,PeriodoBB,0,DesvBB,PRICE_CLOSE);
   hATR = iATR(NULL,0,PeriodoATR);
   if(hBB==INVALID_HANDLE || hATR==INVALID_HANDLE)
     { Print("Erro ao criar handles."); return INIT_FAILED; }
   UltimoDia=-1;
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason){
   IndicatorRelease(hBB);
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
   static datetime ultimaBarra=0;
   datetime barraAtual=iTime(NULL,0,0);
   if(barraAtual==ultimaBarra) return;
   ultimaBarra=barraAtual;

   MqlDateTime dt; TimeToStruct(TimeCurrent(),dt);
   if(dt.day!=UltimoDia){
      if(UsarGestaoRisco){
         PerdaDia=0;
         if(dt.day_of_week==DiaSemanaReset){ PerdaSemana=0; StopsConsec=0; }
      }
      UltimoDia=dt.day;
   }

   if(UsarGestaoRisco){
      PerdaDia=CalculaPerdaDia();
      if(PerdaDia    >= SaldoConta*RiscoDiaPct/100.0   ||
         PerdaSemana >= SaldoConta*RiscoSemanaPct/100.0 ||
         StopsConsec >= MaxStopsConsecutivos){
         if(UsarHardLock && PositionSelect(Symbol())) trade.PositionClose(Symbol());
         return;
      }
   }

   // BB: buffer 0=superior, 1=media, 2=inferior
   double arrSup[2], arrMed[2], arrInf[2], arrATR[2];
   ArraySetAsSeries(arrSup,true); CopyBuffer(hBB, UPPER_BAND, 1,2,arrSup);
   ArraySetAsSeries(arrMed,true); CopyBuffer(hBB, BASE_LINE,  1,2,arrMed);
   ArraySetAsSeries(arrInf,true); CopyBuffer(hBB, LOWER_BAND, 1,2,arrInf);
   ArraySetAsSeries(arrATR,true); CopyBuffer(hATR,0,           1,1,arrATR);

   // Indices: [0]=barra fechada atual, [1]=barra anterior
   double close1=iClose(NULL,0,1), close2=iClose(NULL,0,2);
   double bbSup0=arrSup[0], bbSup1=arrSup[1];
   double bbInf0=arrInf[0], bbInf1=arrInf[1];
   double bbMed0=arrMed[0];
   double atr   =arrATR[0];

   // Filtro de horario
   MqlDateTime dtBar; TimeToStruct(iTime(NULL,0,1),dtBar);
   int hhmm=dtBar.hour*100+dtBar.min;
   if(hhmm<HoraIni*100+MinIni || hhmm>HoraFim*100+MinFim) return;

   if(PositionSelect(Symbol())) return;

   // LONG: barra anterior fechou abaixo da banda inf; atual voltou para dentro
   if(close2<bbInf1 && close1>=bbInf0){
      double sl=close2-atr*MultATRStop;
      double tp=bbMed0;
      trade.Buy(LotePadrao,Symbol(),0,sl,tp);
   }
   // SHORT: barra anterior fechou acima da banda sup; atual voltou para dentro
   else if(close2>bbSup1 && close1<=bbSup0){
      double sl=close2+atr*MultATRStop;
      double tp=bbMed0;
      trade.Sell(LotePadrao,Symbol(),0,sl,tp);
   }
}
