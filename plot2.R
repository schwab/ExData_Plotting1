
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
  #com <- paste("cat ", fileName, " | grep -E '2/2/2007|1/2/2007'", sep="")
  #n <- system(command=com, intern=TRUE)
  read.csv(fileName, na.string="?", sep=";")
  
}

prepareData <- function(df)
{
  # reset the column names
  #names(df) <- c("Date","Time","Global_Active_Power","Global_Reactive_Power","Voltage","Global_Intensity","Sub_Metering_1","Sub_Metering_2","Sub_Metering_3")
  
  # convert the date and time strings to typed columns 
  #df$Date <- gsub("/1/","/01/",df$Date)
  #df$Date <- gsub("/2/","/02/",df$Date)
  df$DateFormat <-as.POSIXct(strptime(paste(df$Date, df$Time, sep = " "),
                                      format = "%d/%m/%Y %H:%M:%S"))
  # filter to just the 2 days needed
  df <- df[(df$Date=="1/2/2007" | df$Date=="2/2/2007"),]
  df
  
}

path <- 'f2Days.csv'
if(!file.exists(path))
{
  df<- map()
  
  df <- prepareData(df)
  write.csv(df,path)
}else 
{
  df <- read.csv(path)
}

# Generate plot2
par(mfrow=c(1,1))
png("plot2.png", width=480, height=480)
plot(df$DateFormat, as.numeric(df$Global_active_power), type="l",  xlab="", ylab="Global Active Power (kilowatts)")
# Turn off device
dev.off()