from starlette.applications import Starlette
from starlette.staticfiles import StaticFiles
from starlette.responses import JSONResponse
from starlette.responses import FileResponse
from contextlib import closing
import sqlite3
import json
import uvicorn
import sys

# Config
DATABASE = '../stopandsearch.db'
DEBUG = True
WARDS = 'wards.json'


def connect_db():
    return sqlite3.connect(DATABASE)


# get a list of unique wards in the database
def relevant_wards_list():
    with closing(connect_db()) as db:
        ward_ids = db.execute('''
        SELECT DISTINCT admin_ward_code
        FROM stop_and_search
        WHERE admin_ward_code IS NOT NULL;
        ''').fetchall()
    return [elt[0] for elt in ward_ids]


# get a count of records for each ward code
def count_by_wards():
    count = {}
    with closing(connect_db()) as db:
        rows = db.execute('''
        SELECT admin_ward_code, COUNT(*)
        FROM stop_and_search
        WHERE admin_ward_code IS NOT NULL
        GROUP BY admin_ward_code''').fetchall()
    for row in rows:
        count[row[0]] = row[1]
    return count


# filter wards.json using the list of unique wards
def relevant_wards_geojson():
    wards_list = relevant_wards_list()
    with open(WARDS) as json_file:
        data = json.load(json_file)
    relevant_features = list(filter(lambda x: x['properties']['wd18cd'] in wards_list, data['features']))  # noqa: E501
    data['features'] = relevant_features
    return data


def feature_with_count(feature, count):
    feature['results'] = count[feature['properties']['wd18cd']]
    return feature


def wards_with_count():
    geojson = relevant_wards_geojson()
    wards_count = count_by_wards()
    features = list(map(lambda x: feature_with_count(x, wards_count), geojson['features']))  # noqa: E501
    geojson['features'] = features
    return geojson


app = Starlette(debug=DEBUG)
app.mount('/static', StaticFiles(directory='static'), name='static')
@app.route('/')
async def index(request):
    return FileResponse('static/dev.html')


@app.route('/api/wards')
async def list_wards(request):
    return JSONResponse(wards_with_count())

if __name__ == '__main__':
    if sys.argv[1] == 'generate':
        print("Generating static/data/wards.json")
        wards = wards_with_count()
        with open('static/data/wards.json', 'w') as outfile:
            json.dump(wards, outfile)
    else:
        uvicorn.run(app, host='0.0.0.0', port=8002)
