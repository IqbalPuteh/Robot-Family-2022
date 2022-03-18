//+------------------------------------------------------------------+
//|                                                  EA TRiple H.mq4 |
//|         Copyright 2021, IG:jasaeaforexmt4 | planntrade@gmail.com |
//|                                     https://www.planandtrade.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, IG:jasaeaforexmt4 | planntrade@gmail.com"
#property link      "https://www.planandtrade.com"
#property version   "5.10"
#property strict

input string EA_NAME="EA TRiple H";//EA Name
input int ExpertID=123456;//Expert ID
enum TradeBase
  {
   BUYSELL=0,//BUY & SELL
   Start_Buy=1,//Start BUY
   Start_Sell=2,//Start SELL
  };
TradeBase StartingTrades=0;//Starting Trades
input double Lot=0.01;//Starting Lot
input double Multiplier=2.5;//Multiplier Lot
bool InvisibleTP=false;//Hidden TP & SL
double Takeprofit=500;
input double TP_Averaging=0;//Takeprofit
input double Stoploss=0;
input double GridStep2=200;//Gridstep 1
input double GridStep22=300;//Gridstep 2
input int Max_Trades=3;//Max Trades
int slippage=100;
input bool CloseOnOpppositeSignal=true;//Close On Opposite Signal

input string Trailing_Setting="--------<Trailing Stop Parameters>--------";//:
input bool Trailing_ON=false;//Trailing Stop
input  double Trail_Start =250.0;//Trailing Start X Pip Profit
input double Trail_Stop =250.0;//Trailing Stoploss X Pip From Market Price
input double TrailingStep =100.0;//Move Every X Pip In Favour
input double Step = 75; //jarak dari pivot

enum LotType
  {
   TambahLot=0,//Lot Adder
   MultiplierLot=1,//Multiplier Lot
   ManualLot=2,//Manual Lot
  };
int Lot_Digits;
bool GridMartingale_ON=true;
string Choose_GridOrder_Lot = "----------<Lot Type>----------";//:
LotType Martingale_Lot =1;//Lot Type
double Lot_Adder= 0.01;//Lot Adder
double LotOrder2=0.01;//Manual Lot Order 2
double LotOrder3=0.02;//Manual Lot Order 3
double LotOrder4=0.04;//Manual Lot Order 4
double LotOrder5=0.08;//Manual Lot Order 5
double LotOrder6=0.16;//Manual Lot Order 6
double LotOrder7=0.32;//Manual Lot Order 7
double LotOrder8=0.64;//Manual Lot Order 8
double LotOrder9=1.28;//Manual Lot Order 9
double LotOrder10=2.56;//Manual Lot Order >=10
bool Manual_Distance=false;
double Grid_Step=100;
double Grid_Step_Buy;
double Grid_Step_Sell;

string Exit1="----------<Exit Base On Percentage Of Account Deposit >----------";//:
double AccountBalance2=1000;//Deposit Balance
bool CloseOnProfit=false;//Exit On Percentage Of Profit
int PercentageProfit=10;//Percentage Of Profit

bool CloseOnLoss=false;//Exit On Percentage Of Loss
int PercentageLoss=10;//Percentage Of Loss

string TradingTime= "--------<Trading Time Parameters>--------";//:
bool Filter_TradingTime=false;//Trading Time
string Time_Start= "00:00"; //Time Start
string Time_End= "23:59"; //Time End

string TL1="TL1";
string Stop1="Stop1";
string TL2="TL2";
string Stop2="Stop2";

//Variable tambahan yang tidak muncul di input parameter ea
int cnt,Select,Orderterbuka;
double TPB,TPS,SLB,SLS;
int OrdercloseBUY,OrdercloseSELL;
datetime Time_CloseBUY,Time_CloseSELL;
double TL1Line,Stop1Line,TL2Line,Stop2Line;

string CommentBuy="BuyOrders : ";
string CommentSell="SellOrders : ";
double SLB_PRICE,SLS_PRICE, Buy_Price,Sell_Price;;
int OrderBuy,OrderSell;
double TotalBuyLot,TotalSellLot,BuyLot,SellLot;
double TotalProfitBuy,TotalProfitSell, TotalProfitAll;;
double TPB_Price,TPS_Price;
int SendOrder;
double GridLot_Buy,GridLot_Sell;
double AvgBuy,AvgSell;
double BEP_BUY,TPB_ALL, BEP_SELL,TPS_ALL;
int Modify;
datetime Xtime,Ytime;
double TotalProfitBuyH,TotalProfitSellH,TotalProfitXY,TLO,TPO;
double WR,WRA, TPO2;
string CommentX,CommentY;

double SellLine;  // R1 Line Price
double BuyLine;   // S1 Line Price
double SellLine2; // R2 Line Price
double BuyLine2;  // S2 Line Price
double SellLine3; // R3 Line Price
double BuyLine3;  // S3 Line Price
double SellLine4; // R4 Line Price
double BuyLine4;  // S4 Line Price
double vPivotLine; // Pivot Line Price 


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+

