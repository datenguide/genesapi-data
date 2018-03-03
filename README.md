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

## How to load data into `genesapi`

The data import is partly automated via [a script](https://github.com/datenguide/datenguide-backend/blob/master/pipeline/load.py#L47) but first needs some manual work. For each downloaded csv-file you need to create a corresponding yaml-file that basically specifies which options to use for the import script.

What we basically do here is to convert tabular data into a tree structure. This is how this wrangling looks like with the base population dataset - first, lets have a look at the downloaded, unprocessed csv file:

### source

```csv
GENESIS-Tabelle: 12411-01-01-4
Bevölkerungsstand: Bevölkerung nach Geschlecht;;;;
- Stichtag 31.12. -;;;;
regionale Tiefe: Kreise und krfr. Städte;;;;
Fortschreibung des Bevölkerungsstandes;;;;
Bevölkerungsstand (Anzahl);;;;
;;31.12.2015;31.12.2015;31.12.2015
;;Insgesamt;männlich;weiblich
DG;Deutschland;82175684;40514123;41661561
01;  Schleswig-Holstein;2858714;1399458;1459256
01001;      Flensburg, Kreisfreie Stadt;85942;42767;43175
01002;      Kiel, Landeshauptstadt, Kreisfreie Stadt;246306;119835;126471
01003;      Lübeck, Hansestadt, Kreisfreie Stadt;216253;103683;112570
01004;      Neumünster, Kreisfreie Stadt;79197;39118;40079
01051;      Dithmarschen, Landkreis;132917;65512;67405
```

As you can see, that's a bit messy. There are some lines at the top we don't need, there is a lot of whitespace and there are not the column names that we actially want – because we want to use the keys ("Merkmale") that the GENESIS database uses instead of the "human readable" names here.

Therefore our script first converts this into a `<fname>_cleaned.csv` like this:

### target

```csv
_id,BEVSTD__GEST,BEVSTD__GESM,BEVSTD__GESW
DG,82175684,40514123,41661561
01,2858714,1399458,1459256
01001,85942,42767,43175
01002,246306,119835,126471
01003,216253,103683,112570
01004,79197,39118,40079
01051,132917,65512,67405
01053,192999,94684,98315
01054,163960,80319,83641
```

As you can see, no we have the actual key names and a much more cleaner csv layout.

You may recognize the double underscores in the column names: That's where the *tree* magic happens.

Double underscores indicate the nested structure for the tree. In this example, these column names:

```
BEVSTD__GEST
BEVSTD__GESM
BEVSTD__GESW
```

would later resolve into a tree structure and provide a `graphql`-query like this:

```graphql
{
  BEVSTD {
    GEST
    GESM
    GESW
  }
}
```

### So, to tell the script how to turn `source` into `target`

Thats the manual work that needs to be done.

#### 1. Put csv-file to the right place

Raw (unprocessed) csv files from the sources mentioned above should be put into the `src`-folder. The naming convention would be the identifier (unique id) for this table in the GENESIS platforms, for the example above this would be `12411-01-01-4.csv`

Source csv files can be automatically downloaded from [regionalstatistik.de](https://regionalstatistik.de), based on a metadata index from [govdata.de](http://govdata.de):


```bash
# a) Download and unzip metadata from govdata.de:

wget https://www.govdata.de/dump/govdata.de-metadata-daily.json.gz
gzip -d govdata.de-metadata-daily.json.gz
```

```javascript
// b) Extract the relevant URLs (e.g. using NodeJS):

data=require("./govdata.de-metadata-daily.json"); // load json into memory
var f=data.filter(a=>/regionalstatistik/.test(a.url)).map(b=>b.resources.filter(a=>a.format=="CSV").map(a=>a.url)).reduce((a,b)=>a.concat(b)).join('\n'); // filter, filter CSV files, get urls, flatten array, concantenate with newspaces
fs.writeFile("links.txt", f, function(err) {if(err) {}}); // write to links.txt
```

```bash
# c) Download individual CSV files:

wget -i links.txt
```

#### 2. Inspect csv-file

The tables from the GENESIS platforms can have different levels of complexity:
- Simple: Just a few columns with one row headers (no nested levels)
- Complex: Some columns but with more rows for headers, this means the column headers are "nested" in a way
- Even more complex: Tables that contain row values that should actually be column headers, so they need to be *pivoted* first.

#### 3. Create specification how to wrangle it

Create a `yaml`-file in the `src`-folder with the same name as the source csv file. For the population example above this would be then `12411-01-01-4.yaml`

It looks exactly like this:

```yaml
skip: 8
skipfooter: 4
names:
  - _id
  - name
  - BEVSTD__GEST
  - BEVSTD__GESM
  - BEVSTD__GESW
subset:
  - _id
  - BEVSTD__GEST
  - BEVSTD__GESM
  - BEVSTD__GESW
```

- `skip`: We skip the first 8 rows of the source file because it contains data we don't need
- `skipfooter`: We also strip out the last 4 lines for the same reason
- `names`: We give new column names in exactly this order. As you see, we already use the *double underscore technique* to indicate the nested keys. The `_id`-column is special to link the different datasets to the corresponding regions identified via their `id`.
- `subset`: We only use these columns because we don't need the names. We could also use the `exclude` option for this to get the same result:

```yaml
exclude:
    - name
```

There are many more options possible in this yaml specs. Have a look at the [docstring of the script](https://github.com/datenguide/datenguide-backend/blob/master/pipeline/load.py#L47)


## License

The software and documentation in this repo is published under [MIT license](https://github.com/datenguide/genesapi-data/blob/master/LICENSE).

The [source data](https://github.com/datenguide/genesapi-data/tree/master/src) was originally published by the [Statistische Ämter des Bundes und der Länder](https://www.regionalstatistik.de/) under the [dl-de/by-2-0 license](https://www.govdata.de/dl-de/by-2-0).
