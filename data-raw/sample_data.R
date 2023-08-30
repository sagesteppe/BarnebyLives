library(usethis)
library(googlesheets4)

googledrive::drive_auth("reedbenkendorf27@gmail.com")
# read in data from the sheet to process
collection_examples <- read_sheet('1iOQBNeGqRJ3yhA-Sujas3xZ2Aw5rFkktUKv3N_e4o8M',
                        sheet = 'Processed - Examples')
usethis::use_data(processed)
