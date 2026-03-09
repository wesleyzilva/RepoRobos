//+------------------------------------------------------------------+
//| mar_REV_04_v1_ifr_afastamento_pct.mq5                           |
//| Grupo: REVERSAO_MEDIA                                            |
//| Versao: v1 | Timeframe: M15 / M30                               |
//| Descricao: IFR extremo E preco afastado >X% da MME200.          |
//|            Entrada quando IFR sai da zona extrema.              |
//|            Stop: ATR x2.0. Alvo: 50% do afastamento da MME200.  |
//+------------------------------------------------------------------+
#property copyright "mar_REV_04_v1_ifr_afastamento_pct"
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
input int    PeriodoIFR     = 14;
input double IFRSobVend     = 30.0;
input double IFRSobComp     = 70.0;
input int    PeriodoMME200  = 200;
input double AfastamentoPct = 1.5;   // % minimo de afastamento da MME200
input int    PeriodoATR     = 14;
input double MultATR        = 2.0;
input int    HoraIni        = 9;
input int    MinIni         = 30;
input int    HoraFim        = 17;
input int    MinFim         = 0;
input double LotePadrao     = 1.0;

//--- Globals
CTrade trade;
int    hIFR, hMME200, hATR;
double PerdaDia, PerdaSemana;
int    StopsConsec, UltimoDia;

//+------------------------------------------------------------------+
int OnInit(){
   hIFR   = iRSI(NULL,0,PeriodoIFR,PRICE_CLOSE);
   hMME200= iMA(NULL,0,PeriodoMME200,0,MODE_EMA,PRICE_CLOSE);
   hATR   = iATR(NULL,0,PeriodoATR);
   if(hIFR==INVALID_HANDLE || hMME200==INVALID_HANDLE || hATR==INVALID_HANDLE)
     { Print("Erro ao criar handles."); return INIT_FAILED; }
   UltimoDia=-1;
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason){
   IndicatorRelease(hIFR);
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

   // Indicadores (barras 1=atual fechada, 2=anterior)
   double arrIFR[2], arrMME200[1], arrATR[1];
   ArraySetAsSeries(arrIFR,true);   CopyBuffer(hIFR,  0,1,2,arrIFR);
   ArraySetAsSeries(arrMME200,true);CopyBuffer(hMME200,0,1,1,arrMME200);
   ArraySetAsSeries(arrATR,true);   CopyBuffer(hATR,  0,1,1,arrATR);

   double ifr0=arrIFR[0], ifr1=arrIFR[1];   // ifr0=barra fechada, ifr1=anterior
   double mme200=arrMME200[0], atr=arrATR[0];
   double fechar=iClose(NULL,0,1);

   double distPct=(mme200>0) ? MathAbs(fechar-mme200)/mme200*100.0 : 0;

   // Filtro de horario
   MqlDateTime dtBar; TimeToStruct(iTime(NULL,0,1),dtBar);
   int hhmm=dtBar.hour*100+dtBar.min;
   if(hhmm<HoraIni*100+MinIni || hhmm>HoraFim*100+MinFim) return;

   if(PositionSelect(Symbol())) return;
   if(distPct<AfastamentoPct) return;   // afastamento insuficiente

   // LONG: abaixo da MME200 + IFR era sobrevendido e subiu (sai da zona)
   if(fechar<mme200 && ifr1<=IFRSobVend && ifr0>IFRSobVend){
      double sl=fechar-atr*MultATR;
      double tp=fechar+(fechar-mme200)*0.5;   // 50% do afastamento
      trade.Buy(LotePadrao,Symbol(),0,sl,tp);
   }
   // SHORT: acima da MME200 + IFR era sobrecomprado e caiu (sai da zona)
   else if(fechar>mme200 && ifr1>=IFRSobComp && ifr0<IFRSobComp){
      double sl=fechar+atr*MultATR;
      double tp=fechar-(mme200-fechar)*0.5;
      trade.Sell(LotePadrao,Symbol(),0,sl,tp);
   }
}
