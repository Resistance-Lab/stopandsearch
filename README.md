# Stop and Search browser

A tool to analyse UK stop and search data. Currently focused on Greater Manchester.

## Install process

You will need Python and the Datasette tool, which does all the heavy lifting.  For Mac OS you can achieve this with the following

```
brew install python
pip3 install -r requirements.txt
```

Download relevant data from the areas you're interested in from the [police.uk](https://data.police.uk/data/) database, being sure to select 'include stop and search' data.

Extract the resulting zip file into the `./data` folder.

Make one table with all stop and search in it. This command concatenates all the monthly results into one table (indicated by `-t` flag)

`csvs-to-sqlite ./data/*/*stop-and-search.csv stopandsearch.db -t stop_and_search`

## Running it

### Locally

To view it on your local computer, run the following command and navigate to http://localhost:8001 in your web browser.

`datasette serve stopandsearch.db`

You can add `-h 0.0.0.0` if you want other computers on your network to access it.

###  On the web

Register for Heroku, and download and install the CLI.

Execute the following command. You're done!

`datasette publish heroku stopandsearch.db -n stopandsearch --install=datasette-cluster-map datasette-vega`

## Geocoding locations

By default the API only provides lat/lng data. `python geocode.py` will add ward, postcode and lsoa data.

You can query which locations failed to geocode correctly with:

`SELECT * FROM stop_and_search WHERE geocode_failed = 1;`

You can reset this with:

`UPDATE stop_and_search SET geocode_failed = NULL WHERE geocode_failed = 1;`
