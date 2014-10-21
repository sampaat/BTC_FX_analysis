#create markets list
markets <- BTC_getmarketlist()

#create table of market forenames, currencies and markets
nametable <- matrix(unlist(lapply(markets,function(x) c(substr(x, 1, nchar(x)-3),substr(x, nchar(x)-3+1, nchar(x)),x,FALSE))),ncol=4,byrow = TRUE)

#list of market forenames and traded currencies
marketlist <- unique(nametable[,1])
currlist <- unique(nametable[,2])

#load all data

for(i in 1:length(nametable[,1])){
    
  tray <- BTC_downloadFX(nametable[i,1], nametable[i,2])
  
  if(!is.null(tray)){
    assign(nametable[i,3],tray)
    nametable[i,4]<-TRUE
  }
}

#mtgox currencies

btc_curr<-unique(nametable[(nametable[,4]%in% TRUE),2])
btc_markets<-nametable[(nametable[,4]%in% TRUE),3]

#convert unixtime to dates
#as.Date(as.POSIXct(mtgoxAUD[1,1], tz="GMT", origin="1970-01-01"))


require(plyr)
#daily summary tables

#create tables of daily traffics for every currency

start_date ="2012/1/1"
end_date = "2014/1/1"

dates<-seq(as.Date(start_date), as.Date(end_date), "days")

#check if market was active in the time interval
#isactive <- matrix()
#for(i in 1:length(btc_markets)){
#  eval(parse(text=paste("sta<-apply("btc_markets[i]"[,1], 2, function(x) ifelse(x>start_date, 1, ifelse(x<start_date, 0, NA)))")))
#  eval(parse(text=paste("sta<-apply("btc_markets[i]"[,1], 2, function(x) ifelse(x<end_date, 1, ifelse(x>end_date, 0, NA)))")))
# not finished, but not needed
#}

#shitti name conversation
coinUSD<-eval(`1coinUSD`)
btc_markets[1]<-"coinUSD"

#transform unix timestamps to daily dates, and calculate daily number of transactions, daily sum of transactions in bitcoin and currency
for(i in 1:length(btc_markets)){
  print(btc_markets[i])
  eval(parse(text=paste("colnames(",btc_markets[i],")<-c('date','rate','BTC')",sep="")))
  eval(parse(text=paste(btc_markets[i],"_rates<-ddply(",btc_markets[i],", .(as.Date(as.POSIXct(date, tz='GMT', origin='1970-01-01'))), summarize, num_of_trans = length(rate), sum_trans_btc = sum(BTC), sum_trans_curr = sum(rate * BTC) )",sep="")))
  eval(parse(text=paste("colnames(",btc_markets[i],"_rates)<-c('date','num_of_trans','sum_trans_btc','sum_trans_curr')",sep="")))
}

#create tables for days where each row is a day and each column is a market
#for the currency sums we need to transform the currencies to the same unit (USD or EUR or CNY)

num_of_trans<-matrix(nrow=length(dates),ncol=length(btc_markets))
sum_trans_btc<-matrix(nrow=length(dates),ncol=length(btc_markets))
sum_trans_curr<-matrix(nrow=length(dates),ncol=length(btc_markets))

for(i in 1:length(dates)){
  print(dates[i])
  for(j in 1:length(btc_markets)){
    a=eval(parse(text=paste(btc_markets[j],"_rates[",btc_markets[j],"_rates[,'date'] == '",dates[i],"',2]",sep="")))
    if(length(a)==0){a<-0}
    num_of_trans[i,j]=a
    b=eval(parse(text=paste(btc_markets[j],"_rates[",btc_markets[j],"_rates[,'date'] == '",dates[i],"',3]",sep="")))
    if(length(b)==0){b<-0}
    sum_trans_btc[i,j]=b
    c=eval(parse(text=paste(btc_markets[j],"_rates[",btc_markets[j],"_rates[,'date'] == '",dates[i],"',4]",sep="")))
    if(length(c)==0){c<-0}
    sum_trans_curr[i,j]=c
  }
  
}

colnames(num_of_trans)<-btc_markets
colnames(sum_trans_btc)<-btc_markets
colnames(sum_trans_curr)<-btc_markets
rownames(num_of_trans)<-dates
rownames(sum_trans_btc)<-dates
rownames(num_of_trans)<-dates


#normalize rows tthat the sum of each row = 1
num_of_trans_1<-apply(num_of_trans, 1, function(x)(x/sum(x)))
sum_trans_btc_1<-apply(sum_trans_btc, 1, function(x)(x/sum(x)))
#sum_trans_curr_1<-apply(sum_trans_curr, 1, function(x)(x/sum(x)))

