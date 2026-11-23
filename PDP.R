library("tidyverse")
library("ggplot2")
raw_data <- read_csv("occurencedata.csv")

# Visualizing the Raw Data

sum(duplicated(raw_data))
unique(raw_data$spp)
unique(raw_data$month)
unique(raw_data$year)
colSums(is.na(raw_data))

# Cleaning Time and Date Data

clean_data <- raw_data %>%
  mutate(date=as.Date(date, format="%d/%m/%Y")) %>%
  mutate(time=as.character(time)) %>%
  mutate(time = str_replace(time, "\\.", ":")) %>%
  mutate(time=ifelse(
    str_count(time, ":") == 1,
    str_c(time, ":00"),
    time
  )) %>%
  mutate(month = as.numeric(format(date, "%m"))) %>%
  filter(!is.na(time))

# Adding Month Names

clean_data <- clean_data %>%
  mutate(month_name=ifelse(month==4, "April",
                           ifelse(month==5, "May",
                                  ifelse(month==6, "June",
                                         ifelse(month==7, "July", NA)))))

# Cleaning Location Data

clean_data <- clean_data %>%
  filter(lat >= 40 & lat <= 50) %>%
  filter(lon >= 8 & lon <= 10)

# got rid of two rows where lat was 4.52

# Formatting Species Names

clean_data <- clean_data %>%
  mutate(spp=ifelse(spp=="Pelesc", "Pelophylax synkl. esculentus",
                ifelse(spp=="Hylint", "Hyla intermedia",
                       ifelse(spp=="Bufvir", "Bufotes viridis", spp))))

# Final Review of Clean Data

summary(clean_data)
unique(clean_data$time)
unique(clean_data$month)
unique(clean_data$month_name)
unique(clean_data$year)
unique(clean_data$spp)
sum(duplicated(clean_data))
colSums(is.na(clean_data))

# Exporting Clean CSV

write_csv(clean_data, "occurencedata_clean.csv")

# Creating a Graph

clean_data$month_name <- factor(
  clean_data$month_name,
  levels=c("April", "May", "June", "July")
  )

ggplot(clean_data, aes(x=month_name, fill=spp)) + geom_bar(position="dodge") + 
  labs(title="Amphibian Observation Distribution Across Monitored Months",
       x="Month",
       y="Number of Observations",
       fill="Species")