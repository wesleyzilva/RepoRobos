//+------------------------------------------------------------------+
//| mar_REV_02_v1_zscore_afastamento.mq5                             |
//| Grupo: REVERSAO_MEDIA                                            |
//| Versao: v1 | Timeframe: M15 / M30                               |
//| Descricao: Z-Score do preco em relacao a media de N periodos.    |
//|            Z > +2: sobrecomprado -> short                        |
//|            Z < -2: sobrevendido  -> long                         |
//|            Stop: ATR x1.5. Alvo: retorno a media (Z=0).         |
//+------------------------------------------------------------------+
#property copyright "mar_REV_02_v1_zscore_afastamento"
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
input int    PeriodoMedia  = 20;
input double LimiteZScore  = 2.0;
input int    PeriodoATR    = 14;
input double MultATR       = 1.5;
input int    HoraIni       = 9;
input int    MinIni        = 30;
input int    HoraFim       = 17;
input int    MinFim        = 0;
input double LotePadrao    = 1.0;

//--- Globals
CTrade trade;
int    hMedia, hATR;
double PerdaDia, PerdaSemana;
int    StopsConsec, UltimoDia;

//+------------------------------------------------------------------+
int OnInit(){
   hMedia = iMA(NULL,0,PeriodoMedia,0,MODE_EMA,PRICE_CLOSE);
   hATR   = iATR(NULL,0,PeriodoATR);
   if(hMedia==INVALID_HANDLE || hATR==INVALID_HANDLE)
     { Print("Erro ao criar handles."); return INIT_FAILED; }
   UltimoDia=-1;
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason){
   IndicatorRelease(hMedia);
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

   // Indicadores
   double arrMedia[1], arrATR[1];
   ArraySetAsSeries(arrMedia,true); CopyBuffer(hMedia,0,1,1,arrMedia);
   ArraySetAsSeries(arrATR,true);   CopyBuffer(hATR,  0,1,1,arrATR);
   double media=arrMedia[0], atr=arrATR[0];

   // Z-Score: copia N fechamentos para calculo de desvio padrao
   double closes[];
   ArraySetAsSeries(closes,true);
   CopyClose(NULL,0,1,PeriodoMedia,closes);

   double somaQuad=0;
   for(int i=0;i<PeriodoMedia;i++)
      somaQuad+=MathPow(closes[i]-media,2);
   double desvio=MathSqrt(somaQuad/PeriodoMedia);
   double zscore=(desvio>0) ? (closes[0]-media)/desvio : 0;

   // Filtro de horario
   MqlDateTime dtBar; TimeToStruct(iTime(NULL,0,1),dtBar);
   int hhmm=dtBar.hour*100+dtBar.min;
   if(hhmm<HoraIni*100+MinIni || hhmm>HoraFim*100+MinFim) return;

   if(PositionSelect(Symbol())) return;

   // LONG: Z-Score muito negativo (sobrevendido)
   if(zscore<=-LimiteZScore){
      double sl=closes[0]-atr*MultATR;
      double tp=media;
      trade.Buy(LotePadrao,Symbol(),0,sl,tp);
   }
   // SHORT: Z-Score muito positivo (sobrecomprado)
   else if(zscore>=LimiteZScore){
      double sl=closes[0]+atr*MultATR;
      double tp=media;
      trade.Sell(LotePadrao,Symbol(),0,sl,tp);
   }
}
