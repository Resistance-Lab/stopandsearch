# Stop and Search browser

A tool to analyse UK stop and search data. Currently focussed on Greater Manchester.

## Install process

For Mac OS, you will need Python and the Datasette tool, which does all the heavy lifting.

```
brew install python
pip3 install -r requirements.txt
```

Download relevant data from the areas you're interested in in the police's database, being sure to select 'include stop and search' data.

`https://data.police.uk/data/`

Extract the resulting zip file into the `./data` folder.

Make one table with all stop and search in it. This command concatenates all the monthly results into one table (indicated by `-t` flag)

`csvs-to-sqlite ./data/*/*stop-and-search.csv stopandsearch.db -t stop_and_search`

## Running it

### Locally

To view it on your local computer, run the following command and navigate to `http://localhost:8001/` in your browser.

`datasette serve stopandsearch.db`

###  On the web

Register for Heroku, and download and install the CLI.

Execute the following command. You're done!

`datasette publish heroku stopandsearch.db -n stopandsearch --install=datasette-cluster-map`


## Geocoding locations

By default the API only provides lat/lng data. `ruby geocode.rb` will add ward and lsoa data. First though, you'll need to add some extra columns from the sqlite command line as follows.

```
sqlite stopandsearch.db
ALTER TABLE stop_and_search ADD admin_ward text
ALTER TABLE stop_and_search ADD postcode text;
ALTER TABLE stop_and_search ADD lsoa text;
```