//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   CleanUp();
   return;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   HideTestIndicators(True);

   double Spread,PipValue,MinLot,MaxLot;
   Spread =NormalizeDouble(MarketInfo(NULL,MODE_SPREAD),0);
   PipValue=NormalizeDouble(MarketInfo(NULL,MODE_TICKVALUE),2);

   MinLot=MarketInfo(NULL,MODE_MINLOT);
   MaxLot=MarketInfo(NULL,MODE_MAXLOT);

   if(MinLot<=0.01)
      Lot_Digits=2;
   if(MinLot==0.1)
      Lot_Digits=1;
   if(MinLot==1)
      Lot_Digits=0;



//-----------------------------------------------------------------------------------||
//Coding menghitung Close order yang terakhir.
   OrdercloseBUY=0;
   OrdercloseSELL=0;
   Time_CloseBUY=0;
   Time_CloseSELL=0;
   TotalProfitXY=0;
   for(cnt=0; cnt<OrdersHistoryTotal(); cnt++)
     {
      Select=OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID &&OrderType()<2)
           {
            TotalProfitXY+=(OrderProfit() +OrderCommission()+OrderSwap());
           }
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID && OrderType()==0)
           {
            OrdercloseBUY++;
            Time_CloseBUY=OrderCloseTime();
           }
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID && OrderType()==1)
           {
            OrdercloseSELL++;
            Time_CloseSELL=OrderCloseTime();
           }
        }
     }
//-----------------------------------------------------------------------------------||



//-----------------------------------------------------------------------------------||
//Coding menghitung Open order yang terbuka.
   Orderterbuka=0;
   OrderBuy=0;
   OrderSell=0;
   TotalBuyLot=0;
   TotalSellLot=0;
   TotalProfitBuy=0;
   TotalProfitSell=0;
   TotalProfitAll=0;
   AvgBuy=0;
   AvgSell=0;
   Xtime=0;
   Ytime=0;

   for(cnt=0; cnt<OrdersTotal(); cnt++)
     {
      Select=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID && OrderType()<2)
           {
            Orderterbuka++;
            TotalProfitAll+=(OrderProfit() +OrderCommission()+OrderSwap());
           }
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID && OrderType()==0)
           {
            Buy_Price=OrderOpenPrice();
            OrderBuy++;
            BuyLot=OrderLots();// ini hanya untuk order terakhir
            TotalBuyLot+=OrderLots();
            SLB_PRICE=OrderStopLoss();
            TPB_Price=OrderTakeProfit();
            TotalProfitBuy+=(OrderProfit() +OrderCommission()+OrderSwap());
            AvgBuy= NormalizeDouble(TotalProfitBuy/TotalBuyLot/PipValue,Digits);
            Xtime=OrderOpenTime();
            CommentX=OrderComment();
           }

         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID && OrderType()==1)
           {
            Sell_Price=OrderOpenPrice();
            OrderSell++;
            SellLot=OrderLots();// ini hanya untuk order terakhir
            TotalSellLot+=OrderLots();
            SLS_PRICE=OrderStopLoss();
            TPS_Price=OrderTakeProfit();
            TotalProfitSell+=(OrderProfit() +OrderCommission()+OrderSwap());
            AvgSell= NormalizeDouble(TotalProfitSell/TotalSellLot/PipValue,Digits);
            Ytime=OrderOpenTime();
            CommentY=OrderComment();
           }
        }
     }
//-----------------------------------------------------------------------------------||



   BuyLine = NormalizeDouble(ObjectGet("H4_S1_Line",OBJPROP_PRICE1),Digits);
   SellLine = NormalizeDouble(ObjectGet("H4_R1_Line",OBJPROP_PRICE1),Digits);
   BuyLine2 = NormalizeDouble(ObjectGet("H4_S2_Line",OBJPROP_PRICE1),Digits);
   SellLine2 = NormalizeDouble(ObjectGet("H4_R2_Line",OBJPROP_PRICE1),Digits);
   BuyLine3 = NormalizeDouble(ObjectGet("H4_S2_Line",OBJPROP_PRICE1),Digits);
   SellLine3 = NormalizeDouble(ObjectGet("H4_R2_Line",OBJPROP_PRICE1),Digits);
   BuyLine4 = NormalizeDouble(ObjectGet("H4_S2_Line",OBJPROP_PRICE1),Digits);
   SellLine4 = NormalizeDouble(ObjectGet("H4_R2_Line",OBJPROP_PRICE1),Digits);
   vPivotLine = NormalizeDouble(ObjectGet("H4PivotLine",OBJPROP_PRICE1),Digits);

   TL1Line = NormalizeDouble(ObjectGet(TL1,OBJPROP_PRICE1),Digits);
   Stop1Line = NormalizeDouble(ObjectGet(Stop1,OBJPROP_PRICE1),Digits);
   TL2Line = NormalizeDouble(ObjectGet(TL2,OBJPROP_PRICE1),Digits);
   Stop2Line = NormalizeDouble(ObjectGet(Stop2,OBJPROP_PRICE1),Digits);

   double NETPL,PLPecentage;
   NETPL=NormalizeDouble(TotalProfitXY+TotalProfitAll,2);
