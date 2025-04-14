//+------------------------------------------------------------------+
//|                                         EA-WPREMAwithRecovery.mq4|
//+------------------------------------------------------------------+
input double MaxSpread = 33;
input int StartHour = 1, StartMinute = 0;
input int StopHour = 21, StopMinute = 0;
input int TargetPips = 10;
input double LotSize = 0.1;
input double LotMultiplier = 1.2;
input int GridDistance = 300; // jarak dalam pip, bukan point

double wpr, ema10, ema11;

//+------------------------------------------------------------------+
int OnInit() { return(INIT_SUCCEEDED); }
void OnDeinit(const int reason) {}
//+------------------------------------------------------------------+
void OnTick() {
    // Validasi waktu trading
    datetime now = TimeCurrent();
    if (TimeHour(now) < StartHour || (TimeHour(now) == StartHour && TimeMinute(now) < StartMinute)) return;
    if (TimeHour(now) > StopHour || (TimeHour(now) == StopHour && TimeMinute(now) > StopMinute)) return;

    // Validasi spread
    if (MarketInfo(Symbol(), MODE_SPREAD) > MaxSpread) return;

    // Hitung indikator
    wpr = iWPR(Symbol(), 0, 111, 0);
    ema10 = iMA(Symbol(), 0,10 , 0, MODE_EMA, PRICE_CLOSE, 0);
    ema11 = iMA(Symbol(), 0, 11, 0, MODE_EMA, PRICE_OPEN, 0);

    int total = GetOpenOrderCount();
    int direction = GetOpenDirection();

   // Entry awal jika tidak ada posisi terbuka
   if (total == 0) {
    double ema10_prev = iMA(Symbol(), 0, 10, 0, MODE_EMA, PRICE_CLOSE, 1);
    double ema11_prev = iMA(Symbol(), 0, 11, 0, MODE_EMA, PRICE_OPEN, 1);

       // EMA 3 cross ke atas EMA 5 dan WPR <= -100 → BUY
       if (wpr >= -100 && wpr < -90 && ema10_prev < ema11_prev && ema10 > ema11) {
           OpenOrder(OP_BUY, LotSize);
       } else
   
       // EMA 3 cross ke bawah EMA 5 dan WPR >= 0 → SELL
       if (wpr <= 0 && wpr > -10 && ema10_prev > ema11_prev && ema10 < ema11) {
           OpenOrder(OP_SELL, LotSize);
       }

    }
     else {
        // Ada posisi recovery
        double tpPrice = GetAverageTP();
        direction = GetOpenDirection();

        if ((direction == OP_BUY && Bid >= tpPrice) || (direction == OP_SELL && Ask <= tpPrice)) {
            CloseAllOrders();
            return;
        } else

        if (CanAddRecovery(GetOpenDirection())) {
            double newLot = GetLastLotSize() * LotMultiplier;
            OpenOrder(GetOpenDirection(), newLot, true); // pakai harga Open[0]
        }
    }
}

//+------------------------------------------------------------------+
//| Membuka Order                                                    |
//+------------------------------------------------------------------+
void OpenOrder(int orderType, double lot, bool useCandleOpen = false) {
    double price;

    if (useCandleOpen) {
        price = Open[0];  // Entry di harga open candle
    } else {
        price = (orderType == OP_BUY) ? Ask : Bid;  // Harga pasar
    }

    color clr = (orderType == OP_BUY) ? clrBlue : clrRed;
    int slippage = 30;

    int ticket = OrderSend(Symbol(), orderType, lot, price, slippage, 0, 0, "Grid Recovery", 0, 0, clr);

    if (ticket < 0) {
        Print("OrderSend error: ", GetLastError());
    } else {
        Print("Order opened. Ticket: ", ticket, " at price: ", price);
    }
}

//+------------------------------------------------------------------+
//| Tutup Semua Order                                                |
//+------------------------------------------------------------------+
void CloseAllOrders() {
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
            bool closed = false;
            if (OrderType() == OP_BUY)
                closed = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrWhite);
            if (OrderType() == OP_SELL)
                closed = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrWhite);

            if (!closed) {
                Print("Gagal menutup order. Ticket: ", OrderTicket(), " Error: ", GetLastError());
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Mendapatkan Jumlah Order                                         |
//+------------------------------------------------------------------+
int GetOpenOrderCount() {
    int count = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) count++;
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Arah Posisi Terbuka                                              |
//+------------------------------------------------------------------+
int GetOpenDirection() {
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
            return OrderType();
        }
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Hitung TP Rata-rata (Weighted Average TP)                        |
//+------------------------------------------------------------------+
double GetAverageTP() {
    double totalLots = 0;
    double weightedPrice = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                totalLots += OrderLots();
                weightedPrice += OrderOpenPrice() * OrderLots();
            }
        }
    }
    if (totalLots == 0) return 0;
    double avgPrice = weightedPrice / totalLots;
    double pip = (Digits == 3 || Digits == 5) ? 10 * Point : Point;
    return (GetOpenDirection() == OP_BUY) ? avgPrice + TargetPips * pip : avgPrice - TargetPips * pip;
}

//+------------------------------------------------------------------+
//| Lot posisi terakhir                                              |
//+------------------------------------------------------------------+
double GetLastLotSize() {
    double lastTime = 0;
    double lastLot = LotSize;
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
            if (OrderOpenTime() > lastTime) {
                lastTime = OrderOpenTime();
                lastLot = OrderLots();
            }
        }
    }
    return lastLot;
}

//+------------------------------------------------------------------+
//| Harga entry terakhir                                             |
//+------------------------------------------------------------------+
double GetLastEntryPrice() {
    double lastTime = 0;
    double lastPrice = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
            if (OrderOpenTime() > lastTime) {
                lastTime = OrderOpenTime();
                lastPrice = OrderOpenPrice();
            }
        }
    }
    return lastPrice;
}

//+------------------------------------------------------------------+
//| Logika validasi buka grid baru                                   |
//+------------------------------------------------------------------+
bool CanAddRecovery(int direction) {
    static datetime lastBarTime = 0;
    if (Time[0] == lastBarTime) return false;  // hanya satu posisi per candle

    double lastPrice = GetLastEntryPrice();
    double currentPrice = (direction == OP_BUY) ? Bid : Ask;
    double pipSize = (Digits == 3 || Digits == 5) ?  Point : Point;
    double minDistance = GridDistance * pipSize;

    if (direction == OP_BUY && currentPrice < (lastPrice - minDistance)) {
        lastBarTime = Time[0];
        return true;
    } else
    if (direction == OP_SELL && currentPrice > (lastPrice + minDistance)) {
        lastBarTime = Time[0];
        return true;
    }

    return false;
}
