#!/bin/bash

######################################
## Custom Web Almanac script        ##
######################################
#
# This script installs all the required dependencies needed to run the
# Web Almanac website providing you have python and node installed.
#
# It also runs our tests to ensure the website is working for all pages.
#
# It is used by various GitHub actions to build and test the site.
#

# exit when any command fails instead of trying to continue on
set -e

TEMP_TEMPLATES_DIRECTORY=templates_new

# This script must be run from src directory
if [ -d "src" ]; then
  cd src
fi

if [ -d "${TEMP_TEMPLATES_DIRECTORY}" ]; then
  echo "${TEMP_TEMPLATES_DIRECTORY} already exists. Exiting"
  exit 1
fi

echo "Installing node modules"
npm install

echo "Building website"
npm run generate

echo "Backing up templates"
cp -r templates "${TEMP_TEMPLATES_DIRECTORY}"

echo "Checkout main branch"
git checkout main

echo "Reinstalling node modules"
rm -rf node_modules
npm install

echo "Building website"
npm run generate

echo "Diff the two folders"
#Don't fail if there are differences so turn off that
set +e
DIFF_OUTPUT=$(diff -r templates "${TEMP_TEMPLATES_DIRECTORY}")
set -e

echo "Differences:"
echo "${DIFF_OUTPUT}"

if [ -n "${DIFF_OUTPUT}" ]; then
  PR_COMMENT="The following diffs were found:%0A```${DIFF_OUTPUT}```"
  echo "::set-env name=PR_COMMENT::\"${PR_COMMENT}\""
fi

echo "Removing templates backup"
rm -rf "${TEMP_TEMPLATES_DIRECTORY}"

echo "Comparison complete"
