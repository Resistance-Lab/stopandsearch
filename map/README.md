# Ward Map

This is a python app which serves a map of wards, with colors relating to the number of records.  It's currently limited to a simple count of records per ward, but could be extended to allow more detailed queries.

## Usage

### Using Docker

```
make -f Makefile.docker deps
make -f Makefile.docker wards.json
make -f Makefile.docker run
```

If `make -f Makefile.docker wards.json` fails, try increasing the memory available to Docker (works for me on 8GB, defaults to 2GB).

### Not using Docker

This requires Python 3.6+ to run

```
make deps # run once, to ensure dependencies are installed
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

To simplify all of this, you can also run it in Docker.  In which case change `make` to `make -f Makefile.docker` in all of the above instructions.

Regardless of how you run it, generating the geojson file will take a long time.  And on machines with limited resources, may even fail to run at all.

## Development

stopandsearchapi.py handles both generating the static data for the site, and can also render the complete site.  dev.html is the development site that this runs, whereas the static site uses index.html.

## TODO

* Dependencies clash with Datasette (run `pip uninstall click` if you need to install Datasette again)