//AccountBalance2=NormalizeDouble((AccountEquity()-(TotalProfitXY+TotalProfitAll)),0);

   PLPecentage=NormalizeDouble((NETPL/AccountBalance2)*100,2);



   if(InvisibleTP==false)
     {
      if(TP_Averaging>0 && TP_Averaging>=MarketInfo(NULL,MODE_STOPLEVEL))
        {
         TPB=NormalizeDouble(Ask+TP_Averaging*Point,Digits);
         TPS=NormalizeDouble(Bid-TP_Averaging*Point,Digits);
        }
      if(TP_Averaging<MarketInfo(NULL,MODE_STOPLEVEL))
        {TPB=0;  TPS=0; }
     }

   if(InvisibleTP==true)
     {TPB=0;  TPS=0; }



   if(InvisibleTP==false)
     {
      //Stoploss Buy kita beri nama variable SLB
      //Stoploss SELL kita beri nama variable SLS
      if(Stoploss>0 && Stoploss>=MarketInfo(NULL,MODE_STOPLEVEL))
        {
         SLB=NormalizeDouble(Ask-Stoploss*Point,Digits);
         SLS=NormalizeDouble(Bid+Stoploss*Point,Digits);
        }
      if(Stoploss<MarketInfo(NULL,MODE_STOPLEVEL))
        {SLB=0;  SLS=0; }
     }

   if(InvisibleTP==true)
     {SLB=0;  SLS=0; }



//-----------------------------------------------------------------------------------------||
//Codes of Open Buyorder
//Logika BUY Candle, Jika Close Candle sebelumnya diatas Open, Maka BUY
   if(StartingTrades==0)//Start With Buy and SELL
     {
      if(Orderterbuka==0 && GF_X() && GF_X2() && Stop_BUY())
        {
         //Coding Mengirim Open order BUY
         int Ord_Send=OrderSend(Symbol(),0,Lot,Ask,slippage,SLB,0,EA_NAME,ExpertID,0,clrLime);
        }
      //-----------------------------------------------------------------------------------------||
      //Codes of Open Sellorder
      //Logika SELL Candle, Jika Close Candle sebelumnya dibawah Open, Maka BUY
      if(Orderterbuka==0 && GF_Y() && GF_Y2() && Stop_SELL())
        {
         //Coding Mengirim Open order SELL
         int Ord_Send=OrderSend(Symbol(),1,Lot,Bid,slippage,SLS,0,EA_NAME,ExpertID,0,clrRed);
        }
     }
//-----------------------------------------------------------------------------------------||



//-----------------------------------------------------------------------------------------||
//Codes of Open Buyorder
//Logika BUY Candle, Jika Close Candle sebelumnya diatas Open, Maka BUY
   if(StartingTrades==1)//Start With Buy
     {
      if(Orderterbuka==0)
        {
         //Coding Mengirim Open order BUY
         int Ord_Send=OrderSend(Symbol(),0,Lot,Ask,slippage,SLB,TPB,"BUY",ExpertID,0,clrLime);
        }
     }
//-----------------------------------------------------------------------------------------||



//-----------------------------------------------------------------------------------------||
//Codes of Open Sellorder
//Logika SELL Candle, Jika Close Candle sebelumnya dibawah Open, Maka BUY
   if(StartingTrades==2)////Start With SELL
     {
      if(Orderterbuka==0)
        {
         //Coding Mengirim Open order SELL
         int Ord_Send=OrderSend(Symbol(),1,Lot,Bid,slippage,SLS,TPS,"SELL",ExpertID,0,clrRed);
        }
     }
//-----------------------------------------------------------------------------------------||



//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
   if(Martingale_Lot==0) //Tambah Lot
     {

      if(OrderSell>0)
        {
         GridLot_Sell= NormalizeDouble(SellLot+Lot_Adder,Lot_Digits);
        }
      if(OrderBuy>0)
        {
         GridLot_Buy= NormalizeDouble(BuyLot+Lot_Adder,Lot_Digits);
        }

     }
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
   if(Martingale_Lot==1) ///Perkalian Lot
     {

      if(OrderSell>0)
        {
         GridLot_Sell= NormalizeDouble(SellLot*Multiplier,Lot_Digits);
        }
      if(OrderBuy>0)
        {
         GridLot_Buy= NormalizeDouble(BuyLot*Multiplier,Lot_Digits);
        }

     }
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||



