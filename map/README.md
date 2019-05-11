# Ward Map

This is a python app which serves a map of wards, with colors relating to the number of records.  It's currently limited to a simple count of records per ward, but could be extended to allow more detailed queries.

## Usage

This requires Python 3.6+ to run

```
make wards.json # to download and convert a huge kml file to geojson
make # to actually run it
open http://localhost:8002 # to view it in a browser
```

## TODO

* Searching through a 500MB json file on every page load is slow
* Dependencies clash with Datasette (run `pip uninstall click` if you need to install Datasette again)