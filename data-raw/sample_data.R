library(usethis)
library(googlesheets4)

#setwd('/media/steppe/hdd/BarnebyLives/data-raw')
setwd('~/Documents/assoRted/BarnebyLives/data-raw')
googledrive::drive_auth("reedbenkendorf27@gmail.com")

# read in data from the sheet to process
collection_examples <- read_sheet(
  '1iOQBNeGqRJ3yhA-Sujas3xZ2Aw5rFkktUKv3N_e4o8M', sheet = 'Processed - Examples')
usethis::use_data(collection_examples, overwrite = TRUE)

uncleaned_collection_examples <- read_sheet(
  '1iOQBNeGqRJ3yhA-Sujas3xZ2Aw5rFkktUKv3N_e4o8M', sheet = 'Data Entry - Examples')
usethis::use_data(uncleaned_collection_examples, overwrite = TRUE)

## database templates
database_templates <- read.csv('Fields.csv')
usethis::use_data(database_templates, overwrite = TRUE)






# prepare material for authorship table.
setwd('/media/steppe/hdd/BarnebyLives/data-raw')
abbrevs <- read.csv('ipni_author_abbreviations.csv')


trailed <- vector(mode = 'character', length = nrow(abbrevs))
trailed[grep('\\.$', abbrevs$author_abbrevation)] <- '.'
# identify which abbreviations have a trailing period

abbrevs_spaced <- sub('\\.$', '', abbrevs$author_abbrevation) # remove the trailing periods
abbrevs_notrail <- sub('\\.(?!.*\\.)', ". ",
                       abbrevs_spaced, perl = T) # identify the last period in the name, and add a space after it

abbrevs <- paste0(abbrevs_notrail, trailed)
ipni_authors <- abbrevs

usethis::use_data(ipni_authors)




###############################################################################
### Here we will set up some of the data we will use in the package.

# add files for templates

herbaria_info <- read.csv('/media/sagesteppe/ExternalHD/Barneby_Lives-dev/herbarium_data/index_herbariorum_info.csv')
usethis::use_data(herbaria_info)

collection_examples <- read.csv('/media/sagesteppe/ExternalHD/Barneby_Lives-dev/herbarium_data/shipping_examples.csv')
collection_examples[collection_examples==""] <- NA
usethis::use_data(collection_examples, overwrite = TRUE)

project_examples <-
  read.csv('/media/sagesteppe/ExternalHD/Barneby_Lives-dev/herbarium_data/project.csv')
usethis::use_data(project_examples)

# Save the output formats for different herbaria databases

database_templates <-
  read.csv('/media/steppe/hdd/Barneby_Lives-dev/database_data/Fields.csv')
usethis::use_data(database_templates)
