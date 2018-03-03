# genesapi-data
Source datasets from GENESIS instances and their meta descriptions

## Folders:

- `src`: contains downloaded csv files and corresponding yaml specification for each file
- `keys`: contains metadata about keys ("Merkmale")

## Data sources

- GENESIS instances (they don't contain the same datasets)
    - [GENESIS destatis](https://www-genesis.destatis.de/genesis/online)
    - [regionalstatistik](https://www.regionalstatistik.de/genesis/online/)

- Metadata from [govdata.de](http://govdata.de):
    - https://www.govdata.de/dump/govdata.de-metadata-daily.json.gz

## How to load data into `datenguide-backend`

### 1. Put csv-file to the right place

Raw (unprocessed) csv files from the sources mentioned above should be put into the `src`-folder. The naming convention would be the identifier (unique id) for this table in the GENESIS platforms, for example `23112-01-04-4.csv`

## License

The software and documentation in this repo is published under [MIT license](https://github.com/datenguide/genesapi-data/blob/master/LICENSE).

The [source data](https://github.com/datenguide/genesapi-data/tree/master/src) was originally published by the [Statistische Ämter des Bundes und der Länder](https://www.regionalstatistik.de/) under the [dl-de/by-2-0 license](https://www.govdata.de/dl-de/by-2-0).

