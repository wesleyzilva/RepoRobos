//+------------------------------------------------------------------+
//|  mar_MED_02_NAS100.mq5                                          |
//|  Grupo: MEDIAS — Versao MT5                                     |
//|  Descricao: Score das 4 medias moveis. Conta quantas MMAs o    |
//|             preco esta acima ou abaixo. Score >= 3 = compra.   |
//|             Score <= -3 = venda. Alta seletividade e baixo     |
//|             ruido. Excelente para ativos tendenciais como       |
//|             NAS100, US500 e US30.                              |
//|  Ativo: NAS100 — tambem testavel em US500, US30               |
//|  Timeframe: H1 / H4                                           |
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

// ── As 4 medias ──────────────────────────────────────────────────
input int    PeriodoMME1         = 9;
input int    PeriodoMME2         = 21;
input int    PeriodoMMA3         = 50;
input int    PeriodoMMA4         = 200;

// ── Score de entrada/saida ────────────────────────────────────────
input int    ScoreEntradaCompra  = 3;    // minimo 3 medias abaixo do preco
input int    ScoreEntradaVenda   = -3;   // minimo 3 medias acima do preco
input int    ScoreSaidaCompra    = 1;    // sair quando score cai para 1
input int    ScoreSaidaVenda     = -1;

// ── Saida ─────────────────────────────────────────────────────────
input bool   UsarSaidaTempo      = true;
input int    MaxBarrasPosicao    = 20;
input bool   UsarTrailing        = true;
input double PontosTrailing      = 250.0;

// ── Gestao de risco ───────────────────────────────────────────────
input bool   UsarGestaoRisco     = true;
input bool   UsarHardLock        = true;
input double RiscoDiaPct         = 1.5;
input double RiscoSemanaPct      = 3.0;
input int    MaxStopsConsecutivos= 2;
input double VolumeLote          = 0.01;

//+------------------------------------------------------------------+
//| Variaveis globais                                                |
//+------------------------------------------------------------------+
int    hMME1, hMME2, hMMA3, hMMA4;
double fPrecoEntrada;
double fMelhorPreco;
int    iDirecaoPosicao;
int    iBarrasPosicao;
double fResultadoDia, fResultadoSemana;
int    iStopsConsec;
bool   bBloqueioDia, bBloqueioSemana;
datetime dtUltimoBar, dtUltimoReset;

int OnInit()
{
   hMME1 = iMA(_Symbol, _Period, PeriodoMME1, 0, MODE_EMA, PRICE_CLOSE);
   hMME2 = iMA(_Symbol, _Period, PeriodoMME2, 0, MODE_EMA, PRICE_CLOSE);
   hMMA3 = iMA(_Symbol, _Period, PeriodoMMA3, 0, MODE_SMA, PRICE_CLOSE);
   hMMA4 = iMA(_Symbol, _Period, PeriodoMMA4, 0, MODE_SMA, PRICE_CLOSE);
   if(hMME1==INVALID_HANDLE || hMME2==INVALID_HANDLE || hMMA3==INVALID_HANDLE || hMMA4==INVALID_HANDLE)
      return INIT_FAILED;
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(hMME1); IndicatorRelease(hMME2);
   IndicatorRelease(hMMA3); IndicatorRelease(hMMA4);
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
      fResultadoDia += resultado; fResultadoSemana += resultado;
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

   double closeB1 = iClose(_Symbol, _Period, 1);
   double mme1    = GetBuf(hMME1, 1);
   double mme2    = GetBuf(hMME2, 1);
   double mma3    = GetBuf(hMMA3, 1);
   double mma4    = GetBuf(hMMA4, 1);

   // Score: +1 preco acima da media, -1 abaixo
   int score = 0;
   if(closeB1 > mme1) score++; else score--;
   if(closeB1 > mme2) score++; else score--;
   if(closeB1 > mma3) score++; else score--;
   if(closeB1 > mma4) score++; else score--;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   // ── SAIDAS ──────────────────────────────────────────────────
   if(TenhoCompra())
   {
      iBarrasPosicao++;
      if(bid > fMelhorPreco) fMelhorPreco = bid;
      bool sair = false;
      if(score <= ScoreSaidaCompra)                             sair = true;
      if(UsarSaidaTempo && iBarrasPosicao >= MaxBarrasPosicao) sair = true;
      if(UsarTrailing   && bid < fMelhorPreco - PontosTrailing * _Point) sair = true;
      if(sair) trade.PositionClose(_Symbol);
   }

   if(TenhoVenda())
   {
      iBarrasPosicao++;
      if(fMelhorPreco == 0 || ask < fMelhorPreco) fMelhorPreco = ask;
      bool sair = false;
      if(score >= ScoreSaidaVenda)                              sair = true;
      if(UsarSaidaTempo && iBarrasPosicao >= MaxBarrasPosicao) sair = true;
      if(UsarTrailing   && ask > fMelhorPreco + PontosTrailing * _Point) sair = true;
      if(sair) trade.PositionClose(_Symbol);
   }

   // ── ENTRADAS ────────────────────────────────────────────────
   if(!TenhoCompra() && !TenhoVenda())
   {
      iBarrasPosicao = 0; fMelhorPreco = 0;
      if(UsarGestaoRisco && (bBloqueioDia || bBloqueioSemana)) return;

      if(score >= ScoreEntradaCompra)
      {
         trade.Buy(VolumeLote, _Symbol, ask, 0, 0, "MED_score_alta");
         fPrecoEntrada = ask; iDirecaoPosicao = 1; fMelhorPreco = ask;
      }
      else if(score <= ScoreEntradaVenda)
      {
         trade.Sell(VolumeLote, _Symbol, bid, 0, 0, "MED_score_baixa");
         fPrecoEntrada = bid; iDirecaoPosicao = -1; fMelhorPreco = bid;
      }
   }
}
