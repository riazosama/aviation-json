SHELL = /bin/bash
MAKEFLAGS += --no-print-directory --silent
export PATH := ./node_modules/.bin:$(PATH):./bin
LINT_DIR = $(wildcard bin/* *.js src/*.js test/*.js scrapers/*.js spikes/*.js test/*/*.js scrapers/*/*.js spikes/*/*.js)

default: setup test

setup:
	npm install

# lint
lint:
	echo "Linting started..."
	eslint $(LINT_DIR)
	echo "Linting finished without errors"

test: lint
	mocha test

dev:
	mocha test -w

test-coverage-report:
	echo "Generating coverage report, please stand by"
	test -d node_modules/nyc/ || npm install nyc
	nyc mocha && nyc report --reporter=html
	open coverage/index.html

# For coveralls integration on Travis-ci
test-coveralls:
	npm install nyc
	nyc npm test && nyc report --reporter=text-lcov | coveralls


aviation-json:
	./bin/cleanup airline_destinations
	./bin/cleanup airlines
	./bin/cleanup airport_airlines
	./bin/cleanup airport_cities
	./bin/cleanup airport_runways
	./bin/cleanup airports
	./bin/cleanup city_airports

sync: aviation-scraper aviation-json

aviation-scraper: setup
	aviation-scraper -d
	aviation-scraper -l
	aviation-scraper -c
	aviation-scraper -a

help:
	./bin/cleanup -h

.PHONY: test