#substract the column averages from each column
num_of_trans_2<-apply(num_of_trans_1, 2, function(x)(x-mean(x)))
sum_trans_btc_2<-apply(sum_trans_btc_1, 2, function(x)(x-mean(x)))
#sum_trans_curr_2<-apply(sum_trans_curr_1, 2, function(x)(x-avg(x)))

#evaluate svd
num_of_trans_SVD<-svd(num_of_trans_2)
sum_trans_btc_SVD<-svd(sum_trans_btc_2)
#sum_trans_curr_SVD<-svd(sum_trans_curr_2)

#calculate daily average exchange rates
daily_fxrate<-sum_trans_btc/num_of_trans
colnames(daily_fxrate)<-btc_markets
rownames(daily_fxrate)<-dates

#plot the time-varying contribution of the weights

matplot(dates,sum_trans_btc_SVD$v[,1:5],dates,type="l",log="",xlab="date",ylab="singular vector weight",xaxt='n')
axis.Date(1,dates)
legend("bottomleft", legend = c("1st","2nd","3rd","4th","5th","6th"), col=1:6, pch=1, ncol=2)


###
#currency specific calculations
###

#calculate daily transaction sums in btc and currency for currencies

sum_of_trans_btc_curr<-matrix(0,nrow=length(dates),ncol=length(btc_curr))
sum_of_trans_curr_curr<-matrix(0,nrow=length(dates),ncol=length(btc_curr))

for(i in 1:length(dates)){
  print(dates[i])
  for(j in 1:length(btc_markets)){
    curr<-match(substr(btc_markets[j], nchar(btc_markets[j])-3+1, nchar(btc_markets[j])),btc_curr)
    sum_of_trans_btc_curr[i,curr]=sum_of_trans_btc_curr[i,curr]+sum_trans_btc[i,j]
    sum_of_trans_curr_curr[i,curr]=sum_of_trans_curr_curr[i,curr]+sum_trans_curr[i,j]
  }
  
}
colnames(sum_of_trans_btc_curr)<-btc_curr
rownames(sum_of_trans_btc_curr)<-dates

colnames(sum_of_trans_curr_curr)<-btc_curr
rownames(sum_of_trans_curr_curr)<-dates

#take the biggest active currencies and plot it
sotbc_big<-sum_of_trans_btc_curr[,colSums(sum_of_trans_btc_curr)>10^6]
matplot(as.Date(dates),sotbc_big,type="l",log="y",col=1:ncol(sotbc_big),xlab="date",ylab="daily traffic in BTC",xaxt='n')
axis.Date(1,dates)
legend("bottomleft", legend = colnames(sotbc_big), col=1:ncol(sotbc_big), pch=1)

#plot the sum of daily transactions in btc for all markets
plot(t(rbind(dates,rowSums(sum_of_trans_btc_curr))),xaxt='n',type="l")
axis.Date(1,dates)

#calculate daily average rates
daily_avg_fxrate<-sum_of_trans_curr_curr/sum_of_trans_btc_curr

plot(t(rbind(dates,daily_avg_fxrate[,"USD"])),xaxt='n',type="l",log="y")
axis.Date(1,dates)

daf_USD_loglag<- log(daily_avg_fxrate[2:nrow(daily_avg_fxrate),"USD"]) - log(daily_avg_fxrate[1:nrow(daily_avg_fxrate)-1,"USD"])

#plot USD daily return vs daily forex traffic

par(mar = c(5, 4, 4, 4) + 0.3)
plot(t(rbind(dates[2:length(dates)],abs(daf_USD_loglag))),xaxt='n',type="l",log="",xlab="date",ylab="USD daily abs log return")
par(new = TRUE)
plot(t(rbind(dates,rowSums(sum_of_trans_btc_curr))), type = "l", axes = FALSE, bty = "n", xlab = "", ylab = "",xaxt='n',col="2")
axis(side=4, at = pretty(range(rowSums(sum_of_trans_btc_curr))))
mtext("daily forex traffic of all currencies in BTC (log scale)", side=4, line=3)
axis.Date(1,dates)
legend("topleft",legend=c("USD daily avg price","BTC forex traffic"),text.col=c("black","red"),pch=c(16,16),col=c("black","red"))
legend("topleft",legend=c("USD daily avg price","BTC forex traffic"),text.col=c("black","red"),pch=c(16,15),col=c("black","red"))