//----------------------------------------------------------------------------------------||
   if(Martingale_Lot==2) ///Manual Lot
     {

      if(OrderSell==1)
        {GridLot_Sell= NormalizeDouble(LotOrder2,Lot_Digits);}
      if(OrderSell==2)
        {GridLot_Sell= NormalizeDouble(LotOrder3,Lot_Digits);}
      if(OrderSell==3)
        {GridLot_Sell= NormalizeDouble(LotOrder4,Lot_Digits);}
      if(OrderSell==4)
        {GridLot_Sell= NormalizeDouble(LotOrder5,Lot_Digits);}
      if(OrderSell==5)
        {GridLot_Sell= NormalizeDouble(LotOrder6,Lot_Digits);}
      if(OrderSell==6)
        {GridLot_Sell= NormalizeDouble(LotOrder7,Lot_Digits);}
      if(OrderSell==7)
        {GridLot_Sell= NormalizeDouble(LotOrder8,Lot_Digits);}
      if(OrderSell==8)
        {GridLot_Sell= NormalizeDouble(LotOrder9,Lot_Digits);}
      if(OrderSell>=9)
        {GridLot_Sell= NormalizeDouble(LotOrder10,Lot_Digits);}

      if(OrderBuy==1)
        {GridLot_Buy= NormalizeDouble(LotOrder2,Lot_Digits);}
      if(OrderBuy==2)
        {GridLot_Buy= NormalizeDouble(LotOrder3,Lot_Digits);}
      if(OrderBuy==3)
        {GridLot_Buy= NormalizeDouble(LotOrder4,Lot_Digits);}
      if(OrderBuy==4)
        {GridLot_Buy= NormalizeDouble(LotOrder5,Lot_Digits);}
      if(OrderBuy==5)
        {GridLot_Buy= NormalizeDouble(LotOrder6,Lot_Digits);}
      if(OrderBuy==6)
        {GridLot_Buy= NormalizeDouble(LotOrder7,Lot_Digits);}
      if(OrderBuy==7)
        {GridLot_Buy= NormalizeDouble(LotOrder8,Lot_Digits);}
      if(OrderBuy==8)
        {GridLot_Buy= NormalizeDouble(LotOrder9,Lot_Digits);}
      if(OrderBuy>=9)
        {GridLot_Buy= NormalizeDouble(LotOrder10,Lot_Digits);}

     }
//----------------------------------------------------------------------------------------||



//----------------------------------------------------------------------------------------||
   if(Manual_Distance==true) ///Manual Step
     {

      if(OrderSell==1)
        { Grid_Step_Sell=GridStep2;}

      if(OrderBuy==1)
        { Grid_Step_Buy=GridStep2;}

     }
//----------------------------------------------------------------------------------------||
   if(Manual_Distance==false)
     {
      if(OrderSell==1)
        { Grid_Step_Sell=GridStep2;}
      if(OrderSell>1)
        { Grid_Step_Sell=GridStep22;}

      if(OrderBuy==1)
        { Grid_Step_Buy=GridStep2;}
      if(OrderBuy>1)
        { Grid_Step_Buy=GridStep22;}
     }
//----------------------------------------------------------------------------------------||



//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
   if(GridMartingale_ON) // Untuk order berikutnya
     {
      if(OrderBuy>0 && X_Distance() && OrderBuy<Max_Trades)
        {
         SendOrder=OrderSend(Symbol(),OP_BUY,GridLot_Buy,Ask,slippage,SLB,0
                             ,EA_NAME,ExpertID,0,clrLime);
        }

      if(OrderSell>0 && Y_Distance() && OrderSell<Max_Trades)
        {
         SendOrder=OrderSend(Symbol(),OP_SELL,GridLot_Sell,Bid,slippage,SLS,0
                             ,EA_NAME,ExpertID,0,clrRed);
        }
     }
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||



//-----------------------------------------------------------------------------------------||
//Codes of CloseOrder
   if(CloseOnOpppositeSignal)
     {
      for(cnt=OrdersTotal()-1; cnt>=0; cnt--)
        {
         Select= OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID)
           {
            if(OrderType()==OP_BUY && Orderterbuka>0 && GF_Y3())   //Coding Close BUYOrder
              {
               int Close_Order=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrYellow);
              }


            if(OrderType()==OP_SELL && Orderterbuka>0 && GF_X3())  // Coding Close SellOrder
              {
               int Close_Order=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrYellow);
              }
           }
        }
     }
//----------------------------------------------------------------------------------------||



//----------------------------------------------------------------------------------------||
   if(InvisibleTP==true && Stoploss>0)
     {
      for(cnt=OrdersTotal()-1; cnt>=0; cnt--)
        {
         Select= OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID)
           {

            if(OrderType()==OP_BUY &&  Bid<=NormalizeDouble(OrderOpenPrice()-Stoploss*Point,Digits))
              { CloseOrder=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrYellow); }

            if(OrderType()==OP_SELL &&  Ask>=NormalizeDouble(OrderOpenPrice()+Stoploss*Point,Digits))
              { CloseOrder=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrRed); }


           }
        }
     }
