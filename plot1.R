# NOTE to Evaluator :  The function map (as in MapReduce) uses unix cat and grep 
# to minimize the amount of data we have to load into memory, this probably won't work in windows 
# without some installed unix utilities or cygwin.  The return from this is just a 
# list of string data that contains matching lines with the date patterns we are interested in
library(dplyr)
library(lubridate)
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

# Get the data 
n<- map()
powerData <- createTable(n)
# reset the column names
names(powerData) <- c("Date","Time","Global_Active_Power","Global_Reactive_Power","Voltage","Global_Intensity","Sub_Metering_1","Sub_Metering_2","Sub_Metering_3")
# head(twoDaysPower)

# convert the date and time strings to typed columns 
powerData$Date <- gsub("/1/","/01/",powerData$Date)
powerData$Date <- gsub("/2/","/02/",powerData$Date)
powerData$DateFormat <- as.Date(strptime(paste(powerData$Date, powerData$Time),"%d/%m/%Y %H:%M:%S"))
#gap <- powerData$Global_Active_Power
powerData$Global_Active_Power <- as.numeric(powerData$Global_Active_Power)
# filter to just the 2 days needed
y <- 2007
d <- c(1,2)
m <- 2
f2Days <- powerData %>% filter(year(DateFormat) %in% y & month(DateFormat) %in% m & day(DateFormat) %in% d & Global_Active_Power != "?")
head(f2Days)
par(mfrow=c(1,1))
png(filename="plot1.png")
hist(f2Days$Global_Active_Power, breaks=12, col="red",main="Global Active Power", xlab="Global Active Power (kilawatts)")
dev.off()