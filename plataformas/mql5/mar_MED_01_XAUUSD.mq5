//+------------------------------------------------------------------+
//|  mar_MED_01_XAUUSD.mq5                                          |
//|  Grupo: MEDIAS — Versao MT5                                     |
//|  Descricao: Cruzamento de medias MME rapida x MME lenta.        |
//|             Quando MME rapida cruza acima da lenta = compra.    |
//|             Abaixo = venda. Filtro: confirmacao de fechamento   |
//|             alem da MME lenta. Trailing para capturar movimento.|
//|  Ativo: XAUUSD — tambem testavel em EURUSD, US30              |
//|  Timeframe: M15 / M30 / H1                                     |
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

// ── Medias ────────────────────────────────────────────────────────
input int    PeriodoMMERapida     = 9;
input int    PeriodoMMELenta      = 21;
input bool   UsarFiltroFechamento = true;  // fecha alem da MME lenta

// ── Saida ─────────────────────────────────────────────────────────
input bool   UsarSaidaCruzInverso = true;
input bool   UsarSaidaTempo       = true;
input int    MaxBarrasPosicao     = 20;
input bool   UsarTrailing         = true;
input double PontosTrailing       = 150.0; // pontos do ativo

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
int    hMMERapida;
int    hMMELenta;
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
   hMMERapida = iMA(_Symbol, _Period, PeriodoMMERapida, 0, MODE_EMA, PRICE_CLOSE);
   hMMELenta  = iMA(_Symbol, _Period, PeriodoMMELenta,  0, MODE_EMA, PRICE_CLOSE);
   if(hMMERapida == INVALID_HANDLE || hMMELenta == INVALID_HANDLE) return INIT_FAILED;
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(hMMERapida);
   IndicatorRelease(hMMELenta);
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

   double mmeRapida     = GetBuf(hMMERapida, 1);
   double mmeLenta      = GetBuf(hMMELenta,  1);
   double mmeRapidaAnt  = GetBuf(hMMERapida, 2);
   double mmeLentaAnt   = GetBuf(hMMELenta,  2);
   double closeB1       = iClose(_Symbol, _Period, 1);

   bool bCruzouParaCima  = (mmeRapidaAnt <= mmeLentaAnt) && (mmeRapida > mmeLenta);
   bool bCruzouParaBaixo = (mmeRapidaAnt >= mmeLentaAnt) && (mmeRapida < mmeLenta);

   if(UsarFiltroFechamento)
   {
      bCruzouParaCima  = bCruzouParaCima  && (closeB1 > mmeLenta);
      bCruzouParaBaixo = bCruzouParaBaixo && (closeB1 < mmeLenta);
   }

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   // ── SAIDAS ──────────────────────────────────────────────────
   if(TenhoCompra())
   {
      iBarrasPosicao++;
      if(bid > fMelhorPreco) fMelhorPreco = bid;
      bool sair = false;
      if(UsarSaidaCruzInverso && mmeRapida < mmeLenta)            sair = true;
      if(UsarSaidaTempo       && iBarrasPosicao >= MaxBarrasPosicao) sair = true;
      if(UsarTrailing         && bid < fMelhorPreco - PontosTrailing * _Point) sair = true;
      if(sair) trade.PositionClose(_Symbol);
   }

   if(TenhoVenda())
   {
      iBarrasPosicao++;
      if(fMelhorPreco == 0 || ask < fMelhorPreco) fMelhorPreco = ask;
      bool sair = false;
      if(UsarSaidaCruzInverso && mmeRapida > mmeLenta)              sair = true;
      if(UsarSaidaTempo       && iBarrasPosicao >= MaxBarrasPosicao) sair = true;
      if(UsarTrailing         && ask > fMelhorPreco + PontosTrailing * _Point) sair = true;
      if(sair) trade.PositionClose(_Symbol);
   }

   // ── ENTRADAS ────────────────────────────────────────────────
   if(!TenhoCompra() && !TenhoVenda())
   {
      iBarrasPosicao = 0; fMelhorPreco = 0;
      if(UsarGestaoRisco && (bBloqueioDia || bBloqueioSemana)) return;

      if(bCruzouParaCima)
      {
         trade.Buy(VolumeLote, _Symbol, ask, 0, 0, "MED_cruzamento_alta");
         fPrecoEntrada = ask; iDirecaoPosicao = 1; fMelhorPreco = ask;
      }
      else if(bCruzouParaBaixo)
      {
         trade.Sell(VolumeLote, _Symbol, bid, 0, 0, "MED_cruzamento_baixa");
         fPrecoEntrada = bid; iDirecaoPosicao = -1; fMelhorPreco = bid;
      }
   }
}