//----------------------------------------------------------------------------------------||



   if(InvisibleTP==true)
     {
      if(OrderBuy==1 && TP_Averaging>0)
        {
         if(Bid>= NormalizeDouble(Buy_Price+ TP_Averaging*Point,Digits)&& TotalProfitBuy>0)
           {CloseALLBUY();}
        }

      if(OrderBuy>1 && TP_Averaging>0)
        {
         if(Bid>= NormalizeDouble((BEP_BUY+(TP_Averaging*Point)),Digits)&& TotalProfitBuy>0)
           {CloseALLBUY();}
        }

      if(OrderSell==1 && TP_Averaging>0)
        {
         if(Ask<= NormalizeDouble(Sell_Price - TP_Averaging*Point,Digits) && TotalProfitSell>0)
           {CloseALLSELL();}
        }

      if(OrderSell>1 && TP_Averaging>0)
        {
         if(Ask<= NormalizeDouble((BEP_SELL - (TP_Averaging*Point)),Digits) && TotalProfitSell>0)
           {CloseALLSELL();}
        }
     }


   /*
   //KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
   if(TP_Averaging>0 && InvisibleTP==false)
      {
       for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
        {
        Select=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==ExpertID)
           {
               if(OrderType()==OP_SELL && OrderSell>1 && TPS_Price==0  )
               {
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),
                        NormalizeDouble( ( Sell_Price-(TP_Averaging*Point)),Digits) ,0,clrYellow);
               }

               if(OrderType()==OP_BUY && OrderBuy>1  && TPB_Price==0 )
               {

               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),
                      NormalizeDouble( (Buy_Price+(TP_Averaging*Point)),Digits),0,clrYellow);
               }
           }
       }
    }
   //KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
   */



//----------------------------------------------------------------------------------------||
   if(OrderBuy>0)
     {
      BEP_BUY= NormalizeDouble((Bid-AvgBuy*Point),Digits);
      TPB_ALL=NormalizeDouble((BEP_BUY+(TP_Averaging*Point)),Digits);
     }

   if(OrderSell>0)
     {
      BEP_SELL= NormalizeDouble((Ask+AvgSell*Point),Digits);
      TPS_ALL=NormalizeDouble((BEP_SELL-(TP_Averaging*Point)),Digits);
     }
//----------------------------------------------------------------------------------------||



//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
   if(TP_Averaging>0 && InvisibleTP==false)
     {
      for(cnt=OrdersTotal()-1; cnt>=0; cnt--)
        {
         Select=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==ExpertID)
           {
            if(OrderType()==OP_SELL && OrderSell>0 && TPS_Price==0)
              {
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),
                                  NormalizeDouble((BEP_SELL - (TP_Averaging*Point)),Digits),0,clrYellow);
              }

            if(OrderType()==OP_BUY && OrderBuy>0 && TPB_Price==0)
              {

               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),
                                  NormalizeDouble((BEP_BUY+(TP_Averaging*Point)),Digits),0,clrYellow);
              }
           }
        }
     }
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||



   /*
   if( Volume[0]<=50 )
   { RefreshRates(); }

   if(ProfitTarget>0 && TotalProfitAll>ProfitTarget)
    {CloseALL();}

   if(LossTarget>0 && TotalProfitAll<-LossTarget)
    {CloseALL();}

   if(ProfitTargetBuy>0 && TotalProfitBuy>ProfitTargetBuy)
    {CloseALLBUY();}

   if(ProfitTargetSell>0 && TotalProfitSell>ProfitTargetSell)
    {CloseALLSELL();}
   */



   int  Ord_Modif;
   double TSP2;
   TSP2=(Trail_Stop+TrailingStep);

