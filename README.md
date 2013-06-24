matlab-yahoo-finance
====================

Utility functions in Matlab to retrieve and managed Yahoo! Finance data

Yahoo!Finance let to download historical stock prices (included dividends & splits) at finance.yahoo.com.
Instead of parse data from HTML pages, it's possible to do a smart download directly from ichart.finance.yahoo.com/table.csv?
It returns all data in CSV-format quickly parsable inside Matlab without the physical CSV file.

The code uses java.io.BufferedReader class to reads text from a character-input stream (CSV file) in a faster way.

The output is a structure or arrat of structures with fields: Ticker, Date, Open(O), High(H), Low(L), Close(C), Volume, Frequency.
OHLC are already asjusted for dividends/splits. Frequency is timeframe: d/w/m (daily,weekly,monthly)

The functions supports multi-ticker input requests.


