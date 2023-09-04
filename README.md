BarnebyLives! is an R program which serves to help botanical collectors in Western North America. BarnebyLives! runs multiple types of queries to acquire political and administrative, geographic, and taxononomic data for recently collected herbarium specimens. It also has limited abilities to search for taxonomic synonyms, check spelling of family, genus, and species names, as well as author abbreviations.  

BarnebyLives! serves the entirety of the flora of Western North America West, which coincides with the Mississippi River. It also includes the entirety of the state of Illinois, and portions of Indiana. However, the area is bounded on it's North by Canada and South by Mexico, essentially it covers the western portion of the Conterminous United States (which excludes Alaska). While it covers this range, most variables are focused on supporting botanists working West of the Rocky Mountain Front Range, especially those operating on Bureau of Land Management and Forest Service lands.

BarnebyLives! Is meant to supplement, not supplant, collectors field note endeavors. Variables which BarnebyLives! may produce, automatically, for each collection includes:

**Political**  
- State  
- County   
- Township  
- Public Land Survey System (township, range, section)  

**Geographic**
- Mountain Range (if relevant)  
- Nearest Geographic Names Information System (GNIS) place name, and distance and azimuth from it  

**Site characteristics**  
- Elevation (both meters and feet)  
- Slope  
- Aspect  
- Surficial geology  
- Geomorphon (major landform elements) 

**Taxonomic**  
- Spell check for Family, Genus, and specific epithet 
- Searches for synonym to species  
- Spell checks taxonomic authorities 

**Directions**  
- directions to a parking spot can be acquired from Google Maps; however this implies the location can be driven to in the first place.

**Other features include**   
- Date parsing, e.g. convert date into congruent museum formats (month in European style)  
- Conversion of Degrees Minutes Seconds (DMS) to Decimal Degrees (DD)  
- Exporting collection data as a 'shapefile' or KML for use in a GIS or GoogleEarth

**Label and shipping manifest generation**
- Herbarium Labels which autopopulate from the script output
- Manifests which autopopulate from the script outputs
- Herbarium labels with retro dot municipality maps

**Electronic data for mass digital specimen upload**
- Puts out data in formats congruent with Symbiota, Darwincore, Rocky Moutain Herbarium, and Consortium of Pacific Northwest Herbaria. 

If the datasheet which is submitted to BarnebyLives! contains text in a cell, the program WILL NOT BE QUERIED for that variable if it is under 'Site Characteristics'. 

Currently BarnebyLives! Is being run on a juiced up computer either in Rogers Park Chicago or Reno. The amount of data which it queries is very large. Please let me know if you have a query and I will run it for you. If you only collect from a smaller portion of the West, e.g. a certain state, or FS/BLM Unit/Field Office, you should be able to set up a local instance. Although, the documentation for such an endeavor is nascent the endeavor is simple, see "crop2boundary" for the workflow. 

## Installation

BarnebyLives! is in beta testing, and can currently only be installed as 0.1.0 from github. 
```r
devtools::install_github('sagesteppe/BarnebyLives')
```
We hope to collaborate with others to treat CONUS and to create multiformat data e.g. Darwincore, CPNWH, etc., and push this product onto CRAN as well as publish a short piece in APPS! It is on the backburner, but still simmering! Stay tuned in but dropped out!

## Input Data Column Names

Meadow fringes adjacent to young lower montane forest , sloped ridgelines

|    Column name      | Second Header |
| -----------------   | ------------- |
|  Collection_number  | The collection number for the primary botanist. This number should unambiguously identify the collection, and be inclusive of all replicates (multiple herbaria sheets). We recommend using a number agnostic of projects and seasons. E.g. Reed Clark Benkendorf 2848 denotes the 2848th collection of there life.   |


## Geodata directory structure

```
$ tree -d
geodata
├── allotments
├── aspect
├── elevation
├── geology
├── geomorphons
├── mountains
├── pad
├── places
├── plss
├── political
└── slope
```
Several of these subdirectories are quite large. In total my local instance takes up around 16gb of data.

```
$ du -h
708M	./geology
73M	./political
3.8M	./mountains
136M	./allotments
435M	./pad
4.6G	./slope
81M	./places
816M	./plss
4.2G	./elevation
4.1G	./aspect
455M	./geomorphons
16G	.
```
As you can see the data regarding site physical characteristics take up most of space. Because of this you can download data to a directory which you find suitable. For me personally, I slap all of them on an hdd.

```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs            13G  2.4M   13G   1% /run
/dev/nvme0n1p2  468G  278G  167G  63% /
tmpfs            63G  4.5M   63G   1% /dev/shm
tmpfs           5.0M  4.0K  5.0M   1% /run/lock
/dev/nvme0n1p1  511M  6.1M  505M   2% /boot/efi
/dev/sda1       3.6T  603G  2.9T  18% /hdd
tmpfs            13G  124K   13G   1% /run/user/1000
```

## Save the Trees

You will need to print you labels for the sheets. We do so as follows. 

a bash loop, such as this, works to combine the labels - 4 per page. 
```
files=(raw/*)
for (( i=0; i<${#files[*]}; i+=4 ));
do
  filename="${files[i]##*/}"
	pdfjam "${files[@]:$i:4}" --nup 2x2 --landscape --outfile "processed/$filename" --noautoscale true  
done
```

obviously the pages of labels can then be combined, like this, to create a single print job. 
```
files=(processed/*)
pdftk ${files[*]} output final/labels.pdf
```

Creating labels will require several open source pieces of software, both of which are associated with Tex.
```
sudo apt-get update
sudo apt-get install pdfjam -y
sudo apt-get install pdftek -y
```

We also recommend the use of 24 pound paper, it looks better after gluing. 

## Chicago Botanic Garden Fieldworkers Usage

There are multiple ways to submit jobs to BarnebyLives! One method is to submit your herbarium data collection sheet via email to me. The preferred method is to enter your data onto [Google Sheets](https://docs.google.com/spreadsheets/d/1iOQBNeGqRJ3yhA-Sujas3xZ2Aw5rFkktUKv3N_e4o8M/edit#gid=0). You will need to be added as a user for this. Contact my @chicagobotanic.org for this. This project contains 3 tabs 
- definitions of all fields which can be filled  (Data Definitions)  
- examples of real (my) collections for 2023 to base your work off (Data Entry - Examples)  
- user submittal sheet  (Data Entry)  
- an example of the text output which will be generated (Processed - Examples)
- the text output which is generated for queries (Processed)


There are two colors on this sheet. White (or Black in dark mode) are cells which cannot be derived via the program. Blue cells are optional, or otherwise not required. 

### Usage Process

Allow up to 1 month of processing time for a request. You should be working on labels throughout the season. Your submittal will be ran within a couple weeks.  The results will be populated in the sheet 'Processed', you will need to manually review/edit them, once you are satisfied and made the required alterations we will submit them for label generation.



*BarnebyLives! Was named after Rupert Charles Barneby, botanist extraordinaire, artist, socialite, and kind hearted human being. He is the hero the West needs not Hayduke. Hence, BarnebyLives!*

![Portrait of Rupert Barneby by Dwight Ripley 1955](man/figures/Portrait_of_Rupert_Barneby.png)