//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM||
   if(Trailing_ON==true && OrderBuy>0)
     {
      for(cnt=OrdersTotal()-1; cnt>=0; cnt--)
        {
         Select=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID)
           {
            if(OrderType()==OP_BUY && TotalProfitBuy>0)
              {
               if(Trail_Start>0)
                 {
                  //if(Bid>=NormalizeDouble(BEP_BUY+Trail_Start*Point,Digits))
                  if(Bid>=NormalizeDouble(vPivotLine+Point*Step,Digits))
                    {
                     if(((Bid-OrderStopLoss())/Point >TSP2) || (OrderStopLoss()==0))
                       {
                        //Ord_Modif=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-(Point*Trail_Stop),Digits),OrderTakeProfit(),0,clrLime);
                        Ord_Modif=OrderModify(OrderTicket(),OrderOpenPrice(),
                                               NormalizeDouble(vPivotLine,Digits),OrderTakeProfit(),0,clrLime);
                       }
                    }
                 }
              }


           }
        }
     }
   if(Trailing_ON==true && OrderSell>0)
     {
      for(cnt=OrdersTotal()-1; cnt>=0; cnt--)
        {
         Select=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID)
           {
            if(OrderType()==OP_SELL && TotalProfitSell>0)
              {
               if(Trail_Start>0)
                 {
                  //if(Ask<=NormalizeDouble(BEP_SELL-Trail_Start*Point,Digits))
                  if(Ask<=NormalizeDouble(vPivotLine+Point*Step,Digits))
                    {
                     if(((OrderStopLoss()-Ask)/Point >TSP2) || (OrderStopLoss()==0))
                       {
                        //Ord_Modif=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Trail_Stop*Point,Digits),OrderTakeProfit(),0,Red);
                        Ord_Modif=OrderModify(OrderTicket(),OrderOpenPrice(),
                                               NormalizeDouble(vPivotLine,Digits),OrderTakeProfit(),0,clrLime);
                       }
                    }
                 }
              }

           }
        }
     }
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM||



   bool showtext=true;
   if(showtext==true)
     {
      //----------------------------------------------------------------------------------------||
      string_window("EA_NAME", 5, 30, 0);  //X,Y
      ObjectSetText("EA_NAME",EA_NAME, 16, "Impact", clrSkyBlue);
      ObjectSet("EA_NAME", OBJPROP_CORNER, 3);  //Corner

      /*
      string_window( "By", 5, 50, 0); //X,Y
      ObjectSetText( "By","Created by www.planandtrade.com", 10, "Impact", clrSkyBlue);
      ObjectSet( "By", OBJPROP_CORNER, 3);  //Corner

      string_window( "By2", 5, 30, 0); //X,Y
      ObjectSetText( "By2","Education | Research | Service & Store Of Forex Algo Trading", 10, "Impact", clrSkyBlue);
      ObjectSet( "By2", OBJPROP_CORNER, 3);  //Corner
      */

      string_window("ACN", 5, 30, 0);  //X,Y
      ObjectSetText("ACN","Account Number : " +DoubleToStr(AccountNumber(),0), 12, "Cambria", clrWhite);
      ObjectSet("ACN", OBJPROP_CORNER, 1);   //Corner

      string_window("BUY", 5, 60, 0);  //X,Y
      ObjectSetText("BUY","BUY Order : " +DoubleToStr(OrderBuy,0), 10, "Cambria", clrLime);
      ObjectSet("BUY", OBJPROP_CORNER, 1);   //Corner

      string_window("BUY2", 5, 80, 0);  //X,Y
      ObjectSetText("BUY2","BUY Profit : " +DoubleToStr(TotalProfitBuy,2), 10, "Cambria", clrLime);
      ObjectSet("BUY2", OBJPROP_CORNER, 1);   //Corner

      string_window("BUY3", 5, 100, 0);  //X,Y
      ObjectSetText("BUY3","Total BUY Lot : " +DoubleToStr(TotalBuyLot,Lot_Digits), 10, "Cambria", clrLime);
      ObjectSet("BUY3", OBJPROP_CORNER, 1);   //Corner

      string_window("SELL", 5, 120+20, 0);   //X,Y
      ObjectSetText("SELL","SELL Order : " +DoubleToStr(OrderSell,0), 10, "Cambria", clrRed);
      ObjectSet("SELL", OBJPROP_CORNER, 1);   //Corner

      string_window("SELL2", 5, 140+20, 0);  //X,Y
      ObjectSetText("SELL2","SELL Profit : " +DoubleToStr(TotalProfitSell,2), 10, "Cambria", clrRed);
      ObjectSet("SELL2", OBJPROP_CORNER, 1);   //Corner

      string_window("SELL3", 5, 160+20, 0);  //X,Y
      ObjectSetText("SELL3","Total SELL Lot : " +DoubleToStr(TotalSellLot,Lot_Digits), 10, "Cambria", clrRed);
      ObjectSet("SELL3", OBJPROP_CORNER, 1);   //Corner

      string_window("PROFIT1", 5, 180+40, 0);  //X,Y
      ObjectSetText("PROFIT1","Total Profit BUY & SELL : " +DoubleToStr(TotalProfitAll,Lot_Digits), 10, "Cambria", clrYellow);
      ObjectSet("PROFIT1", OBJPROP_CORNER, 1);   //Corner

      string_window("BALANCE1", 5, 200+60, 0);  //X,Y
      ObjectSetText("BALANCE1","Account Balance : " +DoubleToStr(AccountBalance(),0), 12, "Cambria", clrWhite);
      ObjectSet("BALANCE1", OBJPROP_CORNER, 1);   //Corner

      string_window("EQUITY1", 5, 220+60, 0);  //X,Y
      ObjectSetText("EQUITY1","Account Equity : " +DoubleToStr(AccountEquity(),0), 12, "Cambria", clrWhite);
      ObjectSet("EQUITY1", OBJPROP_CORNER, 1);   //Corner
     }
//----------------------------------------------------------------------------------------||



//----------------------------------------------------------------------------------------||
//EA telah selesai dan siap di backtest
   return;
  }
//+------------------------------------------------------------------+



//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
void CleanUp()
  {
   ObjectDelete("EA_NAME");
   ObjectDelete("By");
   ObjectDelete("By2");
   ObjectDelete("ACN");
   ObjectDelete("BUY");
   ObjectDelete("BUY2");
   ObjectDelete("BUY3");
   ObjectDelete("BUY4");
   ObjectDelete("SELL");
   ObjectDelete("SELL2");
   ObjectDelete("SELL3");
   ObjectDelete("PROFIT1");
   ObjectDelete("BALANCE1");
   ObjectDelete("EQUITY1");
  }
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
int string_window(string n, int xoff, int yoff, int WindowToUse)
  {
   ObjectCreate(n, OBJ_LABEL, WindowToUse, 0, 0);
//ObjectSet( n, OBJPROP_CORNER, 1 );
   ObjectSet(n, OBJPROP_XDISTANCE, xoff);
   ObjectSet(n, OBJPROP_YDISTANCE, yoff);
   ObjectSet(n, OBJPROP_BACK, true);
   return (0);
  }
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||



