##Origin and properties of the raw dataset

The origin of the BTC_FX dataset is an [api page](http://api.bitcoincharts.com/v1/csv/) of bitcoincharts.com. The First part of *markets_and_data.R* and *functions.R* script download the data and then create the daily tables. The datasets conatin historical data of individual binds of Bitcoin (BTC) foreing exchange (FX) markets, that can be observed on the bitcoincharts.com site. The data records contains the time, price and ammount parameters of the deals. The observed time is from 2010.04.25. to 2014.11.13.


##Accessibility of the dataset

The BTC_FX data set is publicly accessible on [CasJobs](http://nm.vo.elte.hu/casjobs/default.aspx) server of Eötvös Loránd University

##Tables of the SQL dataset

1. __FX_bind__

  contains the recorded binds, each with the following properties:

  - _bind_time_			time of deal
  - _bind_price_		price of deal in the currency of the market
  - _bind_quant_		amount of BTC
  - _market_		type of the game / probability of winning in percent (0.01% - 98%)

2. __Markets_list__

	contains the following information about the markets:

  - _market_		name of BTC_FX market
  - _provider_	name of the market provider (can make markets in more than one currency)
  - _currency_	3 character ISO codes of currencies with considerable amount of exceptions (see below)

3. __Daily_markets__

	contains statistics of daily market traffic from 2012.01.01 to 2014.11.01

  - _time_day_  date of the day
  - _market_		name of BTC_FX market
  - _num_		    number of transactions on the given day
  - _sum_btc_		sum of transactions on the given day in BTC
  - _sum_currency_	sum of transactions on the given day in the currency of the market


3. __Daily_currency__

  contains statistics of daily traffic in currencies from 2012.01.01 to 2014.11.01

  - _time_day_  date of the day
  - _currency_	3 character ISO codes of currencies with considerable amount of exceptions (see below)
  - _num_		    number of transactions on the given day
  - _sum_btc_		sum of transactions on the given day in BTC
  - _sum_currency_	sum of transactions on the given day in the given currency

3. __Daily_markets__

  contains statistics of daily provider traffic from 2012.01.01 to 2014.11.01

  - _time_day_  date of the day
  - _provider_	name of provider
  - _num_		    number of transactions on the given day
  - _sum_btc_		sum of transactions on the given day in BTC
  
##Currency exceptions
  
 - __LTC__ denotes LiteCoin, an electronic currency similar to BTC
 - __SLL__ denotes Second Life Lindens instead of Sierra Leone Leon