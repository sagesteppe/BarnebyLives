# Preparing to use BarnebyLives!

``` r
# remotes::install_github('sagesteppe/BarnebyLives')
library(BarnebyLives)
library(tidyverse)
library(sf)
library(terra)
```

BarnebyLives relies on a variety of data to be downloaded locally to
your computer to work. My instance, which covers a large area,
essentially from Michigan to California, South through Texas to the
Canadian border is around 16GiB. Many more regional collections are
likely to be in the realm of 4-10 GiB, so relative to a normal R package
A LOT of data. Relative to a typical geospatial workflow…. Essentially
no data. Given how much larger the amount of disk data are on computers
I think this amount is trivial to consider.

It’s important that you decide where BarnebyLives will be installed on
your computer. While I have couple computers, I maintain only a single
instance of BarnebyLives. It lives on one of my 3.5 terabyte hard drives
which I have set up for various science projects.

I will be downloading and copying some of the data to that location,
where I have a directory named ‘Barneby_Lives-dev’.

## Taxonomic Data

**Worldwide Checklist of Vascular Plants** provides the local taxonomic
information required to perform much of the name matching. We utilize it
to ensure that queries sent to **Plants of The World Online** are
spelled correctly, in order to reduce the number of queries we make to
it. “The World Checklist of Vascular Plants, a continuously updated
resource for exploring global plant diversity” serves as the basis for
Kews Plants of the Worlds, this publication details the process behind
the data set. We can download a static copy of the data from Kews data
portal at: <http://sftp.kew.org/pub/data-repositories/WCVP/>, I simply
download the data manually rather than by script. This is not that large
of a file, so it be downloaded in a couple minutes.

We subset names by continent, I have experimented using Regions within
continents, but the results are usually wanting.

``` r
p2 <- '/media/steppe/hdd/Barneby_Lives-dev/taxonomic_data' # note we have downloaded it 
# to this location - this is the location where our taxonomy data will be unpacked to!

TaxUnpack(path = p2, continents = 'NORTHERN AMERICA')
```

The way that BarnebyLives matches spellings of names is very simple. It
creates three tables, one large table which contains all of the species
in the WFO database, one moderately small table which contains all
infraspecific taxa (varieties and subspecies), and a small table of all
of the genera.

However, both the genus and specific epithet tables are abbreviated. We
find the results from these tables based on only the leading first two
or three characters. This gives rises to one of BarnebyLives(!)
limitations, the assumption that the first two characters of the genus,
and first three letters of the specific epithet are spelled correctly.