//----------------------------------------------------------------------------------------||
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
bool Filter_OrderDistance=true;
bool X_Distance()
  {
   if(Filter_OrderDistance)
     {
      if(Ask <=Buy_Price-Grid_Step_Buy*Point)
         return true;
      else
         return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Y_Distance()
  {
   if(Filter_OrderDistance)
     {
      if(Bid >=Sell_Price+Grid_Step_Sell*Point)
         return true;
      else
         return false;
     }
   return true;
  }
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
//----------------------------------------------------------------------------------------||



//----------------------------------------------------------------------------------------||
//Coding Filter StopBuy Order
bool FilterStopOrder=true;
ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
bool Stop_BUY()
  {
   if(FilterStopOrder)
     {
      if(iTime(NULL,timeframe,0)- Time_CloseBUY>0)
         return true;
      else
         return false;
     }
   return true;
  }
//----------------------------------------------------------------------------------------||
//----------------------------------------------------------------------------------------||
//Coding Filter StopSell Order
bool Stop_SELL()
  {
   if(FilterStopOrder)
     {
      if(iTime(NULL,timeframe,0)-Time_CloseSELL>0)
         return true;
      else
         return false;
     }
   return true;
  }
//----------------------------------------------------------------------------------------||



//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||
bool Filter_OneOrderOneBar=true;
bool X_time()
  {
   if(Filter_OneOrderOneBar)
     {
      if(Time[0]-Xtime>0)

         return true;
      else
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Y_time()
  {
   if(Filter_OneOrderOneBar)
     {
      if(Time[0]-Ytime>0)
         return true;
      else
         return false;
     }
   return true;
  }
//KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK||



//----------------------------------------------------------------------------------------||
string Time_Serv;
bool Filter_Time()
  {
   if(Filter_TradingTime)
     {
      Time_Serv=TimeToStr(TimeCurrent(),TIME_MINUTES|TIME_SECONDS);
      if(Time_Serv>=Time_Start && Time_Serv<=Time_End)
        {return true; }
      else
        {
         return false;
        }
     }
   return true;
  }
//----------------------------------------------------------------------------------------||



//----------------------------------------------------------------------------------------||
string MoneyManagement="----------<TP & SL $ Base Amount>----------";//:
double ProfitTarget=0;
double LossTarget=0;
//----------------------------------------------------------------------------------------||
//Script CloseALL Trades
int CloseOrder;
void CloseALL()
  {
   for(cnt=OrdersTotal()-1; cnt>=0; cnt--)
     {
      Select= OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID)
        {
         if(OrderType()==OP_BUY && OrderBuy>0)
           { CloseOrder=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrBlue); }
         if(OrderType()==OP_SELL &&  OrderSell>0)
           { CloseOrder=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrRed); }
        }
     }
  }
//----------------------------------------------------------------------------------------||
//----------------------------------------------------------------------------------------||
//Script CloseALL BUY Trades
//int CloseOrder;
double ProfitTargetBuy=0;
void CloseALLBUY()
  {
   for(cnt=OrdersTotal()-1; cnt>=0; cnt--)
     {
      Select= OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID)
        {
         if(OrderType()==OP_BUY && OrderBuy>0)
           { CloseOrder=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrBlue); }
        }
     }
  }
//----------------------------------------------------------------------------------------||
//----------------------------------------------------------------------------------------||
//Script CloseALL SELL Trades
//int CloseOrder;
double ProfitTargetSell=0;
void CloseALLSELL()
  {
   for(cnt=OrdersTotal()-1; cnt>=0; cnt--)
     {
      Select= OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber() == ExpertID)
        {
         if(OrderType()==OP_SELL &&  OrderSell>0)
           { CloseOrder=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrRed); }
        }
     }
  }
//----------------------------------------------------------------------------------------||
string MoneyManagement111="---------------------------------------------------------------------------------------------------------------------------------------";//:
string MoneyManagement222="www.planandtrade.com - Education | Research | Service & Store Of Forex Algorithm Trading";//Created by instagram:jasaeaforexmt4
string MoneyManagement333="---------------------------------------------------------------------------------------------------------------------------------------";//:



//----------------------------------------------------------------------------------------||
input string StringTMA="-----------<ForexTripleHit_Fixed  Parameters>-----------";//:
input bool TMA=true;//ForexTripleHit_Fixed Filter ON

input int T1=0;//InformerPosition
//---input bool T2=true;//Line
//---input bool T3=true;//ArrowSig
//---input bool T4=false;//Levels
//---input color T5=clrWhite;//TextColor
//---input color T6=clrKhaki;//LevelsColor
//---input color T7=clrDeepSkyBlue;//BuyColor
//---input color T8=clrGold;//SellColor
//---input int T9=0;//AlertMode
//---input bool T10=true;//Alerts
//---input bool T11=false;//EmailAlert
//---input bool T12=false;//Notification
//---input int T13=300;//TakeProfitM15
//---input int T14=150;//StopLossM15
//---input int T15=400;//TakeProfitM30
//---input int T16=200;//StopLossM30
//---input int T17=800;//TakeProfitH1
//---input int T18=400;//StopLossH1

