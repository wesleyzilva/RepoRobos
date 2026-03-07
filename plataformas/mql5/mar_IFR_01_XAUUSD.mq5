//+------------------------------------------------------------------+
//|  mar_IFR_01_XAUUSD.mq5                                          |
//|  Grupo: IFR_RSI — Versao MT5                                    |
//|  Descricao: Divergencia bullish/bearish de IFR com candle de    |
//|             rejeicao. Adaptado de mar_IFR_01 (Profit) para MT5. |
//|             Funciona muito bem em XAUUSD pela volatilidade e    |
//|             reversoes tecnicas frequentes no ouro.              |
//|  Ativo: XAUUSD (Ouro) — tambem testavel em NAS100, US500       |
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
input int    PeriodoIFR         = 9;
input int    LookbackDivergencia= 12;   // janela para comparar fundos/topos
input double DeltaIFRMinimo     = 2.0;  // diferenca minima no IFR

// ── Candle de rejeicao ────────────────────────────────────────────
input double MultiplicadorPavio = 1.5;  // pavio >= corpo * mult
input double MaxPavioOpostoCorpo= 1.2;

// ── Saida IFR ────────────────────────────────────────────────────
input bool   UsarSaidaIFR       = true;
input double NivelSaidaCompra   = 55.0;
input double NivelSaidaVenda    = 45.0;
input bool   UsarSaidaTempo     = true;
input int    MaxBarrasPosicao   = 12;

// ── Trailing ─────────────────────────────────────────────────────
input bool   UsarTrailing       = true;
input double PontosTrailing     = 150.0; // em pontos do ativo (XAUUSD: 1.5 dolar)

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

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit()
{
   hIFR = iRSI(_Symbol, _Period, PeriodoIFR, PRICE_CLOSE);
   if(hIFR == INVALID_HANDLE) { Print("Erro ao criar handle IFR"); return INIT_FAILED; }
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(hIFR);
}

//+------------------------------------------------------------------+
//| Helpers                                                          |
//+------------------------------------------------------------------+
bool NovaBarraIniciou()
{
   datetime dtAtual = iTime(_Symbol, _Period, 0);
   if(dtAtual != dtUltimoBar) { dtUltimoBar = dtAtual; return true; }
   return false;
}

double GetIFR(int deslocamento)
{
   double buf[]; ArraySetAsSeries(buf, true);
   if(CopyBuffer(hIFR, 0, deslocamento, 1, buf) < 1) return 50;
   return buf[0];
}

bool TenhoCompra()  { return PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY;  }
bool TenhoVenda()   { return PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL; }
double PrecoAtualPosicao() { return PositionSelect(_Symbol) ? PositionGetDouble(POSITION_PRICE_OPEN) : 0; }

//+------------------------------------------------------------------+
//| ResetDiario                                                      |
//+------------------------------------------------------------------+
void ResetDiario()
{
   MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
   MqlDateTime dtR; TimeToStruct(dtUltimoReset, dtR);
   if(dt.day != dtR.day)
   {
      fResultadoDia = 0;
      bBloqueioDia  = false;
      dtUltimoReset = TimeCurrent();
      if(dt.day_of_week == 1) // segunda-feira
      {
         fResultadoSemana = 0;
         bBloqueioSemana  = false;
      }
   }
}

//+------------------------------------------------------------------+
//| GestaoRisco: atualiza resultados e bloqueios                     |
//+------------------------------------------------------------------+
void AtualizarGestaoRisco()
{
   double saldo = AccountInfoDouble(ACCOUNT_BALANCE);
   double limiteDia    = saldo * RiscoDiaPct    / 100.0;
   double limiteSemana = saldo * RiscoSemanaPct / 100.0;

   // Detecta fechamento de posicao
   if(iDirecaoPosicao != 0 && !TenhoCompra() && !TenhoVenda() && fPrecoEntrada > 0)
   {
      double preco = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double resultado;
      if(iDirecaoPosicao == 1)
         resultado = (preco - fPrecoEntrada) * VolumeLote * 100; // xauusd: $1/pip por 0.01 lot
      else
         resultado = (fPrecoEntrada - preco) * VolumeLote * 100;

      fResultadoDia    += resultado;
      fResultadoSemana += resultado;
      if(resultado < 0) iStopsConsec++; else iStopsConsec = 0;
      fPrecoEntrada = 0; iDirecaoPosicao = 0; iBarrasPosicao = 0;
   }

   if(UsarHardLock)
   {
      if(fResultadoDia    <= -limiteDia)    bBloqueioDia    = true;
      if(fResultadoSemana <= -limiteSemana) bBloqueioSemana = true;
      if(iStopsConsec     >= MaxStopsConsecutivos) bBloqueioDia = true;
   }
}

