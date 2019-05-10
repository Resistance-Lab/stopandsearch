venv/bin/python:
	virtualenv venv
	venv/bin/pip install -r requirements.txt

.PHONY: run
run: venv/bin/python
	datasette serve stopandsearch.db -h 0.0.0.0

.PHONY: test
test: venv/bin/python
	venv/bin/flake8 geocode.py
	venv/bin/nosetests
