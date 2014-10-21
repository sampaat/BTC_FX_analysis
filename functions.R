BTC_downloadFX <- function(mark,curr) {
  
  #create url name for download
  filename <- paste(mark,toupper(curr),".csv.gz",sep="")
  url <- paste("http://api.bitcoincharts.com/v1/csv/",filename,sep="")
  
  #download .gz and check if correctly 
  if(download.file(url,filename) != 0){
    stop("Error occured in the download process. Check market name and currency")
  }

  print(filename)
  
  if(file.info(filename)$size>50){
    return(read.csv(filename,header = FALSE))
  }else{
    print("File empty")
    return(NULL)
  }
}

BTC_getmarketlist <- function() {
  
  #set url name for download
  url = "http://api.bitcoincharts.com/v1/csv/"
  
  #load data, also throw away unimportant parts
  mess <- head(read.table("http://api.bitcoincharts.com/v1/csv/",sep="\n",skip = 4),-2)
  
  #return vector of the market-currency pairs
  return(apply(mess,1,function(x) unlist(strsplit(unlist(strsplit(toString(x),"[.]"))[1],"[=]"))[2]))
  
}


