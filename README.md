# Data Analytics Capstone: How Does a Bike-Share Navigate Speedy Success?

## Statement of the Business Task

While Cyclistic’s customer base of casual riders,  those who purchase day passes and single journey rides, are growing, there is an opportunity for the organization for future revenue growth in the annual membership plans, where profitability can be maximized, driven by a strong customer sentiment about the services. 

Business cases to be answered are the following: how different are the annual members and casual riders in terms of usage? Why would they, the casual riders, be compelled to upgrade to a yearly plan? How can we capture this segment using digital media and what strategy are we going to utilize? 

Using the internal data provided by Cyclistic, our task is to come up with a recommendation, backed up by data-driven insights and visualization and create a marketing strategy from there to capture the existing casual riders into annual members.

## Description of Data Source

Cyclistic’s Full Year 2022 trips are going to be the dataset for this project. For the legal and privacy purpose of this study, refer to the About the Dataset section below. 

The data is downloaded, extracted from a compressed file, stored in a subfolder with consistent naming conventions, and prepped in Excel for cleaning. 

A quick glimpse at the excel sheets tells us the following columns:

| Column | Description | Sample |
| --- | --- | --- |
| ride_id | unique identifier of each trips | F96D5A74A3E41399 |
| rideable_type | type of bike used | electric_bike |
| started_at | Date and Time value at the beginning of trip | 1/21/2023 20:05 |
| ended_at | Date and Time value at the end of trip | 1/21/2023 20:16 |
| start_station_name | Station name at the beginning of trip | Lincoln Ave & Fullerton Ave |
| start_station_id | Station identifier at the beginning of trip | TA1309000058 |
| end_station_name | Station name at the end of trip | Hampden Ct & Diversey Ave |
| end_station_id | Station identifier at the end of trip | 202480 |
| start_lat | Geotag of the station | 41.92407 |
| start_lng | Geotag of the station | -87.6463 |
| end_lat | Geotag of the station | 41.93 |
| end_lng | Geotag of the station | -87.64 |
| member_casual | Type of subscription | member |

Upon quick inspection of the datasets at Excel, there are no known issues with biases and data credibility. 

However, upon quick sorting and filtering, there are missing values and incomplete rows to be investigated and to be take considered of:

*start_station_name, start_station_id, end_station_name,* and *end_station_id* are missing in some trips. This means that the user could’ve either logged just the beginning or ending (or neither) stations.  Some geological tags are also missing.

Other than that, the values in other columns are consistent with the structure intended.

## Data Processing

Tools to be used in data cleaning are the following:

1. **Microsoft Excel** - For general and quick inspections of downloaded data queried and cleaned at the BigQuery.
2. **Google Cloud Platform** - For handling large amount of tables with millions of rows. This is also where the data calculations are performed using SQL queries to pull up from a database. For uploading the GBs worth of data into the table, a Google Cloud Storage is required.
3. **Jupyter Notebook** - Utilized the Pandas library to merge all 12 months worth of data into a single spreadsheet. Python loops also makes it easy for large-scale file manipulation.
4. **Power BI.** For data visualization and create continuity with the Excel Power Query.

## Cleaning and Addition

The data cleaning process is facilitated in Microsoft Excel, specifically the Power Query editor. The sample codes are used in the first excel file  and just replicated across the nine months using the final advanced editor code at the end of this section.

In Excel Power Query:

1. Removed all duplicate *ride_id*, changed all *docked_bikes* to *electric_bike* as per the updated standards. 
2. To help with the analyses, a ride_duration column was added. The output was transformed into minutes.

```
ride_duration = [ended_at] - [started_at]
```

Using the filter function, the dataset returns multiple rows of negative duration, which means that the transaction posted the start of trip way after the user ended the ride. Rows with such values are filtered out, leaving 0s and positive values.

1. Also filtered out the rows with blank locations.
2. Create a column indicating the day of the week that each ride was initiated.

