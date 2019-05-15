# install.package("RSQLite")

# load the data from the database
library(DBI)
con <- dbConnect(RSQLite::SQLite(), "../stopandsearch.db")
stop_and_search <- dbReadTable(con, "stop_and_search")
dbDisconnect(con)

# parse the dates
stop_and_search['Date'] <- as.POSIXct(stop_and_search$Date,format="%Y-%m-%dT%H:%M:%OS", tz="UTC")

# save to an Rdata file
save(stop_and_search, file="data/stop_and_search.Rdata")
