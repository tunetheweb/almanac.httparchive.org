#!/bin/bash

# exit when any command fails
set -e

# This script must be run from src directory
if [ -d "src" ]; then
  cd src
fi

echo "Installing and testing python environment"
python -m pip install --upgrade pip
pip install -r requirements.txt
pytest

echo "Installing node modules"
npm install

echo "Building website"
#npm run generate

echo "Starting website"
python main.py background &
sleep 5

echo "Running ps"
ps

echo "Testing website"
ps | grep "python main.py"
echo "Check website is running - use [p]ython so we don't match the grep itself"
ps | grep "[p]ython main.py"
echo "Running status code tests"
npm run test

echo "Website started successfully"