```
day_of_week = Date.DayOfWeekName([started_at)] 
```

1. Extract the time of the day. 

```
time_of_day = DateTime.Time([started_at])
```

In summary, the advanced Power Query editor code are as follows:

```
let
    Source = Excel.CurrentWorkbook(){[Name="Table1"]}[Content],
    #"Added ride_duration" = Table.AddColumn(Source, "ride_duration", each [ended_at]-[started_at]),
    #"Changed Type" = Table.TransformColumnTypes(#"Added ride_duration",{{"ride_duration", type duration}}),
    #"Added day_of_week" = Table.AddColumn(#"Changed Type", "day_of_week", each Date.DayOfWeekName([started_at])),
    #"Added time_of_day" = Table.AddColumn(#"Added day_of_week", "time_of_day", each DateTime.Time([started_at])),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added time_of_day",{{"time_of_day", type time}}),
    #"Calculated Total Minutes" = Table.TransformColumns(#"Changed Type1",{{"ride_duration", Duration.TotalMinutes, type number}}),
    #"Filtered Rows" = Table.SelectRows(#"Calculated Total Minutes", each true),
    #"Filtered Rows1" = Table.SelectRows(#"Filtered Rows", each [start_station_name] <> null and [start_station_name] <> ""),
    #"Filtered Rows2" = Table.SelectRows(#"Filtered Rows1", each [end_station_name] <> null and [end_station_name] <> ""),
    #"Filtered Rows3" = Table.SelectRows(#"Filtered Rows2", each [ride_duration] >= 0),
    #"Filtered Rows4" = Table.SelectRows(#"Filtered Rows3", each true),
    #"Changed Type2" = Table.TransformColumnTypes(#"Filtered Rows4",{{"started_at", type datetime}, {"ended_at", type datetime}, {"time_of_day", type time}})
in
    #"Changed Type2"
```

## Merging

To facilitate a much more efficient use of computer and cloud memory, as well as simpler workload, data merging of all 12 months can save us with tons of resources. A python script running on pandas below contains the process of excel merging:

```python
import pandas as pd
import os

# For Checking
df = pd.read_csv('./Cleaned Dataset/202212-divvy-tripdata.csv')
df.head()

# For-Loop
files = [file for file in os.listdir('./Cleaned Dataset')]

merged_data = pd.DataFrame()
for file in files:
    df = pd.read_csv('./Cleaned Dataset/' + file)
    merged_data = pd.concat([merged_data, df])

merged_data.head()
merged_data.to_csv('merged_data.csv', index = False)
```

This returns a 904MB excel file.

Alternatively, for data visualization purposes, R programming code can also merge the 12 months data set.

```
install.packages('openxlsx')
library(tidyverse)  
library(lubridate)  
library(ggplot2)  
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
write.xlsx(trips_2022,'cleaned_Data.xls', row.names=FALSE)
```

# Analysis

### Basic Statistical Values

Using the BigQuery and running the SQL code,

```sql
SELECT
  COUNT(*) AS all_rides_2022,
  ROUND(AVG(ride_duration),2) AS average_ride_duration
   
FROM `cyclistic.cyclistic-trips`
```

the terminal returns:

| all_rides_2022 | average_ride_duration |
| --- | --- |
| 4369291 | 17.1 |

For the median, since SQL commands can get complicated nested queries and subqueries before arriving at the value, a simple R code can return the following statistical values and comparisons:

