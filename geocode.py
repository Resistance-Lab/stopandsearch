import requests
import sqlite3

# The following three items are the only things you may need to edit here
REQUEST_LIMIT = 100  # Maximum number of locations to send to the API at once
DATABASE = 'stopandsearch.db'  # The filename of the database
POSTCODES_API = 'https://api.postcodes.io/postcodes'  # The API endpoint


# Get a database connection
def connect_db():
    return sqlite3.connect(DATABASE)


# Build the request data to send to the API
def generate_query(rows):
    lat_lon = {"geolocations": []}
    for row in rows:
        lat_lon['geolocations'].append(
            {"longitude": row[1], "latitude": row[0]}
        )
    return lat_lon


# Actually query the API
def bulk_query(rows):
    body = generate_query(rows)
    # print(body)
    r = requests.post(url=POSTCODES_API, json=body)
    return r.json()


# Actually update the database
def update_db(db, results):
    if results['status'] != 200:
        print("got bad data back: %s" % results)
        return
    for result in results['result']:
        # print(result)
        if result['result'] is None or len(result['result']) == 0:
            print("location not found: %s" % result)
            db.execute("""
            UPDATE stop_and_search
            SET geocode_failed = 1
            WHERE latitude = ?
            AND longitude = ?
            """, (result['query']['latitude'], result['query']['longitude']))
            db.commit()
            continue
        db.execute("""
        UPDATE stop_and_search
        SET admin_ward=?,
        postcode=?,
        lsoa=?,
        geocode_failed=0
        WHERE latitude=?
        AND longitude=?
        """, (result['result'][0]['admin_ward'],
              result['result'][0]['postcode'],
              result['result'][0]['lsoa'],
              result['query']['latitude'],
              result['query']['longitude']))
        db.commit()


# Query how many rows we've not geocoded at yet
def get_remaining(db):
    return db.execute("""
    SELECT COUNT(*)
    FROM stop_and_search
    WHERE geocode_failed IS NULL
    """).fetchone()[0]


# Add a column, ignoring errors about duplicate columns
def maybe_add_column(db, query):
    try:
        print(query)
        db.execute(query)
        db.commit()
    except sqlite3.OperationalError:
        pass


# Add the extra columns needed for geocoded data
def add_columns(db):
    maybe_add_column(db, 'ALTER TABLE stop_and_search ADD admin_ward text')
    maybe_add_column(db, 'ALTER TABLE stop_and_search ADD postcode text;')
    maybe_add_column(db, 'ALTER TABLE stop_and_search ADD lsoa text;')
    maybe_add_column(db, 'ALTER TABLE stop_and_search ADD geocode_failed integer;')  # noqa: E501


def main():
    with connect_db() as db:
        add_columns(db)
        remaining = get_remaining(db)
        print("%d remaining" % remaining)

        while remaining > 0:
            # This is more efficient if there are duplicate locations
            rows = db.execute("""
                    SELECT DISTINCT latitude, longitude
                    FROM stop_and_search
                    WHERE geocode_failed IS NULL
                    LIMIT ?""",
                              [REQUEST_LIMIT]
                              ).fetchall()
            postcodes = bulk_query(rows)
            update_db(db, postcodes)

            remaining = get_remaining(db)
            print("%d remaining" % remaining)


if __name__ == "__main__":
    main()
