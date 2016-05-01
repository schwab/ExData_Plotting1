
library(dplyr)
library(lubridate)

# map will extract a small set of data from the source (which is > 120Mb) to reduce 
# size of the working the data needed in memory
# note : this won't work if your OS doesn't have the cat and grep functions (ie windows) 
# SO, I included the reduced set of data in the uploaded file f2Days.csv
# it will be automatically used by the code if it's found in the current working direcroty
#  
map <- function() 
{
  fileName <- "household_power_consumption.txt"
  com <- paste("cat ", fileName, " | grep -E '2/2/2007|1/2/2007'", sep="")
  n <- system(command=com, intern=TRUE)
  n
}
createTable <- function(n) {
  con <- textConnection(n)
  data <- read.csv(con, sep=";")
  close(con)
  data  
}
prepareData <- function(df)
{
  # reset the column names
  names(df) <- c("Date","Time","Global_Active_Power","Global_Reactive_Power","Voltage","Global_Intensity","Sub_Metering_1","Sub_Metering_2","Sub_Metering_3")
  # head(twoDaysPower)
  
  # convert the date and time strings to typed columns 
  df$Date <- gsub("/1/","/01/",df$Date)
  df$Date <- gsub("/2/","/02/",df$Date)
  df$DateFormat <- parse_date_time(paste(f2Days$DateFormat, f2Days$Time),"%Y-%m-%d %H:%M:%S")
  df <- filter(df,Global_Active_Power != "?")
  #gap <- powerData$Global_Active_Power
  df$Global_Active_Power <- as.numeric(as.character(df$Global_Active_Power))
  # filter to just the 2 days needed
  y <- 2007
  d <- c(1,2)
  m <- 2
  f2Days <- df %>% filter(year(DateFormat) %in% y & month(DateFormat) %in% m & day(DateFormat) %in% d & Global_Active_Power != "?")
  f2Days  
}

path <- 'f2Days.csv'
if(!file.exists(path))
{
  n<- map()
  df <- createTable(n)
  f2Days <- prepareData(df)
  write.csv(f2Days,path)
}else 
{
  f2Days <- read.csv(path)
}
# Get the data 




# Generate plot1
par(mfrow=c(1,1))
png(filename="plot1.png")
hist(f2Days$Global_Active_Power, breaks=12, col="red",main="Global Active Power", xlab="Global Active Power (kilawatts)")
dev.off()