load("data/stop_and_search.Rdata")
library(ggplot2)
library(directlabels)
library(plyr)

working_data <- stop_and_search

dates <- as.Date(stop_and_search$Date)

ethnicity_by_date <- aggregate(stop_and_search, by=list(stop_and_search$Self.defined.ethnicity, dates), FUN=length)
vars <- unique(ethnicity_by_date$Group.1)

p <- ggplot(ethnicity_by_date, aes(ethnicity_by_date$Group.2, ethnicity_by_date$Date, group = ethnicity_by_date$Group.1)) +
  geom_line() +
  geom_point() +
  geom_dl(aes(label=ethnicity_by_date$Group.1),
          method=list(dl.combine("first.points", "last.points"), cex = 0.7))
p+aes(colour=ethnicity_by_date$Group.1)+
  scale_linetype(guide="none")

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

working_data$admin_ward <- paste0("`", stop_and_search$admin_ward, "`")
wards <- aggregate(stop_and_search, by=list(stop_and_search$admin_ward_code, stop_and_search$admin_ward), FUN = length)[,0:3]
colnames(wards) <- c("code", "ward", "count")
dotchart(wards$count, labels = wards$code)
