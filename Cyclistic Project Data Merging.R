library(tidyverse)  
library(lubridate)  
library(ggplot2)
library(openxlsx)
getwd() 
setwd("C:/Users/kiane/Documents/Python Learning/Cyclistic Project") 

jan <- read_csv('./Cleaned Dataset/202201-divvy-tripdata.csv')
feb <- read_csv('./Cleaned Dataset/202202-divvy-tripdata.csv')
mar <- read_csv('./Cleaned Dataset/202203-divvy-tripdata.csv')
apr <- read_csv('./Cleaned Dataset/202204-divvy-tripdata.csv')
may <- read_csv('./Cleaned Dataset/202205-divvy-tripdata.csv')
jun <- read_csv('./Cleaned Dataset/202206-divvy-tripdata.csv')
jul <- read_csv('./Cleaned Dataset/202207-divvy-tripdata.csv')
aug <- read_csv('./Cleaned Dataset/202208-divvy-tripdata.csv')
sep <- read_csv('./Cleaned Dataset/202209-divvy-tripdata.csv')
oct <- read_csv('./Cleaned Dataset/202210-divvy-tripdata.csv')
nov <- read_csv('./Cleaned Dataset/202211-divvy-tripdata.csv')
dec <- read_csv('./Cleaned Dataset/202212-divvy-tripdata.csv')

trips_2022 <- bind_rows(jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)

write.csv2(trips_2022,'cleaned_Data.xlsx', row.names = FALSE)

mean(trips_2022$ride_duration) 
median(trips_2022$ride_duration) 

summary(trips_2022$ride_duration)

aggregate(trips_2022$ride_duration ~ trips_2022$member_casual, FUN = mean)
aggregate(trips_2022$ride_duration ~ trips_2022$member_casual, FUN = median)
aggregate(trips_2022$ride_duration ~ trips_2022$member_casual, FUN = max)
aggregate(trips_2022$ride_duration ~ trips_2022$member_casual, FUN = min)

trips_2022$day_of_week <- ordered(trips_2022$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
aggregate(trips_2022$ride_duration ~ trips_2022$member_casual + trips_2022$day_of_week, FUN = mean)