//+------------------------------------------------------------------+
//| OnTick                                                           |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!NovaBarraIniciou()) return;
   ResetDiario();
   if(UsarGestaoRisco) AtualizarGestaoRisco();

   double fIFR    = GetIFR(1);
   double fIFRAnt = GetIFR(2);

   // Dados do candle fechado (barra 1)
   double highB1  = iHigh(_Symbol,  _Period, 1);
   double lowB1   = iLow(_Symbol,   _Period, 1);
   double openB1  = iOpen(_Symbol,  _Period, 1);
   double closeB1 = iClose(_Symbol, _Period, 1);

   double range   = highB1 - lowB1;
   double corpo   = MathAbs(openB1 - closeB1);
   double pavioSup= highB1 - MathMax(openB1, closeB1);
   double pavioInf= MathMin(openB1, closeB1) - lowB1;

   bool bMartelo = (range > 0) && (corpo > 0)
                && (pavioInf >= corpo * MultiplicadorPavio)
                && (pavioSup <= corpo * MaxPavioOpostoCorpo);

   bool bEstrela = (range > 0) && (corpo > 0)
                && (pavioSup >= corpo * MultiplicadorPavio)
                && (pavioInf <= corpo * MaxPavioOpostoCorpo);

   // Fundos/topos minimos/maximos nos ultimos LookbackDivergencia barras
   double lowMin = lowB1, ifrMinimo = fIFR;
   double highMax= highB1, ifrMaximo = fIFR;
   for(int k = 2; k <= LookbackDivergencia; k++)
   {
      double l = iLow(_Symbol, _Period, k);
      double h = iHigh(_Symbol, _Period, k);
      double r = GetIFR(k);
      if(l < lowMin)  { lowMin   = l; ifrMinimo = r; }
      if(h > highMax) { highMax  = h; ifrMaximo = r; }
   }

   bool bDivAlta  = (lowB1  < lowMin)  && (fIFR > ifrMinimo + DeltaIFRMinimo);
   bool bDivBaixa = (highB1 > highMax) && (fIFR < ifrMaximo - DeltaIFRMinimo);

   // ── SAIDAS ──────────────────────────────────────────────────
   if(TenhoCompra())
   {
      iBarrasPosicao++;
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(bid > fMelhorPreco) fMelhorPreco = bid;

      bool sair = false;
      if(UsarSaidaIFR   && fIFR >= NivelSaidaCompra)        sair = true;
      if(UsarSaidaTempo && iBarrasPosicao >= MaxBarrasPosicao) sair = true;
      if(UsarTrailing   && fMelhorPreco > 0 && bid < fMelhorPreco - PontosTrailing * _Point) sair = true;
      if(sair) trade.PositionClose(_Symbol);
   }

   if(TenhoVenda())
   {
      iBarrasPosicao++;
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(fMelhorPreco == 0 || ask < fMelhorPreco) fMelhorPreco = ask;

      bool sair = false;
      if(UsarSaidaIFR   && fIFR <= NivelSaidaVenda)           sair = true;
      if(UsarSaidaTempo && iBarrasPosicao >= MaxBarrasPosicao) sair = true;
      if(UsarTrailing   && fMelhorPreco > 0 && ask > fMelhorPreco + PontosTrailing * _Point) sair = true;
      if(sair) trade.PositionClose(_Symbol);
   }

   // ── ENTRADAS ────────────────────────────────────────────────
   if(!TenhoCompra() && !TenhoVenda())
   {
      iBarrasPosicao = 0;
      if(UsarGestaoRisco && (bBloqueioDia || bBloqueioSemana)) return;

      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      if(bDivAlta && bMartelo)
      {
         trade.Buy(VolumeLote, _Symbol, ask, 0, 0, "IFR_div_alta");
         fPrecoEntrada = ask; iDirecaoPosicao = 1; fMelhorPreco = ask;
      }
      else if(bDivBaixa && bEstrela)
      {
         trade.Sell(VolumeLote, _Symbol, bid, 0, 0, "IFR_div_baixa");
         fPrecoEntrada = bid; iDirecaoPosicao = -1; fMelhorPreco = bid;
      }
   }
}
