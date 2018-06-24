#!/bin/sh

genesapi clean ./src defaults.yaml --target-dir ./cleaned --dtypes ./build/dtypes.json
genesapi transform ./cleaned --dtypes ./build/dtypes.json > ./build/db.csv
genesapi build_tree ./build/db.csv ./build/keys.json --fix ./fix_be_hh.yaml > ./build/tree.json

