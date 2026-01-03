# BarnebyLives! Running pipeline

## Purpose

The purpose of this script is to assist botanical collectors in
accessioning their collections. It is the central component of this
entire package. Here we will go over ensuring that values which will be
printed onto herbarium labels and uploaded into databases are accurate.

It is our experience that many herbaria now request digital copies of
collection information in their own format. This script aims to
alleviate the investment in time this requires, and in doing so allow
the collector more time to do less onerous tasks; such as collection and
study.

While in theory all of the tasks in this script could be automated,
doing so neglect the opinions of local taxonomic authorities. While
several database options for updating collections (and spell checking
names) which are current and well curated (e.g. Kew Plants of the World)
exist, we feel many proposals and combinations require interpretation by
those in the regions attempting to understand the material at hand.

This script will perform the following tasks.

#### Geographic

**1)** Convert coordinates to a Decimal Degrees format, if needed
(e.g. from DMS 72\*17.55 -\> 72.29861).  
**2)** Retrieve appropriate political place names. (i.e. State,
County).  
**3)** Retrieve accurate elevation values of coordinates.  
**4)** Retrieve Public Land Ownership (e.g. United States Forest
Service, Bureau of Land Management).  
**5)** Project coordinates from one system to another, if needed
(e.g. from an UTM zone to WGS84).  
**6)** Retrieve Cadastral data from the PLSS for Township, Range,
Section (TRS)

#### Temporal

**1)** Provide a ‘written’ date in the style of choosing. (e.g. 12th May
2021), for the purpose of labeling.

#### Taxonomic

**1)** Provide a ‘spell check’ for family.  
**2)** Provide a ‘spell check’ for genus.  
**3)** Provide a ‘spell check’ for epithet.  
**4)** Provide a ‘spell check’ for authorities.  
**5)** In addition you may check for synonymy at each of these taxonomic
levels, and accept or reject suggestions.

#### Directions

I preface this with the observation that a good deal of collectors and
curators consider these data non-essential now. Regardless, if you are
so inclined to gain access to a free google maps account these services
are provided.

**1)** Write directions, from a town of notable size or repute, to the
closet parking spot to the collection locality.

Note that these directions may not reflect the actual route traveled by
the collectors, but rather what Google Maps thinks is optimal - at the
time of the query. *Caveat emptor.*

## Usage

Files required to use this script:

- PAD-US database for retrieving land ownership information if needed
  (*note does not include identities of Private owners*).
- World Flora Online static copy of the database.

``` r
# devtools::install_github('sagesteppe/BarnebyLives')
library(tidyverse)
library(BarnebyLives)
```

load data

``` r
df <- uncleaned_collection_examples
```

### Ensure Coordinates and Dates and formatted appropriately

Date parsing, e.g. convert date into congruent museum formats (month in
roman numerals, or spelled out). This step assumes that you are
recording your dates in the American format of (month/day/year), rather
than the internationally more common format (day/month/year). We will
also parse out the day of month, month of year, and year, which is used
in multiple possible downstream software.

``` r
data <- date_parser(df, coll_date = 'Date_digital', det_date = 'Determined_date')

dplyr::select(data, starts_with('Date')) |>
  head()
```

#### Conversion of Degrees Minutes Seconds (DMS) to Decimal Degrees (DD).

The DMS format is still used in a few applications we will convert this
to the more generally utilized DD format. We will maintain both formats
in the data set, so others have them readily available for other uses
aside from creating herbarium labels.

``` r
data <- dms2dd(data, dms = F)

dplyr::select(data, starts_with(c('latitude', 'longitude'))) %>% 
  utils::head()
```

Several spreadsheet software auto-increment numeric columns by default.
We try to identify that issue here.

``` r
data <- autofill_checker(data)

dplyr::select(data, Long_AutoFill_Flag, Lat_AutoFill_Flag) |> 
  utils::head()
```

For internal usage and data acquisition we will make data set explicitly
spatial, rather than just holding coordinates in a column. This is also
required to write out data in a format readable by Google Earth or
another Geographic Information System.

``` r
data <- coords2sf(data)

data |>
  select(Collection_number, geometry) |>
  str() # now we can see that it is an sf object
```

### Retrieve Political/Administrative Information

BarnebyLives! will retrieve various components of both political and
administrative information. All of these data which include: The
*state*, and *county* of collection, and the *township, range, section
(TRS)* from the Public Land Survey System (PLSS). It will also determine
whether a Federal or State Agency manages or owns the land which were
collected from, and if so return the name of it. If either the United
States Forest Service or Bureau of Land Management does manage the land,
it will return information on grazing allotments.

Retrieve State, County, Ownership, TRS, and allotment information

``` r
p <- '/media/steppe/hdd/Barneby_Lives-dev/geodata'

data <- political_grabber(data, y = 'Collection_number', path = p)
```

### Geographic Information for Locality info

Many younger collectors use Site Names which are quite broad, we
advocate for the usage of locality names.

