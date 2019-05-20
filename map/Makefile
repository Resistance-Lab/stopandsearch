.PHONY: run
run:
	python stopandsearchapi.py
.PHONY: deps
deps:
	pip install -r requirements.txt
wards.kml:
	wget -O wards.kml https://opendata.arcgis.com/datasets/7f535363afdc4881a1c77fe90cfa7713_1.kml
wards.json: wards.kml
	echo this will take a long time to run
	k2g wards.kml .
	mv wards.geojson wards.json
.PHONY: test
test:
	flake8 stopandsearchapi.py
	nosetests
static/data/wards.json: wards.json
	python stopandsearchapi.py generate
