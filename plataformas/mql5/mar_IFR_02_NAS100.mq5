//+------------------------------------------------------------------+
//|  mar_IFR_02_NAS100.mq5                                          |
//|  Grupo: IFR_RSI — Versao MT5                                    |
//|  Descricao: Pullback do IFR em tendencia definida pela MME200.  |
//|             Em tendencia de alta: IFR cai ate 40 e retorna.    |
//|             Em tendencia de baixa: IFR sobe ate 60 e retorna.  |
//|             Adaptado de mar_IFR_09 (Profit). Excelente para    |
//|             indices tendenciais como NAS100 e US500.            |
//|  Ativo: NAS100 — tambem testavel em US500, XAUUSD              |
//|  Timeframe: M30 / H1                                           |
//|  Versao: 1.0 — marco/2026                                       |
//+------------------------------------------------------------------+

#property copyright "Wesley — RepoRobos"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

CTrade trade;

//+------------------------------------------------------------------+
//| Parametros de entrada                                            |
//+------------------------------------------------------------------+

// ── IFR ───────────────────────────────────────────────────────────
input int    PeriodoIFR           = 14;
input double NivelPullbackCompra  = 40.0;  // IFR cai ate aqui em pullback de alta
input double NivelPullbackVenda   = 60.0;  // IFR sobe ate aqui em pullback de baixa
input double NivelSaidaCompra     = 60.0;
input double NivelSaidaVenda      = 40.0;

// ── MME200 ────────────────────────────────────────────────────────
input int    PeriodoMME200        = 200;
input double MargemMMEPontos      = 50.0;  // pontos de margem vs MME200

// ── Saida ─────────────────────────────────────────────────────────
input bool   UsarSaidaIFR         = true;
input bool   UsarSaidaTempo       = true;
input int    MaxBarrasPosicao     = 16;
input bool   UsarTrailing         = true;
input double PontosTrailing       = 200.0; // em pontos do ativo

// ── Gestao de risco ───────────────────────────────────────────────
input bool   UsarGestaoRisco      = true;
input bool   UsarHardLock         = true;
input double RiscoDiaPct          = 1.5;
input double RiscoSemanaPct       = 3.0;
input int    MaxStopsConsecutivos = 2;
input double VolumeLote           = 0.01;

//+------------------------------------------------------------------+
//| Variaveis globais                                                |
//+------------------------------------------------------------------+
int    hIFR;
int    hMME200;
double fPrecoEntrada;
double fMelhorPreco;
int    iDirecaoPosicao;
int    iBarrasPosicao;
double fResultadoDia;
double fResultadoSemana;
int    iStopsConsec;
bool   bBloqueioDia;
bool   bBloqueioSemana;
datetime dtUltimoBar;
datetime dtUltimoReset;

int OnInit()
{
   hIFR   = iRSI(_Symbol, _Period, PeriodoIFR, PRICE_CLOSE);
   hMME200= iMA(_Symbol, _Period, PeriodoMME200, 0, MODE_EMA, PRICE_CLOSE);
   if(hIFR == INVALID_HANDLE || hMME200 == INVALID_HANDLE) return INIT_FAILED;
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(hIFR);
   IndicatorRelease(hMME200);
}

bool NovaBarraIniciou()
{
   datetime dt = iTime(_Symbol, _Period, 0);
   if(dt != dtUltimoBar) { dtUltimoBar = dt; return true; }
   return false;
}

double GetBuf(int handle, int deslocamento)
{
   double buf[]; ArraySetAsSeries(buf, true);
   if(CopyBuffer(handle, 0, deslocamento, 1, buf) < 1) return 0;
   return buf[0];
}

bool TenhoCompra() { return PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY; }
bool TenhoVenda()  { return PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL; }

void ResetDiario()
{
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   MqlDateTime dtR; TimeToStruct(dtUltimoReset, dtR);
   if(dt.day != dtR.day)
   {
      fResultadoDia = 0; bBloqueioDia = false; dtUltimoReset = TimeCurrent();
      if(dt.day_of_week == 1) { fResultadoSemana = 0; bBloqueioSemana = false; }
   }
}