Now we will also prepare the author abbreviations data set. These data
come from [IPNI](https://www.ipni.org/), and were minimally processed on
my end, see the script within the data-raw directory on github for
details. We will save a copy of them in the taxonomy folder as well.

``` r
data('ipni_authors', package='BarnebyLives')
write.csv(ipni_authors, file.path(p2, 'ipni_author_abbreviations.csv'))
```

## Geographic data

Many of these data sets are very large we are going to crop them to the
area of analysis, and save the subsets. This package depends on
**terra** and makes use of Virtual Raster Tiles to query parameters.

You can readily define a simple custom extent for your study area. The
coordinates are fine to grab and round from Google Maps or similar. What
is important is that the 5th set of coordinates is a repeat of the 1st
set of coordinates.

``` r
bound <- data.frame(
  y = c(30, 30, 50, 50, 30), 
  x = c(-85, -125, -125, -85, -85)
) |>
  sf::st_as_sf(coords = c('x', 'y'), crs = 4326) |> 
  sf::st_bbox() |>
  sf::st_as_sfc()

bb_vals <- c(-125, -85, 30, 50)
w_illi <- terra::ext(bb_vals)
```

The data which we obtain our data sources from come as very large tiles.
We will clip these down to the extent of our analysis. Essentially
raster tiles should be no larger than 2 gigabytes. So we need to ensure
that we create a tile grid which will allow us to save these data under
those constraints.

``` r
tile_cells <- sf::st_make_grid(
  bound,
  what = "polygons", square = T, flat_topped = F, crs = 4326,
  n = c(
  abs(round( (bb_vals[2] - bb_vals[1]) / 5, 0)), # rows
    abs(round( (bb_vals[3] - bb_vals[4]) / 5, 0))) #cols
)  |>  
  sf::st_as_sf() |> 
  dplyr::rename(geometry = x) |>
  mutate(
    x = sf::st_coordinates(sf::st_centroid(.))[,1],
    y = sf::st_coordinates(sf::st_centroid(.))[,2], 
         .before = geometry, 
         dplyr::across(c('x', 'y'), \(x) round(x, 1)),
         cellname = paste0('n', abs(y), 'w', abs(x))
         )

tile_cellsV <- terra::vect(tile_cells)
```

This package comes with the ‘mason’ function, which will cut up the
raster data sets, and save them in a new location.

The source for our physical raster data is ‘Geomorpho90m, empirical
evaluation and accuracy assessment of global high-resolution
geomorphometric layers’. These data are available from here
<https://opentopography.s3.sdsc.edu/minio/dataspace/OTDS.012020.4326.1/raster/>

``` r
bound <- data.frame(
   y = c(42, 42, 44, 44, 42),
   x = c(-117, -119, -119, -117, -117)
)

data_setup(
  path = '/media/steppe/hdd/BL_sandbox/geodata_raw', 
  pathOut = '/media/steppe/hdd/BL_sandbox',
  bound = bound, cleanup = FALSE
  )
```

We will simply crop the vector data to the limit of the study area. We
utilize the U.S. Census Bureau’s data for this. We can download the
States data set from the U.S. Census Bureau’s website. The other data
sets can be loaded in from the tigris r package. The counties outline
file can be downloaded from here
<https://catalog.data.gov/dataset/tiger-line-shapefile-2020-nation-u-s-counties-and-equivalent-entities>.

``` r
counties <- st_read('../geodata_raw/USCounties/tl_2020_us_county.shp', quiet = T) %>% 
  st_transform(st_crs(tile_cells)) %>% 
  select(STATEFP, COUNTY = NAME)

states <- tigris::states() %>% 
  select(STATEFP, STATE = NAME, STUSPS) %>% 
  st_drop_geometry()

counties <- counties[st_intersects(counties, st_union(tile_cells)) %>% lengths > 0, ]
counties <- left_join(counties, states, by = "STATEFP") %>% 
  select(-STATEFP) %>% 
  arrange(STATE)

states <- counties %>%
  distinct(STUSPS) %>% 
  pull(STUSPS)

st_write(counties, dsn = file.path('../geodata/political', 'political.shp'))

rm(counties)
```

We will set up our places data set which we will use go gather driving
directions from Google maps. We can download these data directly in R
using the tigris package.

``` r
bb <- st_as_sf(bound)

st <- tigris::states() %>% 
  st_transform(4326)
st <- st[st_intersects(st, bb) %>% lengths > 0, c('STATEFP', 'NAME', 'STUSPS') ]
places <- lapply(st$STUSPS, tigris::places)

places <- places %>% 
  bind_rows() %>% 
  filter(str_detect(NAMELSAD, 'city')) %>% 
  dplyr::select(STATEFP, NAME) %>% 
  sf::st_centroid() %>% 
  st_transform(4326) 

places <- places %>% 
  rename(CITY = NAME) %>% 
  left_join(., st %>% 
              st_drop_geometry(), by = 'STATEFP') %>% 
  st_transform(4326)

places <- places[st_intersects(places, bb) %>% lengths > 0, ]
places <- st_set_precision(places, precision=10^3)
st_write(places, 'places.shp', append = F) # this will drop location coordinates to 3 decimal places. 
places <- st_read('places.shp')

google_towns <- select(places, -STUSPS, -STATEFP, STATE = NAME) %>% 
  rowid_to_column("ID")

usethis::use_data(google_towns)

rm(places, google_towns)
```

We can access a Mountains dataset from EarthEnv which we can use for
portions of our place names here <https://www.earthenv.org/mountains>.

``` r
mtns <- st_read('../geodata_raw/globalMountains/GMBA_Inventory_v2.0_standard_basic.shp', 
        quiet = T) %>% 
  st_make_valid() %>% 
  select(MapName) %>% 
  st_crop(., st_union(tile_cells))|>
  dplyr::rename(Mountains = MapName) |>
  dplyr::mutate(Mountains = stringr::str_remove(Mountains, '[(]nn[])]'))

st_write(mtns, dsn = file.path('../geodata/mountains', 'mountains.shp'), quiet = T)

rm(mtns)
```

Our place names are acquired from the United States Geological Surveys
GNIS data set
<https://www.usgs.gov/tools/geographic-names-information-system-gnis>.

``` r
files <- paste0('../geodata_raw/GNIS/Text/DomesticNames_', states, '.txt')
cols <- c('feature_name', 'prim_lat_dec', 'prim_long_dec')

places <- lapply(files, read.csv, sep = "|") %>% 
  map(., ~ .x |> select(all_of(cols))) %>% 
  data.table::rbindlist() %>% 
  st_as_sf(coords = c('prim_long_dec', 'prim_lat_dec'), crs = 4269) %>% 
  st_transform(4326)

places <- places[st_intersects(places, st_union(tile_cells)) %>% lengths > 0, ]
places <- places %>% 
  mutate(ID = 1:nrow(.))

st_write(places, dsn = file.path('../geodata/places', 'places.shp'), quiet = T)

rm(places, cols, files)
```

To determine the land ownership of collections we utilize the Protected
Areas Database-United States also from the USGS
<https://www.usgs.gov/programs/gap-analysis-project/science/pad-us-data-download>
.

``` r
padus <- st_read(dsn = '../geodata_raw/PADUS3/PAD_US3_0.gdb', 
                 layer = 'PADUS3_0Fee') %>% 
  filter(State_Nm %in% states) %>% 
  select(Mang_Name, Unit_Nm) %>% 
  st_cast('MULTIPOLYGON')

tile_cells <- st_transform(tile_cells, st_crs(padus))
padus <- padus[st_intersects(padus, st_union(tile_cells)) %>% lengths > 0, ]
padus <- st_transform(padus, crs = 4326)

st_write(padus, dsn = file.path('../geodata/pad', 'pad.shp'), quiet = T)

# replace really long state land board names with 'STATE SLB'

padus <- st_read('../../Barneby_Lives-dev/geodata/pad/pad.shp')

padus <- padus %>% # this one is just a wild outlier. 
  mutate(Unit_Nm = 
           str_replace(Unit_Nm, 
                               'The State of Utah School and Institutional Trust Lands Administration', 'Utah')
         )

st_write(padus, dsn = file.path('../geodata/pad', 'pad.shp'), quiet = T, append = F)

rm(padus)
```

The best geological data set are also, naturally, provided by the USGS.
The geodatabase can be downloaded from here
<https://mrdata.usgs.gov/geology/state/>

``` r
geological <- st_read(
  '../geodata_raw/geologicalMap/USGS_StateGeologicMapCompilation_ver1.1.gdb', 
          layer = 'SGMC_Geology', quiet = T) %>% 
  select(GENERALIZED_LITH, UNIT_NAME) 

tile_cells <- st_transform(tile_cells, st_crs(geological))
geological <- geological[st_intersects(geological, st_union(tile_cells)) %>% lengths > 0, ]
geological <- st_crop(geological, st_union(tile_cells))
geological <- st_transform(geological, 4326)

st_write(geological, dsn = file.path('../geodata/geology', 'geology.shp'), quiet = T)

tile_cells <- st_transform(tile_cells, crs = 4326)
rm(geological)
```

Grazing allotments for the bureau of land management can be downloaded
from
<https://gbp-blm-egis.hub.arcgis.com/datasets/blm-natl-grazing-allotment-polygons>

Grazing allotments for the United States Forest Service can be
downloaded from
<https://data.fs.usda.gov/geodata/edw/datasets.php?xmlKeyword=allotments>

``` r
blm <- st_read(
  '../geodata_raw/BLMAllotments/BLM_Natl_Grazing_Allotment_Polygons.shp') %>% 
  select(ALLOT_NAME)
usfs <- st_read(
  '../geodata_raw/USFSAllotment/S_USA.Allotment.shp', quiet = T
) %>% 
  dplyr::select(ALLOT_NAME = ALLOTMENT_) 

allotments <- bind_rows(blm, usfs) %>% 
  st_make_valid()
tile_cells <- st_transform(tile_cells, st_crs(allotments))
allotments <- allotments[st_intersects(allotments, st_union(tile_cells)) %>% lengths > 0, ]
allotments <- st_crop(allotments, st_union(tile_cells))
allotments <- st_transform(allotments, 4326)

st_write(allotments, dsn = file.path('../geodata/allotments', 'allotments.shp'), quiet = T)

rm(blm, usfs, allotments)
```

Public land survey system data are HUGE. We have to download them from
here, as a zipped geodatabase.
<https://catalog.data.gov/dataset/blm-natl-plss-public-land-survey-system-polygons-national-geospatial-data-asset-ngda>

``` r
bound_nm <- data.frame(
  y = c(31, 31, 50, 50, 31), 
  x = c(-95, -125, -125, -95, -95)
) %>% 
  st_as_sf(coords = c('x', 'y'), crs = 4326) %>% 
  st_bbox() %>% 
  st_as_sfc()

township <- st_read(
  '../geodata_raw/nationalPLSS/ilmocplss.gdb', layer = 'PLSSTownship', quiet = T
) %>% 
  st_cast('POLYGON') %>% 
  select(TWNSHPLAB, PLSSID)

bound_nm <- st_transform(bound_nm, st_crs(township))
township <- township[st_intersects(township, bound_nm) %>% lengths > 0, ]
township <- st_drop_geometry(township)

section <- st_read(
  '../geodata_raw/nationalPLSS/ilmocplss.gdb', layer = 'PLSSFirstDivision', quiet = T
) %>% 
  st_cast('POLYGON') %>% 
  select(FRSTDIVLAB, PLSSID, FRSTDIVID)

section <- section[st_intersects(section, bound_nm) %>% lengths > 0, ]

trs <- inner_join(section, township, 'PLSSID') %>% 
  mutate(TRS = paste(TWNSHPLAB, FRSTDIVLAB)) %>% 
  select(TRS)

before <- object.size(trs)
trs <- st_simplify(trs)
after <- object.size(trs)
object.size(trs)

st_write(trs, 
         dsn = file.path('../geodata/plss', 'plss.shp'), quiet = T)

rm(section, township, trs, bound_nm, before, after)
```

``` r
sf::st_read('../geodata/political/political.shp', quiet = T) %>% 
  rename(County = COUNTY, State = STATE) %>% 
  st_write(., '../geodata/political/political.shp', quiet = T, append = F)

sf::st_read('../geodata/allotments/allotments.shp', quiet = T) %>% 
  dplyr::mutate(Allotment = str_to_title(ALLOT_NAME)) %>% 
  dplyr::select(-ALLOT_NAME) %>% 
  st_write(., '../geodata/allotments/allotments.shp', quiet = T, append = F)

sf::st_read('../geodata/plss/plss.shp', quiet = T) %>% 
  rename(trs = TRS) %>% 
  st_write(., '../geodata/plss/plss.shp', quiet = T, append = F)

sf::st_read('../geodata/pad/pad.shp', quiet = T) %>% 
  sf::st_make_valid() %>% 
  dplyr::filter(sf::st_is_valid(.)) %>% 
  mutate(Unit_Nm = str_replace(Unit_Nm, "National Forest", "NF"),
         Unit_Nm = str_replace(Unit_Nm, "District Office", "DO"), 
         Unit_Nm = str_replace(Unit_Nm, "Field Office", "FO"), 
         Unit_Nm = str_replace(Unit_Nm, "National Park", "NP"),
         Unit_Nm = str_replace(Unit_Nm, 'National Grassland', 'NG'),
         Unit_Nm = str_replace(Unit_Nm, "National Wildlife Refuge|National Wildlife Range", "NWR"),
         Unit_Nm = str_replace(Unit_Nm, 'National Monument', 'NM'),
         Unit_Nm = str_replace(Unit_Nm, "National Recreation Area", "NRA"), 
         Unit_Nm = str_replace(Unit_Nm, "State Resource Management Area", "SRMA"), 
         Unit_Nm = str_replace(Unit_Nm, "State Trust Lands", "STL"), 
         Unit_Nm = str_replace(Unit_Nm, "Department", "Dept."),
         Unit_Nm = str_replace(Unit_Nm, "Recreation Area", "Rec. Area"),
         Unit_Nm = str_replace(Unit_Nm, 'Wildlife Habitat Management Area', "WHMA"), 
         Unit_Nm = str_replace(Unit_Nm, 'Wildlife Management Area', "WMA")) %>% 
  st_write(., '../geodata/pad/pad.shp', quiet = T, append = F)


sf::st_read('../geodata/places/places.shp', quiet = T) %>% 
  mutate(
    fetr_nm = str_remove(fetr_nm, ' Census Designated Place' ),
    fetr_nm = str_remove(fetr_nm, 'Township of '), 
    fetr_nm = str_remove(fetr_nm, ' \\(historical\\)'),
    fetr_nm = str_remove(fetr_nm, 'Village of '),
    fetr_nm = str_remove(fetr_nm, 'Town of '), 
    fetr_nm = str_remove(fetr_nm, 'City of ')
    ) %>% 
  filter(!str_detect(fetr_nm,
                     'Election Precinct| County|Ditch|Unorganized Territory|Canal|Lateral|Division|
                     River Division|Drain Number|Waste Pond|Commissioner District|Lake Superior|Lake Michigan')) %>% 
  mutate(
    fetr_nm = str_replace(fetr_nm, ' Canyon', ' cnyn.'),
    fetr_nm = str_replace(fetr_nm, ' Campground', ' cmpgrnd.'),
    fetr_nm = str_replace(fetr_nm, ' Creek', ' crk.'),
    fetr_nm = str_replace(fetr_nm, ' Fork', ' fk.'),
    fetr_nm = str_replace(fetr_nm, ' Lake', ' lk.'),
    fetr_nm = str_replace(fetr_nm, ' Meadows', ' mdws.'),
    fetr_nm = str_replace(fetr_nm, ' Meadow', ' mdw.'),
    fetr_nm = str_replace(fetr_nm, ' Mountains', ' mtns.'),
    fetr_nm = str_replace(fetr_nm, ' Mountain', ' mtn.'),
    fetr_nm = str_replace(fetr_nm, ' Number', ' #'),
    fetr_nm = str_replace(fetr_nm, ' Point', ' pt.'),
    fetr_nm = str_replace(fetr_nm, ' Reservoir', ' rsvr.'),
    fetr_nm = str_replace(fetr_nm, ' River ', ' rvr.')
  ) %>% 
  st_write(., '../geodata/places/places.shp', quiet = T, append = F)
```