bool T2=true;//Line
bool T3=true;//ArrowSig
bool T4=false;//Levels
color T5=clrWhite;//TextColor
color T6=clrKhaki;//LevelsColor
color T7=clrDeepSkyBlue;//BuyColor
color T8=clrGold;//SellColor
int T9=0;//AlertMode
bool T10=true;//Alerts
bool T11=false;//EmailAlert
bool T12=false;//Notification
int T13=300;//TakeProfitM15
int T14=150;//StopLossM15
int T15=400;//TakeProfitM30
int T16=200;//StopLossM30
int T17=800;//TakeProfitH1
int T18=400;//StopLossH1



string ITMA="ForexTripleHit_Fixed";
ENUM_TIMEFRAMES TFTMA=PERIOD_CURRENT;//ForexTripleHit_Fixed Timeframe
double TMAB1,TMAB2,TMAB3,TMAB4,TMAB5;
double TMAS1,TMAS2,TMAS3,TMAS4,TMAS5;

double TMAB1New,TMAB2New;
double TMAS1New,TMAS2New;
//----------------------------------------------------------------------------------------||
bool GF_X()
  {

   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,1)>2000000)
     {TMAB1=0;}
   else
     {
      TMAB1=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,1)>2000000)
     {TMAS1=0;}
   else
     {
      TMAS1=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,2)>2000000)
     {TMAB2=0;}
   else
     {
      TMAB2=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,2);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,2)>2000000)
     {TMAS2=0;}
   else
     {
      TMAS2=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,2);
     }

   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,6,1)>2000000)
     {TMAB1New=0;}
   else
     {
      TMAB1New=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,6,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,7,1)>2000000)
     {TMAS1New=0;}
   else
     {
      TMAS1New=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,7,1);
     }

   if(TMA)
     {
      if(TMAB1>0)
         return true;
      else
         return false;
     }
   return true;
  }
//----------------------------------------------------------------------------------------||
//----------------------------------------------------------------------------------------||
bool GF_Y()
  {

   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,1)>2000000)
     {TMAB1=0;}
   else
     {
      TMAB1=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,1)>2000000)
     {TMAS1=0;}
   else
     {
      TMAS1=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,2)>2000000)
     {TMAB2=0;}
   else
     {
      TMAB2=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,2);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,2)>2000000)
     {TMAS2=0;}
   else
     {
      TMAS2=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,2);
     }

   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,6,1)>2000000)
     {TMAB1New=0;}
   else
     {
      TMAB1New=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,6,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,7,1)>2000000)
     {TMAS1New=0;}
   else
     {
      TMAS1New=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,7,1);
     }

   if(TMA)
     {
      if(TMAS1<0)
         return true;
      else
         return false;
     }
   return true;
  }
//----------------------------------------------------------------------------------------||



//----------------------------------------------------------------------------------------||
bool GF_X3()
  {

   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,1)>2000000)
     {TMAB1=0;}
   else
     {
      TMAB1=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,1)>2000000)
     {TMAS1=0;}
   else
     {
      TMAS1=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,2)>2000000)
     {TMAB2=0;}
   else
     {
      TMAB2=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,2);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,2)>2000000)
     {TMAS2=0;}
   else
     {
      TMAS2=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,2);
     }

   if(CloseOnOpppositeSignal)
     {
      if(TMAB1>0 && TMAS2<0)
         return true;
      else
         return false;
     }
   return true;
  }
//----------------------------------------------------------------------------------------||
//----------------------------------------------------------------------------------------||
bool GF_Y3()
  {

   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,1)>2000000)
     {TMAB1=0;}
   else
     {
      TMAB1=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,1)>2000000)
     {TMAS1=0;}
   else
     {
      TMAS1=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,1);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,2)>2000000)
     {TMAB2=0;}
   else
     {
      TMAB2=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,2,2);
     }
   if(iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,2)>2000000)
     {TMAS2=0;}
   else
     {
      TMAS2=iCustom(NULL,TFTMA,ITMA,T1,T2,T3,T4,T5,T6,T7,T8,T9,T10,T11,T12,T13,T14,T15,T16,T17,T18,3,2);
     }

   if(CloseOnOpppositeSignal)
     {
      if(TMAS1<0 && TMAB2>0)
         return true;
      else
         return false;
     }
   return true;
  }
//----------------------------------------------------------------------------------------||



//----------------------------------------------------------------------------------------||
input string Arrow="-----------<Auto Pivot 4H HLO Parameters>-----------";//:
input bool YMSScalperv12_fix=true;//Auto Pivot 4H HLO Filter ON
string Indicator2="Auto Pivot 4H HLO";
ENUM_TIMEFRAMES YMSScalperTimeframe=0;//Auto Pivot 4H HLO Timeframe

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GF_X2()
  {

   if(YMSScalperv12_fix)
     {
      if(Bid<BuyLine && Bid>BuyLine2)
         return true;
      else
         return false;
     }
   return true;
  }
//----------------------------------------------------------------------------------------||
//----------------------------------------------------------------------------------------||
bool GF_Y2()
  {

   if(YMSScalperv12_fix)
     {
      if(Ask>SellLine && Ask<SellLine2)
         return true;
      else
         return false;
     }
   return true;
  }
//----------------------------------------------------------------------------------------||
//+------------------------------------------------------------------+
