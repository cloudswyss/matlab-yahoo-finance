function S = HistDataYahoo(symList,sDate,eDate,freq,dateFmt)
%HistDataYahoo - retrieve historical data from Yahoo! Finance for a single
%   or multiple symbols within a range date for a custom time frame (daily,weekly,monthly)
%   Returns the adjusted prices (dividends/splits) for Open, High, Low, Close, Volume
%   Symbols can be a single string or a cell of strings {'aapl','msft',...}
%
%   Output is an array of structures
%
%   INPUT:
%
%   symList (string/cell of strings): ticker list. It cannot be empty
%   sDate (string): start date with format YYYYMMDD (ie. 20130621)
%                   Default = last year
%   eDate (string): last date with format YYYYMMDD. Default = yesterday
%   freq (string): time frame 'd' (daily) or 'w' (weekly) or 'm' (monthly)
%                  Default = 'd'
%   dateFmt (string): convert yahoo format YYYY-MM-DD to custom format
%
%   OUTPUT:
%
%   S (structure or array of structure): historical values
%
%   S =
%
%     Ticker: []
%       Date: []
%       Open: []
%       High: []
%        Low: []
%      Close: []
%     Volume: []
%       Freq: []
%
%   EXAMPLE:
%
%   S = HistDataYahoo('AAPL')
%   S = HistDataYahoo('AAPL','20130102')
%   S = HistDataYahoo('AAPL','20130102','20130615')
%   S = HistDataYahoo('AAPL','20130102','20130615','w')
%   S = HistDataYahoo({'AAPL','MSFT','SPX'},'20130102','20130615','m')
%   S = HistDataYahoo({'AAPL','MSFT','SPX'},'20130102','20130615','m','dd-mmm-yyyy')

%check inputs
if ~exist('symList','var') || (~ischar(symList) &&  ~iscell(symList)) || isempty(symList)
    error('symList: it can be only a single string or a cell of strings');
end
if ischar(symList)
    ticker = {symList};
else
    ticker = symList;
end
if ~exist('sDate','var') || isempty(sDate)
    sdt = datevec(now - 365);
else
    sdt = datevec(sDate,'yyyymmdd');
end
if ~exist('eDate','var') || isempty(sDate)
    edt = datevec(now - 1);
else
    edt = datevec(eDate,'yyyymmdd');
end
if ~exist('freq','var') || isempty(freq)
    f = 'd';
else
    if strcmpi(freq,{'d','w','m'}) == 0
        error('freq: please insert frequency as string ''d'' (daily) or ''w'' (weekly) or ''m'' (monthly)');
    else
        f = lower(freq);
    end
end
if ~exist('dateFmt','var') || isempty(dateFmt)
    dfmt = 'mm/dd/yyyy';
else
    dfmt = dateFmt;
end

%set main URL string
urlmain = 'http://ichart.finance.yahoo.com/table.csv?';
urlxp = '&ignore=.csv';

%set output
S = struct('Ticker',[],'Date',[],'Open',[],'High',[],'Low',[],'Close',[],'Volume',[],'Freq',[]);

for i = 1:length(ticker)
    
    %set url string
    urlsym = ['&s=' upper(ticker{i})];
    urlsdt = ['&a=' num2str(sdt(2)-1) '&b=' num2str(sdt(3)) '&c=' num2str(sdt(1))];
    urledt = ['&d=' num2str(edt(2)-1) '&e=' num2str(edt(3)) '&f=' num2str(edt(1))];
    urlf = ['&g=' f];
    url = [urlmain urlsym urlsdt urledt urlf urlxp];
    
    
    %open a connection to the URL with java inputstream
    buf = java.io.BufferedReader(java.io.InputStreamReader(openStream(java.net.URL(url))));
    
    %header
    header = char(readLine(buf));
    
    t = 1;
    while 1
        %read line
        bufline = char(readLine(buf));
        
        if isempty(bufline)
            break
        end
        
        %find comma delimiter
        sep = find(bufline == ',');
        
        %get fields from string
        nDate = bufline(1:sep(1) - 1);
        nOpen = str2double( bufline(sep(1) + 1 : sep(2) - 1) );
        nHigh = str2double( bufline(sep(2) + 1 : sep(3) - 1) );
        nLow = str2double( bufline(sep(3) + 1 : sep(4) - 1) );
        nClose = str2double( bufline(sep(4) + 1 : sep(5) - 1) );
        nVolume = str2double( bufline(sep(5) + 1 : sep(6) - 1) );
        nAdjClose = str2double( bufline(sep(6) + 1 : end) );
        
        %adjust for dividends/splits
        tDate{t,1} = nDate;
        tOpen(t,1) = nOpen  * nAdjClose / nClose;
        tHigh(t,1) = nHigh  * nAdjClose / nClose;
        tLow(t,1) = nLow * nAdjClose / nClose;
        tClose(t,1)= nClose * nAdjClose / nClose;
        tVolume(t,1)  = nVolume;
        
        t = t + 1;
    end
    
    %flip data from oldest to newest
    hDate = flipud(tDate);
    %convert format
    hDate = cellstr(datestr(hDate,dfmt));
    hOpen = flipud(tOpen);
    hHigh = flipud(tHigh);
    hLow = flipud(tLow);
    hClose = flipud(tClose);
    hVolume = flipud(tVolume);
    
    %close buffer
    buf.close();
    
    %output
    S(i).Ticker = upper(ticker{i});
    S(i).Date = hDate;
    S(i).Open = hOpen;
    S(i).High = hHigh;
    S(i).Low = hLow;
    S(i).Close = hClose;
    S(i).Volume = hVolume;
    S(i).Freq = f;
    
end

end
