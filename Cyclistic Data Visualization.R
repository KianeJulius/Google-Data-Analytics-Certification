install.packages("dplyr")
install.packages("ggplot2")
install.packages('pacman')


library("dplyr")
library("ggplot2")
library('pacman')

setwd('C:/Users/kiane/Documents/Python Learning/Cyclistic Project')
df <- read.csv(file = 'merged_data.csv', header = TRUE)
head(df)
str(df)
dim(df)
## Returns 4369291 rows, 16 columns
## Plotting

plot1 <- ggplot(df, aes(x = member_casual, y = count(ride_id)))

plot1

