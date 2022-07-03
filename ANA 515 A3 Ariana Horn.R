#Assignment 2 - getting and cleaning data
#checking wd 
getwd()

#downloading bulk storm details data for 1994
#loading data into R 
#loading packages I will use 
install.packages("tidyverse")
install.packages("dplyr")
library("tidyverse")
library("dplyr")
#limit dataframe to certain variables 
#select variables begin and end (as a test)
mv<-c("BEGIN_DATE_TIME", "END_DATE_TIME")
beginend <- StormEvents_details_ftp_v1_0_d1994_c20220425_2[mv]
#select 15 variables for new dataframe
myvar<-c("BEGIN_DATE_TIME", "END_DATE_TIME", "EPISODE_ID", "EVENT_ID", "STATE", "STATE_FIPS", "CZ_NAME", "CZ_TYPE", "CZ_FIPS", "EVENT_TYPE", "SOURCE", "BEGIN_LAT", "BEGIN_LON", "END_LAT", "END_LON")
newdata<-StormEvents_details_ftp_v1_0_d1994_c20220425_2[myvar]
head(newdata)
#arrange data by state name 
arrange(newdata, STATE, .by_group = FALSE)
#change state and county names to title case 
str_to_title(newdata$STATE)
#limit to the events listed by county FIPS (CZ_TYPE of “C”) and then remove the CZ_TYPE column 
filter(newdata, CZ_TYPE == "C")
select(newdata, -CZ_TYPE)  
#pad the state and county FIPS with a “0” at the beginning (hint: there’s a function in stringr to do this) and then unite the two columns to make one fips column with the 5 or 6-digit county FIPS code 
install.packages("stringr")
library("stringr")
str_pad(newdata$STATE_FIPS, width = 3, side = "left", pad = "0")
str_pad(newdata$CZ_FIPS, width = 3, side = "left", pad = "0")
newdata$NEW_FIPS <- str_c(newdata$STATE_FIPS," ", newdata$CZ_FIPS)

#change all the column names to lower case 
rename_all(newdata, tolower)
#dataframe with these three columns: state name, area, and region 
data("state")
us_state <- data.frame(state = state.name, area = state.area, region = state.region)
#chaning us_state df to uppercase
upper_us_state <-(mutate_all(us_state, toupper))
#create a dataframe with the number of events per state in the year 1994. 
#merge in the state information dataframe you just created in step 8. 
#remove any states that are not in the state information dataframe
#chaning state df to lowercase 
nrevent_state <- data.frame(table(newdata$STATE))
str_to_title(nrevent_state$Var1)
state <- rename(nrevent_state, c("State"="Var1"))
state_merge <- merge(x = state, y = upper_us_state, by.x = "State", by.y = "state")
head(state_merge)


#creating plot y= number of storm events in 1994 and x= land area 
library(ggplot2)
storm_plot_by_state <- ggplot(state_merge, aes(x=area, y=Freq)) +
  geom_point(aes(color=region)) +
  labs(x = "Land area (square miles)", y = "# of storm events(1994)")
storm_plot_by_state 