void AtualizarGestaoRisco()
{
   double saldo = AccountInfoDouble(ACCOUNT_BALANCE);
   double limiteDia    = saldo * RiscoDiaPct    / 100.0;
   double limiteSemana = saldo * RiscoSemanaPct / 100.0;

   if(iDirecaoPosicao != 0 && !TenhoCompra() && !TenhoVenda() && fPrecoEntrada > 0)
   {
      double preco = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double resultado = (iDirecaoPosicao == 1)
         ? (preco - fPrecoEntrada) * VolumeLote * 100
         : (fPrecoEntrada - preco) * VolumeLote * 100;
      fResultadoDia    += resultado;
      fResultadoSemana += resultado;
      if(resultado < 0) iStopsConsec++; else iStopsConsec = 0;
      fPrecoEntrada = 0; iDirecaoPosicao = 0; iBarrasPosicao = 0;
   }
   if(UsarHardLock)
   {
      if(fResultadoDia    <= -limiteDia)          bBloqueioDia    = true;
      if(fResultadoSemana <= -limiteSemana)        bBloqueioSemana = true;
      if(iStopsConsec     >= MaxStopsConsecutivos) bBloqueioDia    = true;
   }
}

void OnTick()
{
   if(!NovaBarraIniciou()) return;
   ResetDiario();
   if(UsarGestaoRisco) AtualizarGestaoRisco();

   double fIFR     = GetBuf(hIFR,    1);
   double fIFRAnt  = GetBuf(hIFR,    2);
   double fMME200  = GetBuf(hMME200, 1);
   double closeB1  = iClose(_Symbol, _Period, 1);

   bool bTendenciaAlta  = closeB1 > fMME200 + MargemMMEPontos * _Point;
   bool bTendenciaBaixa = closeB1 < fMME200 - MargemMMEPontos * _Point;

   bool bPullbackAlta  = bTendenciaAlta  && (fIFRAnt < NivelPullbackCompra) && (fIFR >= NivelPullbackCompra);
   bool bPullbackBaixa = bTendenciaBaixa && (fIFRAnt > NivelPullbackVenda)  && (fIFR <= NivelPullbackVenda);

   // ── SAIDAS ──────────────────────────────────────────────────
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   if(TenhoCompra())
   {
      iBarrasPosicao++;
      if(bid > fMelhorPreco) fMelhorPreco = bid;
      bool sair = false;
      if(UsarSaidaIFR   && fIFR >= NivelSaidaCompra)          sair = true;
      if(UsarSaidaTempo && iBarrasPosicao >= MaxBarrasPosicao) sair = true;
      if(UsarTrailing   && bid < fMelhorPreco - PontosTrailing * _Point) sair = true;
      if(sair) trade.PositionClose(_Symbol);
   }

   if(TenhoVenda())
   {
      iBarrasPosicao++;
      if(fMelhorPreco == 0 || ask < fMelhorPreco) fMelhorPreco = ask;
      bool sair = false;
      if(UsarSaidaIFR   && fIFR <= NivelSaidaVenda)            sair = true;
      if(UsarSaidaTempo && iBarrasPosicao >= MaxBarrasPosicao) sair = true;
      if(UsarTrailing   && ask > fMelhorPreco + PontosTrailing * _Point) sair = true;
      if(sair) trade.PositionClose(_Symbol);
   }

   // ── ENTRADAS ────────────────────────────────────────────────
   if(!TenhoCompra() && !TenhoVenda())
   {
      iBarrasPosicao = 0; fMelhorPreco = 0;
      if(UsarGestaoRisco && (bBloqueioDia || bBloqueioSemana)) return;

      if(bPullbackAlta)
      {
         trade.Buy(VolumeLote, _Symbol, ask, 0, 0, "IFR_pullback_alta");
         fPrecoEntrada = ask; iDirecaoPosicao = 1; fMelhorPreco = ask;
      }
      else if(bPullbackBaixa)
      {
         trade.Sell(VolumeLote, _Symbol, bid, 0, 0, "IFR_pullback_baixa");
         fPrecoEntrada = bid; iDirecaoPosicao = -1; fMelhorPreco = bid;
      }
   }
}