A locality name is going to provide the relation between a site and the
actual collection area through a distance and azimuth. All of the sites
which we use as prospective identifiers are from the Geographic Names
Information System, these names have undergone standardization, and
general cleaning up to better reflect currently acceptable naming
practices (i.e. misogynistic and racist names have largely - if not
entirely - been removed). Using GNIS allows for places to be
unambiguously related to each other. While I hate saying that a
collection site is XX km from a river at 121 degrees, because well -
just think about it, that seems to be what people want.

Retrieve Nearest GNIS place name, and azimuth from it.

``` r
data <- site_writer(data, path = p)
```

### Site characteristics

BarnebyLives acquires a range of characteristics which are useful to
describe the physical environment, these are: elevation (both meters and
feet), slope, aspect, surficial geology, and geomorphons.

Here are some details on some of the data sets which we are using. All
elevation data come from [DEM90](https://www.earthenv.org/DEM), as the
name implies this data set is at roughly 90 meters of roughly in the X
and Y dimensions. This product is then used to derive both slope (in
degrees) and aspect (in degrees) information. Slope conveys the change
in elevation between adjacent cells, while aspect discusses which way
water would flow downslope. An aspect of East states that water would
flow downslope to the east. Surficial geology data are acquired from the
United States Geological Survey, it works very well for characterizing
major geology types in an area, although you may be on a minor inclusion
within that material. Geomorphons are a bit more peculiar, they may
refer to several things, but here they refer to [10 standardized
landform
positions](https://www.sciencedirect.com/science/article/abs/pii/S0169555X12005028)
[Geomorpho90m](https://portal.opentopography.org/dataspace/dataset?opentopoID=OTDS.012020.4326.1),
which are useful for characterizing landform position. These are useful
for spatial ecology and describe where on the landscape the population
was broadly located.

``` r
data <- physical_grabber(data, path = p)
```

### Taxonomic

BarnebyLives performs multiple operations related to taxonomy and
nomenclature. The function **spell_check()**, will attempt to determine
whether the supplied binomial scientific name, and family are spelled
correctly and offer suggestions if they are not.

This function requires that the first few letters of the generic name
and epithet are spelled correctly. It will run a spell check against
nearly all published plant name spellings, and search for the most
similar spelling within these lists if material is not found. It will
operate on both pieces of the binomial separately, and can work to
identify the species within the context of genus.

``` r
p <- '/media/steppe/hdd/Barneby_Lives-dev/taxonomic_data'
data <- spell_check(data, path = p)

data <- spell_check(data = data, column = 'Full_name', path = p)
data <- family_spell_check(data, path = p)
```

A similar check is to determine that the author whom is cited for
describing the species, or transferring it to another genus, is spelled
using the standard author abbreviations. This check operates under a
similar manner to **spell_check()**. The list which is consults *is*
comprehensive, within a few years, of all taxonomists whom have
published plant species.

``` r
data <- author_check(data, path = p)
```

The final process in the taxonomic step is to ensure that the spellings
of any species noted in the *vegetation*, or *associates* fields are
accurate. These *will not* then be submitted to Kew, as the fields could
quickly overwhelm the API.

``` r
data <- associates_spell_check(data, 'Associates', path = p) # we can run on both columns. 
data <- associates_spell_check(data, 'Vegetation', path = p)
```

Remove the collected species from associated species lists. Many
collectors include the focal collection when performing data entry.

``` r
data <- associate_dropper(data, 'Full_name', col  = 'Associates')
data <- associate_dropper(data, 'Full_name', col  = 'Vegetation')
```

After BarnebyLives verifies spelling, it submits names to Plants of the
World Online to check for synonymy. BL will not automatically overwrite
your submitted species - interpretation of results is important,
especially as *spell_check* may occasionally mis-match material.

``` r
names <- sf::st_drop_geometry(data) %>% 
  pull(Full_name) # should be a vector fo searching

pow_res <- lapply(names,
      powo_searcher) %>% 
  bind_rows()
data <- bind_cols(data, pow_res)

rm(names, pow_res)
```

### Directions

Directions to a parking spot can be acquired from Google Maps; however
this implies the location can be driven to in the first place. This may
require interactive alterations from the user.

``` r
SoS_gkey = Sys.getenv("Sos_gkey")
directions <- directions_grabber(data, api_key = SoS_gkey)
```

## Export collections

Write out the data for use in label generation, and as a master copy for
exporting data for mass upload to a database.

``` r
## Export Collections 
data <- sf::st_drop_geometry(data) |>
  as.data.frame() |>
  mutate(Coordinate_uncertainty = "+/- 5m")

## mac can be weird with this file. 
readr::write_excel_csv(
  data, 
  file.path('..', 'labels', 'cleaned_collection_data.csv')
  )
```

We can also export collections as either (or both!) a ‘shapefile’ or KML
for use in GIS or GoogleEarth.

``` r
geodata_writer(data, path = 'someplace', 
               filename = 'Herbarium_Collections_2023',
               filetype = 'kml')
```