```r
median(trips_2022$ride_duration)
10.6
summary(trips_2022$ride_duration)
    Min.  1st Qu.   Median     Mean     3rd Qu.        Max. 
    0.00     6.05    10.60    17.10       19.02    34354.07
aggregate(trips_2022$ride_duration ~ trips_2022$member_casual, FUN = mean)
  trips_2022$member_casual trips_2022$ride_duration
1                   casual                 23.99310
2                   member                 12.45173
aggregate(trips_2022$ride_duration ~ trips_2022$member_casual, FUN = median)
  trips_2022$member_casual trips_2022$ride_duration
1                   casual                13.850000
2                   member                 8.983333
trips_2022$day_of_week <- ordered(trips_2022$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
> aggregate(trips_2022$ride_duration ~ trips_2022$member_casual + trips_2022$day_of_week, FUN = mean)
   trips_2022$member_casual trips_2022$day_of_week trips_2022$ride_duration
1                    casual                 Sunday                 27.22748
2                    member                 Sunday                 13.85077
3                    casual                 Monday                 24.83411
4                    member                 Monday                 12.03288
5                    casual                Tuesday                 21.44198
6                    member                Tuesday                 11.79114
7                    casual              Wednesday                 20.71797
8                    member              Wednesday                 11.84691
9                    casual               Thursday                 21.40345
10                   member               Thursday                 12.03186
11                   casual                 Friday                 22.35712
12                   member                 Friday                 12.22694
13                   casual               Saturday                 26.76606
14                   member               Saturday                 13.98159
```

### Business Questions

1. Which customer type has the top total ridership for the year?

```sql
SELECT
  ROUND(SUM(ride_duration)/1000000,2) AS total_ride_in_million_hours,
  member_casual AS subscription_type
FROM `cyclistic.cyclistic-trips`
GROUP BY member_casual
```

| total_ride_in_million_hours | subscription_type |
| --- | --- |
| 42.18 | casual |
| 32.51 | member |
1. Who is our largest customer segment?

```sql
SELECT
  COUNT(DISTINCT ride_id) AS ridership_2022,
  member_casual AS subscription_type
FROM `cyclistic.cyclistic-trips`
GROUP BY member_casual
```

| ridership_2022 | subscription_type |
| --- | --- |
| 1,758,150 | casual |
| 2,611,139 | member |
1. What is the average ridership per subscription type?

```sql
SELECT
  ROUND((SELECT ROUND(SUM(ride_duration),2) 
	FROM `cyclistic.cyclistic-trips` WHERE member_casual = 'casual')
  /
  (SELECT COUNT(member_casual) 
	FROM `cyclistic.cyclistic-trips` 
	WHERE member_casual = 'casual'),2) AS average_rideminutes_per_casual_user,
  

	ROUND((SELECT ROUND(SUM(ride_duration),2) 
	FROM `cyclistic.cyclistic-trips` WHERE member_casual = 'member')
  /
  (SELECT COUNT(member_casual) 
	FROM `cyclistic.cyclistic-trips` 
	WHERE member_casual = 'member'),2) AS average_rideminutes_per_member,

FROM `cyclistic.cyclistic-trips`
LIMIT 1
```

| average_rideminutes_per_casual_user | average_rideminutes_per_member |
| --- | --- |
| 23.99 | 12.45 |
1. What day of the week has the most riders?

```sql
SELECT
DISTINCT day_of_week, COUNT (DISTINCT ride_id) AS rides
FROM `cyclistic.cyclistic-trips`
GROUP BY day_of_week
ORDER BY rides DESC
```

| day_of_week | rides |
| --- | --- |
| Saturday | 705,613 |
| Thursday | 645,891 |
| Wednesday | 616,369 |
| Friday | 608,849 |
| Tuesday | 607,624 |
| Sunday | 599,018 |
| Monday | 585,925 |

# Recommendations

1. Strategize promotional materials centering around the cost-effectiveness of annual plans.
2. In-app marketing campaigns should be more prominent during the weekend.
3. Release first-time annual discounts at the casual riders arriving and departing at the strip of stations lining the Lake Michigan.
4. Invest more on the stations leading up to the Loop and the Residential area at the south of downtown, preferably for those coming from the suburban centers.
5. Additionally, increase the docking capacity at the downtown stations to accommodate the afternoon rush hours from office to home.



