#' install or update World Vascular Plants Checklist
#'
#' This function checks to see whether the version of WCVP is the most current, if not, it will re-download WCVP and set up the BL taxonomy structure.
#' @param verbose boolean, TRUE/FALSE, whether to print messages to console or not. Defaults to FALSE.

wcvp_update <- function(verbose){

  path <- "http://sftp.kew.org/pub/data-repositories/WCVP/"



}

### obtain the date of the current downloaded version ###

p2wcvp <- '/home/sagesteppe/Downloads/wcvp'

date_extracted <- gsub('Extracted: ', '',
  as.character(
   readxl::read_xlsx(path = file.path(p2wcvp, 'README_WCVP.xlsx'))[7,1]
  )
)

date_extracted <- as.Date(date_extracted, format = '%d/%m/%Y')


### obtain the date of the most recent version on the web ###
path <- "http://sftp.kew.org/pub/data-repositories/WCVP/"
wcvp_pattern <- "wcvp[.]zip\\s*(.*?)\\s*wcvp_dwca[.]zip"
date_pattern <- '20[0-9]{2}-[0-9]{2}-[0-9]{2}'

content <-
  rvest::read_html(path) |>
  rvest::html_element("body") |>
  rvest::html_element("pre") |>
  rvest::html_text2()

date_uploaded <- unlist(regmatches(content, regexec(wcvp_pattern, content)))[1]
date_uploaded <- regmatches(
  date_uploaded, gregexpr(date_pattern, date_uploaded, perl = TRUE))[[1]]
date_uploaded <- as.Date(date_uploaded)

rm(wcvp_pattern, date_pattern, content)


### to re-download or not ? ###

dif <- as.numeric(date_uploaded - date_extracted) # difference in days.

if(dif < 14){

  options(timeout = max(300, getOption("timeout"))) # 5 minute timeout

  download.file(url = paste0(path, '/wcvp.zip'), destfile = 'wcvp.zip')
  unzip('wcvp.zip', overwrite = TRUE)

} # kind of spit ball limit, the first time i checked the lag was 6 days.



