# Ward Map

This is a python app which serves a map of wards, with colors relating to the number of records.  It's currently limited to a simple count of records per ward, but could be extended to allow more detailed queries.

## Usage

This requires Python 3.6+ to run

```
make wards.json # to download and convert a huge kml file to geojson
make # to actually run it
open http://localhost:8002 # to view it in a browser
```

You can also render this into a static site:

```
make static/data/wards.json
cd static
python -m http.server || python -m SimpleHTTPServer
```

## Development

stopandsearchapi.py handles both generating the static data for the site, and can also render the complete site.  dev.html is the development site that this runs, whereas the static site uses index.html.

## TODO

* Dependencies clash with Datasette (run `pip uninstall click` if you need to install Datasette again)