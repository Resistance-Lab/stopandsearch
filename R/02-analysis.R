load("data/stop_and_search.Rdata")
library(ggplot2)
library(directlabels)
library(plyr)
library(dplyr)

dates <- as.Date(stop_and_search$Date)

# Plot ethnicity by date
ethnicity_by_date <- aggregate(stop_and_search, by=list(stop_and_search$Officer.defined.ethnicity, dates), FUN=length)
vars <- unique(ethnicity_by_date$Group.1)
p <- ggplot(ethnicity_by_date, aes(ethnicity_by_date$Group.2, ethnicity_by_date$Date, group = ethnicity_by_date$Group.1)) +
  geom_line() +
  geom_point() +
  geom_dl(aes(label=ethnicity_by_date$Group.1),
          method=list(dl.combine("first.points", "last.points"), cex = 0.7))
p+aes(colour=ethnicity_by_date$Group.1)+
  scale_linetype(guide="none")

# Bunch of charts exploring the data
dotchart(table(stop_and_search$Self.defined.ethnicity), main="Self-reported ethnicity")
dotchart(table(stop_and_search$Officer.defined.ethnicity), main="Officer-reported ethnicity")
dotchart(table(stop_and_search$Gender), main="Gender")
dotchart(table(stop_and_search$Age.range), main="Age Range")
dotchart(table(stop_and_search$Legislation), main="Legislation")
dotchart(table(stop_and_search$Object.of.search), main="Object of search")
dotchart(table(stop_and_search$Outcome), main="Outcome")
dotchart(table(stop_and_search$Removal.of.more.than.just.outer.clothing), main="Removal of more than just outer clothing")
dotchart(table(stop_and_search$geocode_failed), main="failed to geocode")
dotchart(table(stop_and_search$admin_ward), main="Admin Ward")

# Which wards get the most stop and searches?
working_data <- stop_and_search
working_data$admin_ward <- paste0("`", stop_and_search$admin_ward, "`")
wards <- aggregate(stop_and_search, by=list(stop_and_search$admin_ward_code, stop_and_search$admin_ward), FUN = length)[,0:3]
colnames(wards) <- c("code", "ward", "count")
dotchart(wards$count, labels = wards$code)

# Which wards are outliers in terms of very few stop and searches?
# Note this is purely on numbers, we might care more about whether wards are actually in GM or not
# outlier_wards <- filter(wards, wards$count <10)
# stop_and_search_without_outliers <- filter(stop_and_search, ! stop_and_search$admin_ward_code %in% outlier_wards$code)

# Render some pie charts of outcomes for a selection of wards
wards <- c("Moss Side", "Moston", "Withington", "Saddleworth West and Lees", "Saddleworth South")
outcomes <- table(stop_and_search$Outcome)
par(mfrow = c(1,5))
for(i in wards){
  #print(i)
  ward_data <- stop_and_search %>%
    filter(admin_ward == i)
  pie(table(ward_data$Type), main=i)
}

# Function to return the number of decimal places in a latitude/longitude
# This is here in the assumption that the varying decimal places actually mean something
# As far as I can tell, they don't
decimalplaces <- function(x) {
  if ((x %% 1) != 0) {
    nchar(strsplit(sub('0+$', '', as.character(x)), '.', fixed=TRUE)[[1]][[2]])
  } else {
    return(0)
  }
}

find_hull = function(df) df[chull(df$x, df$y), ]

# Slim down the categories of outcomes
action_type = function(df) {
  if (df == 'Nothing found - no further action' || df == 'A no further action disposal') {
    return('Nothing')
  } else if (df == 'A no further action disposal' || df == 'Community resolution' || df == 'Local resolution' || df == 'Offender cautioned' || df == 'Caution (simple or conditional)' || df == 'Offender given penalty notice' || df == 'Penalty Notice for Disorder') {
    return('Minor')
  } else if (df == 'Arrest' || df == 'Suspect arrested' || df == 'Summons / charged by post' || df == 'Suspect summonsed to court' || df == 'Penalty Notice for Disorder') {
    return('Major')
  } else if (df == 'Offender given drugs possession warning' || df == 'Khat or Cannabis warning') {
    return('Drugs')
  } else {
    return('Unknown')
  }
}

# Build a new dataframe with only GM stops and searches
# AdminAreas.csv comes from https://www.doogal.co.uk/AdminAreasCSV.ashx
admin_areas <- read.csv('AdminAreas.csv')
gm_wards <- filter(admin_areas, admin_areas$County.Code == "E11000010")
stop_and_search_without_outliers <- filter(stop_and_search, stop_and_search$admin_ward_code %in% gm_wards$Ward.Code)


# Build a new dataframe of GM-only outcomes and locations, using our categorisation from above, ignoring anything without an outcome
locations <- data.frame(stop_and_search_without_outliers$Outcome, stop_and_search_without_outliers$Latitude, stop_and_search_without_outliers$Longitude)
locations$stop_and_search_without_outliers.Outcome <- sapply(locations$stop_and_search_without_outliers.Outcome, action_type)
locations <- na.omit(locations)

# Random dice roll, gauranteed to be random
set.seed(6)

# Use the Elbow method to pick the count of clusters
k.max <- 10
data <- locations
# Outcome has to be numeric for the elbow graphing
data$stop_and_search_without_outliers.Outcome <- sapply(locations$stop_and_search_without_outliers.Outcome, function(x){
  if (x=='Nothing') {
    return(0)
    
  } else if (x=='Minor') {
    return(1)
  } else if (x=='Major') {
    return(2)
  } else if (x=='Drugs') {
    return(3)
  } else {
    return(4)
  }
})
wss <- sapply(1:k.max, function(k){kmeans(data, k, nstart=50,iter.max=15)$tot.withinss})
wss
par(mfrow=c(1,1))
plot(1:k.max, wss,
     type="b", pch=19,frame=FALSE,
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares")

# Sample the data into training and testing dataframes
idx = sample(1:nrow(locations), size=nrow(locations)*0.5)
train.idx = 1:nrow(locations) %in% idx
test.idx = ! 1:nrow(locations) %in% idx
train = locations[train.idx, 2:3]
test = locations[test.idx, 2:3]
labels = locations[train.idx, 1]

# Perform the fitting
library(class)
fit = knn(train, test, labels, k = 2) # k=2 being the number of clusters, from the Elbow Graph
fit

# Prepare the graph data
plot.df = data.frame(test, predicted = fit)
plot.df1 = data.frame(x = plot.df$stop_and_search_without_outliers.Longitude,
                      y = plot.df$stop_and_search_without_outliers.Latitude,
                      predicted = plot.df$predicted)
boundary = ddply(plot.df1, .variables = "predicted", .fun = find_hull)

# Finally plot the clusters
ggplot(plot.df, aes(stop_and_search_without_outliers.Longitude, stop_and_search_without_outliers.Latitude, color = predicted, fill = predicted)) +
  geom_point(size = 5) +
  geom_polygon(data = boundary, aes(x,y), alpha=0.2)
# Perhaps the outcome is more likely to be 'Nothing' around the edges of Greater Manchester
