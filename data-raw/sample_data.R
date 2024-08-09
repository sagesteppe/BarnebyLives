library(usethis)
library(googlesheets4)

setwd('/media/steppe/hdd/BarnebyLives/data-raw')
googledrive::drive_auth("reedbenkendorf27@gmail.com")
# read in data from the sheet to process
collection_examples <- read_sheet('1iOQBNeGqRJ3yhA-Sujas3xZ2Aw5rFkktUKv3N_e4o8M',
                        sheet = 'Processed - Examples')
usethis::use_data(collection_examples, overwrite = TRUE)

database_templates <- read.csv('Fields.csv')
usethis::use_data(database_templates, overwrite = TRUE)
