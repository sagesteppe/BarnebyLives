# Package index

## Workflow functions

User facing functions for carrying out the BL workflow

- [`associate_dropper()`](https://sagesteppe.github.io/BarnebyLives/reference/associate_dropper.md)
  : remove collection from associated species
- [`associates_spell_check()`](https://sagesteppe.github.io/BarnebyLives/reference/associates_spell_check.md)
  : Format associated species, and spell check them internally
- [`author_check()`](https://sagesteppe.github.io/BarnebyLives/reference/author_check.md)
  : Check spelling of botanical author abbreviations
- [`autofill_checker()`](https://sagesteppe.github.io/BarnebyLives/reference/autofill_checker.md)
  : Search for accidental auto-increments from spreadsheet autofills
- [`coords2sf()`](https://sagesteppe.github.io/BarnebyLives/reference/coords2sf.md)
  : create an sf object row by row to reflect different datum
- [`date2text()`](https://sagesteppe.github.io/BarnebyLives/reference/date2text.md)
  : take mdy format date and make it written herbarium label format
- [`date_parser()`](https://sagesteppe.github.io/BarnebyLives/reference/date_parser.md)
  : create herbarium format dates for specimens
- [`directions_grabber()`](https://sagesteppe.github.io/BarnebyLives/reference/directions_grabber.md)
  : Have Google maps help you write directions to a site
- [`dms2dd()`](https://sagesteppe.github.io/BarnebyLives/reference/dms2dd.md)
  : this function parses coordinates from DMS to decimal degrees
- [`family_spell_check()`](https://sagesteppe.github.io/BarnebyLives/reference/family_spell_check.md)
  : check that family is spelledcorrectly.
- [`format_database_import()`](https://sagesteppe.github.io/BarnebyLives/reference/format_database_import.md)
  : Export a spreadsheet for mass upload to an herbariums database
- [`geodata_writer()`](https://sagesteppe.github.io/BarnebyLives/reference/geodata_writer.md)
  : write out spatial data for collections to Google Earth or QGIS
- [`label_writer()`](https://sagesteppe.github.io/BarnebyLives/reference/label_writer.md)
  : write herbarium labels to pdf
- [`map_maker()`](https://sagesteppe.github.io/BarnebyLives/reference/map_maker.md)
  : Make a quick county dot map to display the location of the
  collection
- [`physical_grabber()`](https://sagesteppe.github.io/BarnebyLives/reference/physical_grabber.md)
  : gather physical characteristics of the site
- [`political_grabber()`](https://sagesteppe.github.io/BarnebyLives/reference/political_grabber.md)
  : gather political site information
- [`powNAce()`](https://sagesteppe.github.io/BarnebyLives/reference/powNAce.md)
  : Easily compare POW column to input columns
- [`powo_searcher()`](https://sagesteppe.github.io/BarnebyLives/reference/powo_searcher.md)
  : query plants of the world online for taxonomic information
- [`site_writer()`](https://sagesteppe.github.io/BarnebyLives/reference/site_writer.md)
  : gather distance and azimuth from site to center of town
- [`spell_check()`](https://sagesteppe.github.io/BarnebyLives/reference/spell_check.md)
  : check that genera and specific epithets are spelled (almost)
  correctly
- [`split_scientificName()`](https://sagesteppe.github.io/BarnebyLives/reference/split_scientificName.md)
  : split out a scientific input column to pieces

## Preparing data to run BL

Data prep functions

- [`data_download()`](https://sagesteppe.github.io/BarnebyLives/reference/data_download.md)
  : Download the data required to establish a BL instance
- [`data_setup()`](https://sagesteppe.github.io/BarnebyLives/reference/data_setup.md)
  : Set up the downloaded data for a BarnebyLives instance
- [`TaxUnpack()`](https://sagesteppe.github.io/BarnebyLives/reference/TaxUnpack.md)
  : a function to subset the WCVP data set to an area of focus
- [`check_data_setup_outputs()`](https://sagesteppe.github.io/BarnebyLives/reference/check_data_setup_outputs.md)
  : Check whether expected output files from data_setup() exist

## Data

- [`collection_examples`](https://sagesteppe.github.io/BarnebyLives/reference/collection_examples.md)
  : Collection examples for a shipping manifest
- [`database_templates`](https://sagesteppe.github.io/BarnebyLives/reference/database_templates.md)
  : database_templates
- [`google_towns`](https://sagesteppe.github.io/BarnebyLives/reference/google_towns.md)
  : This is a reproduced and slightly curated list of populated places.
- [`herbaria_info`](https://sagesteppe.github.io/BarnebyLives/reference/herbaria_info.md)
  : herbaria_info
- [`ipni_authors`](https://sagesteppe.github.io/BarnebyLives/reference/ipni_authors.md)
  : IPNI author abbreviations
- [`project_examples`](https://sagesteppe.github.io/BarnebyLives/reference/project_examples.md)
  : project_examples
- [`shipping_examples`](https://sagesteppe.github.io/BarnebyLives/reference/shipping_examples.md)
  : shipping_examples
- [`names_vec`](https://sagesteppe.github.io/BarnebyLives/reference/randomNames.md)
  : 10 random plant names from taxize
- [`wcvp_update()`](https://sagesteppe.github.io/BarnebyLives/reference/wcvp_update.md)
  : install or update World Vascular Plants Checklist

## Label formatting functions

functions used while labels are being generated

- [`associates_writer()`](https://sagesteppe.github.io/BarnebyLives/reference/associates_writer.md)
  : do or don't write the associated plant species
- [`collection_writer()`](https://sagesteppe.github.io/BarnebyLives/reference/collection_writer.md)
  : format collector info and codes
- [`escape_latex()`](https://sagesteppe.github.io/BarnebyLives/reference/escape_latex.md)
  : escape characters for use with latex rendering
- [`species_font()`](https://sagesteppe.github.io/BarnebyLives/reference/species_font.md)
  : ensure proper italicization of a associated species
- [`writer()`](https://sagesteppe.github.io/BarnebyLives/reference/writer.md)
  : write values and collapse NAs
- [`writer_fide()`](https://sagesteppe.github.io/BarnebyLives/reference/writer_fide.md)
  : do or don't write determination information

## Some internals

functions used internally

- [`all_authors()`](https://sagesteppe.github.io/BarnebyLives/reference/all_authors.md)
  : retrieve author results for autonyms
- [`directions_overview()`](https://sagesteppe.github.io/BarnebyLives/reference/directions_overview.md)
  : return a quick route summary from googleway::google_directions
- [`format_degree()`](https://sagesteppe.github.io/BarnebyLives/reference/format_degree.md)
  : ASCII compliant degree symbol
- [`get_google_directions()`](https://sagesteppe.github.io/BarnebyLives/reference/get_google_directions.md)
  : identify a populated place near a collection and get directions from
  there
- [`notFound()`](https://sagesteppe.github.io/BarnebyLives/reference/notFound.md)
  : notify user if an entry had any results not found in POWO
- [`mason()`](https://sagesteppe.github.io/BarnebyLives/reference/mason.md)
  : a wrapper around terra::makeTiles for setting the domain of a
  project
- [`result_grabber()`](https://sagesteppe.github.io/BarnebyLives/reference/result_grabber.md)
  : collect the results of a successful powo search
- [`specificDirections()`](https://sagesteppe.github.io/BarnebyLives/reference/specificDirections.md)
  : Import Google directions to a site
- [`try_again()`](https://sagesteppe.github.io/BarnebyLives/reference/try_again.md)
  : try to download from Kew again, with just the binomial
- [`writer2()`](https://sagesteppe.github.io/BarnebyLives/reference/writer2.md)
  : write values and collapse NAs
