```
brew install python
pip3 install datasette csvs-to-sqlite
```

Download relevant data, being sure to select 'include stop and search' data

`https://data.police.uk/data/`

Make a folder for it, and it it in 'data'

Make one table with all stop and search in it

`csvs-to-sqlite ./data/*/*stop-and-search.csv stop-and-search.db -t stop_and_search`

Register for Heroku

Install and login to the CLI

`datasette publish heroku stopandsearch.db -n stopandsearch`
