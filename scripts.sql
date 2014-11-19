--use dbase
USE BTC_FX

--create table

CREATE TABLE FX_bind
(
bind_time		DATETIME,
bind_btc		FLOAT,
bind_currency	FLOAT,
market			VARCHAR(20)
)

CREATE TABLE FX_init
(
line			VARCHAR(20),
bind_time		BIGINT,
bind_btc		FLOAT,
bind_currency	FLOAT,
market			VARCHAR(20)
)

BULK
INSERT FX_init
FROM '\\retdb02\Data\Temp\user\sampaat\BTC_FX_transactions_3.csv'
WITH
(
FIRSTROW = 2 ,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n' ,
TABLOCK
)

--insert records to FX_bind table with coversion of time from unixtime to date (first declare function)

INSERT FX_bind
SELECT dateadd(S, bind_time, '1970-01-01'), bind_btc, bind_currency, REPLACE(market,'"','')
FROM FX_init

DROP TABLE FX_init

--market list

CREATE TABLE Markets
(
market			VARCHAR(20),
provider		VARCHAR(15),
currency		VARCHAR(3)
)

CREATE TABLE Markets_init
(
line			VARCHAR(20),
provider		VARCHAR(15),
currency		VARCHAR(3),
market			VARCHAR(20),
tf				VARCHAR(10)
)

BULK
INSERT Markets_init
FROM '\\retdb02\Data\Temp\user\sampaat\nametable.csv'
WITH
(
FIRSTROW = 2 ,
FIELDTERMINATOR = '","',
ROWTERMINATOR = '\n'
)

INSERT Markets
SELECT market, provider, currency
FROM Markets_init

DROP TABLE Markets_init

--daily market statistics

CREATE TABLE Daily_markets
(
time_day		DATE,
market			VARCHAR(20),
num				BIGINT,
sum_btc			FLOAT,
sum_currency		FLOAT
)

CREATE TABLE Daily_markets_init
(
line			VARCHAR(20),
time_day		INT,
market			VARCHAR(20),
num				INT,
sum_btc			FLOAT,
sum_currency		VARCHAR(20)
)

BULK
INSERT Daily_markets_init
FROM '\\retdb02\Data\Temp\user\sampaat\Daily_markets.csv'
WITH
(
FIRSTROW = 2 ,
FIELDTERMINATOR = '","',
ROWTERMINATOR = '\n'
)

INSERT Daily_markets
SELECT dateadd(D, time_day-15340, '2012-01-01'), market, num, sum_btc, CAST(REPLACE(sum_currency,'"','') AS FLOAT)
FROM Daily_markets_init

DROP TABLE Daily_markets_init

--daily currency statistics

CREATE TABLE Daily_currency
(
time_day		DATE,
currency		VARCHAR(3),
num				BIGINT,
sum_btc			FLOAT,
sum_currency	FLOAT
)

CREATE TABLE Daily_currency_init
(
line			VARCHAR(20),
time_day		INT,
currency		VARCHAR(3),
num				BIGINT,
sum_btc			FLOAT,
sum_currency	VARCHAR(20)
)

BULK
INSERT Daily_currency_init
FROM '\\retdb02\Data\Temp\user\sampaat\Daily_curr.csv'
WITH
(
FIRSTROW = 2 ,
FIELDTERMINATOR = '","',
ROWTERMINATOR = '\n'
)

INSERT Daily_currency
SELECT dateadd(D, time_day-15340, '2012-01-01'), currency, num, sum_btc, CAST(REPLACE(sum_currency,'"','') AS FLOAT)
FROM Daily_currency_init

DROP TABLE Daily_currency_init

--daily provider statistics

CREATE TABLE Daily_provider
(
time_day		DATE,
provider		VARCHAR(15),
num				BIGINT,
sum_btc			FLOAT
)

CREATE TABLE Daily_provider_init
(
line			VARCHAR(10),
time_day		INT,
provider		VARCHAR(15),
num				BIGINT,
sum_btc			FLOAT,
sum_currency	VARCHAR(20)
)

BULK
INSERT Daily_provider_init
FROM '\\retdb02\Data\Temp\user\sampaat\Daily_pro.csv'
WITH
(
FIRSTROW = 2 ,
FIELDTERMINATOR = '","',
ROWTERMINATOR = '\n'
)

INSERT Daily_provider
SELECT dateadd(D, time_day-15340, '2012-01-01'), provider, num, sum_btc
FROM Daily_provider_init

DROP TABLE Daily_provider_init
